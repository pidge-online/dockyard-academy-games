defmodule Games.MixProject do
  use Mix.Project

  def project do
    [
      app: :games,
      version: "0.3.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 2.0"},
      {:jason, "~> 1.4"}
    ]
  end
end
