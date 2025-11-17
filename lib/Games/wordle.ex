#to still do:
# - sourcing words
# - feedback call
# - storing words
# - preventing used guesses

alias Games.GameProcedures, as: GameProcedures
alias Games.StringUtils, as: StringUtils

defmodule Games.Wordle do
  use HTTPoison.Base
  @base_url "https://random-words-api.kushcreates.com/"

  def fetch_word(language \\ "en", length \\ 5) do
    url = "#{@base_url}api?language=#{language}&length=#{length}&words=1"
    case get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, unpack_json_word(Jason.decode!(body))}
      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "Received status code #{status_code}"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  def unpack_json_word(json) do
    [res] = json
    Map.get(res, "word")
  end

  def start_game do
    IO.puts("\nFetching random word from online database...")
    {:ok, answer} = fetch_word()

    IO.gets("Word located! Please type a 5 letter word to begin guessing: ")
    |> validate_input
    |> check_answer(String.split(answer, "", trim: true))
  end

  def is_valid_guess?(guess, past_guesses \\ []) do
    reconstructed_history = past_guesses
    |> Enum.map(&(Enum.unzip(&1)))
    |> Enum.map(fn {charlist, _states} -> List.to_string(charlist) end)

    cond do
      String.to_atom(guess) == :history -> print_history(past_guesses)
      String.length(guess) != 5 -> {:error, :invalid_length_input}
      not is_binary(guess) -> {:error, :invalid_characters_in_input}
      guess in reconstructed_history -> {:error, :word_already_attempted}
      true -> {:ok, guess}
    end
  end

  def validate_input(guess, past_guesses \\ []) do
    guess
    |> StringUtils.text_priming_for_validation
    |> is_valid_guess?(past_guesses)
    |> case do
      error when error in [{:error, :invalid_characters_in_input}, {:error, :invalid_length_input}] -> IO.gets("Invalid input. Please type an alphabetical word that is 5 letters long: ")
        |> validate_input(past_guesses)
      {:error, :word_already_attempted} -> IO.gets("You have already guessed that word. Please use another word: ")
        |> validate_input(past_guesses)
      {:ok, :history} -> IO.gets(IO.ANSI.reset() <> "\nPlease enter your next guess: ")
        |> validate_input(past_guesses)
      {:ok, guess} -> String.split(guess, "", trim: true)
    end
  end

  def print_history(history) do
    IO.puts("\nGuess history: ")
    Enum.each(history, fn word -> IO.puts(construct_colourised_result(word)) end)
    {:ok, :history}
  end

  def state_to_list(state) do
    state
    |> Enum.map(&(Tuple.to_list(&1)))
    |> List.flatten
  end

  # pattern matches states out and rezips them after comparing
  def update_guess_state(prior_state, new_state) do
    flat_prior_state = state_to_list(prior_state)
    flat_new_state = state_to_list(new_state)
    [c1, _, c2, _, c3, _ , c4, _, c5, _] = flat_prior_state
    [_, p1, _, p2, _, p3, _, p4, _, p5] = flat_prior_state
    [_, n1, _, n2, _, n3, _, n4, _, n5] = flat_new_state

    Enum.zip([p1, p2, p3, p4, p5], [n1, n2, n3, n4, n5])
    |> Enum.reduce([], fn {old, new}, acc -> [if(!old, do: new, else: old) | acc] end)
    |> Enum.reverse
    |> Enum.zip([c1, c2, c3, c4, c5])
    |> Enum.map(fn {exists, char} -> {char, exists} end)
  end

  def check_answer(guess, answer, attempts \\ 6, past_guesses \\ []) do
    exact_match_letters = check_if_exact_match(guess, answer)
    not_present_letters = check_if_letter_not_present(guess, answer)
    wrong_location_letters = check_if_exists_in_wrong_location(guess, answer)

    #building layers with priority for ensuring right result is reported
    exact_match_letters
    |> update_guess_state(not_present_letters)
    |> update_guess_state(wrong_location_letters)
    |> handle_result(List.to_string(answer), attempts, past_guesses)
  end

  def check_if_letter_not_present(guess, answer) do
    # sees if a letter is in the answer or not
    guess
    |> Enum.map(&(&1 in answer))
    |> Enum.zip(guess)
    |> Enum.map(fn {exists, char} -> {char, if(!exists, do: :not_in_word, else: false)} end)
  end

  def check_if_exact_match(guess, answer) do
    guess
    |> Enum.zip(answer)
    |> Enum.map(fn {guess_char, answer_char} -> {guess_char, if(guess_char == answer_char, do: :correct, else: false)} end)
  end

  def check_if_exists_in_wrong_location(guess, answer) do
    frequencies_in_guess = Enum.frequencies(guess)
    frequencies_in_answer = Enum.frequencies(answer)

    occurance_results = Enum.map(frequencies_in_guess, fn {key, val} ->
      case Map.fetch(frequencies_in_answer, key) do
        :error -> {key, :not_in_word}
        {_, answer_char_frequency} ->
          cond do
            val > answer_char_frequency -> {key, :letter_occurance_over_answer}
            val < answer_char_frequency -> {{key, :letter_occurance_under_answer}}
            true -> {key, :wrong_position}
          end
      end
    end)

    handle_surplus_letter_occurance(guess, occurance_results, frequencies_in_answer)
  end

  def handle_surplus_letter_occurance(guess, guess_state, frequencies), do: handle_surplus_letter_occurance(guess, guess_state, frequencies, [])

  def handle_surplus_letter_occurance([], _guess_state, _frequencies, acc), do: Enum.reverse(acc)

  def handle_surplus_letter_occurance([char | tail], guess_state, frequencies, acc) do
    cond do
      {char, :letter_occurance_over_answer} in guess_state -> cond do
          Map.get(frequencies, char) > 0 ->
            handle_surplus_letter_occurance(tail, guess_state, Map.update!(frequencies, char, &(&1 - 1)), [{char, :wrong_position} | acc])
          true ->
            handle_surplus_letter_occurance(tail, guess_state, frequencies, [{char, :not_in_word} | acc])
      end
      {char, :letter_occurance_under_answer} in guess_state ->
        handle_surplus_letter_occurance(tail, guess_state, frequencies, [{char, :wrong_position} | acc])
      true -> cond do
          {char, :not_in_word} in guess_state ->
            handle_surplus_letter_occurance(tail, guess_state, frequencies, [{char, :not_in_word} | acc])
          {char, :wrong_position} in guess_state ->
            handle_surplus_letter_occurance(tail, guess_state, frequencies, [{char, :wrong_position} | acc])
      end
    end
  end

  def construct_colourised_result(guess) do
    guess
    |> Enum.map(fn {char, state} -> case state do
        :correct -> IO.ANSI.green() <> char
        :wrong_position -> IO.ANSI.yellow() <> char
        :not_in_word -> IO.ANSI.light_black() <> char
      end
    end)
    |> List.to_string
  end

  def handle_result(guess, answer, attempts, past_guesses \\ []) do
    IO.puts("You guessed: #{construct_colourised_result(guess)}.")

    {_, result_letter_states} = Enum.unzip(guess)
    guess_history = [guess] ++ past_guesses

    case result_letter_states do
      [:correct, :correct, :correct, :correct, :correct] -> IO.gets(IO.ANSI.reset() <> "\nThat was completely correct, well done! Want to play again? (y/n/r): ")
        |> GameProcedures.end_of_game_procedure(:wordle)
      [_, _, _, _, _] -> cond do
        attempts == 1 ->
          IO.gets(IO.ANSI.reset() <> "\nUnfortunately that was not correct and you have run out of attempts. The answer was:"
<> IO.ANSI.blue() <> answer <> IO.ANSI.reset() <> ".
Do you wish to try again, quit, or return to the main menu? (y/n/r): \n")
          |> GameProcedures.end_of_game_procedure(:wordle)
        true ->
          IO.gets(IO.ANSI.reset() <> "\nUnfortunately that was not correct. You now have #{attempts - 1} attempts remaining. Please try another word.
If you wish to view your guess history, please type 'history' (colon included): ")
          |> validate_input(guess_history)
          |> check_answer(String.split(answer, "", trim: true), attempts - 1, guess_history)
      end
    end
  end

  def feedback(guess, answer) do
    split_answer = String.split(answer, "", trim: true)
    split_guess = String.split(guess, "", trim: true)
    #implement one-shot testing to assure functionality
    exact_match_letters = check_if_exact_match(split_guess, split_answer)
    not_present_letters = check_if_letter_not_present(split_guess, split_answer)
    wrong_location_letters = check_if_exists_in_wrong_location(split_guess, split_answer)

    #building layers with priority for ensuring right result is reported
    exact_match_letters
    |> update_guess_state(not_present_letters)
    |> update_guess_state(wrong_location_letters)
    |> Enum.unzip
    |> elem(1)
    |> Enum.map(fn state -> case state do
      :correct -> :green
      :wrong_position -> :yellow
      :not_in_word -> :grey
      end
    end)
  end
end
