defmodule Quetzal.MixProject do
  use Mix.Project

  @version "0.1.12"

  def project do
    [
      app: :quetzal,
      version: @version,
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      docs: docs(),
      description: """
      Analytical web apps, beautiful, fast, easy and real-time using Elixir. No Javascript required.
      """
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.1"},
      {:phoenix_live_view, "~> 0.3.0"},
      {:uuid, "~> 1.1"},
      {:ex_doc, "~> 0.20", only: :docs}
    ]
  end

  defp docs do
    [
      main: "Quetzal",
      source_ref: "v#{@version}",
      source_url: "https://github.com/zgbjgg/quetzal"
    ]
  end

  defp package do
    [
      maintainers: ["Jorge Garrido"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/zgbjgg/quetzal"},
      files:
        ~w(lib priv LICENSE mix.exs package.json README.md)
    ]
  end
end
