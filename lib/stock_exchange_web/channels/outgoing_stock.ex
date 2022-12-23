defmodule StockExchangeWeb.OutgoingStockChannel do
  use Phoenix.Channel

  @impl true
  def join("outgoingstock:latest", _message, socket) do
    IO.inspect(label: "successsfully joined")
    {:ok, socket}
  end

  @impl true
  def handle_in(_event, _payload, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info(_message, socket) do
    {:noreply, socket}
  end
end
