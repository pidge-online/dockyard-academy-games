alias Games.GuessingGame, as: GuessingGame
alias Games.RockPaperScissors, as: RockPaperScissors
alias Games.StringUtils, as: StringUtils


defmodule Games do
  @moduledoc """
  Documentation for `Games`.
  """
  def play do
    IO.gets("Hi there! Please select a game to play:

1. 'GuessingGame' (guess a number from 1 to 10)
2. '#{Enum.map(String.split("Rock Paper Scissors", ""), &(&1 <> "\u0336"))}' (Classic RPS) [UNDER CONSTRUCTION]

Enter the corresponding number to choose your game (1/2): \n")
    |> select_game
  end

  defp select_game(game_selection) do
    game_selection
    |> game_start_validation
    |> boot_game
  end

  defp game_start_validation(input) do
    input
    |> StringUtils.text_priming_for_integer_extraction
    |> case do
      {game_selection, _} -> {:ok, game_selection}
      :error -> {:error, :invalid_input}
    end
  end

  defp boot_game(game) do
    case game do
      {:error, _} -> IO.gets("\nInvalid input format detected. Please use the corresponding numeral to select a game from the list (1/2): \n") |> select_game
      {_, 1} -> GuessingGame.start_game
      {_, 2} -> RockPaperScissors.start_game
      _ -> IO.gets("\nInvalid game number selection detected. Please use the corresponding numeral to select a game from the list (1/2): \n") |> select_game
    end
  end
end
