defmodule Quetzal.TextArea do
  @moduledoc """
  Renders an html textarea as component

  # Example

  Use from `components/0` callback from your live view.

  `{Quetzal.TextArea, [id: "mytextarea", rows: "10"]}`

  """
  use Quetzal.Component,
    tag: "textarea"
end
