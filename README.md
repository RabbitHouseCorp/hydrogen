# Hydrogen
Authentication server for Discord bots. 

# Run Hydrogen
- Rename `config/config.exs.example` to `config/config.exs` and fill out everything out need to;
- Run `mix deps.get` to fetch dependencies;
- Run `mix run --no-halt` to start Hydrogen.

# Important Info
Hydrogen runs under port 8080. If that's going to be a problem, you can edit it on `lib/hydrogen/application.ex`.
Just replace 8080 for whatever port you want. For example:
```elixir
{Plug.Cowboy, scheme: :http, plug: Hydrogen.Router, options: [port: 8080]}
```
```elixir
{Plug.Cowboy, scheme: :http, plug: Hydrogen.Router, options: [port: 3000]}
```

Hydrogen caches user data (avatar, guilds, etc). The default TTL is 5s. You can change it on `lib/hydrogen/application.ex`. For more information, refer to con_cache's documentation.
