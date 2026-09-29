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