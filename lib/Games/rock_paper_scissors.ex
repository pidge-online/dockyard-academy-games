alias Games.StringUtils, as: StringUtils
alias Games.GameProcedures, as: GameProcedures

defmodule Games.RockPaperScissors do
  def start_game do
    # Games.game_under_construction()
    IO.gets("\nTo start playing, select rock, paper, or scissors
(rock/paper/scissors): ")
  |> validate_selection
  |> compare_selection(generate_ai_selection())
  end

  defp generate_ai_selection, do: Enum.take_random([:rock, :paper, :scissors], 1) |> List.first

  defp is_valid_move?(input), do: if(input in ["rock", "paper", "scissors"], do: {:ok, String.to_existing_atom(input)}, else: {:error, :invalid_input})

  defp validate_selection(string) do
    string
    |> StringUtils.text_priming_for_validation
    |> is_valid_move?
    |> case do
      {:error, _} -> IO.gets("Invalid move choice selected. Please choose a valid move from rock, paper, or scissors: ") |> validate_selection
      {:ok, played_move} -> played_move
    end
  end

  defp compare_selection(input, ai_selection) do
    winning_moves = [{:rock, :scissors}, {:scissors, :paper}, {:paper, :rock}]
    IO.puts("AI selected: #{ai_selection}!")

    cond do
      {input, ai_selection} in winning_moves -> IO.gets("Congrats! You have won. Do you wish to try another round, quit, or return to the main menu? (y/n/r): ")
        |> GameProcedures.end_of_game_procedure(:rps)
      {ai_selection, input} in winning_moves -> IO.gets("Darn it, the AI beat you! Oh well, always another chance. Would you like to try again, quit, or return to the main menu? (y/n/r): ")
        |> GameProcedures.end_of_game_procedure(:rps)
      input == ai_selection -> IO.gets("Well how curious, the result is a draw. Would you like to try again, quit, or return to the main menu? (y/n/r): ")
        |> GameProcedures.end_of_game_procedure(:rps)
    end
  end
end
