defimpl Jason.Encoder, for: [StockExchange.Stocks.FeaturedStock] do
  def encode(value, opts) do
    value
    |> process_to_json()
    |> Jason.Encode.map(opts)
  end

  def process_to_json(data) do
    data
    |> Map.from_struct()
    |> Map.delete(:__meta__)
    |> Enum.into([])
    |> Enum.reduce([], &remove_unloaded/2)
    |> Enum.into(%{})
  end

  def remove_unloaded({key, %Ecto.Association.NotLoaded{}}, accum) do
    accum |> Keyword.put(key, nil)
  end

  def remove_unloaded({key, %_{__meta__: _} = data_map}, accum) do
    accum |> Keyword.put(key, process_to_json(data_map))
  end

  def remove_unloaded(field, accum), do: accum ++ [field]
end
