defmodule OtpPlayground.Application do
  @moduledoc """
  App entry point. Boots a Supervisor that starts three named Counter
  processes (counter_a/b/c) plus one Chaos process. Also starts a
  background task that calls increment/decrement on a random counter
  every @tick_interval milliseconds, forever.
  """

  use Application

  @count 1_0000

  @impl true
  def start(_type, _args) do
    children = [
      {DynamicSupervisor, strategy: :one_for_one, name: OtpPlayground.CounterSupervisor}
    ]

    opts = [strategy: :one_for_one, name: OtpPlayground.Supervisor]
    {:ok, pid} = Supervisor.start_link(children, opts)

    for i <- 1..@count do
      name = :"counter_#{i}"
      DynamicSupervisor.start_child(
        OtpPlayground.CounterSupervisor,
        {OtpPlayground.Counter, name: name}
      )
    end

    {:ok, pid}
  end
end