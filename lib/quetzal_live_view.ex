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
          {"MyApp", [{Quetzal.Graph.graph [id: "mypiegraph"], [type: "pie", labels: ["RED", "BLUE"], values: [20, 10]]}]}
        end
      end

  You can use the graph and other components to extend your views with custom graphs, tables, etc.

  Also is possible upgrade the components from the server live view, use `update_components/1` over your live view:

  ## Example:

  This example generates a random number and push to live view so Quetzal updates the component in the view:

      defmodule AppWeb.PieLive do
        use Quetzal.LiveView

        @impl Quetzal.LiveView
        def components(_session) do
          {"MyApp", [{Quetzal.Graph, [id: "mypie"], [type: "pie", labels: ["Red", "Blue"], values: [10, 20]]}]}
        end

        def trigger_update() do
          :timer.sleep(5000)
          newvalues = for _n <- 1..3, do: :rand.uniform(100)
          components = [mypie: [labels: ["Black", "White", "Gray"], values: newvalues]]
          update_components("MyApp", components)
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

      def mount(session, socket) do
        {app, components} = case components(session) do
          {app, components} -> {app, components}
          components        -> {UUID.uuid1(), components}
        end

        case app do
          app when is_binary(app) ->
            Registry.register(Quetzal.Registry, app, [])

            socket = socket
            |> assign(:components, components)
            |> assign(:raw_components, """
                 #{raw_components(components)}
               """)
            {:ok, socket}
          app ->
            raise "App should be a String or binary, #{inspect app} was provided."
        end
      end

      def handle_event(event, params, socket) do
        # instead delivery to callback, send a message to callback process
        # and allow delivery to custom definition implemented
        eval = :gen_server.call(Quetzal.Callback, {:dispatch, unquote(opts), event, params})
        socket = case eval do
          {:error, _error}  ->
            socket
          outputs when is_list(eval) ->
            # change property in component so we can assign items again to
            # allow live view server performs an update
            components = socket.assigns[:components]
            |> render_new_components(outputs)

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

      def handle_info({:upgrade, new_components}, socket) do
        components = socket.assigns[:components]
        |> render_new_components(new_components)

        socket = socket
        |> assign(:components, components)
        |> assign(:raw_components, """
             #{raw_components(components)}
          """)
        {:noreply, socket}
      end
      def handle_info(_, socket) do
        {:noreply, socket}
      end

      defp render_new_components(components, new_components) do
        components
        |> Enum.map(fn {t, opts} ->
             id = opts[:id] |> String.to_atom
             properties = new_components |> Keyword.get(id, nil)
             {t, opts} = case properties do
               nil -> {t, opts}
               properties -> {t, update_opts(opts, properties)}
             end
             with [child|_]=children <- Keyword.get(opts, :children, nil),
               new_children <- render_new_components(children, new_components)
             do
               {t, opts |> Keyword.replace!(:children, new_children)}
             else
               nil -> {t, opts}
               _children -> {t, opts}
             end
           {t, component_opts, opts} ->
             id = component_opts[:id] |> String.to_atom
             properties = new_components |> Keyword.get(id, nil)
             case properties do
               nil -> {t, component_opts, opts}
               properties  -> {t, component_opts, update_opts(opts, properties)}
             end
        end)
      end

      defp raw_components(components) do
        # since components are passed trough a single config, mask it as html tags
        components
        |> Enum.map(fn {render, options} ->
             options = case are_valid_component?(options) do
               true  -> raw_components(options)
               false -> options
             end
             case Code.ensure_compiled?(render) do
               true  -> render.html_tag(options)
               false -> {render, options}
             end
           {render, component_opts, options} -> # render graphs
             render.graph(component_opts, options)
        end)
      end

      defp update_opts(opts, properties) do
        opts
        |> Enum.map(fn {property, output} ->
          {property, properties |> Keyword.get(property, output)}
        end)
      end

      defp are_valid_component?([{Quetzal.Graph, _, _} | next]), do: are_valid_component?(next)
      defp are_valid_component?([{_, _} | next]), do: are_valid_component?(next)
      defp are_valid_component?([]), do: true
      defp are_valid_component?(_) do
        false
      end
    end
  end

  @callback components(session :: map) :: any()

  @doc """
  Updates the components sending a message to live view,
  it receives components as string as in Quetzal components definition

  ## Example:

      components = [mypiegraph: [labels: ["Black", "White", "Gray"], values: [black, white, gray]]]
      update_components(components) 

  """ 
  def update_components(app, components) do
    Registry.dispatch(Quetzal.Registry, app, fn entries ->
      entries
      |> Enum.each(fn {pid, _} ->
           send(pid, {:upgrade, components})
      end)
    end) 
  end
end
