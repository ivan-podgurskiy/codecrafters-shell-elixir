defmodule CLI do
  require Logger

  @builtin_commands ["exit", "echo", "type"]

  def main(_args) do
    run_terminal()
  end

  def run_terminal() do
    case IO.gets("$ ") do
      :eof ->
        :ok

      {:error, _} ->
        :ok

      input ->
        {:ok, [command | args]} = parse_input(input)

        case handle_command(command, args) do
          {:continue, output} ->
            IO.puts(output)

            run_terminal()

          {:exit, _} ->
            :ok
        end
    end
  end

  def parse_input(input) do
    ShellWords.split(input)
  end

  def handle_command("exit", _), do: {:exit, :exit_command}
  def handle_command("echo", args), do: {:continue, Enum.join(args, " ")}

  def handle_command("type", [command]) when command in @builtin_commands do
    {:continue, "#{command} is a shell builtin"}
  end

  def handle_command("type", [command]) do
    {:continue, "#{command}: not found"}
  end

  def handle_command(command, _), do: {:continue, "#{command}: command not found"}
end
