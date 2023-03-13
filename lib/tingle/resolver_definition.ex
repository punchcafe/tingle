defmodule Tingle.ResolverDefinition do
  @moduledoc ~S"""
  Internal representation of a @resolver definition before a def clause.
  """

  alias Tingle.Internal.Type

  defstruct name: nil, arity: nil, params: [], type: nil

  @doc ~S"""
  Creates a model representation of a ResolverDefinition from the name, arity, and resolver_attributes 
  provided by the resolver function definition. These parameters are sourced from the on_def callback
  when a user defines a resolver function. Name and arity come directly from the callback, while 
  object_attributes are the keyword list following the @resolver annotation.
  """
  def parse_attributes(name, arity, object_attributes) do
    with {:ok, params} <- parse_params(object_attributes[:params]),
         {:ok, type} <- Type.from_term(object_attributes[:type]) do
      {:ok, %__MODULE__{name: name, arity: arity, params: params, type: type}}
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
end
