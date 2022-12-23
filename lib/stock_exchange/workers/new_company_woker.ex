defmodule StockExchange.NewCompanyWorker do
  use GenServer
  alias StockExchange.Stocks
  alias StockExchange.SendEmailWorker

  @time_interval 1000

  # client

  def start_link(initial_state \\ %{}) do
    GenServer.start(__MODULE__, initial_state, name: __MODULE__)
  end

  # server

  def init(init_state) do
    schedule_work(:fetch_new_stock_companies, 1)
    {:ok, init_state}
  end

  def handle_info(:fetch_new_stock_companies, state) do
    # fetch list of companies
    # save companies
    # after insertation schedule the work

    companies = [
      %{stock_price: 23.5, category: "IT", ticker_symbol: "123"},
      %{stock_price: 23.5, category: "IT", ticker_symbol: "345"},
      %{stock_price: 23.5, category: "IT", ticker_symbol: "100"}
    ]

    # companies = []
    schedule_work({:save_company, companies}, 1)
    {:noreply, state}
  end

  def handle_info({:save_company, companies}, state) do
    with {:ok, :insert_complete} <- insert_companies(companies) do
      schedule_work(:fetch_new_stock_companies, 10000)
    end

    {:noreply, state}
  end

  def schedule_work(message, time) do
    Process.send_after(self(), message, time)
  end

  defp insert_companies(companies) do
    with {:ok, _} <- Stocks.insert_many_featured_stocks(companies) do
      SendEmailWorker.send_multiple_stock_different_users_email()
      {:ok, :insert_complete}
    else
      _ ->
        {:ok, :insert_complete}
    end
  end
end
