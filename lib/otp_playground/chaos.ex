defmodule OtpPlayground.Chaos do
  @moduledoc """
  Randomly crashes a Counter process every 7 seconds, to demonstrate
  supervisor restart behavior. Doesn't know or care about Counter's
  internals — just calls `Counter.crash/1` on a random name.
  """

  # Makes this module a GenServer — injects default callbacks, tags it
  # as implementing the GenServer behaviour.
  use GenServer

  # Fixed, compile-time list of the counter names Chaos is allowed to
  # pick a victim from. A module attribute — same value, shared across
  # every function in this module, never changes at runtime.
  @counters [:counter_a, :counter_b, :counter_c]  # only used in strike
  @strike_multiplier 7

  # Called by the Supervisor when this app boots (bare "OtpPlayground.Chaos"
  # in application.ex means it's called as start_link([])). _opts is unused
  # since Chaos needs no per-instance config, unlike Counter.
  # This starts the process UNNAMED (no name: option) — nothing else needs
  # to address Chaos directly, so no registered name is needed.
  def start_link(_opts), do: GenServer.start_link(__MODULE__, nil)

  # Runs once, automatically, right after start_link creates the process.
  # Arms the first timer and sets state to nil (Chaos tracks nothing).
  @impl true
  def init(_) do
    schedule_strike()
    {:ok, nil}
  end

  # Fires every time this process gets a :strike message — which only
  # ever happens via the self-timer in schedule_strike/0 below.
  @impl true
  def handle_info(:strike, state) do
    # Pick one random name out of @counters, e.g. :counter_b.
    victim = Enum.random(@counters)
    # Calls Counter's client API — sends a :crash message to that
    # specific named process (cast, so Chaos doesn't wait/crash itself).
    IO.puts(">>> CHAOS: crashing #{victim}")
    OtpPlayground.Counter.crash(victim)
    IO.puts(">>> CHAOS: #{victim} restarting...")

    # Re-arm the timer so this keeps happening every 7s, forever.
    schedule_strike()
    {:noreply, state}
  end

  # Private helper (defp = only callable inside this module).
  # Sends this SAME process (self()) a :strike message 7000ms from now.
  # This self-messaging is what turns handle_info(:strike, ...) into a
  # repeating loop — no external timer or scheduler needed.
  defp schedule_strike do
    interval = OtpPlayground.Counter.tick_interval() * @strike_multiplier
    Process.send_after(self(), :strike, interval)
  end
end