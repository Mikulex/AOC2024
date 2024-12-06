defmodule Day06 do
  defp offsets(), do: %{:up => [0, -1], :down => [0, 1], :left => [-1, 0], :right => [1, 0]}
  defp turns(), do: %{:up => :right, :down => :left, :left => :up, :right => :down}

  def solve1(file) do
    matrix =
      File.read!(file)
      |> String.split("\n", trim: true)
      |> Enum.map(fn line -> String.split(line, "", trim: true) end)

    start =
      matrix
      |> Enum.with_index(fn row, y ->
        Enum.with_index(row, fn
          "^", x -> [x, y]
          _, _ -> nil
        end)
      end)
      |> Enum.flat_map(&Function.identity/1)
      |> Enum.find(&(&1 != nil))
      |> IO.inspect(label: "start")

    trace(matrix, start) |> List.flatten() |> Enum.frequencies() |> Map.get("X")
  end

  def trace(matrix, [x, y], dir \\ :up) do
    [n_x, n_y] =
      Enum.zip_with([[x, y], Map.get(offsets(), dir)], fn [a, b] -> a + b end)

    cond do
      Enum.any?([x, y], &(&1 not in 0..(length(matrix) - 1))) ->
        matrix

      get_in(matrix, [Access.at(n_y), Access.at(n_x)]) == "#" ->
        trace(matrix, [x, y], Map.get(turns(), dir))

      true ->
        trace(update_matrix(matrix, [x, y]), [n_x, n_y], dir)
    end
  end

  def update_matrix(matrix, [x, y]),
    do: List.replace_at(matrix, y, List.replace_at(Enum.at(matrix, y), x, "X"))

  def solve2(_file) do
  end
end

demo = "demo.txt"
input = "input.txt"

IO.inspect(Day06.solve1(demo))
IO.inspect(Day06.solve1(input))
# IO.inspect(Day06.solve2(demo))
# IO.inspect(Day06.solve2(input))
