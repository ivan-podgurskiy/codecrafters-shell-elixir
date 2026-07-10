defmodule CLI do
  def main(_args) do
    run_terminal()
  end

  def run_terminal() do
    case IO.gets("$ ") do
      {:error, _} ->
        IO.puts("\nBye")

      input ->
        input
        |> String.trim()
        |> handle_command()

        run_terminal()
    end
  end

  def handle_command(command), do: IO.puts("#{command}: command not found")
end
