defmodule Day08 do
  def solve1(file) do
    matrix = parse(file)

    matrix
    |> get_sattelite_pairs()
    |> Enum.map(fn pair -> get_antinode_stream(pair) end)
    |> Enum.flat_map(fn nodes -> nodes |> Stream.drop(1) |> Enum.take(1) end)
    |> Enum.reject(&out_of_bounds?(matrix, &1))
    |> Enum.sort()
    |> Enum.dedup()
    |> length()
  end

  def solve2(file) do
    matrix = parse(file)

    matrix
    |> get_sattelite_pairs()
    |> Enum.map(fn pair -> get_antinode_stream(pair) end)
    |> Enum.flat_map(fn nodes ->
      Enum.take_while(nodes, fn node -> not out_of_bounds?(matrix, node) end)
    end)
    |> Enum.sort()
    |> Enum.dedup()
    |> length()
  end

  def get_sattelite_pairs(matrix) do
    matrix
    |> Enum.with_index(fn line, y -> Enum.with_index(line, fn el, x -> [el, x, y] end) end)
    |> Enum.flat_map(&Function.identity/1)
    |> Enum.group_by(&hd/1)
    |> Map.delete(".")
    |> Enum.flat_map(fn {_k, v} -> for a <- v, b <- v, a != b, do: [tl(a), tl(b)] end)
  end

  def parse(file) do
    File.read!(file)
    |> String.split("\n", trim: true)
    |> Enum.map(fn line -> String.split(line, "", trim: true) end)
  end

  def get_antinode_stream([a, b]) do
    vec =
      Enum.zip_reduce(a, b, [], fn a_i, b_i, acc -> [b_i - a_i | acc] end)
      |> Enum.reverse()

    Stream.iterate(b, fn b_n ->
      Enum.zip_reduce(vec, b_n, [], fn vec_i, b_i, acc -> [vec_i + b_i | acc] end)
      |> Enum.reverse()
    end)
  end

  def out_of_bounds?(matrix, [x, y]),
    do: Enum.any?([x, y], &(&1 not in 0..(length(matrix) - 1)))
end

demo = "demo.txt"
input = "input.txt"

IO.inspect(Day08.solve1(demo))
IO.inspect(Day08.solve1(input))
IO.inspect(Day08.solve2(demo))
IO.inspect(Day08.solve2(input))
