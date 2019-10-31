defmodule Quetzal.Button do
  @moduledoc """
  Renders an html button as component. 

  # Example

  Use from `components/0` callback from your live view.

  `{Quetzal.Button, [id: "mybtn", children: "Click me!"]}`

  """
  use Quetzal.Component,
    tag: "button",
    type: "submit"
end
