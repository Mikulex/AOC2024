defmodule Day15 do
  @offsets %{"^" => {0, -1}, "v" => {0, 1}, "<" => {-1, 0}, ">" => {1, 0}}

  def solve1(file) do
    [grid, ins] =
      File.read!(file)
      |> String.split("\n\n", trim: true)
      |> Enum.map(&String.split(&1, "\n", trim: true))
      |> Enum.map(fn part -> Enum.map(part, &String.split(&1, "", trim: true)) end)

    ins = ins |> List.flatten() |> Enum.map(&Map.get(@offsets, &1))

    start =
      grid
      |> Enum.with_index(fn line, y -> Enum.with_index(line, fn el, x -> {el, {x, y}} end) end)
      |> List.flatten()
      |> Enum.find(&match?({"@", _}, &1))
      |> elem(1)
      |> IO.inspect(label: "start")

    [grid, ins]
    |> IO.inspect()
    |> move_robot(start)
    |> calculate_score()
  end

  def calculate_score(grid) do
    grid
    |> Enum.with_index(fn line, y -> Enum.with_index(line, fn el, x -> {el, {x, y}} end) end)
    |> List.flatten()
    |> Enum.reduce(0, fn
      {"O", {x, y}}, acc -> acc + (100 * y + x)
      _, acc -> acc
    end)
  end

  def move_robot([grid, []], _start), do: grid

  def move_robot([grid, [head | tail]], pos) do
    [pos, head] |> IO.inspect(label: "current")

    boxes =
      Stream.iterate(pos, fn c -> add(c, head) end)
      |> Stream.drop(1)
      |> Enum.take_while(fn vec ->
        not out_of_bounds?(grid, vec) and get_in_grid(grid, vec) == "O"
      end)

    last_box = if is_nil(boxes), do: nil, else: List.last(boxes)

    cond do
      is_nil(last_box) ->
        next = add(pos, head)

        if get_in_grid(grid, next) == "." do
          grid
          |> update_grid(pos, ".")
          |> update_grid(next, "@")
          |> then(fn g -> move_robot([g, tail], next) end)
        else
          move_robot([grid, tail], pos)
        end

      get_in_grid(grid, add(last_box, head)) == "#" ->
        move_robot([grid, tail], pos)

      get_in_grid(grid, add(last_box, head)) == "." ->
        grid
        |> update_grid(hd(boxes), "@")
        |> update_grid(pos, ".")
        |> update_grid(add(last_box, head), "O")
        |> then(fn g -> move_robot([g, tail], add(pos, head)) end)
    end
  end

  def out_of_bounds?(grid, {x, y}), do: Enum.any?([x, y], &(&1 not in 0..(length(grid) - 1)))

  def get_in_grid(grid, {x, y}), do: get_in(grid, [Access.at(y), Access.at(x)])

  def update_grid(grid, {x, y}, val),
    do: List.replace_at(grid, y, List.replace_at(Enum.at(grid, y), x, val))

  def add({a, b}, {c, d}), do: {a + c, b + d}
end

demo = "demo.txt"
input = "input.txt"

IO.inspect(Day15.solve1(demo))
IO.inspect(Day15.solve1(input))
