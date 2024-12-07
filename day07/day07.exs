defmodule Day07 do
  def solve1(file) do
    parse(file)
    |> Enum.filter(&solvable?/1)
    |> Enum.reduce(0, fn [res | _], acc -> res + acc end)
  end

  def solve2(file) do
    parse(file)
    |> Enum.filter(&solvable?(&1, true))
    |> Enum.reduce(0, fn [res | _], acc -> res + acc end)
  end

  def parse(file) do
    File.read!(file)
    |> String.split("\n", trim: true)
    |> Enum.map(fn line -> Regex.split(~r{[:\s]}, line, trim: true) end)
    |> Enum.map(fn eq -> Enum.map(eq, &String.to_integer/1) end)
  end

  def solvable?([res, first, second | tail], concat? \\ false) do
    concat = Enum.join([first, second]) |> String.to_integer()

    if Enum.empty?(tail),
      do: res == first + second or res == first * second or if(concat?, do: res == concat),
      else:
        solvable?([res, first + second | tail], concat?) ||
          solvable?([res, first * second | tail], concat?) ||
          if(concat?, do: solvable?([res, concat | tail], concat?))
  end
end

demo = "demo.txt"
input = "input.txt"

IO.inspect(Day07.solve1(demo))
IO.inspect(Day07.solve1(input))
IO.inspect(Day07.solve2(demo))
IO.inspect(Day07.solve2(input))
