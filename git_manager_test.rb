
require 'backupper.rb'

c = GitManager.new "~/test"
puts c.is_working_dir_clean?


