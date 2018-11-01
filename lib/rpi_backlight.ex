defmodule RpiBacklight do
  @moduledoc """
  Simple Raspberry Pi backlight control (via sysfs).
  """
  require Logger

  @bl_power "/sys/class/backlight/rpi_backlight/bl_power"
  @brightness "/sys/class/backlight/rpi_backlight/brightness"

  @doc """
  Turns off display backlight.
  """
  @spec off :: :ok | {:error, :operation}
  def off do
    @bl_power
    |> File.write("1")
    |> handle_result()
  end

  @doc """
  Turns on display backlight.
  """
  @spec on :: :ok | {:error, :operation}
  def on do
    @bl_power
    |> File.write("0")
    |> handle_result()
  end

  @doc """
  Sets display brightness. Level must be between 0 and 255.
  """
  @spec brightness(integer()) :: :ok | {:error, :operation | :out_of_bound}
  def brightness(level) when level < 0, do: {:error, :out_of_bound}
  def brightness(level) when level > 255, do: {:error, :out_of_bound}

  def brightness(level) when is_integer(level) do
    @brightness
    |> File.write(Integer.to_string(level))
    |> handle_result()
  end

  defp handle_result(:ok), do: :ok

  defp handle_result({:error, err}) do
    Logger.warn("Got error #{inspect(err)} while trying to write to sysfs")
    {:error, :operation}
  end
end
