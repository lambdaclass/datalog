defmodule Example do
  use Datalog

  # Rules
  rule [:grandfather, "sam", :x] do
    [:father, "sam", :X]
    [:parents, :Y, :X]
  end

  rule [:in, "kim", :R] do
    [:teaches, "kim", "cs422"]
    [:in, "cs422", :R]
  end

  rule [:slithy, "toves"] do
    :mimsy
    :borogroves
    [:outgrabe, "mome", :Raths]
  end

  # Fact (Rule with empty body)
  rule [:grandfather, "bill", "joe"] do
  end
end
