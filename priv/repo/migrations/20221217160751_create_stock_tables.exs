defmodule StockExchange.Repo.Migrations.CreateStockTables do
  use Ecto.Migration

  def change do
    create table("featured_stocks") do
      add :stock_price, :float
      add :ticker_symbol, :string
      add :market_cap, :float
      add :category, :string
      add :location, :string
      add :description, :string
      add :email_notified, :boolean, default: false
      add :socket_notified, :boolean, default: false

      timestamps()
    end

    create table("stock_options") do
      add :name, :string

      timestamps()
    end

    create table("user_favourite_stocks") do
      add :stock_option_id, references("stock_options")
      add :user_id, references("users")

      timestamps()
    end

    create index("user_favourite_stocks", [:user_id, :stock_option_id],
             unique: true,
             name: :unique_stock_option_per_user
           )

    create index("stock_options", [:name], unique: true, name: :unique_stock_option_name)

    create index("featured_stocks", [:ticker_symbol],
             unique: true,
             name: :unique_ticker_symbol
           )
  end
end
