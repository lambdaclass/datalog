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

  alias Datalog.{Rule, Var}

  @type fact :: tuple()

  @type literal :: fact() | Rule.t()

  @type relation_facts :: %{(relation :: atom()) => list(fact())}

  @type relation_rules :: %{(relation :: atom()) => list(Rule.t())}

  @type goal :: tuple()

  defmacro __using__(_options) do
    quote do
      Module.register_attribute(__MODULE__, :__rules, accumulate: true)
      Module.register_attribute(__MODULE__, :__facts, accumulate: true)
      import unquote(__MODULE__)
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(env) do
    relation_facts =
      env.module
      |> Module.get_attribute(:__facts)
      |> Enum.reduce(%{}, &put_fact/2)

    relation_rules =
      env.module
      |> Module.get_attribute(:__rules)
      |> Enum.reduce(%{}, &put_rule/2)

    Module.delete_attribute(env.module, :__facts)
    Module.delete_attribute(env.module, :__rules)

    Module.put_attribute(env.module, :facts, relation_facts)
    Module.put_attribute(env.module, :rules, relation_rules)

    quote do
      def facts, do: @facts

      def facts(relation) when is_atom(relation) do
        @facts[relation]
      end

      def rules, do: @rules

      def init_kb do
        Datalog.Solver.init_kb(@facts, @rules)
      end

      def all(kb, goal) do
        Datalog.Solver.all(kb, goal)
      end

      def one(kb, goal) do
        Datalog.Solver.one(kb, goal)
      end

      def exists?(kb, goal) do
        Datalog.Solver.exists?(kb, goal)
      end
    end
  end

  defp put_fact([rel | _] = r, rel_map) do
    rel_tup = List.to_tuple(r)
    Map.update(rel_map, rel, [rel_tup], fn literals -> [rel_tup | literals] end)
  end

  defp put_rule(%Rule{head: [rel | _] = head, body: body}, rel_map) do
    rule = %Rule{head: List.to_tuple(head), body: Enum.map(body, &List.to_tuple/1)}
    Map.update(rel_map, rel, [rule], fn rules -> [rule | rules] end)
  end

  defmacro deffact(args) do
    {rel, terms} = decompose_call(args)
    {fact, _} = make_literal(:fact, terms, [rel])

    quote do
      @__facts unquote(fact)
    end
  end

  defmacro defrule(args, do: body) do
    {rel, terms} = decompose_call(args)
    {head, seen_vars} = make_literal(:rule, terms, [rel])

    {body, _vars} =
      body
      |> parse_block()
      |> Enum.map(&decompose_call/1)
      |> Enum.map_reduce(
        seen_vars,
        fn {rel, terms}, seen_vars -> make_literal(:rule, terms, [rel], seen_vars) end
      )

    rule = %Rule{head: head, body: body} |> Macro.escape()

    quote do
      @__rules unquote(rule)
    end
  end

  defp decompose_call(args) do
    case Macro.decompose_call(args) do
      {_, _} = pair -> pair
      f -> raise ArgumentError, "invalid syntax: #{Macro.to_string(f)}"
    end
  end

  defp make_literal(type, quoted_literal, acc, seen_vars \\ %{})

  defp make_literal(_type, [], laretil, seen_vars) do
    {Enum.reverse(laretil), seen_vars}
  end

  defp make_literal(:fact, [{_var, _, _} | _], _, _) do
    raise ArgumentError, "invalid syntax in deffact: cannot invoke with free variables"
  end

  defp make_literal(:rule, [{name, _, _} | rest], laretil, seen_vars) do
    var = Map.get(seen_vars, name, Var.new(name))
    seen_vars = Map.put_new(seen_vars, name, var)
    make_literal(:rule, rest, [var | laretil], seen_vars)
  end

  defp make_literal(type, [term | rest], laretil, seen_vars) do
    make_literal(type, rest, [term | laretil], seen_vars)
  end

  defp parse_block({:__block__, _meta, ls}), do: ls
  defp parse_block(l), do: [l]
end
