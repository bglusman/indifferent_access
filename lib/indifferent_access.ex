defmodule IndifferentAccess do
  @moduledoc """
  Recursively adds atom keys in params maps if the strings have existing atoms
  """

  def indifferentize(map) when is_map(map) do
    if Map.get(map, :__struct__) do
      map
    else
      Enum.reduce(map, %{}, fn
        {key, value}, accum when is_binary(key) ->
          existing_atom = atoms_map()[key]
          indifferent_value = indifferentize(value)

          if existing_atom,
            do:
              accum
              |> Map.put_new(existing_atom, indifferent_value)
              |> Map.put(key, indifferent_value),
            else: Map.put(accum, key, indifferent_value)

        {key, value}, accum ->
          indifferent_value = indifferentize(value)
          Map.put(accum, key, indifferent_value)
      end)
    end
  end

  def indifferentize(list) when is_list(list), do: Enum.map(list, &indifferentize/1)

  def indifferentize(non_map), do: non_map

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
