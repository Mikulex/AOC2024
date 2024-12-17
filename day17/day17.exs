defmodule Day17 do
  import Bitwise

  def solve1(file) do
    [[a, b, c], prog] =
      File.read!(file)
      |> String.split("\n\n", trim: true)
      |> Enum.map(&String.split(&1, "\n", trim: true))
      |> Enum.map(fn section ->
        Enum.map(section, &Regex.scan(~r/\d+/, &1, trim: true))
        |> List.flatten()
        |> Enum.map(&String.to_integer/1)
      end)

    data = %{a: a, b: b, c: c}
    [data, output] = run(data, prog, 0, [])
    [data, output |> Enum.join(",")]
  end

  def run(data, prog, ip, output) do
    opcode = Enum.at(prog, ip)
    op = Enum.at(prog, ip + 1)

    case opcode do
      nil ->
        [data, Enum.reverse(output)]

      0 ->
        run(%{data | :a => div(data[:a], 2 ** combo_op(data, op))}, prog, ip + 2, output)

      1 ->
        run(%{data | :b => bxor(data[:b], op)}, prog, ip + 2, output)

      2 ->
        run(%{data | :b => rem(combo_op(data, op), 8)}, prog, ip + 2, output)

      3 ->
        run(data, prog, if(data[:a] != 0, do: op, else: ip + 2), output)

      4 ->
        run(%{data | :b => bxor(data[:b], data[:c])}, prog, ip + 2, output)

      5 ->
        run(data, prog, ip + 2, [rem(combo_op(data, op), 8) | output])

      6 ->
        run(%{data | :b => div(data[:a], 2 ** combo_op(data, op))}, prog, ip + 2, output)

      7 ->
        run(%{data | :c => div(data[:a], 2 ** combo_op(data, op))}, prog, ip + 2, output)
    end
  end

  def combo_op(data, op) do
    case op do
      0 -> 0
      1 -> 1
      2 -> 2
      3 -> 3
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
# IO.inspect(Day17.solve2(demo))
# IO.inspect(Day17.solve2(input))
