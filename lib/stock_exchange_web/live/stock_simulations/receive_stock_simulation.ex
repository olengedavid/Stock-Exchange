defmodule StockExchangeWeb.Simulation.OutgoingStock do
  @moduledoc """
  This module is for personal test and exploaration, the page joins 'outgoingstock:*' channel 
  and send a stock message that is inputed by a user through a form.
  """
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

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def handle_info(%{response: stock}, socket) do
    {:noreply, socket |> assign(:stocks, [stock | socket.assigns.stocks])}
  end
end
