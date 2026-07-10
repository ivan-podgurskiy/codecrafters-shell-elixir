defmodule CLI do
  def main(_args) do
    run_terminal()
  end

  def run_terminal() do
    case IO.gets("$ ") do
      {:error, _} ->
        IO.puts("\nBye")

      input ->
        res =
          input
          |> String.trim()
          |> handle_command()

        if res != :exit do
          run_terminal()
        end
    end
  end

  def handle_command("exit"), do: :exit
  def handle_command(command), do: IO.puts("#{command}: command not found")
end
