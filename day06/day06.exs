defmodule Day06 do
  defp offsets(), do: %{:up => [0, -1], :down => [0, 1], :left => [-1, 0], :right => [1, 0]}
  defp turns(), do: %{:up => :right, :down => :left, :left => :up, :right => :down}

  def solve1(file) do
    File.read!(file)
    |> String.split("\n", trim: true)
    |> Enum.map(fn line -> String.split(line, "", trim: true) end)
    |> then(fn matrix -> trace(matrix, find_start(matrix)) end)
    |> hd()
    |> List.flatten()
    |> Enum.count(&match?("#", &1))
  end

  def solve2(file) do
    matrix =
      File.read!(file)
      |> String.split("\n", trim: true)
      |> Enum.map(fn line -> String.split(line, "", trim: true) end)

    start = find_start(matrix)

    [_, block_positions] = trace(matrix, start)

    block_positions
    |> Enum.reject(&match?(^start, &1))
    |> Enum.map(fn block -> matrix_with_block(matrix, block) end)
    |> Enum.count(fn matrix -> contains_loop?(matrix, start) end)
  end

  def find_start(matrix) do
    matrix
    |> Enum.with_index(fn row, y ->
      Enum.with_index(row, fn
        "^", x -> [x, y]
        _, _ -> nil
      end)
    end)
    |> Enum.flat_map(&Function.identity/1)
    |> Enum.find(&(&1 != nil))
  end

  def contains_loop?(matrix, [x, y], dir \\ :up, visited \\ MapSet.new()) do
    [n_x, n_y] = new_idx([x, y], dir)

    cond do
      out_of_bounds?(matrix, [n_x, n_y]) ->
        false

      MapSet.member?(visited, [x, y, dir]) ->
        true

      get_in(matrix, [Access.at(n_y), Access.at(n_x)]) == "#" ->
        contains_loop?(matrix, [x, y], Map.get(turns(), dir), MapSet.put(visited, [x, y, dir]))

      true ->
        contains_loop?(
          update_matrix(matrix, [x, y]),
          [n_x, n_y],
          dir,
          MapSet.put(visited, [x, y, dir])
        )
    end
  end

  def trace(matrix, [x, y], dir \\ :up, positions \\ MapSet.new()) do
    [n_x, n_y] = new_idx([x, y], dir)

    cond do
      out_of_bounds?(matrix, [n_x, n_y]) ->
        [update_matrix(matrix, [x, y]), MapSet.put(positions, [x, y]) |> Enum.to_list()]

      get_in(matrix, [Access.at(n_y), Access.at(n_x)]) == "#" ->
        trace(matrix, [x, y], Map.get(turns(), dir), MapSet.put(positions, [x, y]))

      true ->
        trace(
          update_matrix(matrix, [x, y]),
          [n_x, n_y],
          dir,
          MapSet.put(positions, [x, y])
        )
    end
  end

  def new_idx([x, y], dir),
    do: Enum.zip_with([[x, y], Map.get(offsets(), dir)], fn [a, b] -> a + b end)

  def out_of_bounds?(matrix, [x, y]),
    do: Enum.any?([x, y], &(&1 not in 0..(length(matrix) - 1)))

  def update_matrix(matrix, [x, y]),
    do: List.replace_at(matrix, y, List.replace_at(Enum.at(matrix, y), x, "X"))

  def matrix_with_block(matrix, [x, y]) do
    unless out_of_bounds?(matrix, [x, y]) do
      List.replace_at(
        matrix,
        y,
        List.replace_at(Enum.at(matrix, y), x, "#")
      )
    end
  end
end

demo = "demo.txt"
input = "input.txt"

IO.inspect(Day06.solve1(demo))
IO.inspect(Day06.solve1(input))
IO.inspect(Day06.solve2(demo))
IO.inspect(Day06.solve2(input))
