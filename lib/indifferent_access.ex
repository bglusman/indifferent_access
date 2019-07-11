defmodule IndifferentAccess do
  @moduledoc """
  Transforms a map into a struct or map supporting indifferent access
  """

  def indifferentize(params, opts \\ []) when is_map(params) do
    case opts[:as] do
      :map -> indifferentize_map(params)
      _default -> IndifferentAccess.IndifferentParams.new(params)
    end
  end

  def indifferentize_map(map) when is_map(map) do
    if Map.get(map, :__struct__) do
      map
    else
      Enum.reduce(map, %{}, fn
        {key, value}, accum when is_binary(key) ->
          existing_atom = atoms_map()[key]
          indifferent_value = indifferentize_map(value)

          if existing_atom,
            do:
              accum
              |> Map.put_new(existing_atom, indifferent_value)
              |> Map.put(key, indifferent_value),
            else: Map.put(accum, key, indifferent_value)

        {key, value}, accum ->
          indifferent_value = indifferentize_map(value)
          Map.put(accum, key, indifferent_value)
      end)
    end
  end

  def indifferentize_map(list) when is_list(list), do: Enum.map(list, &indifferentize_map/1)

  def indifferentize_map(other), do: other

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
