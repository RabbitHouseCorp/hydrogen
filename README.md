# Hydrogen
Authentication server for Discord bots. 

# Run Hydrogen
- Rename `config/config.exs.example` to `config/config.exs` and fill out everything out need to;
- Run `mix deps.get` to fetch dependencies;
- Run `mix run --no-halt` to start Hydrogen.

This is how to run Hydrogen **without** HTTPS. For HTTPS support, keep reading.

# Important Info/How to implement Hydrogen
## Basic information
**Set a environment var called `JWT_KEY` with a safe passphrase**. Hydrogen needs a safe JWT key to ensure token authenticity.

The JWT token will be returned to the final destination as a query parameter. Watch out for the `token` key. Save it somewhere.

To get user info, create a GET request to `/user` with the given JWT token as the value of the Authentication header. If an error object is returned, the user will have to authorize the application again

To get user guilds, create a GET request to `/user/guilds` with the given JWT token as the value of the Authentication header. If an error object is returned, the user will have to authorize the application again

To authenticate the user, redirect them to `/authorize`. It will automatically generate and redirect them to the Discord OAuth2 authorization link.

Hydrogen caches user data (avatar, guilds, etc). The default TTL is 5s for users and 10s for guilds. You can change it on `lib/hydrogen/application.ex`. For more information, refer to con_cache's documentation.

## CSRF protection
To protect your application against CSRF, generate a random string in your front-end, save it somewhere and append it to the end of the `/authorize` URL as a query parameter value when you redirect them.

Example: `https://oauth.owo.com/redirect?state=your-random-string-here`

Now, at your website again, you'll have a `state` key as a query param in the end of the URL (just like when you redirected them to be authenticated) with the JWT token. Check if the received code matches the one you saved. If it doesn't lmaooooo u got click-jacked.

## HTTPS support
Before using HTTPS, please have a basic knowledge of how HTTPS works. If you know what a certificate is, you should be fine.
Your `config.exs.example` has a link to plug's documentation. It's very friendly even if you have no idea on how to use Elixir. All you gotta do is find out which configuration is the correct one for your certificate. Read the page and you'll know what to do.