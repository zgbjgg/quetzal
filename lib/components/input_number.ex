defmodule Quetzal.InputNumber do
  @moduledoc """
  Renders an html input number as component

  # Example

  Use from `components/0` callback from your live view.

  `{Quetzal.InputNumber, [id: "mynumber"]}`

  """
  use Quetzal.Component,
    tag: "input",
    type: "number"
end
