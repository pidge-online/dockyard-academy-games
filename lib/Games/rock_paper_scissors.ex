alias Games.StringUtils, as: StringUtils

defmodule Games.RockPaperScissors do
  def start_game do
    # Games.game_under_construction()
    IO.gets("\n To start playing, select rock, paper, or scissors
(rock/paper/scissors): ")
  |> validate_selection
  |> compare_selection
  end

  def generate_ai_selection, do: Enum.take_random([:rock, :paper, :scissors], 1) |> List.first

  def validate_selection(string) do
    string
    |> StringUtils.text_priming_for_validation
  end

  def compare_selection(selection) do

  end
end
