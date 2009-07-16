
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
    @remote = nil
    
    ## TODO: make it possible to have other branches too
    branch = @repo.location.manager_for(:git).current_branch # if branch == :current_branch
    ErrorManager.warning "No branch checked out for location #{@repo.location.name}. Is it a git repo?" if branch == :no_branch
    @remote = Remote.new(@repo.url, branch)
  end

  def push
    debug "pushing '#{@repo.location.name}' to '#{@repo.name}'..."
    run "git push #{@remote.remote} #{@remote.branch}"
  end

end
