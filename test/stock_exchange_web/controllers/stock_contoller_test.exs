defmodule StockExchangeWeb.StockControllerTest do
  use StockExchangeWeb.ConnCase
  alias StockExchange.AccountsFixtures
  alias StockExchange.Stocks
  
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

    test "index/2 list all featured stocks", %{
      conn: conn,
      featured_stock_attrs: featured_stock_attrs
    } do
      Stocks.create_featured_stock(featured_stock_attrs)
      conn = get(conn, Routes.stock_path(conn, :index))

      assert [%{}] = json_response(conn, 200)
      assert [%{"category" => "Real Estate"}] = json_response(conn, 200)
    end

    test "show/2 list all user favourite stocks", %{
      conn: conn,
      featured_stock_attrs: featured_stock_attrs,
      user: user
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
      conn = get(conn, Routes.stock_path(conn, :show, user.id))

      assert [%{}] = json_response(conn, 200)
      assert [%{"category" => "Real Estate"}] = json_response(conn, 200)
    end
  end
end
