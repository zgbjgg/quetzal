defmodule Quetzal.Checkbox do
  @moduledoc """
  Renders an html checkbox as component

  # Example

  Use from `components/0` callback from your live view.

  `{Quetzal.Checkbox, [id: "mycheckbox"]}`

  """
  use Quetzal.Component,
    tag: "input",
    type: "checkbox"
end
