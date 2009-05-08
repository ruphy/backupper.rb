
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
  
  def status
    return `cd #{@repo.location.path}; git status`
  end

  def add_remote remote, branch = :current
    @remotes << Remote.new(remote, branch)
  end

  def remotes
    return @remotes
  end

  def push remote = :all
    if remote == :all
      #foreach - push
    else
      #push remote
    end
  end

  def add
    `cd #{@repo.location.path}; git add .` unless @repo.location.name == "gibak"
  end

  def commit log
    if @repo.location.name == "gibak"
      `cd ~; gibak commit`
    else
      puts `cd #{@repo.location.path}; git commit -m "#{log}"`
    end
  end
  
end
