# This is an utility module to interact with the mongodb driver.
# THIS MODULE IS NOT RESPONSIBLE FOR ENSURING OPERATION INTEGRITY/SECURITY!!1!1! thats the function job xx
defmodule Hydrogen.Database do
  use Bitwise

  def get_by_id(col, id) do
    case ConCache.get(:db_cache, id) do
      "" ->
        ConCache.touch(:db_cache, id)
        nil

      nil ->
        doc =
          Mongo.find(
            :mongoloide,
            col,
            %{
              "_id" => %{"$in" => [id]}
            },
            limit: 1
          )
          |> Enum.to_list()
          |> List.first()

        ConCache.put(:db_cache, id, (doc && doc) || "")
        doc

      doc ->
        ConCache.touch(:db_cache, id)
        doc
    end
  end

  def update(col, doc) do
    # To maximize speed, let's run the update query in another process.
    # Consistency is not an issue since the cache data is updated in the current process.
    spawn(fn ->
      Mongo.update_one(:mongoloide, col, %{"_id" => Map.get(doc, "_id")}, %{"$set": doc})
    end)

    ConCache.update(:db_cache, Map.get(doc, "_id"), fn _ -> {:ok, doc} end)
  end

  def write_guild(conn, body, schema) do
    token = List.first(Plug.Conn.get_req_header(conn, "authorization"))

    case Hydrogen.Discord.get_filtered_user_guilds(
           token,
           fn el ->
             el["id"] == body["id"]
           end
         ) do
      nil -> {:error, 401, "invalid credentials"}
      [] -> {:error, 403, "inexistent guild"}
      [guild | _] -> write_guild_authpass(token, guild, body, schema)
    end
  end

  defp write_guild_authpass(token, guild, body, schema) do
    # We're almost done with the filtering! Let's check what fields we can actually update, given the user's permissions.
    body =
      Map.put(
        body,
        "set",
        :maps.map(
          fn k, v ->
            :maps.filter(
              fn key, _ ->
                Hydrogen.Util.has_permission?(guild, schema[k][key])
              end,
              v
            )
          end,
          body["set"]
        )
      )

    # Finally, the last filter! Now, we're going to flatten the map so we can just pass the $set map to Hydrogen.Util.update/2.
    body =
      Map.put(
        body,
        "set",
        Hydrogen.Util.flatten_map(body["set"])
      )

    case Hammer.check_rate "edit:#{token}",
                      Application.fetch_env!(:hydrogen, :edit_bucket_ms),
                      Application.fetch_env!(:hydrogen, :edit_bucket_amount) do
      {:allow, count} ->
        if :maps.size(body["set"]) > 0 do
          update("guilds", :maps.merge(body["set"], %{"_id" => guild["id"]}))

          {:ok, %{"updated" => true, "count" => count}}
        else
          {:error, 403, "nothing to update; user missing permissions"}
        end

      {:deny, _limit} ->
        {:error, 429, "you're being rate limited 🤡"}
    end
  end
end
