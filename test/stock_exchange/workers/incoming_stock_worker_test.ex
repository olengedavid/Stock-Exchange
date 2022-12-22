defmodule StockExchange.NewCompanyWorkerTest do
  use ExUnit.Case
  use StockExchange.DataCase

  alias StockExchange.NewCompanyWorker

  describe "start_link/1" do
    test "accept an empty map" do
      assert {:ok, _pid} = NewCompanyWorker.start_link(%{})
    end
  end
end
