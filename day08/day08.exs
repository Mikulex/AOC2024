defmodule Day08 do
  def solve1(file) do
    matrix = parse(file)

    matrix
    |> Enum.with_index(fn line, y ->
      Enum.with_index(line, fn el, x ->
        [el, x, y]
      end)
    end)
    |> Enum.flat_map(&Function.identity/1)
    |> Enum.group_by(&hd/1)
    |> Map.delete(".")
    |> Enum.flat_map(fn {_k, v} -> for a <- v, b <- v, a != b, do: [tl(a), tl(b)] end)
    |> Enum.map(&get_antinode(&1))
    |> Enum.reject(&out_of_bounds?(matrix, &1))
    |> Enum.sort()
    |> Enum.dedup()
    |> length()
  end

  def solve2(_file) do
  end

  def parse(file) do
    File.read!(file)
    |> String.split("\n", trim: true)
    |> Enum.map(fn line -> String.split(line, "", trim: true) end)
  end

  def get_antinode([a, b]) do
    Enum.zip_reduce(a, b, [], fn a_n, b_n, acc -> [b_n - a_n | acc] end)
    |> Enum.reverse()
    |> Enum.zip_reduce(b, [], fn vec, b_n, acc -> [vec + b_n | acc] end)
    |> Enum.reverse()
  end

  def update_matrix(matrix, [[x, y] | tail]) do
    if(Enum.empty?(tail)) do
      List.replace_at(matrix, y, List.replace_at(Enum.at(matrix, y), x, "#"))
    else
      update_matrix(List.replace_at(matrix, y, List.replace_at(Enum.at(matrix, y), x, "#")), tail)
    end
  end

  def out_of_bounds?(matrix, [x, y]),
    do: Enum.any?([x, y], &(&1 not in 0..(length(matrix) - 1)))

  def print_matrix(coords, matrix) do
    coords
    |> then(&update_matrix(matrix, &1))
    |> Enum.map(&Enum.join/1)
    |> Enum.join("\n")
    |> IO.puts()
  end
end

demo = "demo.txt"
input = "input.txt"

IO.inspect(Day08.solve1(demo))
IO.inspect(Day08.solve1(input))
# IO.inspect(Day08.solve2(demo))
# IO.inspect(Day08.solve2(input))
