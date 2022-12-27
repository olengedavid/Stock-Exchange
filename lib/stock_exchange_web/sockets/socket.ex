defmodule StockExchangeWeb.Socket do
  use Phoenix.Socket

  channel "incomingstock:*", StockExchangeWeb.IncomingStockChannel
  channel "outgoingstock:*", StockExchangeWeb.OutgoingStockChannel

  @impl Phoenix.Socket
  def connect(_params, %Phoenix.Socket{} = socket, _connecr_info) do
    {:ok, socket}
  end

  @impl Phoenix.Socket
  def id(_socket), do: nil
end
