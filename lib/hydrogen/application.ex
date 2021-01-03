defmodule Hydrogen.Application do
  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    children = [
      con_cache_child_spec(:user_cache, 1, 5),
      con_cache_child_spec(:guild_cache, 2, 10),
      {Plug.Cowboy, scheme: Application.fetch_env!(:hydrogen, :scheme), plug: Hydrogen.Router, options: [port: Application.fetch_env!(:hydrogen, :port)]}
    ]
    
    Logger.info "Hydrogen is R2G."
    opts = [strategy: :one_for_one, name: Hydrogen.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp con_cache_child_spec(name, interval_ttl, global_ttl) do
    Supervisor.child_spec(
      {
        ConCache,
        [
          name: name,
          ttl_check_interval: :timer.seconds(interval_ttl),
          global_ttl: :timer.seconds(global_ttl)
        ]
      },
      id: {ConCache, name}
    )
  end
end
