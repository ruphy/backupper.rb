
require 'error_manager'

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
    add_remote repo.url
  end

  # Adds a remote
  # remote: remote name
  # branch: branch name, or :current_branch, which means the same as the branch
  # that is currently checked out at runtime.
  def add_remote remote, branch = :current_branch
    branch = @repo.location.manager_for(:git).current_branch if branch == :current_branch
    ErrorManager.warning "No branch checked out for location #{@repo.location.name}. Is it a git repo?" if branch == :no_branch
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
      run("git push #{remote.remote} #{remote.branch}")
    end
  end

end
