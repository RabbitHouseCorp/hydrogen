defmodule Hydrogen.Application do
  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    children = [
      {ConCache, [name: :user_cache, ttl_check_interval: :timer.seconds(1), global_ttl: :timer.seconds(5)]},
      {Plug.Cowboy, scheme: :http, plug: Hydrogen.Router, options: [port: 8080]}
    ]
    
    Logger.info "Hydrogen is R2G."
    opts = [strategy: :one_for_one, name: Hydrogen.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
