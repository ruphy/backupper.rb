
class Remote
  attr_accessor :remote, :branch

  def initialize remote, branch
    @remote = remote
    @branch = branch
  end
end

class GitManager
  
  def initialize repo
    @repo = repo
    @remotes = Array.new
  end
  
  def working_dir_clean?
    @output = `cd #{@repo.location.path}; git status`
    @output.each do |line|
      next if line.start_with? '#'
      return true if line.include? "working directory clean"
    end
    return false
  end
  
  def branch
    cd_path
    `git branch`.each do |line|
      return line.gsub!('* ', '') if line.contain? '*'
    end
  end
  
  def status
    cd @repo.location.path
    return `git status`
  end

  def add_remote remote, branch = :current
    @remotes << Remote.new(remote, branch)
  end

  def remotes
    return @remotes
  end

  def push remote = :all
    if remote == :all
      @remotes.each do |r|
          push r
        end
    else
      run("git push #{remote}")
    end
  end

  def add
    unless @repo.location.name == "gibak"
      cd @repo.location.path
      run("git add .")
    end
  end

  def cd_path
    if @repo.location.name == "gibak"
      run("cd ~")
    else
#       run("cd #{@repo.location.path}")
    end
  end

  def commit log
    cd_path
    if @repo.location.name == "gibak"
      run("gibak commit")
    else
      run("git commit -m \"#{log}\"")
    end
#     puts KDE::Global::config.groupList
  end
  
end
