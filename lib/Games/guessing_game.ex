alias Games.StringUtils, as: StringUtils

defmodule Games.GuessingGame do
  @moduledoc """
  Documentation for `Games.GuessingGame`.
  """

  def generate_number(), do: :rand.uniform(10)

  def start_game do
    answer = generate_number()
    guess = IO.gets("\nGuess a number from 1 to 10. You have 5 attempts: \n")
    accept_guess(guess, answer)
  end

  def check_guess({:error, :invalid_guess}, _) do
    {:error, :invalid_guess}
  end
  def check_guess(guess, answer) do
    if guess == answer, do: {:ok, true}, else: {:error, {:incorrect_guess, guess}}
  end

  def guess_integrity_validate(guess) do
    guess
    |> StringUtils.text_priming_for_integer_extraction
    |> case do
      {guess, _} -> if guess > 0 && guess < 11, do: guess, else: {:error, :invalid_guess}
      :error -> {:error, :invalid_guess}
    end
  end

  def retry_guess(:invalid_guess, answer, attempts) do
    guess = IO.gets("Invalid input. Please try your guess again. You have #{attempts} remaining: \n")
    accept_guess(guess, answer, attempts)
  end

  def retry_guess(:incorrect_guess, guess, answer, attempts) do
    IO.puts("Answer incorrect. Please try again. You have #{attempts} remaining.")

    new_guess = guess
    |> IO.inspect
    |> too_low_or_too_high(answer)
    |> hint_if_low_or_high

    accept_guess(new_guess, answer, attempts)
  end

  def too_low_or_too_high(guess, answer) do
    if guess > answer, do: :high, else: :low
  end

  def hint_if_low_or_high(hint) do
    case hint do
      :high -> IO.gets("Hint: guess was too high: \n")
      :low -> IO.gets("Hint: guess was too low: \n")
    end
  end

  def accept_guess(guess, answer, attempts \\ 5) do
    guess
    |> guess_integrity_validate
    |> check_guess(answer)
    |> check_result(answer, attempts)
  end

  def check_result(result, answer, attempts) do
    if out_of_attempts(result, attempts - 1) == true do
      end_game_or_restart(answer)
    else
      case result do
        {:ok, _} -> end_game_or_restart()
        {_, :invalid_guess} -> retry_guess(:invalid_guess, answer, attempts - 1)
        {_, {:incorrect_guess, guess}} -> retry_guess(:incorrect_guess, guess, answer, attempts - 1)
      end
    end
  end

  def out_of_attempts(result, attempts) do
    cond do
      attempts == 0 && elem(result, 0) == :error -> true
      true -> false
    end
  end

  def end_game_or_restart() do
    IO.gets("Congratulations, that was correct! Do you want to play again? (y/n):  \n") |> end_of_game_procedure
  end

  def end_game_or_restart(answer) do
    IO.gets("You have run out of attempts. The answer was #{answer}. Do you wish to try again? (y/n): \n") |> end_of_game_procedure
  end

  def restart_or_end_validation(input) do
    input
    |> StringUtils.text_priming_for_validation
    |> case do
      response when response in ["n", "exit", "quit"] -> :end_game
      "y" -> :restart
      _ -> {:error, :restart_selection_invalid}
    |> IO.inspect
    end
  end

  def end_of_game_procedure(restart_or_end?) do
    restart_or_end?
    |> restart_or_end_validation
    |> case do
      :restart -> start_game()
      :end_game -> IO.puts("Thanks for playing! Bye for now :)")
      {:error, _} -> IO.gets("Selection invalid. Please select y (yes) or n (no) to play again or exit: \n") |> end_of_game_procedure
    end
  end
end
