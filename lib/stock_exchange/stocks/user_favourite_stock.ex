defmodule StockExchange.Stocks.UserFavouriteStock do
  use Ecto.Schema
  import Ecto.Changeset

  alias StockExchange.Accounts.User
  alias StockExchange.Stocks.StockOption
  alias StockExchange.Stocks.FeaturedStock

  schema "user_favourite_stocks" do
    belongs_to :user, User, foreign_key: :user_id
    belongs_to :stock_option, StockOption

    timestamps()
  end

  @doc false
  def changeset(favourite_stock_option, attrs) do
    favourite_stock_option
    |> cast(attrs, [:user_id, :stock_option_id])
    |> validate_required([:user_id, :stock_option_id])
  end
end
