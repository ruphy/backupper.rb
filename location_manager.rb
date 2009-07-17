# require 'flickr_location_manager'

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
    # Reimplement if commit_makes_sense!
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


require 'git_location_manager'
