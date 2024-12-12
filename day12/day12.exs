defmodule Day12 do
  def solve1(file) do
    File.read!(file)
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
    |> Enum.with_index(fn line, y ->
      line |> Enum.with_index(fn el, x -> {el, {x, y}} end)
    end)
    |> find_areas()
    |> Enum.reduce(0, fn map, acc ->
      map_size(map) * (map |> Map.values() |> Enum.sum()) + acc
    end)
  end

  def find_areas(matrix, points_to_check \\ nil, coords \\ {0, 0}, areas \\ []) do
    start = get_in_matrix(matrix, coords)
    start |> IO.inspect(label: "current starting point")
    new_area = flood_fill(matrix, [start])
    areas = [new_area | areas]
    visited = areas |> Enum.flat_map(&Map.keys(&1))

    points_to_check =
      if(!points_to_check, do: matrix |> List.flatten(), else: points_to_check)
      |> Enum.filter(fn point -> Enum.all?(visited, &(point != &1)) end)

    case points_to_check do
      [] -> areas
      [{_, next_coords} | tail] -> find_areas(matrix, tail, next_coords, areas)
    end
  end

  def flood_fill(matrix, stack, area \\ %{})
  def flood_fill(_matrix, [], area), do: area

  def flood_fill(matrix, stack, area) do
    {{symbol, coords}, tail} = stack |> List.pop_at(0)

    surroundings =
      offsets(coords)
      |> Enum.reject(&out_of_bounds?(matrix, Tuple.to_list(&1)))
      |> Enum.map(fn pair -> get_in_matrix(matrix, pair) end)
      |> Enum.filter(fn {type, _} -> type == symbol end)

    free_sides = 4 - length(surroundings)

    surroundings =
      surroundings
      |> Enum.reject(fn point -> Map.keys(area) |> Enum.any?(&(&1 == point)) end)
      |> Enum.reject(fn point -> tail |> Enum.any?(&(&1 == point)) end)

    flood_fill(matrix, tail ++ surroundings, Map.put(area, {symbol, coords}, free_sides))
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
IO.inspect(Day12.solve1(input))
