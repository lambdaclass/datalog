defmodule Example do
  use Datalog

  # Rules
  defrule grandfather("sam", :X) do
    [:father, "sam", :Y]
    [:parent, :Y, :X]
  end

  defrule grandfather(:X, :Y) do
    [:father, :X, :Z]
    [:parent, :Z, :Y]
  end

  defrule in_("kim", :R) do
    [:teaches, "kim", "cs422"]
    [:in, "cs422", :R]
  end

  defrule slithy("toves") do
    :mimsy
    :borogroves
    [:outgrabe, "mome", :Raths]
  end

  # Fact (Rule with empty body)
  deffact(grandfather("bill", "joe"))

  defrule grandfather("bill", "joe") do
  end
end
