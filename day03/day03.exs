defmodule Day03 do
  def solve1(file) do
    Regex.scan(~r/mul\((\d{1,3}),(\d{1,3})\)/, File.read!(file), capture: :all_but_first)
    |> Enum.map(fn pair -> Enum.map(pair, &String.to_integer(&1)) end)
    |> Enum.map(fn pair -> hd(pair) * hd(tl(pair)) end)
    |> Enum.sum()
  end

  def solve2(file) do
    regex = ~r/(mul\((\d{1,3}),(\d{1,3})\)|do(?:n't)?\(\))/

    Regex.scan(regex, File.read!(file), capture: :all_but_first)
    |> relevant_values()
    |> Enum.map(fn pair -> Enum.map(pair, &String.to_integer(&1)) end)
    |> Enum.map(fn pair -> hd(pair) * hd(tl(pair)) end)
    |> Enum.sum()
  end

  def relevant_values([head | tail], relevant \\ [], opts \\ [active: true]) do
    token = hd(head)

    case token do
      "do()" ->
        relevant_values(tail, relevant)

      "don't()" ->
        relevant_values(tail, relevant, active: false)

      _ ->
        if opts[:active] do
          relevant_values(tail, [tl(head) | relevant], active: true)
        else
          relevant_values(tail, relevant, active: false)
        end
    end
  end

  def relevant_values([], relevant, _opts), do: relevant
end

demo = "demo.txt"
input = "input.txt"

IO.inspect(Day03.solve1(demo))
IO.inspect(Day03.solve1(input))
IO.inspect(Day03.solve2(demo))
IO.inspect(Day03.solve2(input))
