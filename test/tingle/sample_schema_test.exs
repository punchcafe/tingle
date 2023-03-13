defmodule Tingle.SampleSchemaTest do
  use Snapshy
  use ExUnit.Case, async: false

  alias Tingle.Render.Type

  defmodule TestType do
    use Tingle.Type, source_fields: [field_name: Type]

    # TODO: add name option
    @resolver params: [name: typ(![!:string]), filter: :filter], type: [:string]
    def name(source, %{name: name, filter: filter}) do
      {:ok, [name]}
    end

    @resolver type: :integer
    def age(source), do: {:ok, 30}
  end

  defmodule Schema do
    use Absinthe.Schema
    require Tingle.Render.Type

    input_object :filter do
      field(:id, :integer)
    end

    Type.fragment(Tingle.SampleSchemaTest.TestType)

    query do
      field :test, :test_type do
        resolve(fn _, _ ->
          {:ok, %{name: [], filter: %{id: 5}}}
        end)
      end
    end
  end

  test "run it" do
    document = ~S"""
    query {
        test {
            name(filter: {id: 5}, name: ["hello"])
            age
        }
    }
    """

    assert {:ok, %{data: %{"test" => %{"age" => 30, "name" => ["hello"]}}}} ==
             Absinthe.run(document, Schema)
  end
end
