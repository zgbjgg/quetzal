defmodule Quetzal.Form do
  @moduledoc """
  Renders an html form as component.

  # Example

  Use from `components/0` callback from your live view.

  `{Quetzal.Form, [id: "myform", children: ""]}`

  """
  use Quetzal.Component,
    tag: "form"
end
