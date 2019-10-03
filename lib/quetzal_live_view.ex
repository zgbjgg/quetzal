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
          Quetzal.Graph.graph [id: "mypiegraph"], [type: "pie", labels: ["RED", "BLUE"], values: [20, 10]]
        end
      end

  You can use the graph and other components to extend your views with custom graphs, tables, etc.

  Also is possible upgrade the components from the server live view, use `update_components/1` over your live view:

  ## Example:

  This example generates a random number and push to live view so Quetzal updates the component in the view:

      defmodule AppWeb.PieLive do
        use Quetzal.LiveView

        @impl Quetzal.LiveView
        def components() do
          Quetzal.Graph.graph [id: "mypiegraph"], [type: "pie", labels: ["RED", "BLUE"], values: [20, 10]]
        end

        def trigger_update() do
          :timer.sleep(5000)
          r = :rand.uniform(100)
          b = :rand.uniform(100)
          component = Quetzal.Graph.graph [id: "mypiegraph"], [type: "pie", labels: ["RED", "BLUE"], values: [r, b]]
          update_components(component) # this will update the graph
          trigger_update()
        end
      end
  """

  defmacro __using__(opts) do
    quote do
      use Phoenix.LiveView

      import unquote(__MODULE__)
      @behaviour unquote(__MODULE__)

      def render(var!(assigns)) do
        ~L"""
        <%= Phoenix.HTML.raw @raw_components %> 
        """
      end

      def mount(_session, socket) do
        Registry.register(Quetzal.Registry, "PID", [])

        socket = socket
        |> assign(:components, components())
        |> assign(:raw_components, """
            #{raw_components(components())}
          """)
        {:ok, socket}
      end

      def handle_event(event, params, socket) do
        # instead delivery to callback, send a message to callback process
        # and allow delivery to custom definition implemented
        eval = :gen_server.call(Quetzal.Callback, {:dispatch, unquote(opts), event, params})
        socket = case eval do
          {:error, :no_callback_matches}  ->
            socket
          [{outputs, component, properties}] ->
            # change property in component so we can assign items again to
            # allow live view server performs an update
            components = socket.assigns[:components]
            |> Enum.map(fn {t, opts} ->
                 id = opts[:id]
                 case id == component do
                   true  ->
                     opts_to_update = Enum.zip(properties, outputs)
                     opts = opts
                     |> Enum.map(fn {property, output} ->
                          {property, opts_to_update |> Keyword.get(property, output)}
                     end)
                     {t, opts}
                   false -> {t, opts}
                 end
            end)

            socket
            |> assign(:components, components)
            |> assign(:raw_components, """
                #{raw_components(components)}
              """)
          _ ->
            socket # there is some error thrown by callback
        end
        {:noreply, socket}
      end

      def handle_info({:upgrade, components, raw_components}, socket) do
        socket = socket
        |> assign(:components, components)
        |> assign(:raw_components, raw_components)
        {:noreply, socket}
      end
      def handle_info(_, socket) do
        {:noreply, socket}
      end

      defp raw_components(components) do
        # since components are passed trough a single config, mask it as html tags
        components
        |> Enum.map(fn {render, options} ->
             options = case Keyword.keyword?(options) do
               true  -> raw_components(options)
               false -> options
             end
             case Code.ensure_compiled?(render) do
               true  -> render.html_tag(options)
               false -> {render, options}
             end
        end)
      end
    end
  end

  @callback components() :: any()

  @doc """
  Updates the components sending a message to live view,
  it receives components as string as in Quetzal components definition

  ## Example:

      update_components(Quetzal.Graph.graph [id: "mypiegraph"], [type: "pie", labels: ["RED", "BLUE"], values: [20, 10]])

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
