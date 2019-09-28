defmodule QuetzalTest do
  use ExUnit.Case
  doctest Quetzal

  test "greets the world" do
    assert Quetzal.hello() == :world
  end
end
