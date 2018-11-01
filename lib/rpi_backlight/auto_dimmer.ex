defmodule RpiBacklight.AutoDimmer do
  @moduledoc """
  A simple automatic screen blanker.

  `AutoDimmer` can be started under a supervision tree and it will take care
  to dim and poweroff the display. By default the timeout is 10 seconds and
  the brightness level is 255, the maximum allowed.

  Is responsibity of the user to call `activate/0` to keep the
  light active, for example on input events from keyboard or mouse.
  Everytime `activate/0` is called, the timeout is reset.

  `AutoDimmer` can be configured with optional parameters, they are:

    * `:timeout` - the blank timeout in seconds, 10 by default.

    * `:brightness` - the brightness when active, from 0 to 255, 255 by default.

  For example:
    `RpiBacklight.AutoDimmer.start_link(timeout: 30, brightness: 127)` will
    kick in 30 seconds by setting half of the maximum brightness possible.
  """
  use GenServer

  require Logger

  defmodule State do
    @moduledoc false
    defstruct brightness: 255,
              tref: nil,
              timeout: 10_000
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Signal the dimmer to activate the backlight.

  If backlight is already on, restarts the timer.
  """
  def activate do
    GenServer.cast(__MODULE__, {:activate})
  end

  @impl true
  def init(opts) do
    state = init_state(opts)

    Logger.info(
      "Starting backlight controller with " <>
        "#{state.brightness} brightness and " <> "#{state.timeout}msec interval"
    )

    RpiBacklight.brightness(state.brightness)

    tref = Process.send_after(self(), {:blank}, state.timeout)
    {:ok, %{state | tref: tref}}
  end

  @impl true
  def handle_cast({:activate}, %{tref: nil} = state) do
    RpiBacklight.brightness(state.brightness)
    RpiBacklight.on()

    tref = Process.send_after(self(), {:blank}, state.timeout)

    {:noreply, %{state | tref: tref}}
  end

  @impl true
  def handle_cast({:activate}, %{tref: tref} = state) do
    Process.cancel_timer(tref)

    tref = Process.send_after(self(), {:blank}, state.timeout)

    {:noreply, %{state | tref: tref}}
  end

  @impl true
  def handle_info({:blank}, state) do
    Enum.each(state.brightness..0, fn level ->
      RpiBacklight.brightness(level)
      :timer.sleep(10)
    end)

    RpiBacklight.off()

    {:noreply, %{state | tref: nil}}
  end

  defp init_state(opts) do
    state = %State{}

    timeout = Keyword.get(opts, :timeout, div(state.timeout, 1000)) * 1000
    brightness = Keyword.get(opts, :brightness, state.brightness)

    %{state | timeout: timeout, brightness: brightness}
  end
end
