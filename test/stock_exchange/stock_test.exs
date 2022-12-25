defmodule StockExchange.StocksTest do
  use StockExchange.DataCase
  alias StockExchange.Stocks
  alias StockExchange.AccountsFixtures
  alias StockExchange.Repo

  describe "stocks" do
    setup do
      user = AccountsFixtures.user_fixture()

      featured_stock_attrs = %{
        stock_price: 226_262,
        ticker_symbol: "34R",
        market_cap: 368_829,
        category: "Real Estate",
        Location: "New York",
        description: "Good stock",
        socket_notified: false,
        email_notified: true
      }

      [
        user: user,
        featured_stock_attrs: featured_stock_attrs
      ]
    end

    test "create_featured_stock/1 create stock with valid attributes", %{
      featured_stock_attrs: featured_stock_attrs
    } do
      featured_stock = Stocks.create_featured_stock(featured_stock_attrs)
      assert featured_stock.stock_price == featured_stock_attrs.stock_price
      assert featured_stock.ticker_symbol == featured_stock_attrs.ticker_symbol
      assert featured_stock.category == featured_stock_attrs.category
    end

    test "create_featured_stock/1 does not insert mutiple records with the same attrs", %{
      featured_stock_attrs: featured_stock_attrs
    } do
      Stocks.create_featured_stock(featured_stock_attrs)
      Stocks.create_featured_stock(featured_stock_attrs)

      featured_stocks_count = Repo.all(StockExchange.Stocks.FeaturedStock) |> Enum.count()

      assert featured_stocks_count == 1
    end

    test "update_featured_stock/2 update featured stock with correct attributes", %{
      featured_stock_attrs: featured_stock_attrs
    } do
      featured_stock = Stocks.create_featured_stock(featured_stock_attrs)
      {:ok, updated_stock} = Stocks.update_featured_stock(featured_stock, %{email_notified: true})

      assert updated_stock.email_notified == true
    end

    test "create_stock_option/2 create stock option with valid attribute" do
      {:ok, stock_option} = Stocks.create_stock_option(%{name: "Real Estate"})
      assert stock_option.name == "Real Estate"
    end

    test "create_user_favourite/3 create user favourite stock with valid attrs", %{user: user} do
      {:ok, stock_option} = Stocks.create_stock_option(%{name: "Real Estate"})

      {:ok, user_favourite_stock} =
        Stocks.create_user_favourite_stock(%{user_id: user.id, stock_option_id: stock_option.id})

      assert user_favourite_stock.user_id == user.id
      assert user_favourite_stock.stock_option_id == stock_option.id
    end

    test "get_favourite_stock_by/1 fetches users favourite stock", %{
      user: user,
      featured_stock_attrs: featured_stock_attrs
    } do
      {:ok, stock_option} = Stocks.create_stock_option(%{name: "Real Estate"})
      Stocks.create_user_favourite_stock(%{user_id: user.id, stock_option_id: stock_option.id})
      Stocks.create_featured_stock(featured_stock_attrs)

      attrs = %{
        stock_price: 226_262,
        ticker_symbol: "700R",
        market_cap: 368_829,
        category: "Technology"
      }

      Stocks.create_featured_stock(attrs)

      stocks = Stocks.get_favourite_stock_by(user.id)
      stock = hd(stocks)

      assert Enum.count(stocks) == 1
      assert stock.category == "Real Estate"
      refute stock.category == "Technology"
    end

    test "list_ordered_featured_stocks/ fetches featured stocks ordered in descending order", %{
      featured_stock_attrs: featured_stock_attrs
    } do
      last_inserted_stock = Stocks.create_featured_stock(featured_stock_attrs)

      attrs = %{
        stock_price: 226_262,
        ticker_symbol: "800R",
        market_cap: 368_829,
        category: "Technology",
        inserted_at: ~N[2022-12-25 10:01:12]
      }

      Stocks.create_featured_stock(attrs)

      stocks = Stocks.list_ordered_featured_stocks()
      stock = hd(stocks)

      assert Enum.count(stocks) == 2
      assert stock.id == last_inserted_stock.id
    end
  end
end
