

class LocationManager
  attr_accessor :commit_makes_sense # bool, true if the commit (git meaning) concept makes sense in the backend
  
  def initialize location
    @location = location
  end
  
  def status
    # Reimplement!
    # returns a string with human readable status.
    # output of a "status" command is okay.
  end
  
  def working_dir_clean?
    # Reimplement!
    # returns a bool
  end
  
  def last_commit_date
    return nil if !@commit_makes_sense
    
  end
  
  def cd_path
#     if @location.name == "gibak"
#       cd File.expand_path '~'
#     else
      cd @location.path
#     end
  end
  
end

class GitLocationManager < LocationManager
  def initialize location
    super(location)
    @commit_makes_sense = true
  end

  def status
    cd_path
    return f_run("git status")
  end
  
  def commit log
    cd_path
    if @location.name == "gibak"
      run("gibak commit")
    else
      run("git commit -m \"#{log}\"")
    end
  end
  
  def working_dir_clean?
    cd_path
    @output = status
    @output.each do |line|
      next if line.start_with? '#'
      return true if line.include? "working directory clean"
    end
    return false
  end
    
  def current_branch
    cd_path
    f_run("git branch").each do |line|
      return line.gsub!('* ', '') if line.include? '*'
    end
    return :no_branch
  end
  
  def add
    unless @location.name == "gibak"
      cd @location.path
      run("git add .")
    end
  end
  
end


