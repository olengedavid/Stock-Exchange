defmodule StockExchange.SendEmailWorker do
  use GenServer

  alias StockExchange.Stocks
  alias StockExchange.EmailFormat
  # client

  def start_link(initial_state \\ %{}) do
    GenServer.start(__MODULE__, initial_state, name: __MODULE__)
  end

  def send_multiple_stock_different_users_email(element) do
    GenServer.cast(__MODULE__, {:fetch_new_inserted_stocks, element})
  end

  def send_one_stock_different_users_email(featured_stock) do
    GenServer.cast(__MODULE__, {:send_one_stock_emails, featured_stock})
  end

  # server

  @impl true
  def init(init_state \\ %{}) do
    {:ok, init_state}
  end

  @impl true
  def handle_cast({:fetch_new_inserted_stocks, element}, state) do
    featured_stocks = fetch_new_inserted_stocks(element)

    case featured_stocks do
      [] ->
        {:noreply, state}

      _ ->
        state = Map.put(state, :featured_stocks, featured_stocks)
        schedule_work({:send_multiple_stock_emails, featured_stocks}, 1)
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

  @impl true
  def handle_info({:send_multiple_stock_emails, stocks}, state) do
    send_multiple_stock_emails(stocks)
    {:noreply, state}
  end

  def schedule_work(message, time) do
    Process.send_after(self(), message, time)
  end

  defp fetch_new_inserted_stocks(%{"inserted_at" => inserted_at}) do
    Stocks.get_newly_inserted_favourite_stocks(inserted_at)
  end

  defp send_multiple_stock_emails(stocks) do
    grouped_stocks =
      stocks
      |> Enum.group_by(& &1.user.id)

    first_stock = grouped_stocks[1] |> hd()

    with {:ok, :emails_sent} <-
           grouped_stocks
           |> Enum.chunk_every(50)
           |> deliver_multiple_stock_emails(first_stock.user) do
      Stocks.update_email_delivered_stocks_status(stocks)
    end
  end

  defp deliver_multiple_stock_emails([_head | _tail = []] = featured_stocks, user) do
    featured_stocks
    |> Enum.each(fn chunked_stocks ->
      user
      |> EmailFormat.new_stock_update(chunked_stocks)
      |> StockExchange.Mailer.deliver()
    end)

    {:ok, :emails_sent}
  end

  defp deliver_multiple_stock_emails(featured_stocks, user) do
    featured_stocks
    |> Enum.each(fn chunked_stocks ->
      user
      |> EmailFormat.new_stock_update(chunked_stocks)
      |> StockExchange.Mailer.deliver()
    end)
  end

  defp send_one_stock_emails(users, featured_stock) do
    with {:ok, :emails_sent} <-
           users
           |> Enum.chunk_every(50)
           |> deliver_one_stock_emails(featured_stock) do
      Stocks.update_featured_stock(featured_stock, %{email_notified: true})
    end
  end

  defp deliver_one_stock_emails([_head | _tail = []] = users, featured_stock) do
    users
    |> Enum.each(fn chunked_users ->
      chunked_users
      |> Enum.map(fn user ->
        user
        |> EmailFormat.new_stock_update(featured_stock)
        |> StockExchange.Mailer.deliver()
      end)
    end)

    {:ok, :emails_sent}
  end

  defp deliver_one_stock_emails(users, featured_stock) do
    users
    |> Enum.each(fn chunked_users ->
      chunked_users
      |> Enum.map(fn user ->
        user
        |> EmailFormat.new_stock_update(featured_stock)
        |> StockExchange.Mailer.deliver()
      end)
    end)
  end
end
