use Mix.Config

config :xdoor,
  storage_dir: "/root/xdoor",
  ssh_port: 22,
  authorized_keys_update_interval_ms: 60 * 60 * 1000,
  gpio_enabled: true

keys =
  [
    Path.join([System.user_home!(), ".ssh", "id_ed25519.pub"])
  ]
  |> Enum.filter(&File.exists?/1)

if keys == [],
  do:
    Mix.raise("""
    No SSH public keys found in ~/.ssh. An ssh authorized key is needed to
    log into the Nerves device and update firmware on it using ssh.
    See your project's config.exs for this error message.
    """)

config :nerves_firmware_ssh,
  authorized_keys: Enum.map(keys, &File.read!/1)

config :nerves_network, :default,
  wlan0: [
    ssid: System.get_env("NERVES_NETWORK_SSID"),
    psk: System.get_env("NERVES_NETWORK_PSK"),
    key_mgmt: String.to_atom("WPA-PSK")
  ]

# regulatory_domain: "DE"

config :nerves_init_gadget,
  ifname: "wlan0",
  address_method: :dhcp,
  mdns_domain: nil,
  node_name: "xdoor",
  node_host: :mdns_domain,
  ssh_console_port: 8022

config :logger,
  level: :info,
  backends: [RingLogger]
