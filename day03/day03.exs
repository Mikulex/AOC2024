defmodule Day03 do
  def solve1(file) do
    Regex.scan(~r/mul\((\d{1,3}),(\d{1,3})\)/, File.read!(file), capture: :all_but_first)
    |> Enum.map(fn pair -> Enum.map(pair, &String.to_integer(&1)) end)
    |> Enum.map(fn pair -> hd(pair) * hd(tl(pair)) end)
    |> Enum.sum()
  end
end

demo = "demo.txt"
input = "input.txt"

IO.inspect(Day03.solve1(demo))
IO.inspect(Day03.solve1(input))
