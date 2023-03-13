defmodule Tingle.MixProject do
  use Mix.Project

  def project do
    [
      app: :tingle,
      version: "0.0.1",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(Mix.env())
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps(:test) do
    [
      {:snapshy, ">= 0.3.0"},
      {:absinthe, ">= 0.0.0"}
    ]
  end

  defp deps(_), do: []
end
