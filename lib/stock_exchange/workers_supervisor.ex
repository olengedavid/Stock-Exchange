defmodule StockExchange.WorkerSupervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    Supervisor.init(supervisor_children(), strategy: :one_for_one)
  end

  defp supervisor_children() do
    if Mix.env() == :test do
      []
    else
      [
        {StockExchange.NewCompanyWorker, %{}},
        {StockExchange.SendEmailWorker, %{}},
        {StockExchange.SocketNotificationWorker, %{}}
      ]
    end
  end
end