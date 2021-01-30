defmodule Hydrogen.Util do
  require Logger
  use Bitwise

  def generate_endpoint(path) do
    Application.fetch_env!(:hydrogen, :api_endpoint) <> path
  end

  def post(url, a, b) do
    case HTTPoison.post(url, a, b) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> body
      _ -> nil
    end
  end

  def get(url, a) do
    case HTTPoison.get(url, a) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> body
      _ -> nil
    end
  end

  def generate_user_console_data(user) do
    "[#{user["username"]}##{user["discriminator"]}/#{user["id"]}]"
  end

  def generate_module_list do
    Application.fetch_env!(:hydrogen, :modules)
    |> recursive_filter()
    |> Jason.encode!()
  end

  def recursive_filter(map) do
    :maps.map(
      fn _, v -> (is_map(v) && recursive_filter(v)) || v end,
      :maps.filter(fn k, _ -> !Kernel.is_atom(k) end, map)
    )
  end

  def flatten_map(map) when is_map(map) do
    map
    |> Map.to_list()
    |> do_flatten([])
    |> Map.new()
  end

  defp do_flatten([], acc), do: acc

  defp do_flatten([{_k, v} | rest], acc) when is_map(v) do
    v = Map.to_list(v)
    flattened_subtree = do_flatten(v, acc)
    do_flatten(flattened_subtree ++ rest, acc)
  end

  defp do_flatten([kv | rest], acc) do
    do_flatten(rest, [kv | acc])
  end

  def has_permission?(guild, owo), do: (guild["permissions"] &&& owo["permissions"]) > 0
end
