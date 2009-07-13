
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
  
#   def working_dir_clean?
#     cd_path
#     @output = f_run("git status")
#     @output.each do |line|
#       next if line.start_with? '#'
#       return true if line.include? "working directory clean"
#     end
#     return false
#   end
#   
#   def current_branch
#     cd_path
#     f_run("git branch").each do |line|
#       return line.gsub!('* ', '') if line.include? '*'
#     end
#     return :no_branch
#   end
  
#   def status
#     cd @location.path
#     return `git status`
#   end

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

#   def add
#     unless @location.name == "gibak"
#       cd @location.path
#       run("git add .")
#     end
#   end

#   def cd_path
#     if @location.name == "gibak"
#       cd File.expand_path '~'
#     else
#       cd @location.path
#     end
#   end
# 
#   def commit log
#     cd_path
#     if @location.name == "gibak"
#       run("gibak commit")
#     else
#       run("git commit -m \"#{log}\"")
#     end
# #     puts KDE::Global::config.groupList
#   end
  
  def last_commit_date
  end
  
#   def 
  
end
