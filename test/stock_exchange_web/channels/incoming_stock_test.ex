# defmodule StockExchangeWeb.IncomingStockChannelTest do
#   use StockExchangeWeb.ChannelCase
#   alias StockExchangeWeb.IncomingStockChannel

#   setup do
#     {:ok, _, socket} =
#       StockExchangeWeb.Socket
#       |> socket("user_id", %{})
#       |> subscribe_and_join(IncomingStockChannel, "incomingstock:latest")

#     %{socket: socket}
#   end

#   test "ping replies with status ok", %{socket: socket} do
#     ref =
#       push(socket, "add", %{
#         "ticker_symbol" => "45t",
#         "stock_price" => 200,
#         "category" => "Real Estate"
#       })

#     assert_reply ref, :ok, %{"ticker_symsbol" => "45t"}
#   end
# end
