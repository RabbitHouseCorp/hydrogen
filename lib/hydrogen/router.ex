defmodule Hydrogen.Router do
  use Plug.Router
  alias Hydrogen.Util
  
  plug :match
  plug CORSPlug
  plug :dispatch
  
  get "/authorize" do
    conn = conn |> Plug.Conn.fetch_query_params()
    
    url = Util.generate_endpoint("/oauth2/authorize?")
    query = case Map.get(conn.params, "state") do
      nil -> %{response_type: "code"}
      w -> %{response_type: "code", state: w}
    end

    conn
    |> Plug.Conn.resp(:found, "")
    |> Plug.Conn.put_resp_header("location", url <> URI.encode_query(Map.merge(Hydrogen.Discord.get_authorization_body(), query)))
  end

  get "/version" do
    send_resp(conn, 200, "hydrogen v1 (plug/cowboy; elixir)")
  end

  get "/redirect" do
    conn = conn
    |> Plug.Conn.fetch_query_params()
    
    token = Hydrogen.Discord.get_tokens_from_conn(conn)
    |> Hydrogen.JWT.encode()

    query = case Map.get(conn.params, "state") do
      nil -> %{token: token}
      w -> %{token: token, state: w}
    end

    Hydrogen.Discord.get_user_data(token) # let's add the user to the cache.
    conn
    |> Plug.Conn.resp(:found, "")
    |> Plug.Conn.put_resp_header("location", Application.fetch_env!(:hydrogen, :final_redirect) <> "?" <> URI.encode_query(query))
  end

  get "/user" do
    token = Plug.Conn.get_req_header(conn, "authorization")
    data = Hydrogen.Discord.get_user_data(List.first(token))
    if data == nil do
      send_resp(conn, 400, "{\"error\": 1}")
    else
      send_resp(conn, 200, data)
    end
  end

  get "/user/guilds" do
    token = Plug.Conn.get_req_header(conn, "authorization")
    data = Hydrogen.Discord.get_user_guilds(List.first(token))
    if data == nil do
      send_resp(conn, 400, "{\"error\": 1}")
    else
      send_resp(conn, 200, data)
    end
  end

  get "/info" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, "{\"cache_size\":"<> Integer.to_string(ConCache.size(:user_cache)) <> "}")
  end

  match _ do
    send_resp(conn, 404, "resource not found.")
  end  
end