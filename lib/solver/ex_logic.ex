if Code.ensure_loaded?(ExLogic) do
  defmodule Datalog.Solver.ExLogic do
    @moduledoc """
    Adapter for ExLogic (https://github.com/metdinov/ex_logic)
    """

    use ExLogic

    alias ExLogic.Var
    alias Datalog.Rule

    @behaviour Datalog.Solver.Adapter

    @impl Datalog.Solver.Adapter
    def init_kb(rules, relation_facts) do
      IO.inspect(relation_facts)
      compiled_facts =
        for {rel, terms} <- relation_facts, into: %{} do
          fact_var = Var.new(rel)

          compiled_goal =
            terms
            |> Enum.map(&eq(fact_var, &1))
            |> disj()

          {rel, compiled_goal}
        end

      compiled_rules =
        for %Rule{head: literal, body: body} <- rules, into: %{} do
          head = rewrite_vars(literal)

          body
          |> Enum.map(&rewrite_vars/1)
          |> Enum.map(&eq(head, &1))
          |> conj()
        end
        |> conj()

      %{relation_facts: compiled_facts, rules: compiled_rules}
    end

    @impl Datalog.Solver.Adapter
    def all(%{relation_facts: relation_facts, rules: rules}, goal) do
      rel = elem(goal, 0)
      facts_goal = relation_facts[rel]
      goal = rewrite_vars(goal)

      composed_goal =
        conj do
          rules
          facts_goal
          goal
        end

      facts =
        run_all([rel_var]) do
          eq(rel_var, composed_goal)
        end

      {:ok, facts}
    end

    @impl Datalog.Solver.Adapter
    def one(%{relation_facts: relation_facts, rules: rules}, goal) do
      rel = elem(goal, 0)
      facts_goal = relation_facts[rel]
      goal = rewrite_vars(goal)

      composed_goal =
        conj do
          rules
          facts_goal
          goal
        end

      facts =
        run(1, [rel_var]) do
          eq(rel_var, composed_goal)
        end

      {:ok, facts}
    end

    defp rewrite_vars(literal, acc \\ [])

    defp rewrite_vars(literal, acc) when is_tuple(literal) do
      rewrite_vars(Tuple.to_list(literal), acc)
    end

    defp rewrite_vars([], acc) do
      acc
      |> Enum.reverse()
      |> List.to_tuple()
    end

    defp rewrite_vars([%Datalog.Var{} = v | t], acc) do
      rewrite_vars(t, [clone_var(v) | acc])
    end

    defp rewrite_vars([constant | t], acc) do
      rewrite_vars(t, [constant | acc])
    end

    defp clone_var(%Datalog.Var{} = var) do
      struct(Var, Map.from_struct(var))
    end
  end
end
