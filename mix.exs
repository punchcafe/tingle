defmodule Tingle.MixProject do
  use Mix.Project

  def project do
    [
      app: :tingle,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(Mix.env())
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps(:test) do
    [
      {:snapshy, ">= 0.3.0"},
      {:absinthe, ">= 0.0.0"}
    ]
  end

  defp deps(_), do: []
end
