defmodule IndifferentAccess do
  @moduledoc """
  Transforms a map into a struct or map supporting indifferent access.

  Primary intended usage is via `IndifferentAccess.Plug`, see docs there.
  """

  alias IndifferentAccess.Params

  @doc """
  Returns a struct or map accessible by Atom keys with several configuration optons determining behavior. See examples below.

  ## Examples
      iex> IndifferentAccess.indifferentize(%{"schedulers" => "4"})
      %IndifferentAccess.Params{params: %{"schedulers" => "4"}}

      iex> IndifferentAccess.indifferentize(%{"schedulers" => "4"})[:schedulers]
      "4"

      iex> IndifferentAccess.indifferentize(%{"schedulers" => %{"tls" => "3"}})[:schedulers][:tls]
      "3"

      iex> IndifferentAccess.indifferentize(%{"schedulers" => %{"tls" => "3"}}, strategy: :static)[:schedulers][:tls]
      nil

      iex> IndifferentAccess.initialize_atoms_map()
      iex> IndifferentAccess.indifferentize(%{"schedulers" => %{"tls" => "3"}}, as: :map)[:schedulers][:tls]
      "3"

      iex> IndifferentAccess.initialize_atoms_map()
      iex> IndifferentAccess.indifferentize(%{"schedulers" => %{"tls" => "3", "random_string" => "2"}}, as: :map)[:schedulers]
      %{:tls => "3", "random_string" => "2"}
  """
  def indifferentize(params, opts \\ []) when is_map(params) do
    case opts[:as] do
      :map -> indifferentize_map(params, opts)
      nil -> Params.new(params, opts)
    end
  end

  @doc """
  Returns a map with String keys replaced or supplemented by Atom keys where equivalent atoms exist.

  ## Examples
      iex> IndifferentAccess.initialize_atoms_map()
      iex> IndifferentAccess.indifferentize_map(%{"schedulers" => "4"})
      %{schedulers: "4"}

      iex> IndifferentAccess.initialize_atoms_map()
      iex> IndifferentAccess.indifferentize_map(%{"schedulers" => "4"}, strategy: :augment)
      %{:schedulers => "4", "schedulers" => "4"}

      iex> IndifferentAccess.initialize_atoms_map()
      iex> IndifferentAccess.indifferentize_map(%{"schedulers" => %{"tls" => "3", "others" => "2"}})
      %{schedulers: %{"others" => "2", :tls => "3"}}
  """
  def indifferentize_map(map, opts \\ [])

  def indifferentize_map(map, opts) when is_map(map) do
    if Map.get(map, :__struct__) do
      map
    else
      map_keys = Map.keys(map)

      Enum.reduce(map, %{}, fn
        {key, value}, accum when is_binary(key) ->
          existing_atom = atoms_map()[key]
          indifferent_value = indifferentize_map(value, opts)

          case opts[:strategy] do
            :augment ->
              if existing_atom,
                do:
                  accum
                  |> Map.put_new(existing_atom, indifferent_value)
                  |> Map.put(key, indifferent_value),
                else: Map.put(accum, key, indifferent_value)

            nil ->
              if existing_atom && existing_atom not in map_keys,
                do:
                  accum
                  |> Map.put_new(existing_atom, indifferent_value)
                  |> Map.delete(key),
                else: Map.put(accum, key, indifferent_value)
          end

        {key, value}, accum ->
          indifferent_value = indifferentize_map(value, opts)
          Map.put(accum, key, indifferent_value)
      end)
    end
  end

  def indifferentize_map(list, opts) when is_list(list),
    do: Enum.map(list, &indifferentize_map(&1, opts))

  def indifferentize_map(other, _opts), do: other

  def initialize_atoms_map() do
    atoms_count = :erlang.system_info(:atom_count)

    existing_atoms_map =
      Enum.map(0..(atoms_count - 1), fn i ->
        atom = :erlang.binary_to_term(<<131, 75, i::24>>)
        {to_string(atom), atom}
      end)
      |> Map.new()

    Application.put_env(:indifferent_access, :all_atoms_map, existing_atoms_map)
  end

  def atoms_map() do
    Application.get_env(:indifferent_access, :all_atoms_map)
  end
end
