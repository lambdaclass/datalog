defmodule Datalog.Var do
  @moduledoc """
  Logic variables.
  """

  @derive {Inspect, only: [:name]}
  @enforce_keys [:name, :__ref__]
  defstruct [:name, :__ref__]

  @type t :: %Datalog.Var{name: String.t(), __ref__: reference()}

  @doc """
  Returns a new variable with the given (optional) name.

  ## Example

    iex> Datalog.Var.new("x")
    #Datalog.Var<name: "x", ...>
  """
  @spec new(name :: String.t()) :: Datalog.Var.t()
  def new(name \\ "unnamed") when is_binary(name) or is_atom(name) do
    %Datalog.Var{name: name, __ref__: make_ref()}
  end
end
