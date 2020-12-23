defmodule Example do
  use Datalog

  deffact person(:juan)

  deffact person(:caro)

  deffact parent(:juana)

  deffact parent(:helena, :juan)

  deffact related(:helena, :juan, :juana, :aida)

  # defrule ancestor(x, y) do
  #   parent(x, y)
  # end
end
