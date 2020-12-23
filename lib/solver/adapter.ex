defmodule Datalog.Solver.Adapter do
  @moduledoc """
  Specifies the API that solvers are expected to implement.
  """

  @typedoc """
  The type returned by the solver after parsing and compiling a `Datalog.knowledge_base()`.
  """
  @type compiled_kb :: any()

  @doc """
  Takes the rules and facts from the knowledge base and allows the solver
  to parse and compile rules.
  Returns the compiled knowlege base.
  """
  @callback init_kb(list(Datalog.Rule.t()), Datalog.relation_facts()) :: compiled_kb()

  @doc """
  Takes a knowledge base and a goal and returns a list of all the facts that satisfy
  the goal or an `:error`.
  """
  @callback all(compiled_kb(), Datalog.goal()) ::
              {:ok, list(Datalog.fact())} | {:error, term()}

  @doc """
  Takes a knowledge base and a goal and returns a fact that satisfies the goal or an `:error`.
  """
  @callback one(compiled_kb(), Datalog.goal()) ::
              {:ok, Datalog.fact()} | {:error, term()}
end