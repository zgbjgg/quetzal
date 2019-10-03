defmodule Quetzal.Supervisor do
  @moduledoc """
  A simple supervisor to start the registry and callback processes

  Just include into your app tree supervision:

  # Example

      `{Quetzal, name: Quetzal.Registry}`

  """
  use Supervisor

  def start_link(opts) do
    name =
      opts[:name] ||
        raise ArgumentError, "the :name option is required when starting Quetzal Registry"

    sup_name = Module.concat(name, "Supervisor")
    Supervisor.start_link(__MODULE__, opts, name: sup_name)
  end

  def init(opts) do
    name = opts[:name]

    registry = [
      keys: :duplicate,
      name: name
    ]

    children = [
      {Registry, registry},
      {Quetzal.Callback, []}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
