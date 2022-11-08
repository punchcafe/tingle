defmodule Fastql.Schema do
  alias Fastql.Type.Definition
  # defmacro schema_fragment(types) when is_list(types)
  def schema_fragment(type) when is_atom(type) do
    type.__resolvers__()
    |> Enum.map(fn {k, v} -> v end)
    |> Enum.map(&render_resolver/1)
  end

  defp render_resolver(definition = %{name: name, type: type, params: params}) do
    params =
      params
      |> Enum.map(&render_arg/1)
      |> Enum.reduce(
        quote do
        end,
        &quote do
          unquote(&1)
          unquote(&2)
        end
      )

    quote do
      field unquote(name), unquote(render_type(type)) do
        unquote(params)
      end
    end
  end

  defp render_arg({key, type}) do
    quote do
      arg(unquote(key), unquote(render_type(type)))
    end
  end

  defp render_type(type) do
    type_modifier =
      case Definition.type_modifier(type) do
        :not_list -> & &1
        :nullable_list -> &quote(do: list_of(unquote(&1)))
        :non_null_list -> &quote(do: non_null(list_of(unquote(&1))))
      end

    quote do
      unquote(type |> Definition.type_name() |> type_modifier.())
    end
  end

  defp include_context?(definition) do
    num_vanilla_args = if Enum.empty?(definition.params), do: 1, else: 2
    definition.arity > num_vanilla_args
  end
end
