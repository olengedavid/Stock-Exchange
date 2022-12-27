defmodule StockExchangeWeb.IncomingStockChannelTest do
  use StockExchangeWeb.ChannelCase
  alias StockExchangeWeb.IncomingStockChannel

  setup do
    {:ok, _, socket} =
      StockExchangeWeb.Socket
      |> socket("user_id", %{})
      |> subscribe_and_join(IncomingStockChannel, "incomingstock:latest")

    %{socket: socket}
  end


end
