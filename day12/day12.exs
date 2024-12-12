defmodule Day12 do
  def solve1(file) do
    indexed_matrix =
      File.read!(file)
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, "", trim: true))
      |> Enum.with_index(fn line, y ->
        line |> Enum.with_index(fn el, x -> {el, {x, y}} end)
      end)

    first = get_in_matrix(indexed_matrix, {0, 0})
    flood_fills(indexed_matrix, [first])
  end

  def flood_fills(matrix, [{symbol, coords} | tail], current_area \\ [], areas \\ []) do
    surroundings =
      offsets(coords)
      |> Enum.reject(&out_of_bounds?(matrix, Tuple.to_list(&1)))
      |> Enum.map(fn pair -> get_in_matrix(matrix, pair) end)
  end

  def out_of_bounds?(matrix, coords),
    do: Enum.any?(coords, &(&1 not in 0..(length(matrix) - 1)))

  def get_in_matrix(matrix, {x, y}), do: get_in(matrix, [Access.at(y), Access.at(x)])

  def offsets({x, y}),
    do: for(x_i <- -1..1, y_i <- -1..1, abs(x_i - y_i) == 1, do: {x + x_i, y + y_i})
end

demo = "demo.txt"
input = "input.txt"

IO.inspect(Day12.solve1(demo))
# IO.inspect(Day12.solve1(input))
