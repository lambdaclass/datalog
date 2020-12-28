defmodule Example do
  use Datalog

  deffact father(:juan, :juana)

  deffact father(:juan, :helena)

  deffact father(:juan, :juan)

  deffact mother(:aida, :juana)

  deffact mother(:aida, :helena)

  defrule parent(x, y) do
    father(x, y)
  end

  defrule parent(x, y) do
    mother(x, y)
  end

  defrule ancestor(x, y) do
    parent(x, y)
  end

  defrule ancestor(x, y) do
    parent(x, z)
    ancestor(z, y)
  end
end
