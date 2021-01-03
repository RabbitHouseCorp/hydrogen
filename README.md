# Hydrogen
Authentication server for Discord bots. 

# Run Hydrogen
- Rename `config/config.exs.example` to `config/config.exs` and fill out everything out need to;
- Run `mix deps.get` to fetch dependencies;
- Run `mix run --no-halt` to start Hydrogen.

# Important Info/How to implement Hydrogen
**Set a environment var called `JWT_KEY` with a safe key**. Hydrogen needs a safe JWT key to ensure token authenticity.

The JWT token will be returned to the final destination as a query parameter. Watch out for the `token` key. Save it somewhere.

To get user info, create a GET request to `/user` with the given JWT token as the value of the Authentication header. If an error object is returned, the user will have to authorize the application again

Hydrogen runs under port 8080. If that's going to be a problem, you can edit it on `lib/hydrogen/application.ex`.
Just replace 8080 for whatever port you want. For example:
```elixir
{Plug.Cowboy, scheme: :http, plug: Hydrogen.Router, options: [port: 8080]}
```
```elixir
{Plug.Cowboy, scheme: :http, plug: Hydrogen.Router, options: [port: 3000]}
```

Hydrogen caches user data (avatar, guilds, etc). The default TTL is 5s. You can change it on `lib/hydrogen/application.ex`. For more information, refer to con_cache's documentation.
