defmodule Fastql.Type do
  @opaque resolver_def :: {field_name :: atom, arity :: integer, function :: any}

  alias Fastql.Type.Definition

  def on_def(env, kind, name, args, guards, body) do
    if resolver_spec = Module.get_attribute(env.module, :resolver) do
      {:ok, definition} = parse_def(name, Enum.count(args), resolver_spec)

      schemas =
        env.module
        |> Module.get_attribute(:__fastql_schema__, %{})

      if Map.get(schemas, name), do: raise("Multiple declarations for single resolver")

      Module.put_attribute(env.module, :__fastql_schema__, Map.put(schemas, name, definition))
    end

    Module.put_attribute(env.module, :resolver, nil)
  end

  def typ(expression, list, nullable_list) do
    case expression do
      {:!, _, [[nested]]} -> typ(nested, false, true)
      [[nested]] -> typ(nested, true, false)
      {:!, _, [name]} when is_atom(name) -> {name, false, list, nullable_list}
      {_, _, [name]} when is_atom(name) -> {name, true, list, nullable_list}
    end
  end

  defmacro typ(expression) do
    result = expression |> typ(false, false) |> Macro.escape()
  end

  defp parse_def(name, arity, keyword) do
    with {:ok, params} <- parse_params(keyword[:params]),
         {:ok, type} <- parse_type(keyword[:type]) do
      {:ok, %Definition{name: name, arity: arity, params: params, type: type}}
    end
  end

  defp parse_type(nil), do: {:error, :type_required}

  defp parse_type(type_name) when is_atom(type_name),
    do: {:ok, {type_name, true, false, false}}

  defp parse_type([type_name]) when is_atom(type_name), do: {:ok, {type_name, true, true, true}}
  defp parse_type(typ = {_, _, _, _}), do: {:ok, typ}
  defp parse_type(_), do: {:error, :invalid_type}

  defp parse_params(nil), do: {:ok, []}

  defp parse_params(params) when is_list(params) do
    all_valid =
      params
      |> Enum.map(fn {k, v} ->
        {:ok, type} = parse_type(v)
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
            |> Module.get_attribute(:__fastql_schema__, %{})
            |> Enum.to_list()
            |> Macro.escape()
          )
    end
  end

  defmacro __using__(opts) do
    quote do
      import Fastql.Type, only: [typ: 1]
      @before_compile unquote(__MODULE__)
      @on_definition {unquote(__MODULE__), :on_def}
    end
  end
end
