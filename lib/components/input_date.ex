defmodule Quetzal.InputDate do
  @moduledoc """
  Renders an html input date as component

  # Example

  Use from `components/0` callback from your live view.

  `{Quetzal.InputDate, [id: "mydate"]}`

  """
  use Quetzal.Component,
    tag: "input",
    type: "date"
end
