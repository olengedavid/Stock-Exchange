defmodule StockExchangeWeb.FallbackController do
  use StockExchangeWeb, :controller

  def call(conn, {:error, error}) do
    conn
    |> put_status(:not_found)
    |> json(error)
  end
end
