defmodule StockExchange.SocketNotificationWorker do
  @moduledoc """
  This module sends socket notification to 'outgoingstock:latest' websocket channel, 
  which resembles the mobile client
  """
  use GenServer
  alias StockExchange.Stocks
  require Logger
  @time_interval 10000

  # client

  def start_link(initial_state \\ %{}) do
    GenServer.start(__MODULE__, initial_state, name: __MODULE__)
  end

  # server

  def init(init_state) do
    schedule_work(:fetch_featured_stocks, @time_interval)
    {:ok, init_state}
  end

  def handle_info(:fetch_featured_stocks, state) do
    stocks = Stocks.get_stocks_not_socket_notified()

    case stocks do
      [] ->
        schedule_work(:fetch_featured_stocks, @time_interval)
        {:noreply, state}

      [_head | _tail] ->
        send_socket_notifications(stocks)
        schedule_work(:fetch_featured_stocks, @time_interval)
        {:noreply, state}
    end
  end

  @impl true
  def handle_info(msg, state) do
    Logger.debug("Unexpected message in StockExchange.SocketNotificationWorker: #{inspect(msg)}")
    {:noreply, state}
  end

  def schedule_work(message, time) do
    Process.send_after(self(), message, time)
  end

  defp send_socket_notifications(stocks) do
    Task.Supervisor.async_stream_nolink(
      StockExchange.TaskSupervisor,
      stocks,
      fn featured_stock ->
        with :ok <-
               Stocks.broadcast("outgoingstock:latest", %{response: featured_stock}) do
          Stocks.update_featured_stock(featured_stock, %{socket_notified: true})
        end
      end,
      ordered: false,
      max_concurrency: 7
    )
    |> Stream.run()
  end
end
