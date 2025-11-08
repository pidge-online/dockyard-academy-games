alias Games.StringUtils, as: StringUtils
alias Games.EndOfGameProcedures, as: EndOfGameProcedures

defmodule Games.RockPaperScissors do
  def start_game do
    # Games.game_under_construction()
    IO.gets("\n To start playing, select rock, paper, or scissors
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

    cond do
      {input, ai_selection} in winning_moves -> IO.gets("Congrats! You have one. Do you wish to try another round, quit, or return to the main menu? (y/n/r)")
        |> EndOfGameProcedures.end_of_game_procedure(Games.RockPaperScissors.start_game)
      {ai_selection, input} in winning_moves -> IO.gets("Darn it, the AI beat you! Oh well, always another chance. Would you like to try again, quit, or return to the main menu? (y/n/r)")
        |> EndOfGameProcedures.end_of_game_procedure(Games.RockPaperScissors.start_game)
      input == ai_selection -> IO.gets("Well how curious, the result is a draw. Would you like to try again, quit, or return to the main menu? (y/n/r)")
        |> EndOfGameProcedures.end_of_game_procedure(Games.RockPaperScissors.start_game)
    end
  end
end
