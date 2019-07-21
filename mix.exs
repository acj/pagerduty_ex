defmodule PagerdutyEx.Mixfile do
  use Mix.Project

  def project do
    [app: :pagerduty_ex,
     version: "1.0.0",
     elixir: "~> 1.8",
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     aliases: [compile: ["compile --warnings-as-errors"]],
     deps: deps(),
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: [coveralls: :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test]
    ]
  end

  defp package do
    [
      name: :pagerduty_ex,
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["acjensen@gmail.com"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/acj/pagerduty_ex"}
    ]
  end

  defp description do
    """
    A simple client library for PagerDuty API v2.
    """
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [
      extra_applications: [
        :httpoison,
        :logger,
        :poison,
      ]
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:cowboy, "~> 1.0", only: :test},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:httpoison, "~> 1.5"},
      {:poison, "~> 4.0"},
      {:retry, "~> 0.13"},
      {:excoveralls, "~> 0.10", only: :test}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]
end
