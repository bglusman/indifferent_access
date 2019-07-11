defmodule IndifferentAccess.Plug do
  @moduledoc """
  Several modes of indifferent access can be configured via the opts passed in to
  a pipeline plug.

  The default constructs a new IndifferentAccess.Params struct in place of Conn.params and Conn.query_params.
  That struct has two behaviors, the default where any map returned from its Access methods
  will also be a Params struct, or if `strategy: :static` is passed in here, it will only set the top level
  params as a struct and any returned values will be unchanged.

  Alternatively, if you want to retain a bare map in your params, pass the option `as: :map` and
  it will recursively replace string keys with atom keys in params maps if the strings have existing atoms
  (also note you must call `IndifferentAccess.initialize_atoms_map/0` for this behavior at app startup).
  Note that this option isn't truly "indifferent" and will only support atom access because it has replaced the
  strings with atoms as the keys.

  There is another option that is not reccomended to also pass ``strategy: :augment`
  in addition to `as: :map` and it will leave string keys in place alongside additional atom keys pointing to the
  same value.  Note this basically rendered enumeration on the map useless/confusion, and also makes updates to the map
  problematic as the two values will diverge.
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
