defmodule Day04 do
  def solve1(file) do
    File.read!(file)
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
    |> xmas_matches()
  end

  def xmas_matches(matrix) do
    horizontals =
      matrix
      |> count_horizontals()

    verticals =
      matrix
      |> Enum.zip_with(&Function.identity/1)
      |> count_horizontals()

    line_length = length(Enum.at(matrix, 0))

    diag_desc =
      matrix |> count_diagonals(line_length)
  end

  def count_horizontals(list) do
    list
    |> Enum.map(&Enum.chunk_every(&1, 4, 1, :discard))
    |> Enum.map(fn row -> Enum.map(row, &Enum.join(&1)) end)
    |> List.flatten()
    |> Enum.count(fn word -> word == "XMAS" || word == "SAMX" end)
  end

  def count_diagonals(matrix, length, total \\ 0, [x, y] \\ [0, 0]) do
    cond do
      x >= length - 3 > count_diagonals(matrix, length, total, {0, y + 1})
      y >= length - 3 > total
    end
  end

  def solve2(file) do
  end
end

demo = "demo.txt"
input = "input.txt"

IO.inspect(Day04.solve1(demo))
# 2387 < x < 2438
# != 2394
IO.inspect(Day04.solve1(input))
# IO.inspect(Day04.solve2(demo))
# IO.inspect(Day04.solve2(input))
