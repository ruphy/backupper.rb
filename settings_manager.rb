

class Location
  attr_accessor :location, :type,
                :name, :url
end

class SettingsManager

  def initialize
    reparse
  end

  def reparse
    @home = Array.new
    IO.foreach($config_file) do |line|
      # skip comments
      next if line.start_with? '#'
      # first, locations!
      if line.start_with? '['
        
      end
      if line.start_with? "home"
        repo = Location.new
        config = line.split(',')
        repo.location = config[0]
        repo.type = config[1]
        repo.name = config[2]
        repo.url = config[3]
        @home << repo
      end
    end
  end

  def get_places dir
    if dir == :home
      return @home
    end
  end
  
end
