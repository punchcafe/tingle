defmodule Tingle.Type do
  alias Tingle.ResolverDefinition
  alias Tingle.Internal.Type

  require Tingle.Internal.Type

  def on_def(env, kind, name, args, guards, body) do
    if resolver_spec = Module.get_attribute(env.module, :resolver) do
      {:ok, definition} =
        ResolverDefinition.parse_attributes(name, Enum.count(args), resolver_spec)

      schemas =
        env.module
        |> Module.get_attribute(:__tingle_schema__, %{})

      if Map.get(schemas, name), do: raise("Multiple declarations for single resolver")

      Module.put_attribute(env.module, :__tingle_schema__, Map.put(schemas, name, definition))
    end

    Module.put_attribute(env.module, :resolver, nil)
  end

  defmacro typ(expression) do
    expression |> Type.from_ast(false, false) |> Macro.escape()
  end

  defmacro __before_compile__(env) do
    quote do
      def __resolvers__(),
        do:
          unquote(
            env.module
            |> Module.get_attribute(:__tingle_schema__, %{})
            |> Enum.to_list()
            |> Macro.escape()
          )
    end
  end

  defmacro __using__(opts) do
    type_name =
      opts[:name] ||
        __CALLER__.module
        |> inspect()
        |> String.split(".")
        |> List.last()
        |> Macro.underscore()
        |> String.to_atom()

    quote do
      import Tingle.Type, only: [typ: 1]
      @before_compile unquote(__MODULE__)
      @on_definition {unquote(__MODULE__), :on_def}
      def __type_name__(), do: unquote(type_name)
    end
  end
end
