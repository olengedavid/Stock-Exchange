defmodule StockExchangeWeb.IncomingStockChannel do
  use Phoenix.Channel
  alias StockExchange.Stocks
  alias StockExchange.SendEmailWorker

  @impl true
  def join("incomingstock:latest", _message, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_in("add_stock", payload, socket) when is_map(payload) do
    deliver_email_and_publish_event(payload, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_in(_event, _payload, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info(%{"featured_stock" => payload}, socket) do
    IO.inspect(label: "passing ++>>>><<<<")
    deliver_email_and_publish_event(payload, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_info(%{"stocks" => payload}, socket) when is_list(payload) do
    Stocks.insert_many_featured_stocks(payload)
    {:noreply, socket}
  end

  @impl true
  def handle_info(_message, socket) do
    {:noreply, socket}
  end

  def deliver_email_and_publish_event(payload, socket) do
    featured_stock = Stocks.create_featured_stock(payload)

    with %StockExchange.Stocks.FeaturedStock{} <- featured_stock do
      broadcast("outgoingstock:latest", %{content: featured_stock}) 
      |> IO.inspect(label: "delivered +++>>>>>")
      SendEmailWorker.send_one_stock_different_users_email(featured_stock)
    end
  end

  defp broadcast(topic, message) do
    Phoenix.PubSub.broadcast(
      StockExchange.PubSub,
      topic,
      message
    )
  end
end
