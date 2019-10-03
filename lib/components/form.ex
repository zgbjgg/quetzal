defmodule Quetzal.Form do
  @moduledoc """
  Renders an html form as component with the change event as id.

  # Example

  Use from `components/0` callback from your live view.

  `{Quetzal.Form, [id: "myform", children: ""]}`

  """
  use Quetzal.Component,
    tag: "form"
end
