
def read_global_vars filename
  $debug = false
  $dry_run = false
  IO.foreach(filename) do |line|
  # don't parse carriage returns and extra spaces!
  line.strip!
  
  # skip comments, empty line
  next if line.start_with? '#'
  next if line.empty?
  $debug = true if line == "config.debug"
  $dry_run = true if line == "config.dry_run"
  end
  
  $types = Array.new
  $types << :git if has_git
  $types << :rsync if has_rsync
  $types << :flickr if has_flickr
end

def has_git
  return false if `which git`.include? 'which: no git in' ## TODO okay, this is a bit hacky :-)
  return true
end

def has_rsync
  return false
end

def has_flickr
  return false
end

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

