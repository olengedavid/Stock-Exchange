defmodule StockExchange.Stocks.StockOption do
  use Ecto.Schema
  import Ecto.Changeset

  alias StockExchange.Stocks.UserFavouriteStock

  schema "stock_options" do
    field :name, :string

    has_many :favourite_stock_options, UserFavouriteStock, foreign_key: :stock_option_id
    timestamps()
  end

  @doc false
  def changeset(favourite_stock_option, attrs) do
    favourite_stock_option
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint([:name])
  end
end
