defmodule Quetzal.Label do
  @moduledoc """
  Renders an html label as component

  # Example

  Use from `components/0` callback from your live view.

  `{Quetzal.Label, [id: "mylabel", children: "I'm a label"]}`

  """
  use Quetzal.Component,
    tag: "label"
end
