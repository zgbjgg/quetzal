defmodule Quetzal.Component do
  @doc """
  The base module to make input components with custom action events

  You can create input components or html components from this module,
  using into your own definition. Just should override the `tag/0`
  function in order to apply the tag, also you can pass keywords as options
  to render into the tag.

  ## Example:

  Create an input text to capture an string:

      defmodule MyComponent.Text do
        use Quetzal.Component

        @impl true
        def tag() do
          "input"
        end
      end

  And let's use in this way:

      iex(10)> MyComponent.Text.html_tag([id: "mytext", type: "text"])
      "<input id=\"1\" type=\"text\"></input>"
  """

  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
      @behaviour unquote(__MODULE__)

      require EEx

      @tag_open "<"
      @tag_close ">"
      @tag_open_slash "</"
      @tag_close_slash "/>"

      @impl unquote(__MODULE__)
      def render(options) do
        case tag() do
          :missing -> raise "Missing tag, a component should contain valid html tag into keyword options."
          _        ->
            options = options
            |> Enum.map(fn {opt, value} ->
                 "#{opt}=\"#{value}\""
            end)
            |> Enum.join(" ")

            "#{@tag_open}#{tag()} #{options}#{@tag_close}#{@tag_open_slash}#{tag()}#{@tag_close}"
        end
      end

      EEx.function_from_string(:def, :html_tag, ~s[<%= render(opts) %>], ~w(opts)a)

      @impl unquote(__MODULE__)
      def tag(), do: :missing

      defoverridable tag: 0
    end
  end

  @callback tag() :: String.t()

  @callback render(Keyword.t()) :: String.t()
end
