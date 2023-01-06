defmodule StockExchangeWeb.StockController do
  use StockExchangeWeb, :controller
  alias StockExchange.Stocks
  action_fallback StockExchangeWeb.FallbackController

  def index(conn, _params) do
    stocks = Stocks.list_ordered_featured_stocks()

    case stocks do
      [_ | _] ->
        conn
        |> put_status(200)
        |> json(stocks)

      _ ->
        conn
        |> put_status(422)
        |> json(%{error: "Something went wrong"})
    end
  end

  def show(conn, %{"user_id" => user_id}) do
    stocks = Stocks.get_favourite_stock_by(user_id)

    case stocks do
      [_ | _] ->
        conn
        |> put_status(200)
        |> json(stocks)

      _ ->
        conn
        |> put_status(422)
        |> json(%{error: "Somehting went wrong"})
    end
  end
end
