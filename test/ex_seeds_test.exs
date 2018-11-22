defmodule ExSeedsTest do
  use ExUnit.Case
  doctest ExSeeds

  test "greets the world" do
    assert ExSeeds.hello() == :world
  end
end
