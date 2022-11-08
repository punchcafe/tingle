defmodule Fastql do
  @opaque resolver_def :: {field_name :: atom, arity :: integer, function :: any}

  defmacro __using__(opts) do
    quote do
      def name(%{name: name}), do: name
      def __resolvers__(), do: [{:name, 1, &name/1}]
    end
  end
end
