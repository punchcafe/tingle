defmodule Fastql do
  @opaque resolver_def :: {field_name :: atom, arity :: integer, function :: any}

  defmacro __before_compile__(env) do
    IO.inspect(Module.definitions_in(env.module, :def))

    pub_funcs = Module.definitions_in(env.module, :def)

    quote do
      def __resolvers__(), do: unquote(pub_funcs)
    end
  end

  defmacro __using__(opts) do
    quote do
      @before_compile unquote(__MODULE__)

      def __resolvers__(), do: [{:name, 1}]
    end
  end
end
