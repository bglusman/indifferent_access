defmodule IndifferentAccess.Params do
  alias __MODULE__

  @moduledoc """
  This struct has two behaviors, the default where any map returned from its Access methods
  will also be a Params struct, or if `strategy: :static` is passed as an option, it will only set the top level
  params as a struct and any returned values will be unchanged.
  """
  defstruct params: %{}, opts: []

  @behaviour Access

  def new(params, opts \\ [strategy: :replace]) do
    %Params{params: params, opts: opts}
  end

  @impl Access
  def fetch(%Params{params: params, opts: opts}, key) when is_atom(key) do
    initial_value = Map.fetch(params, key)

    return_value =
      if initial_value != :error, do: initial_value, else: Map.fetch(params, to_string(key))

    wrap(return_value, opts[:strategy])
  end

  def fetch(%Params{params: params, opts: opts}, key) do
    wrap(Map.fetch(params, key), opts[:strategy])
  end

  def get(container, key, default \\ nil)

  def get(%Params{params: params, opts: opts}, key, default) when is_atom(key) do
    initial_value = Map.get(params, key, default)

    return_value =
      if initial_value, do: initial_value, else: Map.get(params, to_string(key), default)

    wrap(return_value, opts[:strategy])
  end

  def get(%Params{params: params, opts: opts}, key, default) do
    wrap(Map.get(params, key, default), opts[:strategy])
  end

  @impl Access
  def get_and_update(%Params{params: params, opts: opts}, key, fun) when is_atom(key) do
    initial_value = Map.get(params, key)
    update_key = if initial_value, do: key, else: to_string(key)
    {get_value, new_params} = Map.get_and_update(params, update_key, fun)
    {wrap(get_value, opts[:strategy]), %__MODULE__{params: new_params}}
  end

  def get_and_update(%Params{params: params, opts: opts}, key, fun) do
    {get_value, new_params} = Map.get_and_update(params, key, fun)
    {wrap(get_value, opts[:strategy]), %__MODULE__{params: new_params}}
  end

  @impl Access
  def pop(container, key, default \\ nil)

  def pop(%Params{params: params, opts: opts}, key, default) when is_atom(key) do
    initial_value = Map.get(params, key)
    pop_key = if initial_value, do: key, else: to_string(key)
    {get_value, new_params} = Map.pop(params, pop_key, default)
    {wrap(get_value, opts[:strategy]), %__MODULE__{params: new_params}}
  end

  def pop(%Params{params: params, opts: opts}, key, default) do
    {get_value, new_params} = Map.pop(params, key, default)
    {wrap(get_value, opts[:strategy]), %__MODULE__{params: new_params}}
  end

  defp wrap(any, :static), do: any

  defp wrap(map, :replace) when is_map(map) do
    new(map)
  end

  defp wrap(list, :replace) when is_list(list) do
    for item <- list, do: wrap(item, :replace)
  end

  defp wrap({:ok, any}, :replace) do
    {:ok, wrap(any, :replace)}
  end

  defp wrap(other, :replace), do: other
end
