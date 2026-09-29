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

defmodule OtpPlayground.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Supervisor.child_spec({OtpPlayground.Counter, name: :counter_a}, id: :counter_a),
      Supervisor.child_spec({OtpPlayground.Counter, name: :counter_b}, id: :counter_b),
      Supervisor.child_spec({OtpPlayground.Counter, name: :counter_c}, id: :counter_c),
      OtpPlayground.Chaos
    ]

    opts = [strategy: :one_for_one, name: OtpPlayground.Supervisor]
    Supervisor.start_link(children, opts)
  end
end