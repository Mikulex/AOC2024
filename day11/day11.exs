defmodule Day11 do
  def solve1(file), do: calc(file, 25)

  def solve2(file), do: calc(file, 75)

  def calc(file, n) do
    File.read!(file)
    |> then(&Regex.split(~r/\s/, &1, trim: true))
    |> Enum.frequencies()
    |> blink(n)
  end

  def blink(counts, 0), do: counts |> Map.values() |> Enum.sum()

  def blink(counts, times) do
    counts
    |> Map.keys()
    |> Enum.reduce(%{}, fn old_stone, map ->
      old_stone_count = counts |> Map.get(old_stone)

      apply_rule(old_stone)
      |> Enum.reduce(map, fn new_stone, map_inner ->
        Map.update(map_inner, new_stone, old_stone_count, &(&1 + old_stone_count))
      end)
    end)
    |> blink(times - 1)
  end

  def apply_rule(val) do
    len = String.length(val)
    split? = rem(len, 2) == 0

    cond do
      val == "0" ->
        ["1"]

      split? ->
        String.split_at(val, div(len, 2))
        |> Tuple.to_list()
        |> Enum.map(&String.to_integer/1)
        |> Enum.map(&Integer.to_string/1)

      true ->
        val
        |> String.to_integer()
        |> then(&((&1 * 2024) |> Integer.to_string() |> List.wrap()))
    end
  end
end

demo = "demo.txt"
input = "input.txt"

IO.inspect(Day11.solve1(demo))
IO.inspect(Day11.solve1(input))
IO.inspect(Day11.solve2(demo))
IO.inspect(Day11.solve2(input))
