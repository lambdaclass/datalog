if Code.ensure_loaded?(ExLogic) do
  defmodule Datalog.Solver.ExLogic do
    @moduledoc """
    Adapter for ExLogic (https://github.com/metdinov/ex_logic)
    """

    use ExLogic

    alias Datalog.{Rule, Var}

    @behaviour Datalog.Solver.Adapter

    @impl Datalog.Solver.Adapter
    def init_kb(relation_facts, relation_rules) do
      compiled_facts =
        for {_rel, fact} <- relation_facts do
          fact
        end
        |> List.flatten()

      {:ok, %{facts: compiled_facts, rules: relation_rules}}
    end

    @impl Datalog.Solver.Adapter
    def all(%{facts: facts, rules: _relation_rules}, goal) do
      goal = rewrite_vars(goal)

      result =
        run_all([x]) do
          facts
          |> Enum.map(&eq(x, &1))
          |> disj()

          eq(x, goal)
        end
        |> List.flatten()

      {:ok, result}
    end

    @impl Datalog.Solver.Adapter
    def one(%{facts: facts, rules: _rules}, goal) do
      goal = rewrite_vars(goal)

      result =
        run(1, [x]) do
          facts
          |> Enum.map(&eq(x, &1))
          |> disj()

          # disj(rules)

          eq(x, goal)
        end
        |> List.flatten()

      {:ok, result}
    end

    @impl Datalog.Solver.Adapter
    def exists?(kb, goal) do
      case one(kb, goal) do
        {:ok, []} -> false
        {:ok, _f} -> true
      end
    end

    def rewrite_vars(literal, acc \\ [])

    def rewrite_vars(literal, acc) when is_tuple(literal) do
      rewrite_vars(Tuple.to_list(literal), acc)
    end

    def rewrite_vars([], acc) do
      acc
      |> Enum.reverse()
      |> List.to_tuple()
    end

    def rewrite_vars([%Datalog.Var{} = v | t], acc) do
      rewrite_vars(t, [clone_var(v) | acc])
    end

    def rewrite_vars([constant | t], acc) do
      rewrite_vars(t, [constant | acc])
    end

    defp clone_var(%Var{} = var) do
      struct(ExLogic.Var, Map.from_struct(var))
    end
  end
end
