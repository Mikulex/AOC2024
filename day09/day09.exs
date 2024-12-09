defmodule Day09 do
  def solve1(file) do
    parse(file)
    |> compress()
    |> Enum.reject(&match?([:space, _], &1))
    |> Enum.flat_map(fn [id, rep] -> for x <- 0..rep, x > 0, do: id end)
    |> Enum.with_index(fn id, idx -> id * idx end)
    |> Enum.sum()
  end

  def solve2(_file) do
  end

  def parse(file) do
    File.read!(file)
    |> String.trim()
    |> String.split("", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index(fn
      repeat, idx when rem(idx, 2) == 0 -> [div(idx, 2), repeat]
      repeat, idx -> [:space, repeat]
    end)
    |> Enum.reject(fn
      [:space, 0] -> true
      _ -> false
    end)
  end

  def compress(list) do
    list |> length() |> IO.inspect(label: "length")

    {[_, s_rep], s_list_idx} =
      list
      |> Enum.with_index()
      |> Enum.find(fn {[id, reps], _idx} -> match?(:space, id) end)
      |> IO.inspect(label: "s_rep, s_idx")

    {[f_id, f_rep], f_list_idx} =
      list
      |> Enum.with_index()
      |> Enum.reverse()
      |> Enum.find(fn {[id, reps], idx} -> not match?(:space, id) end)
      |> IO.inspect(label: "s_rep, s_idx")

    if(
      s_list_idx >= f_list_idx or
        Enum.any?([s_list_idx, f_list_idx], &(&1 not in 0..(length(list) - 1)))
    ) do
      list
    else
      list
      |> List.replace_at(s_list_idx, [:space, s_rep - 1])
      |> List.replace_at(f_list_idx, [f_id, f_rep - 1])
      |> List.insert_at(s_list_idx, [f_id, 1])
      |> Enum.reject(fn [_, rep] -> rep <= 0 end)
      |> compress()
    end
  end
end

demo = "demo.txt"
input = "input.txt"

IO.inspect(Day09.solve1(demo))
IO.inspect(Day09.solve1(input))
# IO.inspect(Day08.solve2(demo))
# IO.inspect(Day08.solve2(input))
