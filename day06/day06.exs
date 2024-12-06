defmodule Day06 do
  def solve1(file) do
    matrix =
      File.read!(file)
      |> String.split("\n", trim: true)
      |> Enum.map(fn line -> String.split(line, "", trim: true) end)

    start =
      matrix
      |> Enum.with_index(fn row, y ->
        Enum.with_index(row, fn el, x -> if(el == "^", do: [x, y]) end)
      end)
      |> Enum.flat_map(&Function.identity/1)
      |> Enum.find(&(&1 != nil))
  end

  def trace(matrix, current, dir \\ :up) do
  end

  def solve2(_file) do
  end
end

demo = "demo.txt"
_input = "input.txt"

IO.inspect(Day06.solve1(demo))
# IO.inspect(Day06.solve1(input))
# IO.inspect(Day06.solve2(demo))
# IO.inspect(Day06.solve2(input))
