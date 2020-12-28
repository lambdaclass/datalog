defmodule Datalog.Solver do
  @moduledoc """
  Solver API module. Uses the adapter provided in `config.exs`.

      config :datalog do
        solver: Datalog.Solver.ExLogic

  Defaults to `Datalog.Solver.ExLogic`.
  """

  @solver Application.get_env(:datalog, :solver, Datalog.Solver.ExLogic)

  defdelegate init_kb(facts, rules), to: @solver
  defdelegate all(kb, goal), to: @solver
  defdelegate one(kb, goal), to: @solver
  defdelegate exists?(kb, goal), to: @solver
end
