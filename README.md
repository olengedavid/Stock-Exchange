# StockExchange

## websocket Testing
  * To test that this server is listening for websocket publication of new stocks, i created a webpage that connects with the server, the  [`page`](http://localhost:4000/outgoing-stock/simulation) has a form that capture stock data and allow for submission, before submitting the data, using the join channel button on the page to connect to the channel that will handle the data. 
  * Once the data is successfully entered, manually feel in the stock options table with required data, this category/name should match the one you entered for the stock, just to help in testing purposes. Additonaly relate this stock category with the user, which means feeling the users and user_favourite_stocks table.
  * For a mobile client demonstration that listen to a websocket, open this [`page`](http://localhost:4000/outgoing-stock/simulation) and repeat the first bulleting, after which the data entered will show on this page.


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
