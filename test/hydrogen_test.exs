defmodule HydrogenTest do
  use ExUnit.Case
  doctest Hydrogen

  test "greets the world" do
    assert Hydrogen.hello() == :world
  end
end
