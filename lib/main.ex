defmodule CLI do
  @builtin_commands ["exit", "echo", "type", "pwd"]

  def main(_args) do
    run_terminal()
  end

  defp run_terminal do
    case IO.gets("$ ") do
      :eof ->
        :ok

      {:error, _reason} ->
        :ok

      input ->
        case parse_input(input) do
          {:ok, []} ->
            run_terminal()

          {:ok, [command | args]} ->
            execute_command(command, args)

          {:error, reason} ->
            IO.puts("Parse error: #{inspect(reason)}")
            run_terminal()
        end
    end
  end

  defp execute_command(command, args) do
    case handle_command(command, args) do
      {:continue, output} ->
        IO.write(output)
        run_terminal()

      :exit ->
        :ok
    end
  end

  defp parse_input(input) do
    ShellWords.split(input)
  end

  defp handle_command("exit", _args) do
    :exit
  end

  defp handle_command("echo", args) do
    {:continue, Enum.join(args, " ") <> "\n"}
  end

  defp handle_command("type", [command])
       when command in @builtin_commands do
    {:continue, "#{command} is a shell builtin\n"}
  end

  defp handle_command("type", [command]) do
    case find_executable(command) do
      nil ->
        {:continue, "#{command}: not found\n"}

      file_path ->
        {:continue, "#{command} is #{file_path}\n"}
    end
  end

  defp handle_command("type", _args) do
    {:continue, "type: expected one argument\n"}
  end

  defp handle_command(command, args) do
    case find_executable(command) do
      nil ->
        {:continue, "#{command}: command not found\n"}

      file_path ->
        {output, _exit_status} =
          System.cmd(file_path, args,
            arg0: command,
            stderr_to_stdout: true
          )

        {:continue, output}
    end
  end

  defp find_executable(command) do
    Enum.find_value(get_os_paths(), fn path ->
      file_path = Path.join(path, command)

      if executable?(file_path) do
        file_path
      end
    end)
  end

  defp get_os_paths do
    separator =
      case :os.type() do
        {:win32, _} -> ";"
        _ -> ":"
      end

    System.get_env("PATH", "")
    |> String.split(separator, trim: true)
  end

  defp executable?(path) do
    case File.stat(path) do
      {:ok, %{type: :regular, mode: mode}} ->
        Bitwise.band(mode, 0o111) != 0

      _ ->
        false
    end
  end
end
