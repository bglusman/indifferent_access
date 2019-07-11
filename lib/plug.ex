defmodule IndifferentAccess.Plug do
  @moduledoc """
  Recursively adds atom keys in params maps if the strings have existing atoms
  """
  import IndifferentAccess, only: [indifferentize: 2, atoms_map: 0]

  def init(opts), do: opts

  def call(conn, opts) do
    if is_nil(atoms_map()) and opts[:as] == :map,
      do:
        raise(
          "IndifferentAccess.initialize_atoms_map() must be called during app initialization."
        )

    conn
    |> Map.put(:params, indifferentize(conn.params, opts))
    |> Map.put(:query_params, indifferentize(conn.query_params, opts))
  end
end
