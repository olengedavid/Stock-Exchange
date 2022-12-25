defmodule StockExchange.Stocks do
  @moduledoc """
  The Stocks context.
  """

  import Ecto.Query, warn: false
  alias StockExchange.Repo

  alias StockExchange.Stocks.{StockOption, FeaturedStock, UserFavouriteStock}
  alias StockExchange.Accounts.User

  def list_featured_stocks() do
    Repo.all(FeaturedStock)
  end

  def list_stock_options() do
    Repo.all(StockOption)
  end

  def get_featured_stock_by_id(id) do
    Repo.get_by(FeaturedStock, %{id: id})
  end

  def get_stock_option(id), do: Repo.get(StockOption, id)

  def get_stock_option_by_name(name) do
    from(so in StockOption, where: so.name == ^name)
  end

  def names_of_all_stock_options() do
    from(so in StockOption, select: so.name)
    |> Repo.all()
  end

  def create_featured_stock(attrs \\ %{}) do
    %FeaturedStock{}
    |> FeaturedStock.changeset(attrs)
    |> Repo.insert!(
      on_conflict: [set: [category: attrs["category"]]],
      conflict_target: :ticker_symbol
    )
  end

  def create_stock_option(attrs \\ %{}) do
    %StockOption{}
    |> StockOption.changeset(attrs)
    |> Repo.insert()
  end

  def create_user_favourite_stock(attrs \\ %{}) do
    %UserFavouriteStock{}
    |> UserFavouriteStock.changeset(attrs)
    |> Repo.insert()
  end

  def update_featured_stock(%FeaturedStock{} = featured_stock, attrs) do
    featured_stock
    |> FeaturedStock.changeset(attrs)
    |> Repo.update()
  end

  def insert_many_featured_stocks(datasets) when is_list(datasets) do
    timestamp = generate_timestamp()

    Repo.transaction(fn ->
      datasets
      |> Stream.map(fn dataset ->
        dataset = Map.put(dataset, :inserted_at, timestamp)
        Map.put(dataset, :updated_at, timestamp)
      end)
      |> Stream.chunk_every(200)
      |> Stream.each(fn maps ->
        Repo.insert_all(FeaturedStock, maps,
          placeholders: %{timestamp: timestamp},
          on_conflict: :nothing
        )
      end)
      |> Stream.run()
    end)
  end

  def insert_many_featured_stocks(dataset) do
    dataset
  end

  def delete_user(%FeaturedStock{} = featured_stock) do
    Repo.delete(featured_stock)
  end

  def change_featured_stock(%FeaturedStock{} = featured_stock, attrs \\ %{}) do
    FeaturedStock.changeset(featured_stock, attrs)
  end

  defp generate_timestamp() do
    NaiveDateTime.utc_now()
    |> NaiveDateTime.truncate(:second)
  end

  def list_ordered_featured_stocks() do
    from(fs in FeaturedStock, order_by: [desc: fs.inserted_at])
    |> Repo.all()
  end

  def user_favourite_stocks_query(stock_options) when is_list(stock_options) do
    from(user in User)
    |> join(:inner, [user], us in assoc(user, :user_stock_options), as: :user_stock)
    |> join(:inner, [_user], fs in FeaturedStock,
      on: fs.category in ^stock_options,
      as: :featured_stock
    )
    |> select([user, featured_stock: fs], %{user: user, featured_stock: fs})
  end

  def get_favourite_stock_by(user_id) do
    from(user in User)
    |> where([user], user.id == ^user_id)
    |> join(:inner, [user], us in assoc(user, :user_stock_options), as: :user_stock)
    |> join(:inner, [_user, user_stock: us], o in assoc(us, :stock_option), as: :stock_option)
    |> join(:inner, [_user, stock_option: o], fs in FeaturedStock,
      on: fs.category == o.name,
      as: :featured_stock
    )
    |> select([_user, featured_stock: fs], fs)
    |> Repo.all()
  end

  def get_inserted_favourite_stocks_email_not_notified() do
    stock_options = names_of_all_stock_options()

    user_favourite_stocks_query(stock_options)
    |> where([featured_stock: fs], fs.email_notified == ^false)
    |> Repo.all()
  end

  def get_users_by_stock_option(option) do
    from(user in User)
    |> join(:inner, [user], us in assoc(user, :user_stock_options), as: :user_stock)
    |> join(:inner, [user_stock: us], so in assoc(us, :stock_option), as: :stock_option)
    |> where([stock_option: so], so.name == ^option)
  end

  def get_stocks_not_socket_notified do
    FeaturedStock
    |> where([fs], fs.socket_notified == ^false)
    |> limit(200)
    |> Repo.all()
  end

  def get_users_for_a_favourite_stock(featured_stock) do
    Repo.all(get_users_by_stock_option(featured_stock.category))
  end

  def update_email_delivered_stocks_status(stocks) do
    stocks
    |> Stream.uniq_by(fn x -> x.featured_stock.id end)
    |> Stream.each(fn x ->
      x.featured_stock
      |> update_featured_stock(%{email_notified: true})
    end)
    |> Stream.run()
  end

  def broadcast(topic, message) do
    Phoenix.PubSub.broadcast(
      StockExchange.PubSub,
      topic,
      message
    )
  end
end
