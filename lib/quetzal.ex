defmodule Quetzal do
  @moduledoc """
  Quetzal - Analytical web apps, beautiful, fast and easy using Elixir. No Javascript required.
  """

  @doc """
  Generates a child spec for Quetzal registry, it requires the name into the keywords.

  ## Example

  Include into your supervision tree:

  `{Quetzal, name: Quetzal.Registry}`

  """
  @spec child_spec(keyword) :: Supervisor.child_spec()
  defdelegate child_spec(options), to: Quetzal.Supervisor
end
