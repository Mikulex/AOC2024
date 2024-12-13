defmodule Day13 do
  def solve1(file) do
    parse(file)
    |> Enum.map(&solve/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.reduce(0, fn
      {a, b}, acc when a > 100 or b > 100 -> acc
      {a, b}, acc -> acc + (3 * a + b)
    end)
  end

  def solve2(file) do
    parse(file)
    |> Enum.map(fn nums -> List.update_at(nums, 4, &(&1 + 10_000_000_000_000)) end)
    |> Enum.map(fn nums -> List.update_at(nums, 5, &(&1 + 10_000_000_000_000)) end)
    |> Enum.map(&solve/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.reduce(0, fn {a, b}, acc -> acc + (3 * a + b) end)
  end

  def parse(file) do
    File.read!(file)
    |> String.split("\n\n", trim: true)
    |> Enum.map(&String.split(&1, "\n", trim: true))
    |> Enum.map(fn lines -> Enum.flat_map(lines, &Regex.scan(~r/\d+/, &1)) |> List.flatten() end)
    |> Enum.map(fn nums -> Enum.map(nums, &String.to_integer/1) end)
  end

  def det(a, b, c, d), do: a * d - c * b

  def solve([x1, y1, x2, y2, s1, s2]) do
    det_a = det(x1, x2, y1, y2)
    det_i = det(s1, x2, s2, y2)
    det_j = det(x1, s1, y1, s2)

    unless det_a == 0 or rem(det_i, det_a) != 0 or rem(det_j, det_a) != 0 do
      {det_i / det_a, det_j / det_a}
    end
  end
end

demo = "demo.txt"
input = "input.txt"

IO.inspect(Day13.solve1(demo))
IO.inspect(Day13.solve1(input))
IO.inspect(Day13.solve2(demo))
IO.inspect(Day13.solve2(input))
