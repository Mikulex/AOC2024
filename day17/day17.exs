defmodule Day17 do
  import Bitwise

  def parse(file) do
    File.read!(file)
    |> String.split("\n\n", trim: true)
    |> Enum.map(&String.split(&1, "\n", trim: true))
    |> Enum.map(fn section ->
      Enum.map(section, &Regex.scan(~r/\d+/, &1, trim: true))
      |> List.flatten()
      |> Enum.map(&String.to_integer/1)
    end)
  end

  def solve1(file) do
    [[a, b, c], prog] = parse(file)

    run(%{a: a, b: b, c: c}, prog, 0, [], :part1) |> Enum.join(",")
  end

  def solve2(file) do
    [_, prog] = parse(file)

    possible =
      for i <- (length(prog) - 1)..0, reduce: [0] do
        valid_for_slice ->
          Enum.flat_map(valid_for_slice, fn a ->
            Stream.from_index(a * 8)
            |> Stream.take(8)
            |> Enum.filter(fn idx ->
              output = run(%{a: idx, b: 0, c: 0}, prog, 0, [], :part2)
              output == Enum.drop(prog, i)
            end)
          end)
      end

    Enum.min(possible)
  end

  def run(data, prog, ip, output, part) when ip >= length(prog), do: Enum.reverse(output)

  def run(data, prog, ip, output, part) do
    op = Enum.at(prog, ip + 1)

    case Enum.at(prog, ip) do
      0 ->
        run(%{data | :a => div(data[:a], 2 ** combo_op(data, op))}, prog, ip + 2, output, part)

      1 ->
        run(%{data | :b => bxor(data[:b], op)}, prog, ip + 2, output, part)

      2 ->
        run(%{data | :b => rem(combo_op(data, op), 8)}, prog, ip + 2, output, part)

      3 ->
        run(data, prog, if(data[:a] != 0, do: op, else: ip + 2), output, part)

      4 ->
        run(%{data | :b => bxor(data[:b], data[:c])}, prog, ip + 2, output, part)

      5 ->
        run(data, prog, ip + 2, [rem(combo_op(data, op), 8) | output], part)

      6 ->
        run(%{data | :b => div(data[:a], 2 ** combo_op(data, op))}, prog, ip + 2, output, part)

      7 ->
        run(%{data | :c => div(data[:a], 2 ** combo_op(data, op))}, prog, ip + 2, output, part)
    end
  end

  def combo_op(data, op) do
    case op do
      val when val < 4 -> val
      4 -> data[:a]
      5 -> data[:b]
      6 -> data[:c]
    end
  end
end

demo = "demo.txt"
input = "input.txt"

IO.inspect(Day17.solve1(demo))
IO.inspect(Day17.solve1(input))
IO.inspect(Day17.solve2(input))
