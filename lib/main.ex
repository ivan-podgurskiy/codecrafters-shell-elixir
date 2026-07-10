defmodule CLI do
  def main(_args) do
    case IO.gets("$ ") do
      nil ->
        IO.puts("\nBye")

      input ->
        input
        |> String.trim()
        |> handle_command()
    end
  end

  def handle_command(command), do: IO.puts("#{command}: command not found")
end
