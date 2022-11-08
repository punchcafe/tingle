defmodule Fastql.Type.Definition do
  @type object_type ::
          {name :: atom, element_nullable? :: atom, repeated? :: atom, list_nullable? :: atom}
  defstruct name: nil, arity: nil, params: [], type: nil

  # TODO: have nice functions here for handling types stuff

  def type_name({name, _, _, _}), do: name

  def type_modifier({_, _, list?, nullable_list?}) do
    cond do
      not list? -> :not_list
      nullable_list? -> :nullable_list
      :repeated -> :non_null_list
    end
  end

  def nullable_type?({_, nullable?, _, _}), do: nullable?
end
