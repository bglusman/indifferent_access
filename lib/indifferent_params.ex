defmodule IndifferentAccess.IndifferentParams do
  alias __MODULE__

  defstruct params: %{}

  @behaviour Access

  def new(params) do
    %IndifferentParams{params: params}
  end

  @impl Access
  def fetch(%IndifferentParams{params: params}, key) when is_atom(key) do
    initial_value = Map.fetch(params, key)
    if initial_value != :error, do: initial_value, else: Map.fetch(params, to_string(key))
  end

  def fetch(%IndifferentParams{params: params}, key) do
    Map.fetch(params, key)
  end

  def get(container, key, default \\ nil)

  def get(%IndifferentParams{params: params}, key, default) when is_atom(key) do
    initial_value = Map.get(params, key, default)
    if initial_value, do: initial_value, else: Map.get(params, to_string(key), default)
  end

  def get(%IndifferentParams{params: params}, key, default) do
    Map.get(params, key, default)
  end

  @impl Access
  def get_and_update(%IndifferentParams{params: params}, key, fun) when is_atom(key) do
    initial_value = Map.get(params, key)
    update_key = if initial_value, do: key, else: to_string(key)
    {get_value, new_params} = Map.get_and_update(params, update_key, fun)
    {get_value, %__MODULE__{params: new_params}}
  end

  def get_and_update(%IndifferentParams{params: params}, key, fun) do
    {get_value, new_params} = Map.get_and_update(params, key, fun)
    {get_value, %__MODULE__{params: new_params}}
  end

  @impl Access
  def pop(container, key, default \\ nil)

  def pop(%IndifferentParams{params: params}, key, default) when is_atom(key) do
    initial_value = Map.get(params, key)
    pop_key = if initial_value, do: key, else: to_string(key)
    {get_value, new_params} = Map.pop(params, pop_key, default)
    {get_value, %__MODULE__{params: new_params}}
  end

  def pop(%IndifferentParams{params: params}, key, default) do
    {get_value, new_params} = Map.pop(params, key, default)
    {get_value, %__MODULE__{params: new_params}}
  end
end
