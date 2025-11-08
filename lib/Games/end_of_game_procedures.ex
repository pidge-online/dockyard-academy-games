alias Games.StringUtils, as: StringUtils

defmodule Games.EndOfGameProcedures do
  def restart_or_end_validation(input) do
    input
    |> StringUtils.text_priming_for_validation
    |> case do
      response when response in ["n", "exit", "quit"] -> :end_game
      response when response in ["r", "return", "main", "main menu"] -> :main_menu
      "y" -> :restart
      _ -> {:error, :restart_selection_invalid}
    |> IO.inspect
    end
  end

  def end_of_game_procedure(restart_or_end?, game_start_function) do
    restart_or_end?
    |> restart_or_end_validation
    |> case do
      :restart -> game_start_function
      :end_game -> IO.puts("Thanks for playing! Bye for now :)")
      :main_menu -> Games.play
      {:error, _} -> IO.gets("Selection invalid. Please select y (yes) or n (no) to play again or exit: \n") |> end_of_game_procedure(game_start_function)
    end
  end
end
