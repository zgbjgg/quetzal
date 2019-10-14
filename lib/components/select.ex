defmodule Quetzal.Select do
  @moduledoc """
  Renders an html select as component

  # Example

  Use from `components/0` callback from your live view.

  `{Quetzal.Select, [id: "myselect", children: "<option>1</option>"]}`

  """
  use Quetzal.Component,
    tag: "select"
end
