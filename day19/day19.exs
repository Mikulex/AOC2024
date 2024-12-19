defmodule Day19 do
  use Agent

  def solve1(file) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
    [towels, patterns] = parse(file)

    patterns |> Enum.count(&(is_possible(&1, towels) > 0))
  end

  def solve2(file) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
    [towels, patterns] = parse(file)

    patterns |> Enum.map(&is_possible(&1, towels)) |> Enum.sum()
  end

  def parse(file) do
    [towels, patterns] =
      File.read!(file)
      |> String.split("\n\n", trim: true)
      |> Enum.map(&String.split(&1, "\n", trim: true))

    towels = towels |> hd |> String.split([",", "\s"], trim: true)
    [towels, patterns]
  end

  def is_possible("", _towels), do: 1

  def is_possible(pattern, towels) do
    options = towels |> Enum.filter(&String.starts_with?(pattern, &1))
    cached = Agent.get(__MODULE__, &Map.get(&1, {pattern, towels}))

    cond do
      cached ->
        cached

      Enum.empty?(options) ->
        Agent.update(__MODULE__, &Map.put(&1, {pattern, towels}, 0))
        0

      true ->
        res =
          options
          |> Enum.map(fn option -> String.replace_prefix(pattern, option, "") end)
          |> Enum.map(fn new_ptrn -> is_possible(new_ptrn, towels) end)
          |> Enum.sum()

        Agent.update(__MODULE__, &Map.put(&1, {pattern, towels}, res))
        res
    end
  end
end

demo = "demo.txt"
input = "input.txt"

IO.inspect(Day19.solve1(demo))
IO.inspect(Day19.solve1(input))
IO.inspect(Day19.solve2(demo))
IO.inspect(Day19.solve2(input))
