defmodule Datalog do
  @moduledoc """
  Documentation for `Datalog`.
  """

  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)
      Module.register_attribute(__MODULE__, :rules, accumulate: true)
      Module.register_attribute(__MODULE__, :facts, accumulate: true)
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def rules do
        Enum.each(@facts, fn fact -> IO.inspect(fact) end)
        Enum.each(@rules, fn rule -> IO.inspect(rule) end)
      end
    end
  end

  defmacro defrule(pred, _opts \\ [], do: block) do
    {name, args} =
      case Macro.decompose_call(pred) do
        {_, _} = pair -> pair
        fun -> raise ArgumentError, "invalid syntax in defrule #{Macro.to_string(fun)}"
      end

    parsed_body = parse_body(block)

    quote do
      @rules {%Rule{head: unquote([name] ++ args), body: unquote(parsed_body)}}
      def unquote(name)(unquote_splicing(args)) do
      end
    end
  end

  defmacro deffact({name, _, args}) do
    quote do
      @facts {%Rule{head: unquote([name] ++ args)}}
      def unquote(name)(unquote_splicing(args)) do
      end
    end
  end

  def parse_body({:__block__, _, l}) when is_list(l) do
    l
  end

  def parse_body(body) do
    [body]
  end
end

defmodule Rule do
  defstruct [:head, body: []]
end
