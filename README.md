# StockExchange

## Database design
All stock information received is saved in the `featured_stocks` table. Any stock category that my be of intrest to users are saved in the `stock_options` table, when a user has interest in a given stock category the information is saved on `user_favourite_stocks` table.

## Newly listed companies
  For period check of newly listed companies,the api has a genserver that calls itself with dummy data after some seconds,and save the information on featured_stocks table. For data integrity, a constraint key is set at the `ticker_symbol` column of the stock companies.

## Stock companies published over pubsub
  To test this locally the mock websocket server will have to be started which runs at port 443. This websocket server sends events with a dummy data that is handled by `stock_client_worker`.

## Publishing websocket events to mobile clients
  Once stock companie are received and saved on the database, socket_notification worker will broadcast these events over pubsub. To demonstrate this, open [`outgoing stock`](http://localhost:4000/outgoing-stock/simulation) live view page, which will display the messages once broadcasted.

## Send email updates
  For users who have marked the stock category as favourite,`send_email_worker` will notify them once the stock information is received.

## API endpoints
  There are two api endpoints `/favourite-stocks/:user_id` which list user's favourite stock option, ordered from the latest stock, and `/featured-stocks` which list all companies stock information.


To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
