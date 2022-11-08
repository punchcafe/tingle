defmodule Fastql.Schema do
  # defmacro schema_fragment(types) when is_list(types)
  defmacro schema_fragment(type) when is_atom(type) do
  end

  defp render_resolver(definition) do
  end

  defp include_context?(definition) do
    num_vanilla_args = if Enum.empty?(definition.params), do: 1, else: 2
    definition.arity > num_vanilla_args
  end
end
