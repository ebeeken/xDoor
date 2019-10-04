defmodule Xdoor.SSHServer do
  use GenServer
  require Logger
  alias Xdoor.SSHKeys

  @greeting "xDoor"
  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_) do
    system_dir = :code.priv_dir(:xdoor) |> Path.join("host_key") |> to_charlist()
    port = Application.fetch_env!(:xdoor, :ssh_port)

    {:ok, server_pid} =
      :ssh.daemon(port, [
        {:id_string, :random},
        {:system_dir, system_dir},
        {:user_dir, system_dir},
        {:key_cb, {SSHKeys, []}},
        {:shell, &start_shell/2},
        {:exec, &start_exec/3}
      ])

    Process.link(server_pid)

    {:ok, %{server_pid: server_pid}}
  end

  def start_shell('open' = user, _peer) do
    Logger.info("Starting shell for user #{user}")
    spawn(fn -> open_door() end)
  end

  def start_shell('close' = user, _peer) do
    Logger.info("Starting shell for user #{user}")
    spawn(fn -> close_door() end)
  end

  def start_exec(_cmd, _user, _peer) do
    spawn(fn ->
      IO.puts("Command execution not alllowed.")
    end)
  end

  defp open_door() do
    IO.puts(@greeting)
    IO.puts("OPENING DOOR")
    toggle_gpio(23)
    Logger.info("Door opened")
  end

  defp close_door() do
    IO.puts(@greeting)
    IO.puts("CLOSING DOOR")
    toggle_gpio(24)
    Logger.info("Door closed")
  end

  defp toggle_gpio(pin_number) do
    if Application.get_env(:xdoor, :gpio_enabled, false) do
      {:ok, gpio} = Circuits.GPIO.open(pin_number, :output)
      Circuits.GPIO.write(gpio, 1)
      :timer.sleep(100)
      Circuits.GPIO.write(gpio, 0)
      Circuits.GPIO.close(gpio)
    end
  end
end
