defmodule Day02 do
  def solve1(file) do
    File.read!(file)
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1))
    |> Enum.map(&Enum.map(&1, fn val -> String.to_integer(val) end))
    |> Enum.map(&Day02.safe?(&1))
    |> Enum.count(&(&1))
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

  def solve2(file) do
  end

end

demo = "demo.txt"
input = "input.txt"

IO.inspect(Day02.solve1(demo))
IO.inspect(Day02.solve1(input))
