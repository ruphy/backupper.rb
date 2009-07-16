
require 'location_manager'
require 'flickr_manager'

class FlickrLocationManager < LocationManager
  
  def initialize location
    super(location)
    @commit_makes_sense = false
  end
  
  def status
    # Reimplement!
    # returns a string with human readable status.
    # output of a "status" command is okay.
  end
  
  def working_dir_clean?
    return true
  end
  
end


