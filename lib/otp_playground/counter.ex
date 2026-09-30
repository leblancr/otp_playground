defmodule OtpPlayground.Counter do
  @moduledoc """
  A single counter process.

  Holds an integer count that increments once per second on its own
  (self-scheduled tick), and can be incremented/decremented/crashed
  on demand. Multiple named instances can run at once — start with
  `start_link(name: :counter_a)`.
  """

  use GenServer

  @tick_interval 1_000   # ← the one source of truth

  def tick_interval, do: @tick_interval   # exposes it to other modules

  # --- Client API ---
  # These are plain functions any other process calls. They don't run the
  # actual logic themselves — they just send a message to the already-running
  # Counter process (found by name), and the process's own loop handles it.

  def start_link(opts) do
    name = Keyword.fetch!(opts, :name)
    initial = Keyword.get(opts, :initial, 0)
    # name: name registers this process under a name (e.g. :counter_a) so
    # other code can reach it without tracking its PID manually.
    GenServer.start_link(__MODULE__, {name, initial}, name: name)
  end

  # cast = fire-and-forget: sends the message, returns immediately, doesn't
  # wait for the process to actually handle it.
  def increment(name), do: GenServer.cast(name, :increment)
  def decrement(name), do: GenServer.cast(name, :decrement)

  # call = request-and-wait: blocks until handle_call replies.
  def get(name), do: GenServer.call(name, :get)

  # cast, not call — so if this Counter crashes, the caller (Chaos)
  # doesn't crash too, since it never waits for a reply.
  def crash(name), do: GenServer.cast(name, :crash)

  # --- Server callbacks ---
  # These run INSIDE the Counter process, called by the GenServer runtime
  # loop — never called directly by you.you define but someone else calls

  @impl true
  def init({name, initial}) do
    schedule_tick()
    # State is a map now (not a bare integer) so we can track the name too.
    {:ok, %{name: name, count: initial}}
  end

  # Fires every 1s — handles messages that aren't cast/call, here a
  # self-sent :tick message (the polling mechanism).
  @impl true
  def handle_info(:tick, state) do
    IO.puts("#{state.name}: #{state.count}")

    case Enum.random([-1, 1]) do
      1 -> increment(state.name)
      -1 -> decrement(state.name)
    end

    schedule_tick()
    {:noreply, state}
  end

  @impl true
  def handle_cast(:increment, state) do
    new_count = state.count + 1
    {:noreply, %{state | count: new_count}}
  end

  @impl true
  def handle_cast(:decrement, state) do
    new_count = state.count - 1
    {:noreply, %{state | count: new_count}}
  end

  # Deliberately crashes the process — this is the "let it crash" demo.
  # The Supervisor watching this process restarts it fresh (state resets).
  @impl true
  def handle_cast(:crash, _state), do: raise("boom")

  @impl true
  def handle_call(:get, _from, state) do
    {:reply, state.count, state}
  end

  # Private helper — only callable inside this module. Sends this same
  # process a :tick message 2000ms from now, which is what makes the
  # 2-second polling loop repeat forever.
  defp schedule_tick do
    Process.send_after(self(), :tick, @tick_interval)
  end
end