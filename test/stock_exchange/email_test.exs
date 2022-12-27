defmodule StockExchange.EmailTest do
  use StockExchange.DataCase
  use ExUnit.Case, async: true

  alias StockExchange.AccountsFixtures
  alias StockExchange.Stocks
  alias StockExchange.EmailFormat
  import Swoosh.TestAssertions

  test "stock email is successfully sent to the user" do
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

    featured_stock = Stocks.create_featured_stock(featured_stock_attrs)
    email = EmailFormat.new_stock_update(user, featured_stock)
    Swoosh.Adapters.Test.deliver(email, [])

    assert_email_sent(email)
  end
end
