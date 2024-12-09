defmodule Day09 do
  def solve1(file) do
    parse(file)
    |> compress()
    |> Enum.reject(&match?([:space, _], &1))
    |> Enum.flat_map(fn [id, rep] -> List.duplicate(id, rep) end)
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
      repeat, _idx -> [:space, repeat]
    end)
    |> Enum.reject(fn
      [:space, 0] -> true
      _ -> false
    end)
  end

  def compress(list) do
    {[_, s_rep], s_list_idx} =
      list
      |> Enum.with_index()
      |> Enum.find(fn {[id, _reps], _idx} -> match?(:space, id) end)

    {[f_id, f_rep], f_list_idx} =
      list
      |> Enum.with_index()
      |> Enum.reverse()
      |> Enum.find(fn {[id, _reps], _idx} -> not match?(:space, id) end)

    if(s_list_idx >= f_list_idx or out_of_bounds?(list, [s_list_idx, f_list_idx])) do
      list
    else
      list
      |> List.replace_at(s_list_idx, [:space, s_rep - 1])
      |> List.replace_at(f_list_idx, [f_id, f_rep - 1])
      |> update_list_at(s_list_idx, f_id)
      |> Enum.reject(fn [_, rep] -> rep <= 0 end)
      |> compress()
    end
  end

  def update_list_at(list, s_list_idx, f_id) do
    case Enum.at(list, s_list_idx + 1) do
      [^f_id, rep] -> list |> List.replace_at(s_list_idx + 1, [f_id, rep + 1])
      _ -> list |> List.insert_at(s_list_idx, [f_id, 1])
    end
  end

  def out_of_bounds?(list, [x, y]),
    do: Enum.any?([x, y], &(&1 not in 0..(length(list) - 1)))
end

demo = "demo.txt"
input = "input.txt"

IO.inspect(Day09.solve1(demo))
IO.inspect(Day09.solve1(input))
# IO.inspect(Day08.solve2(demo))
# IO.inspect(Day08.solve2(input))
