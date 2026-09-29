defmodule OtpPlayground.Application do
  @moduledoc """
  App entry point. Boots a Supervisor that starts three named Counter
  processes (counter_a/b/c) plus one Chaos process, all under a
  :one_for_one 	strategy so a crash in any one only restarts that one.
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
     # you only need to call Supervisor.child_spec/2 when you want to change one of the defaults.
     # Both forms produce the exact same kind of map — %{id: ..., start: {Module, :start_link, [args]}}
      Supervisor.child_spec({OtpPlayground.Counter, name: :counter_a}, id: :counter_a),
      Supervisor.child_spec({OtpPlayground.Counter, name: :counter_b}, id: :counter_b),
      Supervisor.child_spec({OtpPlayground.Counter, name: :counter_c}, id: :counter_c),
      OtpPlayground.Chaos  # he Supervisor actually calls that: OtpPlayground.Chaos.start_link([])
    ]

    opts = [strategy: :one_for_one, name: OtpPlayground.Supervisor]
    Supervisor.start_link(children, opts)
  end
end