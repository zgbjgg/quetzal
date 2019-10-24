defmodule Quetzal.Component do
  @moduledoc """
  The base module to make input components with custom action events

  You can create input components or html components from this module,
  using into your own definition. Use the module options to set the
  built-in custom tags for events or tagging html components, also you
  can pass keywords as options to render into the tag.

  Special tags are: `change`, `keyup`, `keydown`, `target`, `submit`, `click`,
    `focus`, and `blur`. We decide set this available so we can handle `phx` events and
  all components using the behaviour will contain this tags by default and apply
  them if found into tags when rendering the component.

  ## Example:

  Create an input text to capture an string:

      defmodule MyComponent.Text do
        use Quetzal.Component,
          tag: "input",
          type: "text"
      end

  And let's use in this way:

      iex(10)> MyComponent.Text.html_tag([id: "mytext", change: "mytext"])
      "<input id=\"mytext\" type=\"text\" phx-change=\"mytext\"></input>"
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
      @event_tags [:change, :keyup, :keydown, :target, :submit, :click, :focus, :blur]

      @impl unquote(__MODULE__)
      def render(options) do
        opts = unquote(opts)

        # get options from use
        tag = if opts[:tag] == nil do :missing else opts[:tag] end
        type = if opts[:type] == nil do "" else opts[:type] end

        case tag do
          :missing -> raise "Missing tag, a component should contain valid html tag into keyword options."
          _        ->
            # children as opt should be render as is
            children = Keyword.get(options, :children, "")

            options = options
            |> Enum.map(fn {opt, value} ->
                 with true <- Enum.member?(@event_tags, opt)
                 do
                   opt = opt
                   |> Atom.to_string
                   |> (fn opt -> "phx-#{opt}" end).()
                   |> String.to_atom
                   {opt, value}
                 else
                   false -> {opt, value}
                 end
            end)
            |> Keyword.put(:type, type)
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
