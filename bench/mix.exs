defmodule Bench.MixProject do
  use Mix.Project

  def project do
    [
      app: :bench,
      version: "0.1.0",
      elixir: "~> 1.12",
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
      {:benchee, "~> 1.0", only: :dev, runtime: false},
      {:odgn_json_pointer, "~> 3.1"},
      #{:json_pointer, "~> 0.1"},
      {:ex_json_pointer, path: "../", override: true},
    ]
  end
end
