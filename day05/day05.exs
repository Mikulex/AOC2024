defmodule Day05 do
  def solve1(file) do
    [reqs, data] = prepare_data(file)

    data
    |> Enum.filter(fn list -> is_valid_list?(list, reqs) end)
    |> Enum.map(fn list -> Enum.at(list, div(length(list), 2)) end)
    |> Enum.reduce(0, fn el, acc -> acc + String.to_integer(el) end)
  end

  def solve2(file) do
    [reqs, data] = prepare_data(file)

    data
    |> Enum.filter(fn list -> not is_valid_list?(list, reqs) end)
    |> Enum.map(fn list -> fix_list(list, reqs) end)
    |> Enum.map(fn list -> Enum.at(list, div(length(list), 2)) end)
    |> Enum.reduce(0, fn el, acc -> acc + String.to_integer(el) end)
  end

  def prepare_data(file) do
    [reqs, data] =
      File.read!(file)
      |> String.split("\n\n", trim: true)
      |> Enum.map(&String.split(&1, "\n", trim: true))

    reqs =
      reqs
      |> Enum.map(&String.split(&1, "|"))
      |> Enum.group_by(&hd/1, &List.last/1)

    data =
      data
      |> Enum.map(&String.split(&1, ","))
      |> Enum.map(&Enum.reverse/1)

    [reqs, data]
  end

  def is_valid_list?(list, reqs) do
    list
    |> Enum.map(fn val -> is_valid_value?(list, reqs, val) end)
    |> Enum.all?()
  end

  def is_valid_value?(list, reqs, val) do
    case Map.fetch(reqs, val) do
      :error ->
        true

      {_, vals} ->
        MapSet.disjoint?(
          MapSet.new(vals),
          MapSet.new(Enum.drop_while(list, &(val != &1)))
        )
    end
  end

  def fix_list(list, idx \\ 0, reqs) do
    cond do
      is_valid_list?(list, reqs) or idx >= length(list) ->
        list

      is_valid_value?(list, reqs, Enum.at(list, idx)) ->
        fix_list(list, idx + 1, reqs)

      true ->
        case Map.fetch(reqs, Enum.at(list, idx)) do
          :error ->
            fix_list(list, idx + 1, reqs)

          {_, vals} ->
            # get idx of the first element of the list that is part of the mapping
            new_idx = Enum.find_index(Enum.reverse(list), &(&1 in vals))

            if(new_idx != nil) do
              fix_list(Enum.slide(list, idx, length(list) - new_idx - 1), idx, reqs)
            else
              fix_list(list, idx + 1, reqs)
            end
        end
    end
  end
end

demo = "demo.txt"
input = "input.txt"

IO.inspect(Day05.solve1(demo))
IO.inspect(Day05.solve1(input))
IO.inspect(Day05.solve2(demo))
IO.inspect(Day05.solve2(input))
