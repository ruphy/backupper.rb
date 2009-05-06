

class GitManager
  
  def initialize repo
    @repo = repo
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

  def push remote = :all

  end

  def gibak_commit

  end
  
end

