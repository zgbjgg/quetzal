defmodule Quetzal.Div do
  @moduledoc """
  Renders an html div as component

  # Example

  Use from `components/0` callback from your live view.

  `{Quetzal.Div, [id: "mydiv", style: "", children: ""]}` 

  """
  use Quetzal.Component,
    tag: "div"
end
