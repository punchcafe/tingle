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
             age: %Fastql.Resolver.Definition{
               arity: 1,
               name: :age,
               params: [],
               type: {:integer, true, false, false}
             },
             name: %Fastql.Resolver.Definition{
               arity: 2,
               name: :name,
               params: [
                 name: {:string, false, false, true},
                 filter: {:filter, true, false, false}
               ],
               type: {String, true, true, true}
             }
           ]
  end
end
