defmodule OtpPlayground.Application do
  @moduledoc """
  App entry point. Boots a Supervisor that starts three named Counter
  processes (counter_a/b/c) plus one Chaos process. Also starts a
  background task that calls increment/decrement on a random counter
  every @tick_interval milliseconds, forever.
  """

  use Application

#  @counters [:counter_a, :counter_b, :counter_c]

  @impl true
  def start(_type, _args) do
    children = [
      Supervisor.child_spec({OtpPlayground.Counter, name: :counter_a}, id: :counter_a),
      Supervisor.child_spec({OtpPlayground.Counter, name: :counter_b}, id: :counter_b),
      Supervisor.child_spec({OtpPlayground.Counter, name: :counter_c}, id: :counter_c),
      OtpPlayground.Chaos,
    ]

    opts = [strategy: :one_for_one, name: OtpPlayground.Supervisor]
    {:ok, pid} = Supervisor.start_link(children, opts)

    {:ok, pid}
  end
end