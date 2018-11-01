defmodule RpiBacklight.MixProject do
  @moduledoc false
  use Mix.Project

  def project do
    [
      app: :rpi_backlight,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      # hex.pm
      package: package(),
      description: description(),
      source_url: "https://github.com/xadhoom/rpi_backlight",
      # Docs
      name: "RpiBacklight",
      source_url: "https://github.com/xadhoom/rpi_backlight",
      homepage_url: "https://github.com/xadhoom/rpi_backlight",
      docs: [
        # The main page in the docs
        main: "RpiBacklight",
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:credo, "~> 0.10", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end

  defp package() do
    [
      maintainers: ["Matteo Brancaleoni"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/xadhoom/rpi_backlight"}
    ]
  end

  defp description() do
    "Simple Raspberry Pi backlight control (via sysfs)."
  end
end
