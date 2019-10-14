defmodule Quetzal.InputRadio do
  @moduledoc """
  Renders an html input radio as component

  # Example

  Use from `components/0` callback from your live view.

  `{Quetzal.InputRadio, [id: "myradio"]}`

  """
  use Quetzal.Component,
    tag: "input",
    type: "radio"
end
