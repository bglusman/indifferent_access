defmodule IndifferentAccess.Plug do
  @moduledoc """
  Several modes of indifferent access can be configured via the opts passed in to
  a pipeline plug.

  The default constructs a new IndifferentAccess.Params struct in place of Conn.params and Conn.query_params.
  That struct has two behaviors, the default where any map returned from its Access methods
  will also be a Params struct, or if `strategy: :static` is passed in here, it will only set the top level
  params as a struct and any returned values will be unchanged.

  Alternatively, if you want to retain a bare map in your params, pass the option `as: :map` and
  it will recursively replace string keys with atom keys in params maps if the strings have existing atoms.
  Note that this option isn't truly "indifferent" and will only support atom access because it has replaced the
  strings with atoms as the keys.

  There is another option that is not reccomended to also pass ``strategy: :augment`
  in addition to `as: :map` and it will leave string keys in place alongside additional atom keys pointing to the
  same value.  Note this basically renders enumeration on the map useless/confusing, and also makes updates to the map
  problematic as the two values will diverge. This version may not be supported long term, but since this is an experimental
  library and it was easy to support as an option, it was left in place.
  """
  import IndifferentAccess, only: [indifferentize: 2]

  def init(opts) do
    [strategy: Keyword.get(opts, :strategy, :replace), as: Keyword.get(opts, :as, :struct)]
  end

  @doc """
    This is meant to be called in a Plug pipeline, and assumes that params and query_params have already been fetched prior to this call.
    The valid opts are `:as` and `:strategy`, which are set to default values of `:struct` and `:replace` by init/1
  """
  def call(conn, opts) do
    conn
    |> Map.put(:params, indifferentize(conn.params, opts))
    |> Map.put(:query_params, indifferentize(conn.query_params, opts))
  end
end
