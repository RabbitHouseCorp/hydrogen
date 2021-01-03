defmodule Hydrogen.JWT do
  defp get_key do
    case System.fetch_env("JWT_KEY") do
      {:ok, k} -> %{key: k}
      :error -> %{key: "Ksisb827#9*!#8272UshsjsuhakBwknk"}
    end
  end

  def encode(map) do
     JsonWebToken.sign(map, get_key())
  end

  def decode(jwt) do
    case JsonWebToken.verify(jwt, get_key()) do
      {:ok, claims} -> claims
      {:error, _} -> nil
    end
  end
end