defmodule OtpPlayground.Chaos do
  use GenServer

  @counters [:counter_a, :counter_b, :counter_c]

  def start_link(_opts), do: GenServer.start_link(__MODULE__, nil)

  @impl true
  def init(_) do
    schedule_strike()
    {:ok, nil}
  end

  @impl true
  def handle_info(:strike, state) do
    victim = Enum.random(@counters)
    IO.puts(">>> CHAOS: crashing #{victim}")
    OtpPlayground.Counter.crash(victim)
    schedule_strike()
    {:noreply, state}
  end

  defp schedule_strike do
    Process.send_after(self(), :strike, 7_000)
  end
end