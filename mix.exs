defmodule Xdoor.MixProject do
  use Mix.Project

  @app :xdoor
  @version "0.1.0"
  @all_targets [:rpi, :rpi0, :rpi2, :rpi3, :rpi3a, :rpi4, :bbb, :x86_64]

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.9",
      archives: [nerves_bootstrap: "~> 1.9"],
      start_permanent: Mix.env() == :prod,
      build_embedded: true,
      aliases: [loadconfig: [&bootstrap/1]],
      deps: deps(),
      releases: [{@app, release()}],
      preferred_cli_target: [run: :host, test: :host]
    ]
  end

  # Starting nerves_bootstrap adds the required aliases to Mix.Project.config()
  # Aliases are only added if MIX_TARGET is set.
  def bootstrap(args) do
    Application.start(:nerves_bootstrap)
    Mix.Task.run("loadconfig", args)
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Xdoor.Application, []},
      extra_applications: [:logger, :runtime_tools, :ssh, :crypto]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Nerves
      {:nerves, "~> 1.7", runtime: false},
      {:shoehorn, "~> 0.7"},
      {:ring_logger, "~> 0.8"},
      {:toolshed, "~> 0.2"},

      # Added
      {:circuits_gpio, "~> 1.0"},
      {:ex_crypto, "~> 0.10"},
      {:jason, "~> 1.0"},
      {:nerves_leds, "~> 0.8"},
      {:nerves_motd, "~> 0.1.0", targets: @all_targets},
      {:req, "~> 0.4"},
      # {:emqtt, github: "emqx/emqtt", tag: "1.8.7", system_env: [{"BUILD_WITHOUT_QUIC", "1"}]},
      {:emqtt, github: "rabbitmq/emqtt", branch: "otp-26-compatibility", system_env: [{"BUILD_WITHOUT_QUIC", "1"}]},

      # Dependencies for all targets except :host
      {:nerves_runtime, "~> 0.11", targets: @all_targets},
      {:nerves_pack, "~> 0.3", targets: @all_targets},

      # Dependencies for specific targets
      {:nerves_system_rpi, "~> 1.12", runtime: false, targets: :rpi},
      {:nerves_system_rpi0, "~> 1.12", runtime: false, targets: :rpi0},
      {:nerves_system_rpi2, "~> 1.12", runtime: false, targets: :rpi2},
      {:nerves_system_rpi3, "~> 1.12", runtime: false, targets: :rpi3},
      {:nerves_system_rpi3a, "~> 1.12", runtime: false, targets: :rpi3a},
      {:nerves_system_rpi4, "~> 1.12", runtime: false, targets: :rpi4},
      {:nerves_system_bbb, "~> 2.3", runtime: false, targets: :bbb},
      {:nerves_system_x86_64, "~> 1.12", runtime: false, targets: :x86_64}
    ]
  end

  def release do
    [
      overwrite: true,
      cookie: "#{@app}_cookie",
      include_erts: &Nerves.Release.erts/0,
      steps: [&Nerves.Release.init/1, :assemble],
      strip_beams: Mix.env() == :prod
    ]
  end
end
