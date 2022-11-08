defmodule FastqlTest do
  use ExUnit.Case
  doctest Fastql

  defmodule SampleResolver do
    use Fastql

    def name(source, %{param: param}), do: nil
  end

  test "fastql generates resolver methods" do
    assert SampleResolver.__resolvers__() == :ok
  end
end
