defmodule Datalog do
  @moduledoc """
  Documentation for `Datalog`.
  Facts are represented by a tuple like so:

      {relation, term_1, term2, ...}

  where `relation` is an atom and `term_1`, `term_2`, and so on
  are constants.

  Rules are represented by the `%Datalog.Rule{}` struct:

      %Datalog.Rule{
        head: {relation, term_1, ...},
        body: [{relation, term_1, ..}, ...]
      }

  where `relation` is an atom and the terms can be constants or `%Datalog.Var{}`.
  """

  alias Datalog.Solver

  @type fact :: tuple()

  @type literal :: fact() | Datalog.Rule.t()

  @type relation_facts :: %{(relation :: atom()) => list(fact())}

  @type goal :: tuple()

  defmacro __using__(_options) do
    quote do
      Module.register_attribute(__MODULE__, :rules, accumulate: true)
      Module.register_attribute(__MODULE__, :facts, accumulate: true)
      import unquote(__MODULE__)
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(env) do
    relation_facts =
      env.module
      |> Module.get_attribute(:facts)
      |> Enum.reduce(%{}, &put_literal/2)

    rules = Module.get_attribute(env.module, :rules)
    kb = Solver.init_kb(rules, relation_facts)

    quote bind_quoted: [kb: kb] do
      def all(rule) do
        Solver.all(kb, rule)
      end

      def one(rule) do
        Solver.one(kb, rule)
      end
    end
  end

  defp put_literal([rel | _] = r, rel_map) do
    rel_tup = List.to_tuple(r)
    Map.update(rel_map, rel, [rel_tup], fn literals -> [rel_tup | literals] end)
  end

  defmacro deffact(args) do
    {rel, terms} =
      case Macro.decompose_call(args) do
        {_, _} = pair -> pair
        f -> raise ArgumentError, "invalid syntax in deffact #{Macro.to_string(f)}"
      end

    fact = make_literal(:fact, terms, [rel])

    IO.inspect(fact)
    quote do
      @facts unquote(fact)
    end
  end

  defmacro defrule(args, do: body) do
    {rel, terms} =
      case Macro.decompose_call(args) do
        {_, _} = pair -> pair
        f -> raise ArgumentError, "invalid syntax in defrule #{Macro.to_string(f)}"
      end

    rule = make_literal(:rule, terms, [rel])

    quote do
      @rules unquote(rule)

      def unquote(rel)(unquote_splicing(terms)) do
        unquote(body)
      end
    end
  end

  defp make_literal(_type, [], laretil) do
    Enum.reverse(laretil)
  end

  defp make_literal(:fact, [{_var, _, _} | _], _) do
    raise ArgumentError, "invalid syntax in deffact: cannot invoke with free variables"
  end

  defp make_literal(:rule, [{name, _, _} | rest], laretil) do
    make_literal(:rule, rest, [Datalog.Var.new(name) | laretil])
  end

  defp make_literal(type, [term | rest], laretil) do
    make_literal(type, rest, [term | laretil])
  end
end
