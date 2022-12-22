defmodule StockExchangeWeb.Simulation.OutgoingStock do
  use StockExchangeWeb, :live_view

  def render(assigns) do
    ~H"""
        <h2> Mobile Notified Stock Information </h2>

        <table>
        <thead>
            <tr>
            <th>Stock Price</th>
            <th>Ticker Symbol</th>
            <th>Category</th>
            <th>Description</th>

            <th></th>
            </tr>
        </thead>
        <tbody id="stock">
            <%= for stock <- @stocks do %>
            <tr id={"stock-#{stock.id}"}>
                <td><%= stock.stock_price %></td>
                <td><%= stock.ticker_symbol %></td>
                <td><%= stock.category %></td>
                <td><%= stock.description%> </td>
                <td> </td>
            </tr>
            <% end %>
        </tbody>
        </table>
    """
  end

  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(StockExchange.PubSub, "outgoingstock:latest")
    {:ok, socket |> assign(:stocks, [])}
  end

  def handle_params(params, _url, socket) do
    IO.inspect(params, label: "received ++++")
    {:noreply, socket}
  end

  def handle_info(message, socket) do
    IO.inspect(message, label: "received ++++")
    {:noreply, socket}
  end
end
