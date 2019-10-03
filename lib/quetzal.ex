defmodule Quetzal do
  @moduledoc """
  Quetzal - Analytical web apps, beautiful, fast and easy using Elixir. No Javascript required.

  Quetzal provides easy and fast tools to make analytical web apps with real-time updates.

  Quetzal provides the next features:

  * Allows create componets from Elixir code and render into views such as: graphs (plotlyjs),
    inputs and more.

  * It uses a single function to allow update the components via server so instead of
    pulling data it is pushing data whenever you want.

  * It tracks events from components and receives in the live view to
    update live view components.

  ## Example

  First, define a module and use `Quetzal.LiveView`, you don't need `mount/2` or `render/1`,
  when using the Quetzal Live View all is done:

      defmodule AppWeb.PieLive do
        use Quetzal.LiveView
      end

  With this minimal configuration Quetzal is able to render any component into the view, let's
  generate a pie graph to render:

      defmodule AppWeb.PieLive do
        use Quetzal.LiveView

        @impl Quetzal.LiveView
        def components() do
          Quetzal.Graph.graph [id: "my-pie-graph"], [type: "pie", labels: ["RED", "BLUE"], values: [1, 2]]
        end
      end

  The callback returns a new graph component and put into the view the necessary items
  to work with it.

  Now, we are going to the real-time cases, let's say we want update our pie graph when an
  event occurs in the server, so let's define a trigger to make it:

      defmodule AppWeb.PieLive
        use Quetzal.LiveView

        @impl Quetzal.LiveView
        def components() do
          Quetzal.Graph.graph [id: "my-pie-graph"], [type: "pie", labels: ["RED", "BLUE"], values: [1, 2]]
        end

        def trigger_update() do
          :timer.sleep(5000)
          r = :rand.uniform(100)
          b = :rand.uniform(100)
          component = Quetzal.Graph.graph [id: "TEST"], [type: "pie", labels: ["RED", "BLUE"], values: [r, b]]
          update_components(component)
          trigger_update()
        end
      end

  Let's explain the code, first to all, the `trigger_update/0` can be called from iex:

      iex(1)> AppWeb.PieLive.trigger_update

  Then every 5 ms a random numbers will be generated and put into values of the pie graph, and the
  pie graph will be updated, nice eh?.

  To achieve this, Quetzal uses the `update_components/1` function to render the new content, also
  you need configure the javascript hooks, only pass the hooks into the live socket connection:

      ...
      import Quetzal from "quetzal_hooks"
      let quetzal = new Quetzal();
      ...
      let liveSocket = new LiveSocket("/live", Socket, {hooks: quetzal.Hooks})  

  With this minimal configuration, we able to make a real-time app that updates the graph from the
  live view server.

  Some notes that you should be take:

  * All setup should be similar to Phoenix Live View setup except for the first step and use `Quetzal.LiveView`.

  * The hooks should be configured into your app.js file.

  * Layouts should include `plotly.js` if you plan to use graphs (can be included from CDN).

  * Ensure that quetzal hooks are included in the package.json:

        ...
        "dependencies": {
          "phoenix": "file:../deps/phoenix",
          "phoenix_html": "file:../deps/phoenix_html",
          "phoenix_live_view": "file:../deps/phoenix_live_view",
          "quetzal_hooks": "file:../../quetzal"
        },
        ...

  That's all, we are working to add more examples of components, inputs etc. Enjoy!.

  """

  @doc """
  Generates a child spec for Quetzal registry, it requires the name into the keywords.

  ## Example

  Include into your supervision tree:

  `{Quetzal, name: Quetzal.Registry}`

  """
  @spec child_spec(keyword) :: Supervisor.child_spec()
  defdelegate child_spec(options), to: Quetzal.Supervisor
end
