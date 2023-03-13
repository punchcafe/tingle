defmodule Tingle.SchemaTest do
    use Snapshy
    use ExUnit.Case, async: false

    alias Tingle.Schema.Type

  defmodule SampleSchemaResolver do
    use Tingle.Type, source_fields: [field_name: Type]

    # TODO: add name option
    @resolver params: [name: typ(![!:string]), filter: :filter], type: [String]
    def name(source, %{name: name, filter: filter}), do: nil

    @resolver type: :integer
    def age(source), do: 30
  end

  test_snapshot "renders a type definition in schema dsl" do
    Type.schema_fragment(SampleSchemaResolver) |> Macro.to_string()
  end
end