defmodule Day02 do
  def solve1(file) do
    File.read!(file)
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1))
    |> Enum.map(&Enum.map(&1, fn val -> String.to_integer(val) end))
    |> Enum.count(&Day02.safe?(&1))
  end

  def solve2(file) do
    File.read!(file)
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1))
    |> Enum.map(&Enum.map(&1, fn val -> String.to_integer(val) end))
    |> Enum.filter(&(not Day02.safe_when_dampened?(&1, modified: false)))
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

  def safe_when_dampened?(list, keywords \\ [])
  def safe_when_dampened?([head, second, third | tail], keywords) do
    diff = head - second
    cond do
      (abs(diff) > 3 || diff == 0) ->
        if not keywords[:modified] do
          safe_when_dampened?([head, third | tail], modified: true) || safe_when_dampened?([head, second | tail], modified: true)
        else
          false
        end
      # decreasing
      head > second -> cond do
        second > third ->safe_when_dampened?([second, third | tail], modified: keywords[:modified])
        second <= third && not keywords[:modified] -> safe_when_dampened?([head, third | tail], modified: true) || safe_when_dampened?([head, second | tail], modified: true)

        second <= third && keywords[:modified] -> false
      end
      # increasing
      head < second -> cond do
        second < third -> safe_when_dampened?([second, third | tail], modified: keywords[:modified])
        second >= third && not keywords[:modified] -> safe_when_dampened?([head, third | tail], modified: true) || safe_when_dampened?([head, second | tail], modified: true)

        second >= third && keywords[:modified] -> false
      end
      true -> false
    end
  end

  def safe_when_dampened?([head, second], keywords) do
    # if none were modified yet, we can just ignore the last pair
    if not keywords[:modified] do 
      true
    else 
      abs(head - second) <= 3
    end
  end
end

demo = "demo.txt"
input = "input.txt"

IO.inspect(Day02.solve1(demo))
IO.inspect(Day02.solve1(input))
IO.inspect(Day02.solve2(demo))
IO.inspect(Day02.solve2(input), charlists: :as_lists)
