defmodule Day14 do
  def solve1(file, dimensions) do
    get_vectors(file)
    |> get_robots_at(dimensions, 100)
    |> get_quadrants(dimensions)
    |> Enum.map(&Map.values/1)
    |> Enum.map(&Enum.sum/1)
    |> Enum.product()
  end

  def solve2(file, dimensions) do
    get_vectors(file)
    |> find_symmetry(dimensions)
  end

  def find_symmetry(robots, [width, height], idx \\ 0, treshold \\ 200_000000) do
    idx |> IO.inspect(label: "current")

    freqs =
      robots
      |> get_robots_at([width, height], idx)

    min =
      freqs
      |> get_quadrants([width, height])
      |> Enum.map(&Map.values/1)
      |> Enum.map(&Enum.sum/1)
      |> Enum.product()
      |> IO.inspect(label: "current vals")

    if treshold >= min, do: print(freqs, [width, height])

    find_symmetry(robots, [width, height], idx + 1, treshold)
  end

  def get_robots_at(robots, dimensions, seconds) do
    robots
    |> Enum.map(fn robot -> Enum.at(robot, seconds) end)
    |> Enum.map(fn robot ->
      Enum.zip_reduce(robot, dimensions, [], fn
        i, j, acc when i < 0 and rem(i, j) != 0 ->
          acc ++ [j + rem(i, j)]

        i, j, acc ->
          acc ++ [rem(i, j)]
      end)
    end)
    |> Enum.frequencies()
  end

  def get_quadrants(map, [width, height]) do
    map
    |> Map.reject(fn {[x, y], _v} -> x == div(width, 2) or y == div(height, 2) end)
    |> Map.split_with(fn {[x, _y], _v} -> x > div(width, 2) end)
    |> Tuple.to_list()
    |> Enum.map(fn map -> Map.split_with(map, fn {[_x, y], _v} -> y > div(height, 2) end) end)
    |> Enum.flat_map(fn maps -> Tuple.to_list(maps) end)
  end

  def get_vectors(file) do
    File.read!(file)
    |> String.split("\n", trim: true)
    |> Enum.map(&Regex.scan(~r/-?\d+/, &1))
    |> Enum.map(&List.flatten/1)
    |> Enum.map(&Enum.map(&1, fn i -> String.to_integer(i) end))
    |> Enum.map(&Enum.chunk_every(&1, 2))
    |> Enum.map(fn [coord, [v_x, v_y]] ->
      Stream.iterate(coord, fn [x, y] -> [v_x + x, v_y + y] end)
    end)
  end

  def print(freqs, [w, h]) do
    matrix =
      Stream.repeatedly(fn -> "." end)
      |> Enum.take(w * h)
      |> Enum.chunk_every(w)

    res =
      for {k, v} <- freqs, reduce: matrix do
        acc -> update_matrix(acc, k, v)
      end
      |> Enum.map(fn el -> if is_integer(el), do: Integer.to_string(el), else: el end)
      |> Enum.map_join("\n", &Enum.join/1)

    IO.puts(res)
    File.write("img.txt", res)
    dbg()
    freqs
  end

  def update_matrix(matrix, [x, y], val),
    do: List.replace_at(matrix, y, List.replace_at(Enum.at(matrix, y), x, val))
end

demo = "demo.txt"
input = "input.txt"

IO.inspect(Day14.solve1(demo, [11, 7]))
IO.inspect(Day14.solve1(input, [101, 103]))
IO.inspect(Day14.solve2(input, [101, 103]))
