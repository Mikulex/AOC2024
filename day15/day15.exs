defmodule Day15 do
  @offsets %{"^" => {0, -1}, "v" => {0, 1}, "<" => {-1, 0}, ">" => {1, 0}}

  def solve1(file) do
    [grid, ins] =
      File.read!(file)
      |> String.split("\n\n", trim: true)
      |> Enum.map(&String.split(&1, "\n", trim: true))
      |> Enum.map(fn part -> Enum.map(part, &String.split(&1, "", trim: true)) end)

    ins = ins |> List.flatten() |> Enum.map(&Map.get(@offsets, &1))

    start = find_start(grid)

    [grid, ins]
    |> move_robot(start)
    |> calculate_score()
  end

  def solve2(file) do
    [grid, ins] =
      File.read!(file)
      |> String.split("\n\n", trim: true)

    grid =
      grid
      |> String.replace(["#", "O", ".", "@"], fn
        "#" -> "##"
        "O" -> "[]"
        "." -> ".."
        "@" -> "@."
      end)
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, "", trim: true))

    ins =
      ins
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, "", trim: true))
      |> List.flatten()
      |> Enum.map(&Map.get(@offsets, &1))

    start = find_start(grid)

    [grid, ins]
    |> move_robot(start)
    |> calculate_score()
  end

  def find_start(grid) do
    grid
    |> Enum.with_index(fn line, y -> Enum.with_index(line, fn el, x -> {el, {x, y}} end) end)
    |> List.flatten()
    |> Enum.find(&match?({"@", _}, &1))
    |> elem(1)
  end

  def calculate_score(grid) do
    grid
    |> Enum.with_index(fn line, y -> Enum.with_index(line, fn el, x -> {el, {x, y}} end) end)
    |> List.flatten()
    |> Enum.reduce(0, fn
      {"O", {x, y}}, acc -> acc + (100 * y + x)
      {"[", {x, y}}, acc -> acc + (100 * y + x)
      _, acc -> acc
    end)
  end

  def move_robot([grid, []], _start), do: grid

  def move_robot([grid, [head | tail]], pos) do
    boxes =
      Stream.iterate(pos, fn c -> add(c, head) end)
      |> Stream.drop(1)
      |> Enum.take_while(fn vec ->
        Enum.any?(["O", "[", "]"], &(get_in_grid(grid, vec) == &1))
      end)

    next = add(pos, head)

    cond do
      is_nil(boxes) or Enum.empty?(boxes) ->
        move_without_box(grid, pos, next, tail)

      # Part 1
      get_in_grid(grid, List.last(boxes)) == "O" ->
        move_box_in_line(grid, head, tail, pos, next, boxes)

      # Part 2
      Enum.any?(["[", "]"], &(get_in_grid(grid, List.last(boxes)) == &1)) ->
        case head do
          # no vertical movement -> just push
          {_x, 0} ->
            move_box_in_line(grid, head, tail, pos, next, boxes)

          # vertical movement
          {0, _y} ->
            first = hd(boxes)

            large_boxes =
              case get_in_grid(grid, first) do
                "[" ->
                  find_boxes(grid, head, [[first, add(first, {1, 0})]])

                "]" ->
                  find_boxes(grid, head, [[add(first, {-1, 0}), first]])
              end

            case large_boxes do
              nil ->
                move_robot([grid, tail], pos)

              _ ->
                grid =
                  Enum.reduce(large_boxes, grid, fn boxes, acc ->
                    Enum.reduce(boxes, acc, fn box, inner_acc ->
                      inner_acc
                      |> update_grid(add(box, head), get_in_grid(grid, box))
                      |> update_grid(box, ".")
                    end)
                  end)
                  |> update_grid(pos, ".")
                  |> update_grid(next, "@")
                  |> then(fn g -> move_robot([g, tail], next) end)
            end
        end
    end
  end

  def find_boxes(grid, dir, [cur_row | tail]) do
    next_row_small = cur_row |> Enum.map(&add(&1, dir))
    {min, y} = hd(next_row_small)
    {max, _} = List.last(next_row_small)

    cond do
      next_row_small |> Enum.any?(&(get_in_grid(grid, &1) == "#")) ->
        nil

      next_row_small |> Enum.all?(&(get_in_grid(grid, &1) == ".")) ->
        [cur_row | tail]

      true ->
        next_row =
          Stream.iterate({min - 1, y}, fn v -> add(v, {1, 0}) end)
          |> Enum.take_while(fn {xi, _yi} -> xi <= max + 1 end)
          |> Enum.filter(fn box ->
            Enum.any?(["[", "]"], &(get_in_grid(grid, box) == &1))
          end)

        next_row =
          if get_in_grid(grid, hd(next_row)) == "]", do: tl(next_row), else: next_row

        next_row =
          if get_in_grid(grid, List.last(next_row)) == "[",
            do: List.delete_at(next_row, length(next_row) - 1),
            else: next_row

        find_boxes(grid, dir, [next_row, cur_row | tail])
    end
  end

  def move_without_box(grid, pos, next, ins) do
    # robot blocked?
    if get_in_grid(grid, next) == "." do
      grid
      |> update_grid(pos, ".")
      |> update_grid(next, "@")
      |> then(fn g -> move_robot([g, ins], next) end)
    else
      move_robot([grid, ins], pos)
    end
  end

  def move_box_in_line(grid, dir, ins, pos, next, boxes) do
    last_box = List.last(boxes)

    case get_in_grid(grid, add(last_box, dir)) do
      "#" ->
        move_robot([grid, ins], pos)

      # box movable?
      "." ->
        Enum.reduce(boxes, grid, fn box, acc ->
          acc |> update_grid(add(box, dir), get_in_grid(grid, box))
        end)
        |> update_grid(pos, ".")
        |> update_grid(next, "@")
        |> then(fn g -> move_robot([g, ins], next) end)
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
IO.inspect(Day15.solve2(demo))
IO.inspect(Day15.solve2(input))
