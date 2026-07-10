defmodule CLI do
  require Logger

  @builtin_commands ["exit", "echo", "type"]

  def main(_args) do
    run_terminal()
  end

  defp run_terminal() do
    case IO.gets("$ ") do
      :eof ->
        :ok

      {:error, _} ->
        :ok

      input ->
        {:ok, [command | args]} = parse_input(input)

        case handle_command(command, args) do
          {:continue, output} ->
            IO.write(output)

            run_terminal()

          {:exit, _} ->
            :ok
        end
    end
  end

  defp parse_input(input) do
    ShellWords.split(input)
  end

  defp handle_command("exit", _), do: {:exit, :exit_command}
  defp handle_command("echo", args), do: {:continue, Enum.join(args, " ")}

  defp handle_command("type", [command]) when command in @builtin_commands do
    {:continue, "#{command} is a shell builtin"}
  end

  defp handle_command("type", [command]) do
    os_executable = file_exist_in_any_path_and_executable(command)

    case os_executable do
      false ->
        {:continue, "#{command}: not found"}

      file_path ->
        {:continue, "#{command} is #{file_path}"}
    end
  end

  defp handle_command(command, args) do
    os_executable = file_exist_in_any_path_and_executable(command)

    case os_executable do
      false ->
        {:continue, "#{command}: command not found"}

      file_path ->
        {output, _exit_status} = System.cmd(file_path, args, arg0: command)
        {:continue, output}
    end
  end

  defp file_exist_in_any_path_and_executable(command) do
    paths = get_os_paths()
    found = Enum.find(paths, fn path -> executable?(path <> "/" <> command) end)

    case found do
      nil -> false
      path -> path <> "/" <> command
    end
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
