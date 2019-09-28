defmodule Quetzal.LiveView do
  defmacro __using__(opts) do
    quote do
      use Phoenix.LiveView, unquote(opts)

      def render(var!(assigns)) do
       ~L"""
       <%= Phoenix.HTML.raw @components %>
       """
      end

      def mount(_session, socket) do
        components = Quetzal.LiveView.components
        {:ok, assign(socket, :components, components)}
      end
    end
  end

  def components() do
    Quetzal.Graph.pie [id: "TEST"], [labels: ["R", "B"], values: [1, 2]]
  end
end
