defmodule StockExchange.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias StockExchange.Stocks.UserFavouriteStock

  schema "users" do
    field :age, :integer
    field :name, :string
    field :email, :string

    has_many :user_stock_options, UserFavouriteStock

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :age, :email])
    |> validate_required([:name, :age, :email])
  end
end
