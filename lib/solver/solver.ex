defmodule Datalog.Solver do
  @moduledoc """
  Solver API module. Uses the adapter provided in `config.exs`.

      config :datalog do
        solver: Datalog.Solver.ExLogic

  Defaults to `Datalog.Solver.ExLogic`.
  """

  @solver Application.get_env(:datalog, :solver, Datalog.Solver.ExLogic)

  defdelegate init_kb(rules, facts), to: @solver

  defdelegate solve(kb, literal), to: @solver
end
