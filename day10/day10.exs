defmodule Day10 do
  def solve(file) do
    matrix = parse(file)

    matrix
    |> get_start_points()
    |> Enum.map(&trace(&1, matrix))
    |> Enum.reduce([p1: 0, p2: 0], fn {set, sum}, acc ->
      acc
      |> Keyword.update(:p1, nil, &(&1 + MapSet.size(set)))
      |> Keyword.update(:p2, nil, &(&1 + sum))
    end)
  end

  def get_start_points(matrix) do
    matrix
    |> Enum.with_index(fn line, y ->
      Enum.with_index(line, fn el, x -> {el, {x, y}} end)
    end)
    |> Enum.flat_map(&Function.identity/1)
    |> Enum.filter(&match?({0, _}, &1))
  end

  def trace(point, matrix, ends \\ MapSet.new(), count \\ 0)

  def trace({9, {x, y}}, _matrix, ends, count), do: {MapSet.put(ends, {x, y}), count + 1}

  def trace({height, {x, y}}, matrix, ends, count) do
    {x, y}
    |> offsets()
    |> Enum.reject(&out_of_bounds?(matrix, &1))
    |> Enum.filter(fn {x_i, y_i} ->
      height + 1 == get_in(matrix, [Access.at!(y_i), Access.at!(x_i)])
    end)
    |> Enum.map(fn coords -> trace({height + 1, coords}, matrix, ends, count) end)
    |> Enum.reduce({MapSet.new(), 0}, fn {map, count}, {acc_m, acc_c} ->
      {MapSet.union(map, acc_m), acc_c + count}
    end)
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

IO.inspect(Day10.solve(demo))
IO.inspect(Day10.solve(input))
