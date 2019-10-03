defmodule Quetzal.InputText do
  @moduledoc """
  Renders an html input text as component

  # Example

  Use from `components/0` callback from your live view.

  `{Quetzal.InputText, [id: "mytext"]}`

  """
  use Quetzal.Component,
    tag: "input",
    type: "text"
end
