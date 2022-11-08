defmodule FastqlTest do
  use ExUnit.Case
  doctest Fastql

  defmodule SampleResolver do
    use Fastql
  end

  test "fastql generates resolver methods" do
    assert SampleResolver.__resolvers__() == :ok
  end
end
