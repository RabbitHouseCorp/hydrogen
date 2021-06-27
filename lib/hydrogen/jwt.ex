defmodule Hydrogen.JWT.Token do
  use Joken.Config
end

defmodule Hydrogen.JWT do
  alias Hydrogen.JWT.Token

  def encode(map) do
    Token.generate_and_sign!(map)
  end

  def decode(jwt) do
    case Token.verify_and_validate(jwt) do
      {:ok, claims} -> claims
      {:error, _} -> nil
    end
  end
end
