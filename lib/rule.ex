defmodule Datalog.Rule do
  @moduledoc """
  Datalog rules are clauses of the form:

      L_0 :- L_1, ..., L_n

  where L_0 is the head and the body is [L_1, ..., Ln].
  Each L_x term is called a literal, and may contain variables.
  """

  @type t :: %Datalog.Rule{head: Datalog.literal(), body: list(Datalog.literal())}

  @enforce_keys [:head, :body]
  defstruct [:head, :body]
end
