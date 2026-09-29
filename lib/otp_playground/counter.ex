defmodule OtpPlayground.Counter do
  use GenServer

  # Client API

  def start_link(opts) do
    name = Keyword.fetch!(opts, :name)
    initial = Keyword.get(opts, :initial, 0)
    GenServer.start_link(__MODULE__, {name, initial}, name: name)
  end

  def increment(name), do: GenServer.cast(name, :increment)
  def decrement(name), do: GenServer.cast(name, :decrement)
  def get(name), do: GenServer.call(name, :get)
  # def crash(name), do: GenServer.call(name, :crash)
  def crash(name), do: GenServer.cast(name, :crash)

  # Server callbacks

  @impl true
  def init({name, initial}) do
    schedule_tick()
    {:ok, %{name: name, count: initial}}
  end

  @impl true
  def handle_info(:tick, state) do
    new_count = state.count + 1
    IO.puts("#{state.name}: #{new_count}")
    schedule_tick()
    {:noreply, %{state | count: new_count}}
  end

  @impl true
  def handle_cast(:increment, state) do
    {:noreply, %{state | count: state.count + 1}}
  end

  @impl true
  def handle_cast(:decrement, state) do
    {:noreply, %{state | count: state.count - 1}}
  end

  @impl true
  def handle_cast(:crash, _state), do: raise("boom")

  @impl true
  def handle_call(:get, _from, state) do
    {:reply, state.count, state}
  end

  defp schedule_tick do
    Process.send_after(self(), :tick, 1_000)
  end
end