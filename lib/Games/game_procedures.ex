alias Games.StringUtils, as: StringUtils

defmodule Games.GameProcedures do
  def restart_or_end_validation(input) do
    input
    |> StringUtils.text_priming_for_validation
    |> case do
      response when response in ["n", "exit", "quit"] -> :end_game
      response when response in ["r", "return", "main", "main menu"] -> :main_menu
      "y" -> :restart
      _ -> {:error, :restart_selection_invalid}
    end
  end

  def end_of_game_procedure(restart_or_end?, game) do
    restart_or_end?
    |> restart_or_end_validation
    |> case do
      :restart -> restart_game(game)
      :end_game -> IO.puts("Thanks for playing! Bye for now :)")
      :main_menu -> Games.play
      {:error, _} -> IO.gets("Selection invalid. Please select y (yes), n (no) or r (return) to play again, exit, or return to the main menu: \n")
        |> end_of_game_procedure(game)
    end
  end

  def restart_game(game) do
    case game do
      :guessing_game -> Games.GuessingGame.start_game
      :rps -> Games.RockPaperScissors.start_game
      :wordle -> Games.Wordle.start_game
    end
  end
end
