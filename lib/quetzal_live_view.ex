defmodule Quetzal.LiveView do
  @moduledoc """
  Quetzal Live View provides easy interface to handle events, components and
  messages into Quetzal architechture in a fast and fashion way. It uses Phoenix Live View
  to render components and their upgrades.

  In order to use set the Quetzal.LiveView instead Phoenix.LiveView directly over your
  live module:

  ## Example:

  You don't need `mount/2` or `render/1` when using the Quetzal Live View is all done:

      defmodule AppWeb.PieLive do
        use Quetzal.LiveView
      end

  In order to render components to the live view use the `components/0` callback:

  ## Example:

  This will render a pie graph into the view using custom components:

      defmodule AppWeb.PieLive do
        use Quetzal.LiveView

        @impl Quetzal.LiveView
        def components() do
          Quetzal.Graph.pie [id: "my-pie-graph"], [labels: ["RED", "BLUE"], values: [20, 10]]
        end
      end

  You can use the graph and other components to extend your views with custom graphs, tables, etc.

  Also is possible upgrade the components from the server live view, use `update_components/1` over your live view:

  ## Example:

  This example generates a random number and push to live view so Quetzal updates the component in the view :scream:

      defmodule AppWeb.PieLive do
        use Quetzal.LiveView

        @impl Quetzal.LiveView
        def components() do
          Quetzal.Graph.pie [id: "my-pie-graph"], [labels: ["RED", "BLUE"], values: [20, 10]]
        end
      end

      def trigger_update() do
        :timer.sleep(5000)
        r = :rand.uniform(100)
        b = :rand.uniform(100)
        component = Quetzal.Graph.pie [id: "my-pie-graph"], [labels: ["R", "B"], values: [r, b]]
        update_components(component)
        trigger_update()
      end
  """

  defmacro __using__(opts) do
    quote do
      use Phoenix.LiveView, unquote(opts)

      import unquote(__MODULE__)
      @behaviour unquote(__MODULE__)

      def render(var!(assigns)) do
       ~L"""
       <%= Phoenix.HTML.raw @components %> 
       """
      end

      def mount(_session, socket) do
        Registry.register(Quetzal.Registry, "PID", [])
        {:ok, assign(socket, :components, components())}
      end

      def handle_event(event, params,socket) do
        handle_component_event(event, params, socket)
      end

      def handle_info({:upgrade, components}, socket) do
        {:noreply, assign(socket, :components, components)}
      end
      def handle_info(_, socket) do
        {:noreply, socket}
      end
    end
  end

  @callback handle_component_event(event :: binary, unsigned_params :: map, socket :: Socket.t()) ::
    {:noreply, Socket.t()} | {:stop, Socket.t()}

  @callback components() :: any()

  @doc """
  Updates the components sending a message to live view,
  it receives components as string as in Quetzal components definition

  ## Example:

      update_components(Quetzal.Graph.pie [id: "my-pie-graph"], [labels: ["RED", "BLUE"], values: [20, 10]])

  """ 
  def update_components(components) do
    Registry.dispatch(Quetzal.Registry, "PID", fn entries ->
      entries
      |> Enum.each(fn {pid, _} ->
           send(pid, {:upgrade, components})
      end)
    end) 
  end
end
