defmodule Day18 do
  def solve1(file) do
    [towels, patterns] = parse(file)

    patterns |> Enum.count(&is_possible(&1, towels))
  end

  def parse(file) do
    [towels, patterns] =
      File.read!(file)
      |> String.split("\n\n", trim: true)
      |> Enum.map(&String.split(&1, "\n", trim: true))

    towels = towels |> hd |> String.split([",", "\s"], trim: true)
    [towels, patterns]
  end

  def is_possible("", _towels), do: true

  def is_possible(pattern, towels) do
    options = towels |> Enum.filter(&String.starts_with?(pattern, &1))

    if Enum.empty?(options) do
      false
    else
      options
      |> Enum.map(fn option -> String.replace_prefix(pattern, option, "") end)
      |> Enum.any?(fn new_ptrn -> is_possible(new_ptrn, towels) end)
    end
  end
end

demo = "demo.txt"
input = "input.txt"

IO.inspect(Day18.solve1(demo))
IO.inspect(Day18.solve1(input))
