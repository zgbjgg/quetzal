defmodule Quetzal.Component do
  @moduledoc """
  The base module to make input components with custom action events

  You can create input components or html components from this module,
  using into your own definition. Use the module options to set the
  built-in custom tags for events or tagging html components, also you
  can pass keywords as options to render into the tag.

  ## Example:

  Create an input text to capture an string:

      defmodule MyComponent.Text do
        use Quetzal.Component,
          keyup: "value",
          target: "window",
          tag: "input"
      end

  And let's use in this way:

      iex(10)> MyComponent.Text.html_tag([id: "mytext", type: "text"])
      "<input id=\"mytext\" type=\"text\" phx-keyup=\"value\" phx-target=\"window\"></input>"
  """

  defmacro __using__(opts) do
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
        opts = unquote(opts)

        # get options from use
        tag = if opts[:tag] == nil do :missing else opts[:tag] end
        keyup = opts[:keyup]
        target = opts[:target]

        case tag do
          :missing -> raise "Missing tag, a component should contain valid html tag into keyword options."
          _        ->
            # children as opt should be render as is
            children = Keyword.get(options, :children, "")
            options = options
            |> Keyword.put(:"phx-keyup", keyup)
            |> Keyword.put(:"phx-target", target)
            |> Keyword.delete(:children)
            |> Enum.map(fn {_, nil} ->
                 ""
               {opt, value} ->
                 "#{opt}=\"#{value}\""
            end)
            |> Enum.join(" ")

            "#{@tag_open}#{tag} #{options}#{@tag_close}#{children}#{@tag_open_slash}#{tag}#{@tag_close}"
        end
      end

      EEx.function_from_string(:def, :html_tag, ~s[<%= render(opts) %>], ~w(opts)a)
    end
  end

  @callback render(Keyword.t()) :: String.t()
end
