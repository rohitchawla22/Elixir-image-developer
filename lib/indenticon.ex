defmodule Indenticon do
  @moduledoc """
    Documentation for Cards.
    Provides methods for creating, shuffling and dealing with Deck of Cards. 
  """

  @doc """
    return a list of cards
  """

  def main(input) do
    input
    |> hashInput()
    |> pick_color()
    |> build_grid()
    |> filter_odd_squares()
    |> build_pixel_map()
    |> draw_indentity_image()
    |> save_image(input)
  end

  def hashInput(input) do
    hex =
      :crypto.hash(:md5, input)
      |> :binary.bin_to_list()

    # take a list of numbers from this struct and send it to a adifferent method to make a grid
    %Indenticon.Image{hex: hex}
  end

  def pick_color(%Indenticon.Image{hex: [r, g, b | _tail]} = image) do
    # %Indenticon.Image{hex: [r, g, b | _tail]} = image  can pattern match when we receive the arguments for the first time. 
    %Indenticon.Image{image | color: {r, g, b}}
  end

  def build_grid(%Indenticon.Image{hex: hex} = image) do
    # & represents reference, if we have multiple arguments for the function, run for every 1 argument you get in the params. 
    grid =
      hex
      |> Enum.chunk(3)
      |> Enum.map(&mirror_row/1)
      |> List.flatten()
      |> Enum.with_index()

    %Indenticon.Image{image | grid: grid}
  end

  def mirror_row(row) do
    [first, second | _tail] = row
    row ++ [second, first]
  end

  def filter_odd_squares(%Indenticon.Image{grid: grid} = image) do
    # if code is /2 ==0 true else false 
    grid =
      Enum.filter(grid, fn {code, _index} ->
        rem(code, 2) == 0
      end)

    %Indenticon.Image{image | grid: grid}
  end

  def build_pixel_map(%Indenticon.Image{grid: grid} = image) do
    identity_image =
      Enum.map(grid, fn {_code, index} ->
        horizontal = rem(index, 5) * 50
        vertical = div(index, 5) * 50
        top_left = {horizontal, vertical}
        bottom_right = {horizontal + 50, vertical + 50}
        {top_left, bottom_right}
      end)

    %Indenticon.Image{image | pixel_map: identity_image}
  end

  def draw_indentity_image(%Indenticon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each(pixel_map, fn {start, stop} ->
      :egd.filledRectangle(image, start, stop, fill)
    end)

    :egd.render(image)
  end

  def save_image(image, input) do
    File.write("#{input}.png", image)
  end
end
