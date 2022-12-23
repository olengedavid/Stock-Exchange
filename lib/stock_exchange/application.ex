defmodule StockExchange.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      StockExchange.Repo,
      # Start the Telemetry supervisor
      StockExchangeWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: StockExchange.PubSub},
      # Start the Endpoint (http/https)
      StockExchangeWeb.Endpoint,
      # Start a worker by calling: StockExchange.Worker.start_link(arg)

      StockExchange.WorkerSupervisor
      # StockExchange.Worker.start_link()
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: StockExchange.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    StockExchangeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
