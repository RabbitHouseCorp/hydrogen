defmodule Hydrogen.Util do
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
end