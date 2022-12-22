defmodule StockExchange.Stocks.FeaturedStock do
  use Ecto.Schema
  import Ecto.Changeset

  schema "featured_stocks" do
    field :stock_price, :float
    field :ticker_symbol, :string
    field :market_cap, :float
    field :category, :string
    field :location, :string
    field :description, :string
    field :email_notified, :boolean
    field :socket_notified, :boolean

    timestamps()
  end

  @doc false
  def changeset(featured_stock, attrs) do
    featured_stock
    |> cast(attrs, [
      :stock_price,
      :ticker_symbol,
      :market_cap,
      :category,
      :location,
      :email_notified,
      :socket_notified
    ])
    |> validate_required([:ticker_symbol])
    |> unique_constraint(:ticker_symbol)
  end
end
