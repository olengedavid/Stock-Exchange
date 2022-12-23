defmodule StockExchange.SocketNotificationWorker do
  use GenServer
  alias StockExchange.Stocks
  alias StockExchange.Repo

  @time_interval 1000

  # client

  def start_link(initial_state \\ %{}) do
    GenServer.start(__MODULE__, initial_state, name: __MODULE__)
  end

  # server

  def init(init_state) do
    schedule_work(:fetch_featured_stocks, 20000)
    {:ok, init_state}
  end

  def handle_info(:fetch_featured_stocks, state) do
    stocks = Stocks.get_stocks_not_socket_notified()

    case stocks do
      [] ->
        schedule_work(:fetch_featured_stocks, 1000)
        {:noreply, state}

      [_head | _tail] ->
        send_socket_notifications(stocks)
        schedule_work(:fetch_featured_stocks, 1000)
        {:noreply, state}
    end
  end

  def schedule_work(message, time) do
    Process.send_after(self(), message, time)
  end

  defp send_socket_notifications(stocks) do
    Repo.transaction(fn ->
      stocks
      |> Enum.chunk_every(200)
      |> Enum.each(fn maps ->
        maps
        |> Enum.each(fn featured_stock ->
          with :ok <-
                 Stocks.broadcast("outgoingstock:latest", %{response: featured_stock})
                 |> IO.inspect(label: "brod+++") do
            Stocks.update_featured_stock(featured_stock, %{socket_notified: true})
          end
        end)
      end)
    end)
  end
end
