defmodule StockExchangeWeb.Simulation.IncomingStock do
  @moduledoc """
  This liveview page subscribes to 'incomingstock:latest' channel and 
  displays messages received.
  """
  use StockExchangeWeb, :live_view

  def render(assigns) do
    ~H"""
    <button id="incoming-channel">Join Channel </button>

        <form phx-submit="submit" phx-change="change" id="incoming-stock">
            <label for="stock_price">Stock Price: </label>
            <input type="number" id="stock-price" name="stock_price"> <br>
            <label for="ticker_symbol">Ticker Symbol: </label>
            <input type="text" id="ticker_symbol" name="ticker_symbol"> <br>
            <label for="market_cap">Market Cap: </label>
            <input type="number" id="market_cap" name="market_cap"> <br>
            <label for="category">Category: </label>
            <input type="text" id="category" name="category"> <br>
            <label for="location">Location: </label>
            <input type="text" id="location" name="location"> <br>
            <button type="submit"> Submit </button> 
        </form>
    """
  end

  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(StockExchange.PubSub, "incomingstock:latest")
    {:ok, socket}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def handle_event("submit", params, socket) do
    broadcast("incomingstock:latest", %{"featured_stock" => params})
    {:noreply, socket}
  end

  def handle_event("change", _params, socket) do
    {:noreply, socket}
  end

  defp broadcast(topic, message) do
    Phoenix.PubSub.broadcast(
      StockExchange.PubSub,
      topic,
      message
    )
  end
end
