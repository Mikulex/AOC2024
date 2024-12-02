defmodule Day02 do
  def solve1(file) do
    File.read!(file)
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1))
    |> Enum.map(&Enum.map(&1, fn val -> String.to_integer(val) end))
    |> Enum.count(&Day02.safe?(&1))
  end

  def solve2(file) do
    File.read!(file)
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1))
    |> Enum.map(&Enum.map(&1, fn val -> String.to_integer(val) end))
    |> Enum.count(&Day02.safe_when_dampened?(&1, modified: false, first_visit: true))
  end

  def safe?([head, second, third | tail]) do
    diff = head - second

    cond do
      abs(diff) > 3 -> false
      # decreasing
      diff > 0 && second > third -> safe?([second, third | tail])
      # increasing
      diff < 0 && second < third -> safe?([second, third | tail])
      true -> false
    end
  end

  def safe?([head, second]) do
    abs(head - second) <= 3
  end

  def safe_when_dampened?(list, opts \\ [])

  def safe_when_dampened?([head, second, third | tail], opts) do
    diff = head - second

    # IO.puts("#{head},#{second},#{third},#{opts[:modified]} ")
    # IO.puts("---")

    safe_when_removed = fn ->
      safe_when_dampened?([head, third | tail], modified: true, first_visit: false) ||
        safe_when_dampened?([head, second | tail], modified: true, first_visit: false) ||
        (opts[:first_visit] &&
           safe_when_dampened?([second, third | tail], modified: true, first_visit: false))
    end

    cond do
      abs(diff) > 3 || diff == 0 ->
        if not opts[:modified] do
          safe_when_removed.()
        else
          false
        end

      # decreasing
      head > second ->
        cond do
          second > third ->
            safe_when_dampened?([second, third | tail],
              modified: opts[:modified],
              first_visit: false
            )

          second <= third && not opts[:modified] ->
            safe_when_removed.()

          second <= third && opts[:modified] ->
            false
        end

      # increasing
      head < second ->
        cond do
          second < third ->
            safe_when_dampened?([second, third | tail],
              modified: opts[:modified],
              first_visit: false
            )

          second >= third && not opts[:modified] ->
            safe_when_removed.()

          second >= third && opts[:modified] ->
            false
        end

      true ->
        false
    end
  end

  def safe_when_dampened?([head, second], opts) do
    # if none were modified yet, we can just ignore the last pair
    not opts[:modified] || abs(head - second) <= 3
  end
end

demo = "demo.txt"
input = "input.txt"

IO.inspect(Day02.solve1(demo))
IO.inspect(Day02.solve1(input))
IO.inspect(Day02.solve2(demo))
# IO.inspect(Day02.solve2(input), charlists: :as_lists)
