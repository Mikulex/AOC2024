defmodule Day10 do
  def solve1(file) do
    matrix = parse(file)

    matrix
    |> Enum.with_index(fn line, y ->
      Enum.with_index(line, fn el, x -> {el, {x, y}} end)
    end)
    |> Enum.flat_map(&Function.identity/1)
    |> Enum.filter(&match?({0, _}, &1))
    |> Enum.map(&trace(&1, matrix))
    |> Enum.reduce(0, fn map, acc -> acc + MapSet.size(map) end)
  end

  def solve2(_file) do
  end

  def trace({height, {x, y}}, matrix, ends \\ MapSet.new()) do
    cond do
      height == 9 ->
        ends |> MapSet.put({x, y})

      true ->
        {x, y}
        |> offsets()
        |> Enum.reject(&out_of_bounds?(matrix, &1))
        |> Enum.filter(fn {x_i, y_i} ->
          height + 1 == get_in(matrix, [Access.at!(y_i), Access.at!(x_i)])
        end)
        |> Enum.map(fn coords -> {height + 1, coords} end)
        |> Enum.map(fn point -> trace(point, matrix, ends) end)
        |> Enum.reduce(MapSet.new(), fn map, acc -> MapSet.union(map, acc) end)
    end
  end

  def parse(file) do
    File.read!(file)
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
    |> Enum.map(fn line -> Enum.map(line, &String.to_integer/1) end)
  end

  def out_of_bounds?(matrix, {x, y}),
    do: Enum.any?([x, y], &(&1 not in 0..(length(matrix) - 1)))

  def offsets({x, y}),
    do: for(x_i <- -1..1, y_i <- -1..1, abs(x_i - y_i) == 1, do: {x + x_i, y + y_i})
end

demo = "demo.txt"
input = "input.txt"

IO.inspect(Day10.solve1(demo))
IO.inspect(Day10.solve1(input))
# IO.inspect(Day10.solve2(demo))
# IO.inspect(Day10.solve2(input))
