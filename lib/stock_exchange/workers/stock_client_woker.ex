defmodule StockExchange.StockClientWorker do
  @moduledoc """
    This module is the websocket client that receives events from external stock api provider 
  """
  use WebSockex

  alias StockExchange.Stocks
  alias StockExchange.SendEmailWorker

  def start_link(state) do
    websocket_url = Application.fetch_env!(:stock_exchange, :websocket_url)

    WebSockex.start_link(websocket_url, __MODULE__, state, handle_initial_conn_failure: true)
  end

  @impl true
  def handle_disconnect(%{reason: %WebSockex.ConnError{original: :econnrefused}}, state) do
    {:reconnect, state}
  end

  @impl true
  def handle_frame({:text, payload}, state) do
    case response = Jason.decode!(payload) do
      %{} ->
        deliver_email_and_publish_event(response)
        {:ok, state}

      [_ | _] ->
        Stocks.insert_many_featured_stocks(response)
        {:ok, state}
    end
  end

  def deliver_email_and_publish_event(payload) do
    featured_stock = Stocks.create_featured_stock(payload)

    with %StockExchange.Stocks.FeaturedStock{} <- featured_stock do
      with :ok <- Stocks.broadcast("outgoingstock:latest", %{response: featured_stock}) do
        Stocks.update_featured_stock(featured_stock, %{socket_notified: true})
      end

      SendEmailWorker.send_one_stock_different_users_email(featured_stock)
    end
  end

  def convert_to_atom_keys(maps) do
    maps
    |> Enum.map(fn map ->
      for {key, val} <- map, into: %{}, do: {String.to_atom(key), val}
    end)
  end
end
