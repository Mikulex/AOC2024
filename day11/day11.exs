defmodule Day11 do
  def solve1(file) do
    File.read!(file) |> then(&Regex.split(~r/\s/, &1, trim: true)) |> blink(75) |> length()
  end

  def blink(list, 0), do: list

  def blink(list, times) do
    list
    |> Enum.map(&apply_rule/1)
    |> List.flatten()
    |> blink(times - 1)
  end

  def apply_rule(val) do
    # |> IO.inspect(label: "len")
    len = String.length(val)
    split? = rem(len, 2) == 0

    cond do
      val == "0" ->
        "1"

      split? ->
        # |> IO.inspect(label: "split")
        String.split_at(val, div(len, 2))
        |> Tuple.to_list()
        |> Enum.map(&String.to_integer/1)
        |> Enum.map(&Integer.to_string/1)

      true ->
        val
        |> String.to_integer()
        |> then(&((&1 * 2024) |> Integer.to_string()))

        # |> IO.inspect(label: "mult")
    end
  end
end

demo = "demo.txt"
input = "input.txt"

IO.inspect(Day11.solve1(demo))
IO.inspect(Day11.solve1(input))
