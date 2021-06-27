defmodule Hydrogen.MixProject do
  use Mix.Project

  def project do
    [
      app: :hydrogen,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:con_cache, :mnesia, :logger],
      mod: {Hydrogen.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:joken, "~> 2.3"},
      {:jason, "~> 1.1"},
      {:con_cache, "~> 0.13"},
      {:httpoison, "~> 1.7"},
      {:cors_plug, "~> 2.0"},
      {:hammer_backend_mnesia, "~> 0.5"},
      {:hammer, "~> 6.0"},
      {:observer_cli, "~> 1.6"},
      {:mongodb, github: "gergo-papp/mongodb", branch: "patch-1"}
    ]
  end
end
