defmodule FastqlTest do
  use ExUnit.Case

  defmodule SampleResolver do
    use Fastql.Type, source_fields: [field_name: Type]

    # TODO: add name option
    @resolver params: [name: typ(![!:string]), filter: :filter], type: [String]
    def name(source, %{name: name, filter: filter}), do: nil

    @resolver type: :integer
    def age(source), do: 30
  end

  test "fastql generates resolver methods" do
    assert SampleResolver.__resolvers__() == [
             age: %Fastql.Type.Schema{name: :age, arity: 1, params: [], type: :integer},
             name: %Fastql.Type.Schema{
               name: :name,
               arity: 2,
               params: [name: String, filter: FilterType],
               type: String
             }
           ]
  end
end
