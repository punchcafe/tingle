defmodule Tingle.Schema.Type do
  @moduledoc """
  Module for rendering type definitions
  """
  alias Tingle.Type.Definition
  alias Tingle.Internal.Type

  def schema_fragment(mod) when is_atom(mod) do
    fields =
      mod.__resolvers__()
      |> Enum.map(fn {k, v} -> v end)
      |> Enum.map(&render_field(&1, mod))

    quote do
      object unquote(mod.__type_name__()) do
        unquote(fields)
      end
    end
  end

  defp render_field(definition = %{name: name, type: type, params: params}, mod_name) do
    params =
      params
      |> Enum.map(&render_arg/1)
      |> then(fn asts -> {:__block__, [], asts} end)

    quote do
      field unquote(name), unquote(render_type(type)) do
        unquote(params)

        # TODO: have this be determined through different sources, resolvers, straight from struct etc.
        resolve(fn params, ctx = %{source: source} ->
          apply(unquote(mod_name), unquote(name),[source, params, ctx])
        end)
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
      case Type.modifier(type) do
        :not_list -> & &1
        :nullable_list -> &quote(do: list_of(unquote(&1)))
        :non_null_list -> &quote(do: non_null(list_of(unquote(&1))))
      end

    quote do
      unquote(type |> Type.name() |> type_modifier.())
    end
  end

  defp include_context?(definition) do
    num_vanilla_args = if Enum.empty?(definition.params), do: 1, else: 2
    definition.arity > num_vanilla_args
  end
end
