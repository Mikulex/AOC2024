defmodule Day18 do
  def solve1(file, dim, amount) do
    corr = parse(file) |> Enum.take(amount)

    {head, _visited} =
      shortest_path(corr, dim, {dim - 1, dim - 1}, MapSet.new(), [
        %{pos: {0, 0}, dist: 0, prev: nil}
      ])

    path = backtrack(head, [])

    path
    |> length()
    |> IO.inspect(label: "tiles")

    print(corr, dim, path)
  end

  def parse(file) do
    File.read!(file)
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, ",", trim: true))
    |> Enum.map(fn l -> Enum.map(l, &String.to_integer/1) |> List.to_tuple() end)
  end

  def backtrack(head, path) when head.prev == nil, do: path

  def backtrack(head, path), do: backtrack(head.prev, [head | path])

  def shortest_path(_corr, _dim, fin, visited, [head | _tail]) when head.pos == fin,
    do: {head, visited}

  def shortest_path(corr, dim, fin, visited, [head | tail]) do
    next =
      offsets(head.pos)
      |> Enum.reject(&out_of_bounds?(dim, &1))
      |> Enum.reject(&(&1 in corr))
      |> Enum.map(fn c -> %{pos: c, dist: head.dist + 1, prev: head} end)
      |> Enum.reject(&(&1.pos in visited))

    {known, new} = Enum.split_with(next, fn n -> n.pos in Enum.map(tail, & &1.pos) end)

    tail =
      Enum.reduce(tail, [], fn t, acc ->
        n = Enum.find(known, &(&1.pos == t.pos))

        cond do
          n == nil -> [t | acc]
          t.dist <= n.dist -> [t | acc]
          t.dist > n.dist -> [%{t | dist: n.dist} | acc]
        end
      end)

    shortest_path(
      corr,
      dim,
      fin,
      MapSet.put(visited, head.pos),
      Enum.sort_by(tail ++ new, & &1.dist)
    )
  end

  def print(corr, dim, path) do
    IO.write("\n")

    grid =
      Stream.repeatedly(fn -> "." end)
      |> Enum.take(dim * dim)
      |> Enum.chunk_every(dim)

    grid =
      for c <- corr, reduce: grid do
        acc ->
          update_grid(acc, c, "#{IO.ANSI.cyan()}##{IO.ANSI.default_color()}")
      end

    for c <- path, reduce: grid do
      acc ->
        update_grid(acc, c.pos, "#{IO.ANSI.red()}O#{IO.ANSI.default_color()}")
    end
    |> Enum.map_join("\n", &Enum.join/1)
    |> IO.write()

    IO.write("\n")
  end

  def update_grid(grid, {x, y}, val),
    do: List.replace_at(grid, y, List.replace_at(Enum.at(grid, y), x, val))

  def offsets(coords), do: for(x <- -1..1, y <- -1..1, abs(x) != abs(y), do: add({x, y}, coords))
  def add({a, b}, {c, d}), do: {a + c, b + d}
  def out_of_bounds?(dim, coords), do: Enum.any?(Tuple.to_list(coords), &(&1 not in 0..(dim - 1)))
end

demo = "demo.txt"
input = "input.txt"

IO.inspect(Day18.solve1(demo, 7, 12))
IO.inspect(Day18.solve1(input, 71, 1024))
