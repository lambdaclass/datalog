defmodule DatalogTest do
  use ExUnit.Case
  doctest Datalog

  test "greets the world" do
    assert Datalog.hello() == :world
  end
end
