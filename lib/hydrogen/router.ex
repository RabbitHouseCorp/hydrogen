defmodule Hydrogen.Router do
  use Plug.Router
  use Bitwise
  alias Hydrogen.Util

  @modules_json Hydrogen.Util.generate_module_list()

  plug(:match)
  plug(CORSPlug)
  plug(:dispatch)

  get "/authorize" do
    conn = conn |> Plug.Conn.fetch_query_params()

    url = Util.generate_endpoint("/oauth2/authorize?")

    query =
      case Map.get(conn.params, "state") do
        nil -> %{response_type: "code"}
        w -> %{response_type: "code", state: w}
      end

    conn
    |> Plug.Conn.resp(
      :found,
      "Redirecting you to Discord"
    )
    |> Plug.Conn.put_resp_header(
      "location",
      url <> URI.encode_query(Map.merge(Hydrogen.Discord.get_authorization_body(), query))
    )
  end

  get "/version" do
    send_resp(conn, 200, "hydrogen v1 (plug/cowboy; elixir)")
  end

  get "/redirect" do
    conn = Plug.Conn.fetch_query_params(conn)

    token =
      Hydrogen.Discord.get_tokens_from_conn(conn)
      |> Hydrogen.JWT.encode()

    query =
      case Map.get(conn.params, "state") do
        nil -> %{token: token}
        w -> %{token: token, state: w}
      end

    # populate the cache
    spawn(fn -> Hydrogen.Discord.get_user_data(token) end)

    conn
    |> Plug.Conn.resp(:found, "")
    |> Plug.Conn.put_resp_header(
      "location",
      Application.fetch_env!(:hydrogen, :final_redirect) <> "?" <> URI.encode_query(query)
    )
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
    conn =
      conn
      |> Plug.Conn.fetch_query_params()

    token = Plug.Conn.get_req_header(conn, "authorization")

    data =
      case Map.get(conn.params, "permissions") do
        nil ->
          Jason.decode!(Hydrogen.Discord.get_user_guilds(List.first(token)))

        w ->
          Hydrogen.Discord.get_filtered_user_guilds(
            List.first(token),
            &Hydrogen.Util.has_permission?(&1, %{"permissions" => String.to_integer(w)})
          )
      end

    data =
      case Map.get(conn.params, "chinothere") do
        nil ->
          data

        "true" ->
          :lists.filter(fn d -> Hydrogen.Database.get_by_id("guilds", d["id"]) != nil end, data)
      end

    if data == nil do
      send_resp(conn, 400, "{\"error\": 1}")
    else
      send_resp(conn, 200, Jason.encode!(data))
    end
  end

  get "/info" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(
      200,
      "{\"user_cache_size\":" <>
        Integer.to_string(ConCache.size(:user_cache)) <>
        "," <>
        "\"guild_cache_size\":" <>
        Integer.to_string(ConCache.size(:guild_cache)) <>
        "," <>
        "\"db_cache_size\":" <> Integer.to_string(ConCache.size(:db_cache)) <> "}"
    )
  end

  post "/edit/:collection" do
    {:ok, body, conn} = Plug.Conn.read_body(conn)

    modules = Application.fetch_env!(:hydrogen, :modules)

    r =
      case Map.get(modules, collection) do
        nil ->
          {:error, 422, "invalid collection/not enabled on hydrogen configuration"}

        d ->
          # Let's filter all fields that weren't declared in the configuration file.
          body = Jason.decode!(body)
          # Removes undeclared categories
          body =
            Map.put(body, "set", :maps.filter(fn k, _ -> :maps.is_key(k, d) end, body["set"]))

          # Removes undeclared fields on categories
          body =
            Map.put(
              body,
              "set",
              :maps.map(
                fn k, v ->
                  :maps.filter(fn key, _ -> :maps.is_key(key, d[k]) end, v)
                end,
                body["set"]
              )
            )

          # Removes fields that aren't conformant to the validator function (if any)
          body =
            Map.put(
              body,
              "set",
              :maps.map(
                fn k, v ->
                  :maps.filter(
                    fn key, value ->
                      %{:validator => {module, function}} = d[k][key]
                      :erlang.apply(module, function, [value])
                    end,
                    v
                  )
                end,
                body["set"]
              )
            )

          # Remove empty categories
          body = Map.put(body, "set", :maps.filter(fn _, v -> :maps.size(v) > 0 end, body["set"]))

          {mod, fun} = d[:function]

          if :maps.size(body["set"]) > 0 do
            :erlang.apply(mod, fun, [conn, body, d])
          else
            {:error, 403, "nothing to edit - no valid fields were found"}
          end
      end

    case r do
      {:error, code, body} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(code, Jason.encode!(%{"error" => true, "message" => body}))

      {:ok, body} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(Map.merge(%{"error" => false}, body)))
    end
  end

  get "/modules" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, @modules_json)
  end

  match _ do
    send_resp(conn, 404, "resource not found :( anwyays stream fiona apple")
  end
end
