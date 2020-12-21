defmodule Datalog do
  @moduledoc """
  Documentation for `Datalog`.
  """

  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)
      Module.register_attribute(__MODULE__, :rules, accumulate: true)
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def rules do
        Enum.each(@rules, fn rule -> IO.inspect(rule) end)
      end
    end
  end

  defmacro rule(head, do: body) do
    parsed_body = parse_body(body)

    quote do
      @rules {%Rule{head: unquote(head), body: unquote(parsed_body)}}
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
