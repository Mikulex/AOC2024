defmodule Day05 do
  def solve1(file) do
    [reqs, data] =
      File.read!(file)
      |> String.split("\n\n", trim: true)
      |> Enum.map(&String.split(&1, "\n", trim: true))

    reqs =
      reqs
      |> Enum.map(&String.split(&1, "|"))
      |> Enum.group_by(&hd/1, &List.last/1)

    data
    |> Enum.map(&String.split(&1, ","))
    |> Enum.map(&Enum.reverse/1)
    |> Enum.filter(fn list -> is_valid_list?(list, reqs) end)
    |> Enum.map(fn list -> Enum.at(list, div(length(list), 2)) end)
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum()
  end

  def is_valid_list?(list, reqs) do
    list
    |> Enum.map(fn val -> is_valid_value?(list, reqs, val) end)
    |> Enum.all?()
  end

  def is_valid_value?(list, reqs, val) do
    case Map.fetch(reqs, val) do
      :error ->
        true

      {_, vals} ->
        MapSet.disjoint?(
          MapSet.new(vals),
          MapSet.new(Enum.drop_while(list, &(val != &1)))
        )
    end
  end

  def solve2(file) do
  end
end

demo = "demo.txt"
input = "input.txt"

IO.inspect(Day05.solve1(demo))
IO.inspect(Day05.solve1(input))
# IO.inspect(Day05.solve2(demo))
# IO.inspect(Day05.solve2(input))
