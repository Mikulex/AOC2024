defmodule Day01 do
  def solve1(file) do
    sorted_groups(file)
    |> Enum.zip_reduce([], fn [head | tail], acc ->
      [abs(hd(tail) - head) | acc]
    end)
    |> Enum.sum()
  end

  def solve2(file) do
    [head | tail] = sorted_groups(file)
    tail = hd(tail)

    Enum.reduce(head, 0, fn num, acc ->
      acc + num * Enum.count(tail, &(num == &1))
    end)
  end

  def sorted_groups(file) do
    File.read!(file)
    |> String.split("\n")
    |> Enum.filter(&(&1 != ""))
    |> Enum.map(&String.split(&1, "   "))
    |> Enum.map(fn line -> Enum.map(line, &String.to_integer(&1)) end)
    |> group()
    |> Enum.map(&Enum.sort(&1))
  end

  # \\ [] are default arguments, here empty lists
  def group(rem, first \\ [], seconds \\ [])

  def group([head | tail], firsts, seconds) do
    firsts = [hd(head) | firsts]
    seconds = [hd(tl(head)) | seconds]

    group(tail, firsts, seconds)
  end

  def group([], firsts, seconds), do: [firsts, seconds]
end

demo = "demo.txt"
input = "input.txt"

IO.inspect(Day01.solve1(demo))
IO.inspect(Day01.solve1(input))
IO.inspect(Day01.solve2(demo))
IO.inspect(Day01.solve2(input))
