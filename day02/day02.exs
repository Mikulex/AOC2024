defmodule Day02 do
  def solve1(file) do
    parse(file)
    |> Enum.count(&Day02.safe?(&1))
  end

  def solve2(file) do
    parse(file)
    |> Enum.count(&Day02.safe_when_dampened?(&1))
  end

  def parse(file) do
    File.read!(file)
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1))
    |> Enum.map(&Enum.map(&1, fn val -> String.to_integer(val) end))
  end

  def safe?([head, second, third | tail]) do
    diff = head - second

    cond do
      abs(diff) > 3 -> false
      # decreasing
      diff > 0 && second > third -> safe?([second, third | tail])
      # increasing
      diff < 0 && second < third -> safe?([second, third | tail])
      true -> false
    end
  end

  def safe?([head, second]) do
    abs(head - second) <= 3
  end

  def safe_when_dampened?(list, idx \\ 0) do
    cond do
      safe?(Enum.take(list, idx) ++ Enum.drop(list, idx + 1)) ->
        true

      idx < length(list) ->
        safe_when_dampened?(list, idx + 1)

      true ->
        false
    end
  end
end

demo = "demo.txt"
input = "input.txt"

IO.inspect(Day02.solve1(demo))
IO.inspect(Day02.solve1(input))
IO.inspect(Day02.solve2(demo))
IO.inspect(Day02.solve2(input), charlists: :as_lists)
