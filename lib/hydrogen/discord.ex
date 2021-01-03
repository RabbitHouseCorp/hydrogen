defmodule Hydrogen.Discord do
  def get_authorization_body do
    %{
      client_id: Application.fetch_env!(:hydrogen, :client_id),
      redirect_url: Application.fetch_env!(:hydrogen, :discord_redirect_url),
      scope: Enum.join(Application.fetch_env!(:hydrogen, :scope), " ")
    }
  end
  
  def get_tokens_from_conn(conn) do
    %{"code" => code} = conn.params
    
    body = Map.merge(get_authorization_body(), %{
      client_secret: Application.fetch_env!(:hydrogen, :client_secret),
      grant_type: "authorization_code",
      code: code
    })
 
    case Hydrogen.Util.post(Hydrogen.Util.generate_endpoint("/oauth2/token"), URI.encode_query(body), [{"Content-Type", "application/x-www-form-urlencoded"}]) do
      nil -> nil
      body ->
        %{"access_token" => ac} = Jason.decode!(body)
        %{access_token: ac}
    end
  end

  def get_user_data(token) do
    case ConCache.get(:user_cache, token) do
      nil -> get_fresh_user_data(token)
      a ->
        ConCache.touch(:user_cache, token) # Refresh TTL
        a
    end
  end

  def get_fresh_user_data(token) do
    case Hydrogen.JWT.decode(token) do
      nil -> nil
      %{:access_token => ac} ->
        case Hydrogen.Util.get(Application.fetch_env!(:hydrogen, :api_endpoint) <> "/users/@me", [{"Authorization", "Bearer " <> ac}]) do
          nil -> nil # nao tem refresh culpe a daniela gc
          d ->
            ConCache.put(:user_cache, token, d)
            d
        end
    end
  end

  def get_user_guilds(token) do
    case ConCache.get(:guild_cache, token) do
      nil -> get_fresh_user_guilds(token)
      a ->
        ConCache.touch(:guild_cache, token) # Refresh TTL
        a
    end
  end

  def get_fresh_user_guilds(token) do
    case Hydrogen.JWT.decode(token) do
      nil -> nil
      %{:access_token => ac} ->
        case Hydrogen.Util.get(Application.fetch_env!(:hydrogen, :api_endpoint) <> "/users/@me/guilds", [{"Authorization", "Bearer " <> ac}]) do
          nil -> nil
          d ->
            ConCache.put(:guild_cache, token, d)
            d
        end
    end
  end
end