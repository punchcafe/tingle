defmodule Tingle.Type do
  @opaque resolver_def :: {field_name :: atom, arity :: integer, function :: any}

  alias Tingle.Resolver.Definition
  alias Tingle.Internal.Type

  require Tingle.Internal.Type

  def on_def(env, kind, name, args, guards, body) do
    if resolver_spec = Module.get_attribute(env.module, :resolver) do
      {:ok, definition} = parse_def(name, Enum.count(args), resolver_spec)

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

  defp parse_def(name, arity, keyword) do
    with {:ok, params} <- parse_params(keyword[:params]),
         {:ok, type} <- Type.from_term(keyword[:type]) do
      {:ok, %Definition{name: name, arity: arity, params: params, type: type}}
    end
  end

  defp parse_params(nil), do: {:ok, []}

  defp parse_params(params) when is_list(params) do
    all_valid =
      params
      |> Enum.map(fn {k, v} ->
        {:ok, type} = Type.from_term(v)
        {k, type}
      end)

    {:ok, all_valid}
  end

  defp parse_params(_params), do: {:error, :not_list}

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
    type_name = opts[:name] || __CALLER__.module |> inspect() |> String.split(".") |> List.last() |> Macro.underscore() |> String.to_atom()

    quote do
      import Tingle.Type, only: [typ: 1]
      @before_compile unquote(__MODULE__)
      @on_definition {unquote(__MODULE__), :on_def}
      def __type_name__(), do: unquote(type_name)
    end
  end
end
