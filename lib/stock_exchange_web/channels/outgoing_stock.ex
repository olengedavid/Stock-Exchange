defmodule StockExchangeWeb.OutgoingStockChannel do
  @moduledoc """
    This is the channel that mobile clients join to receive new stock 
    notification via a websocket
  """
  use Phoenix.Channel

  @impl true
  def join("outgoingstock:latest", _message, socket) do
    IO.inspect(label: "successsfully joined")
    {:ok, socket}
  end
end
