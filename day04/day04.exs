defmodule Day04 do
  def solve1(file) do
    File.read!(file)
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
    |> xmas_matches()
  end

  def solve2(file) do
    matrix =
      File.read!(file)
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, "", trim: true))

    len = length(matrix)

    patterns =
      for y <- 1..(len - 2), x <- 1..(len - 2), do: mas_patterns(matrix, x, y)

    patterns |> Enum.count(&valid_pattern/1)
  end

  def mas_patterns(matrix, x, y) do
    for y_off <- -1..1, x_off <- -1..1, abs(x_off) == abs(y_off) do
      get_in(matrix, [Access.at(y + y_off), Access.at(x + x_off)])
    end
  end

  def valid_pattern(pattern) do
    case pattern do
      # bottom same
      [a, a, "A", b, b] when (a == "M" or a == "S") and (b == "M" or b == "S") and a != b -> true
      # side same
      [a, b, "A", a, b] when (a == "M" or a == "S") and (b == "M" or b == "S") and a != b -> true
      _ -> false
    end
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

    diag_asc = count_diags(matrix, line_length, :asc)
    diag_desc = count_diags(matrix, line_length, :desc)

    IO.puts("- #{horizontals}, | #{verticals}, / #{diag_asc}, \\ #{diag_desc}")

    horizontals + verticals + diag_asc + diag_desc
  end

  def count_horizontals(list) do
    list
    |> Enum.map(&Enum.chunk_every(&1, 4, 1, :discard))
    |> Enum.map(fn row -> Enum.map(row, &Enum.join/1) end)
    |> List.flatten()
    |> Enum.count(fn word -> word == "XMAS" || word == "SAMX" end)
  end

  def count_diags(matrix, len, sum \\ 0, [x, y] \\ [0, 0], dir) do
    cond do
      y >= len - 3 ->
        sum

      x >= len && dir == :asc ->
        count_diags(matrix, len, sum, [3, y + 1], dir)

      x > len - 4 && dir == :desc ->
        count_diags(matrix, len, sum, [0, y + 1], dir)

      true ->
        count_diags(matrix, len, sum + diagonal_match(matrix, x, y, dir), [x + 1, y], dir)
    end
  end

  def diagonal_match(matrix, x, y, dir) do
    substring =
      if dir == :asc do
        for y_off <- 0..3, x_off <- 0..-3, abs(x_off) == y_off do
          get_in(matrix, [Access.at(y + y_off), Access.at(x + x_off)])
        end
      else
        for y_off <- 0..3, x_off <- 0..3, x_off == y_off do
          get_in(matrix, [Access.at(x + x_off), Access.at(y + y_off)])
        end
      end
      |> Enum.join()

    if Enum.member?(["XMAS", "SAMX"], substring), do: 1, else: 0
  end
end

demo = "demo.txt"
input = "input.txt"

IO.inspect(Day04.solve1(demo))
IO.inspect(Day04.solve1(input))
IO.inspect(Day04.solve2(demo))
IO.inspect(Day04.solve2(input))
