defmodule ExRename do
  @switches [source: :string, dest: :string, exts: :string]
  @aliases [s: :source, d: :dest, e: :exts]
  def start(options) do
    stream = DirWalker.stream(options.from)

    stream
    |> Stream.filter(&Regex.match?(options.regex, &1))
    |> Stream.each(&(rename(&1, options.to)))
    |> Stream.run
  end

  def rename(path, to) do
    basename = Path.basename(path)
    output = Path.join(to, basename)
    # IO.puts "Moving #{basename} to #{output}" 
    File.rename(path, output)
  end
  
  def main(args) do
    args
    |> normalize_args 
    |> parse_args
    |> start
  end

  def normalize_args(args) do
    output = case OptionParser.parse(args, switches: @switches, aliases: @aliases) do
      {[exts: exts], [source, dest], _}  ->
        %{exts: exts, source: source, dest: dest}
      {list, _, _}  ->
        %{exts: list[:exts], source: list[:source], dest: list[:dest]}
      _   ->
        %{}
    end
  end

  def parse_args(%{source: source, dest: dest, exts: exts}) do
    %{
      from:   Path.expand(source), 
      to:     Path.expand(dest), 
      regex:  Regex.compile!(".+(#{exts})$")
    }
  end


end
