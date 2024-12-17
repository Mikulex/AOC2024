defmodule Day16 do
  @offsets %{north: {0, -1}, south: {0, 1}, east: {1, 0}, west: {-1, 0}}
  @symbols %{north: "^", south: "v", east: ">", west: "<"}
  @moves %{
    north: [:west, :east, :north],
    south: [:west, :east, :south],
    east: [:north, :south, :east],
    west: [:north, :south, :west]
  }

  def solve1(file) do
    grid =
      File.read!(file)
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, "", trim: true))

    [finish, start] =
      grid
      |> Enum.with_index(fn line, y -> Enum.with_index(line, fn s, x -> {s, {x, y}} end) end)
      |> List.flatten()
      |> Enum.map(fn
        {s, coords} when s == "S" or s == "E" -> coords
        {_, _} -> nil
      end)
      |> Enum.reject(&is_nil/1)

    shortest_path(grid, finish, [
      %{pos: start, dir: :east, cost: 0, prev: nil}
    ])
    |> Map.filter(fn {{c, _}, v} -> c == finish end)
    |> IO.inspect(label: "end")
  end

  def shortest_path(grid, fin, queue, visited \\ Map.new())
  def shortest_path(_grid, _fin, [], visited), do: visited

  def print_current(grid, head) do
    update_grid(grid, {head.pos, @symbols[head.dir]})
    |> Enum.map_join("\n", &Enum.join/1)
    |> String.replace(
      Map.values(@symbols),
      fn s -> "#{IO.ANSI.cyan()}#{s}#{IO.ANSI.default_color()}" end
    )
    |> IO.write()
  end

  def shortest_path(grid, fin, [head | tail], visited) do
    cond do
      {head.pos, head.dir} in Map.keys(visited) ->
        shortest_path(grid, fin, tail, visited)

      fin == head.pos ->
        Map.put(visited, {head.pos, head.dir}, head.cost)

      true ->
        neighbors =
          @moves[head.dir]
          |> Enum.map(fn dir ->
            %{
              pos: add(head.pos, @offsets[dir]),
              dir: dir,
              cost: head.cost + if(dir == head.dir, do: 1, else: 1001),
              prev: {head.pos, head.dir}
            }
          end)
          |> Enum.reject(fn map -> get_in_grid(grid, map.pos) == "#" end)
          |> Enum.reject(fn map -> {map.pos, map.dir} in visited end)

        tail_positions = tail |> Enum.map(&{&1.pos, &1.dir})

        tail =
          Enum.reduce(neighbors, tail, fn el, acc ->
            if {el.pos, el.dir} in tail_positions do
              acc
              |> update_in(
                [Access.find(&(&1.pos == el.pos and &1.dir == el.dir)), :cost],
                &min(el.cost, &1)
              )
              |> update_in([Access.find(&(&1.pos == el.pos and &1.dir == el.dir)), :prev], fn _ ->
                el.prev
              end)
            else
              [el | acc]
            end
          end)
          |> Enum.sort_by(& &1.cost, :asc)

        visited = Map.put(visited, {head.pos, head.dir}, {head.cost, head.prev})

        shortest_path(grid, fin, tail, visited)
    end
  end

  def construct_path(head, path \\ []) do
    if head.prev == nil,
      do: [{head.pos, head.dir, head.cost} | path],
      else: construct_path(head.prev, [{head.pos, head.dir, head.cost} | path])
  end

  def get_in_grid(matrix, {x, y}), do: get_in(matrix, [Access.at(y), Access.at(x)])

  def add({a, b}, {c, d}), do: {a + c, b + d}

  def update_grid(grid, {{x, y}, val}),
    do: List.replace_at(grid, y, List.replace_at(Enum.at(grid, y), x, val))

  def print(path, grid) do
    path
    |> Enum.reduce(grid, fn {c, s, _}, acc -> update_grid(acc, {c, @symbols[s]}) end)
    |> Enum.map_join("\n", &Enum.join/1)
    |> String.replace(
      Map.values(@symbols),
      fn s ->
        "#{IO.ANSI.cyan()}#{s}#{IO.ANSI.default_color()}"
      end
    )
    |> IO.write()

    IO.write("\n")
  end
end

demo = "demo.txt"
input = "input.txt"

IO.inspect(Day16.solve1(demo))
IO.inspect(Day16.solve1(input))
# IO.inspect(Day16.solve2(demo))
# IO.inspect(Day16.solve2(input))
