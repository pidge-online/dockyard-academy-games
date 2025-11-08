defmodule Games.StringUtils do
  def text_priming_for_validation(string) do
    string
    |> String.trim
    |> String.downcase
  end

  def text_priming_for_integer_extraction(string) do
    string
    |> String.trim
    |> Integer.parse
  end
end
