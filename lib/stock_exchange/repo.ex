defmodule StockExchange.Repo do
  use Ecto.Repo,
    otp_app: :stock_exchange,
    adapter: Ecto.Adapters.Postgres
end
