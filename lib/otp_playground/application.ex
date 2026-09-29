defmodule OtpPlayground.Application do
  @moduledoc """
  App entry point. Boots a Supervisor that starts three named Counter
  processes (counter_a/b/c) plus one Chaos process. Also starts a
  background task that calls increment/decrement on a random counter
  every 2 seconds, forever.
  """

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
    {:ok, pid} = Supervisor.start_link(children, opts)

    Task.start(fn -> inc_dec_loop() end)

    {:ok, pid}
  end

  defp inc_dec_loop do
    Process.sleep(2_000)
    victim = Enum.random([:counter_a, :counter_b, :counter_c])

    OtpPlayground.Counter.get(victim)

    if Enum.random([true, false]) do
      IO.puts(">>> POKE: incrementing #{victim}")
      OtpPlayground.Counter.increment(victim)
    else
      IO.puts(">>> POKE: decrementing #{victim}")
      OtpPlayground.Counter.decrement(victim)
    end

    inc_dec_loop()
  end
end