defmodule Day20 do
  def parse(file) do
    grid =
      File.read!(file)
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, "", trim: true))

    [start, fin] =
      ["S", "E"]
      |> Enum.map(fn c ->
        Enum.with_index(grid, fn line, y ->
          Enum.with_index(line, fn
            ^c, x -> {x, y}
            _, _ -> nil
          end)
        end)
      end)
      |> List.flatten()
      |> Enum.reject(&is_nil/1)

    {grid, start, fin}
  end

  def solve1(file) do
    {grid, start, fin} = parse(file)

    shortest_path(grid, start, %{}, [%{pos: fin, dist: 0, saved: 0}])
    |> Map.new(fn {k, {_, s_dists}} -> {k, s_dists} end)
    |> Map.to_list()
    |> Enum.map(fn {_, v} -> v end)
    |> List.flatten()
    |> Enum.count(&(&1 >= 100))
  end

  def solve2(file) do
    parse(file)
  end

  def shortest_path(grid, fin, visited, [head]) do
    next =
      offsets(head.pos)
      |> Enum.reject(&(get_in_grid(grid, &1) == "#"))
      |> Enum.map(&%{pos: &1, dist: head.dist + 1, saved: 0})
      |> Enum.reject(&(&1.pos in Map.keys(visited)))

    shortcuts =
      shortcuts(head.pos)
      |> Enum.reject(&Enum.any?(&1, fn c -> out_of_bounds?(length(grid), c) end))
      |> Enum.filter(fn [near, far] ->
        get_in_grid(grid, near) == "#" and get_in_grid(grid, far) != "#"
      end)
      |> Enum.filter(fn [_near, far] -> far in Map.keys(visited) end)
      |> Enum.map(fn [_near, far] -> far end)

    s_dists =
      if length(shortcuts) == 0 do
        [0]
      else
        shortcuts
        |> Enum.map(fn s_pos ->
          Map.get(visited, s_pos)
        end)
        |> Enum.map(fn {dist, _s} -> head.dist - dist - 2 end)
      end

    if(head.pos == fin) do
      Map.put(visited, head.pos, {head.dist, s_dists})
    else
      shortest_path(
        grid,
        fin,
        Map.put(visited, head.pos, {head.dist, s_dists}),
        next
      )
    end
  end

  def get_in_grid(grid, {x, y}), do: get_in(grid, [Access.at(y), Access.at(x)])

  def offsets(coords), do: for(x <- -1..1, y <- -1..1, abs(x) != abs(y), do: add({x, y}, coords))

  def shortcuts(coords),
    do:
      for(
        x <- -1..1,
        y <- -1..1,
        abs(x) != abs(y),
        do: [add({x, y}, coords), add({x + x, y + y}, coords)]
      )

  def add({a, b}, {c, d}), do: {a + c, b + d}
  def out_of_bounds?(dim, coords), do: Enum.any?(Tuple.to_list(coords), &(&1 not in 0..(dim - 1)))
end

demo = "demo.txt"
input = "input.txt"

IO.inspect(Day20.solve1(demo))
IO.inspect(Day20.solve1(input))
# IO.inspect(Day20.solve2(demo))
# IO.inspect(Day20.solve2(input))
