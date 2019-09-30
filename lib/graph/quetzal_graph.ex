defmodule Quetzal.Graph do
  @doc """
  The base module to make graph components based on plotly.js
  """
  require EEx

  # decompose every graph component so we can handle almost every supported over plotly
  graph = fn(def_graph) ->
    def unquote(def_graph)(component_opts, options) do
      plotly_graph(unquote(def_graph), component_opts, options)
    end
  end

  Enum.map(~w(pie)a, graph)

  @doc """
  Returns the component that holds the graph and their data holding into a single EEx template
  """
  def plotly_graph(:pie, component_opts, options) do
    # in pie search values and labels as datasource
    values = Keyword.get(options, :values, [])
    labels = Keyword.get(options, :labels, [])
    opts_as_json = Jason.encode!([%{"values" => values, "labels" => labels, "type" => "pie"}])
    build_graph(component_opts, opts_as_json)
  end
  def plotly_graph(_, _, _) do
    {:error, :graph_not_supported}
  end

  defp build_graph(component_opts, options) do
    id = Keyword.get(component_opts, :id, "#")
    style = Keyword.get(component_opts, :style, "")
    class = Keyword.get(component_opts, :class, "")
    """
    #{ html_tag(id, style, class, options) }
    #{ js_tag(id) }
    """
  end

  # EEx template for div to hold graph
  EEx.function_from_string(
    :def,
    :html_tag,
    ~s[<div phx-hook="Graph" id="<%= id %>" style="<%= style %>" class="<%= class %>" options='<%= options %>'></div>],
    ~w(id style class options)a
  )

  # EEx template for script to create graph
  EEx.function_from_string(
    :def,
    :js_tag,
    ~s[<script>
         fn_<%= id %> = new Function("ID = document.getElementById('<%= id %>');" +
           "OPTS = ID.getAttribute('options');" +
           "Plotly.react(ID, JSON.parse(OPTS));");
         fn_<%= id %>()
       </script>],
    ~w(id)a
  )
end
