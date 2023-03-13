defmodule Tingle.Internal.Type do
  @moduledoc """
  Module for handling type definitions
  """

  @opaque t ::
            {name :: atom, element_nullable? :: atom, repeated? :: atom, list_nullable? :: atom}

  def from_ast(expression, list, nullable_list) do
    case expression do
      {:!, _, [[nested]]} -> from_ast(nested, false, true)
      [[nested]] -> from_ast(nested, true, false)
      {:!, _, [name]} when is_atom(name) -> {name, false, list, nullable_list}
      {_, _, [name]} when is_atom(name) -> {name, true, list, nullable_list}
    end
  end

  def from_term(term)
  def from_term(nil), do: {:error, :type_nil}
  def from_term(type_name) when is_atom(type_name), do: {:ok, {type_name, true, false, false}}
  def from_term([type_name]) when is_atom(type_name), do: {:ok, {type_name, true, true, true}}
  def from_term(_native = {_, _, _, _}), do: {:ok, _native}
  def from_term(_), do: {:error, :invalid_type}

  def name({name, _, _, _}), do: name

  def modifier({_, _, list?, nullable_list?}) do
    cond do
      not list? -> :not_list
      nullable_list? -> :nullable_list
      :repeated -> :non_null_list
    end
  end

  def nullable?({_, nullable?, _, _}), do: nullable?
end
