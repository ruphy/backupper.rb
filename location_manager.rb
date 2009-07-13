

class LocationManager
  attr_accessor :commit_makes_sense
  
  def initialize location
    @location = location
  end
  
  def status
    # Reimplement!
    # returns a string with human readable status.
    # output of a "status" command is okay.
  end
  
  def working_dir_clean?
    # Reimplement!
    # returns a bool
  end
  
  def last_commit_date
    return nil if !@commit_makes_sense
  end
  
end

class GitLocationManager < LocationManager
  def initialize location
    super(location)
    @commit_makes_sense = true
  end

  
end


