defmodule StockExchange.EmailFormat do
  use Phoenix.Swoosh, view: StockExchangeWeb.EmailView

  def new_stock_update(user, stocks) do
    new()
    |> to({user.name, user.email})
    |> from({"Bamboo Stock Exchange", "bamboo.stock@example.com"})
    |> subject("Stock Market Production Information")
    |> render_body("stock_template.html", %{username: user.name, stocks: stocks})
  end
end
