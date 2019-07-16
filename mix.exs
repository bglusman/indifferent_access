defmodule IndifferentAccess.MixProject do
  use Mix.Project

  def project do
    [
      app: :indifferent_access,
      version: "0.2.1",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "IndifferentAccess",
      source_url: "https://github.com/bglusman/indifferent_access",
      description:
        "Elixir library for various strategies/experiments for avoiding string access to conn params",
      package: package()
    ]
  end

  defp package do
    [
      files: ~w(lib mix.exs README* LICENSE*),
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/bglusman/indifferent_access",
        "Docs" => "https://hexdocs.pm/indifferent_access/"
      }
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
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
