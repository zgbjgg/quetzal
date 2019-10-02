defmodule Quetzal.Callback do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: Quetzal.Callback)
  end

  @impl true
  def init([]) do
    {:ok, []}
  end

  @impl true
  def handle_call({:dispatch, opts, event, params}, _from, state) do
    id = params |> Map.get("id")
    value = params |> Map.get("value")

    # build arguments
    args = [id, event, value]

    # get module and functions to call
    mod = opts[:handler]
    funs = opts[:callbacks]

    output = funs
    |> Enum.map(fn fun ->
         try do
           :erlang.apply(mod, fun, args)
         catch
           _error -> {:error, :no_callback_matches}
         end
    end)
    {:reply, output, state}
  end
end
