defmodule StockExchange.SendEmailWorker do
  use GenServer

  alias StockExchange.Stocks
  alias StockExchange.EmailFormat
  # client

  def start_link(initial_state \\ %{}) do
    GenServer.start(__MODULE__, initial_state, name: __MODULE__)
  end

  def send_one_stock_different_users_email(featured_stock) do
    GenServer.cast(__MODULE__, {:send_one_stock_emails, featured_stock})
  end

  # server

  @impl true
  def init(init_state \\ %{}) do
    schedule_work(:send_multiple_stock_emails, 2000)
    {:ok, init_state}
  end

  @impl true
  def handle_info(:send_multiple_stock_emails, state) do
    featured_stocks = fetch_new_inserted_stocks()

    case featured_stocks do
      [] ->
        schedule_work(:send_multiple_stock_emails, 5000)
        {:noreply, state}

      _ ->
        send_multiple_stock_emails(featured_stocks)
        schedule_work(:send_multiple_stock_emails, 2000)
        {:noreply, state}
    end
  end

  @impl true

  def handle_cast({:send_one_stock_emails, featured_stock}, socket) do
    users = Stocks.get_users_for_a_favourite_stock(featured_stock)

    case users do
      [] ->
        {:ok, :no_user_for_stock_option}

      [_ | _] ->
        send_one_stock_emails(users, featured_stock)
    end

    {:noreply, socket}
  end

  def schedule_work(message, time) do
    Process.send_after(self(), message, time)
  end

  defp fetch_new_inserted_stocks() do
    Stocks.get_inserted_favourite_stocks_email_not_notified()
  end

  defp send_multiple_stock_emails(stocks) do
    grouped_stocks =
      stocks
      |> Enum.group_by(& &1.user.id)

    first_stock = grouped_stocks[1] |> hd()

    chunked_stocks =
      grouped_stocks
      |> Enum.chunk_every(200)

    chunked_stocks_length = length(chunked_stocks) - 1

    chunked_stocks
    |> Enum.with_index(fn element, index ->
      if chunked_stocks_length == index do
        with {:ok, :emails_sent} <-
               deliver_last_multiple_stock_emails(element, first_stock.user) do
          Stocks.update_email_delivered_stocks_status(stocks)
        end
      else
        deliver_multiple_stock_emails(element, first_stock.user)
      end
    end)
  end

  defp deliver_last_multiple_stock_emails(featured_stocks, user) do
    user
    |> EmailFormat.new_stock_update(featured_stocks)
    |> StockExchange.Mailer.deliver()

    {:ok, :emails_sent}
  end

  defp deliver_multiple_stock_emails(featured_stocks, user) do
    user
    |> EmailFormat.new_stock_update(featured_stocks)
    |> StockExchange.Mailer.deliver()
  end

  defp send_one_stock_emails(users, featured_stock) do
    chunked_users =
      users
      |> Enum.chunk_every(200)

    chunked_users_length = length(chunked_users) - 1

    chunked_users
    |> Enum.with_index(fn element, index ->
      if chunked_users_length == index do
        with {:ok, :emails_sent} <- deliver_last_one_stock_emails(element, featured_stock) do
          Stocks.update_featured_stock(featured_stock, %{email_notified: true})
        end
      else
        deliver_one_stock_emails(element, featured_stock)
      end
    end)
  end

  defp deliver_last_one_stock_emails(users, featured_stock) do
    users
    |> Enum.map(fn user ->
      user
      |> EmailFormat.new_stock_update(featured_stock)
      |> StockExchange.Mailer.deliver()
    end)

    {:ok, :emails_sent}
  end

  defp deliver_one_stock_emails(users, featured_stock) do
    users
    |> Enum.map(fn user ->
      user
      |> EmailFormat.new_stock_update(featured_stock)
      |> StockExchange.Mailer.deliver()
    end)
  end
end
