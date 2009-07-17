
def debug string
  puts "--- #{Dir.pwd} ### #{string}" if $debug
end

# Force run, even in dry_run mode
def f_run c
  run c, true
end

def run command, force_run = false
  debug "pretending to run -- #{command}" if ($dry_run and !force_run)
  debug "running '" + command +"'" unless ($dry_run and !force_run)
  `#{command}` unless ($dry_run and !force_run)
end

def cd path
  path = File.expand_path path
  unless File.directory? path
    puts "#{path} is not a valid directory, not CD'ing into it..."
    return
  end
  return if Dir.pwd == path
  debug("Dir.chdir #{path}")
  Dir.chdir path
end

