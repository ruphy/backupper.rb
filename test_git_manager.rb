
require 'git_manager.rb'
require 'settings_manager.rb'

$path = "~/test"

repo = Repo.new
location = Location.new
location.name = "Test"
location.path = $path
repo.location = location
repo.name = "Test repo"
repo.url = "origin"
repo.repo_type = "git"

c = GitManager.new repo
puts c.working_dir_clean?
puts c.current_branch

