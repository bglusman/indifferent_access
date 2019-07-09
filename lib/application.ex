defmodule IndifferentAccess.Application do
  @moduledoc """
  The Core Application Service.

  The JIQ system business and shared logic lives in this application.
  """
  use Application

  def start(_type, _args) do
    IndifferentAccess.initialize_atoms_map()
    Supervisor.start_link([], strategy: :one_for_one)
  end

  def application do
    [
      mod: {IndifferentAccess.Application, []},
      extra_applications: [:logger]
    ]
  end
end
