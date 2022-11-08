defmodule Fastql.Type.Schema do
  @type object_type ::
          {name :: atom, element_nullable? :: atom, repeated? :: atom, list_nullable? :: atom}
  defstruct name: nil, arity: nil, params: [], type: nil

  #TODO: have nice functions here for handling types stuff
end
