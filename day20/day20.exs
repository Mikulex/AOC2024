defmodule Day20 do
  import Bitwise

  def parse(file) do
    File.read!(file)
    |> String.split("\n", trim: true, trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def solve1(file) do
    parse(file)
    |> Enum.map(fn init -> get_secret_at(init, 2000) end)
    |> Enum.sum()
  end

  def get_secret_at(num, 0), do: num

  def get_secret_at(num, n) do
    get_secret_at(next_number(num), n - 1)
  end

  def next_number(number) do
    number = (number * 64) |> bxor(number) |> rem(16_777_216)
    number = div(number, 32) |> bxor(number) |> rem(16_777_216)
    (number * 2048) |> bxor(number) |> rem(16_777_216)
  end
end

demo = "demo.txt"
input = "input.txt"

IO.inspect(Day20.solve1(demo))
IO.inspect(Day20.solve1(input))
