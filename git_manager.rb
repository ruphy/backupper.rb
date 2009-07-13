
class Remote
  attr_accessor :remote, :branch

  def initialize remote, branch
    @remote = remote
    @branch = branch
  end
end

class GitManager
  
  def initialize repo, location = nil
    @repo = repo
    @location = @repo.location unless @repo == nil
    @location = location if @repo == nil
    @remotes = Array.new
  end

  # Adds a remote
  # remote: remote name
  # branch: branch name, or :current, which is the same as the branch
  # that is currently checked out at runtime.
  def add_remote remote, branch = :current_branch
    branch = current_branch if branch == :current_branch
    @remotes << Remote.new(remote, branch)
#     @repo.add_remote Remote.new(remote, branch)
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
      run("git push #{remote.remote}")
    end
  end

end
