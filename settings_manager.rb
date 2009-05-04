
class Location
  attr_accessor :name, :url
end

class Repo
  attr_accessor :location, :type,
                :name, :url
end

class SettingsManager

  def initialize
    reparse_config
    @repos = {}
  end

  def reparse_config
    @home = Array.new
    IO.foreach($config_file) do |line|
      # skip comments
      next if line.start_with? '#'
      # first, locations!
      if line.start_with? '['
        
        line.each do |i|
          
        end
        next
      end
      if line.start_with? "home"
        repo = Repo.new
        config = line.split(',')
        repo.location = config[0]
        repo.type = config[1]
        repo.name = config[2]
        repo.url = config[3]
        @home << repo
      end
    end
  end

  def get_repos_for location
    if location == :home
      return @home
    end
  end
  
end
