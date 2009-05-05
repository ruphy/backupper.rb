
class ErrorManager
  def ErrorManager.abort_malformed_config_line(line, text)
    puts "Malformed configuration line -- #{$config_file}:#{line}"
    puts ">> #{text}"
    exit 1
  end
end
