defmodule Day12 do
  def solve(file) do
    File.read!(file)
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
    |> Enum.with_index(fn line, y ->
      line |> Enum.with_index(fn el, x -> {el, {x, y}} end)
    end)
    |> find_areas()
    |> Enum.map(&update_sides/1)
    |> Enum.map(fn map -> [map_size(map), Map.values(map)] end)
    |> Enum.map(fn [area, vals] ->
      [area, Enum.reduce(vals, [0, 0], fn [perim, side], [ps, ss] -> [ps + perim, ss + side] end)]
    end)
    |> Enum.map(fn [area, [perim, side]] -> [area * perim, area * side] end)
    |> Enum.reduce([0, 0], fn [perim, side], [ps, ss] -> [ps + perim, ss + side] end)
  end

  def update_sides(map) do
    for {{symbol, coords}, perim} <- map, into: %{} do
      corners_list = corners(coords)

      outer_corners =
        Enum.count(corners_list, fn corners ->
          Enum.all?(corners, fn
            {corner_coords, :side} ->
              not Map.has_key?(map, {symbol, corner_coords})

            {_corner_coords, :diag} ->
              true
          end)
        end)

      inner_corners =
        Enum.count(corners_list, fn corners ->
          Enum.all?(corners, fn
            {corner_coords, :side} ->
              Map.has_key?(map, {symbol, corner_coords})

            {corner_coords, :diag} ->
              not Map.has_key?(map, {symbol, corner_coords})
          end)
        end)

      {{symbol, coords}, [perim, inner_corners + outer_corners]}
    end
  end

  def find_areas(matrix, points_to_check \\ nil, coords \\ {0, 0}, areas \\ []) do
    start = get_in_matrix(matrix, coords)
    new_area = flood_fill(matrix, [start])
    areas = [new_area | areas]
    visited = areas |> Enum.flat_map(&Map.keys(&1))

    points_to_check =
      if(!points_to_check, do: matrix |> List.flatten(), else: points_to_check)
      |> Enum.drop_while(fn point -> Enum.any?(visited, &(point == &1)) end)

    case points_to_check do
      [] -> areas
      [{_, next_coords} | tail] -> find_areas(matrix, tail, next_coords, areas)
    end
  end

  def flood_fill(matrix, stack, area \\ %{})
  def flood_fill(_matrix, [], area), do: area

  def flood_fill(matrix, [{symbol, coords} | tail], area) do
    surroundings =
      offsets(coords)
      |> Enum.reject(&out_of_bounds?(matrix, &1))
      |> Enum.map(fn pair -> get_in_matrix(matrix, pair) end)
      |> Enum.filter(fn {type, _} -> type == symbol end)

    free_sides = 4 - length(surroundings)

    surroundings =
      surroundings
      |> Enum.reject(fn point -> Map.has_key?(area, point) or Enum.any?(tail, &(&1 == point)) end)

    flood_fill(
      matrix,
      tail ++ surroundings,
      Map.put(area, {symbol, coords}, free_sides)
    )
  end

  def out_of_bounds?(matrix, coords),
    do: Enum.any?(Tuple.to_list(coords), &(&1 not in 0..(length(matrix) - 1)))

  def get_in_matrix(matrix, {x, y}), do: get_in(matrix, [Access.at(y), Access.at(x)])

  def offsets({x, y}),
    do: for(x_i <- -1..1, y_i <- -1..1, abs(x_i - y_i) == 1, do: {x + x_i, y + y_i})

  def corners({x, y}),
    do:
      for(
        x_i <- -1..1,
        y_i <- -1..1,
        abs(x_i - y_i) != 1,
        x_i != 0,
        do: [
          {{x + x_i, y + y_i}, :diag},
          {{x + x_i - x_i, y + y_i}, :side},
          {{x + x_i, y + y_i - y_i}, :side}
        ]
      )
end

demo = "demo.txt"
input = "input.txt"

IO.inspect(Day12.solve(demo), label: "demo")
IO.inspect(Day12.solve(input), label: "input")
