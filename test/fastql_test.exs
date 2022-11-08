defmodule FastqlTest do
  use ExUnit.Case

  defmodule SampleResolver do
    use Fastql.Type, source_fields: [field_name: Type]

    # TODO: add name option
    @resolver params: [name: String, filter: FilterType], type: String
    def name(source, %{name: name, filter: filter}), do: nil

    @resolver type: :integer
    def age(source), do: 30
  end

  test "fastql generates resolver methods" do
    assert SampleResolver.__resolvers__() == :ok
  end

  test "fastql generates schema methods" do
    assert SampleResolver.__schema__() == :ok
  end
end
