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
      %IndifferentAccess.Params{params: %{"schedulers" => "4"}, opts: [as: :struct, strategy: :replace]}

      iex> IndifferentAccess.indifferentize(%{"schedulers" => "4"}, as: :struct, strategy: :replace)[:schedulers]
      "4"

      iex> IndifferentAccess.indifferentize(%{"schedulers" => %{"tls" => "3"}}, as: :struct, strategy: :replace)[:schedulers][:tls]
      "3"

      iex> IndifferentAccess.indifferentize(%{"schedulers" => %{"tls" => "3"}}, as: :struct, strategy: :static)[:schedulers][:tls]
      nil

      iex> IndifferentAccess.indifferentize(%{"schedulers" => %{"tls" => "3"}}, as: :map, strategy: :replace)[:schedulers][:tls]
      "3"

      iex> IndifferentAccess.indifferentize(%{"schedulers" => %{"tls" => "3", "random_string" => "2"}}, as: :map, strategy: :replace)[:schedulers]
      %{:tls => "3", "random_string" => "2"}
  """
  def indifferentize(params, opts \\ [as: :struct, strategy: :replace]) when is_map(params) do
    case opts[:as] do
      :map -> indifferentize_map(params, opts)
      :struct -> Params.new(params, opts)
    end
  end

  @doc """
  Returns a map with String keys replaced or supplemented by Atom keys where equivalent atoms exist.

  ## Examples
      iex> IndifferentAccess.indifferentize_map(%{"schedulers" => "4"}, strategy: :replace)
      %{schedulers: "4"}

      iex> IndifferentAccess.indifferentize_map(%{"schedulers" => "4"}, strategy: :augment)
      %{:schedulers => "4", "schedulers" => "4"}

      iex> IndifferentAccess.indifferentize_map(%{"schedulers" => %{"tls" => "3", "others" => "2"}}, strategy: :replace)
      %{schedulers: %{"others" => "2", :tls => "3"}}

      iex> IndifferentAccess.indifferentize_map(%{"schedulers" => %{"tls" => "3", "others" => "2"}}, strategy: :static)
      ** (RuntimeError) `strategy: :static` is only valid within IndifferentAccess.Params struct, not when using `as: :map` option in plug or indifferentize_map directly
  """
  def indifferentize_map(map, opts \\ [])

  def indifferentize_map(map, opts) when is_map(map) do
    if Map.get(map, :__struct__) do
      map
    else
      map_keys = Map.keys(map)

      Enum.reduce(map, %{}, fn
        {key, value}, accum when is_binary(key) ->
          indifferent_value = indifferentize_map(value, opts)

          case opts[:strategy] do
            :augment ->
              if existing_atom(key),
                do:
                  accum
                  |> Map.put_new(existing_atom(key), indifferent_value)
                  |> Map.put(key, indifferent_value),
                else: Map.put(accum, key, indifferent_value)

            :replace ->
              if existing_atom(key) && existing_atom(key) not in map_keys,
                do:
                  accum
                  |> Map.put_new(existing_atom(key), indifferent_value)
                  |> Map.delete(key),
                else: Map.put(accum, key, indifferent_value)

            :static ->
              raise "`strategy: :static` is only valid within IndifferentAccess.Params struct," <>
                      " not when using `as: :map` option in plug or indifferentize_map directly"
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

  defp existing_atom(key) do
    String.to_existing_atom(key)
  rescue
    ArgumentError -> nil
  end
end
