
class Location
  attr_accessor :name, :url
end

class Repo
  attr_accessor :location, :type,
                :name, :url
end

class SettingsManager

  def initialize
    @repos = Hash.new
    
    reparse_config
  end

  def reparse_config
    @repos[:home] = Array.new
    IO.foreach($config_file) do |line|
      line.lstrip!
      # skip comments
      next if line.start_with? '#'
      # first, locations!
      if line.start_with? '['
        c = line.split('=')
        c[0].chop!
        next
      end
      config = line.split(',')
      if config.size == 4
        repo = Repo.new
        repo.location = config[0]
        repo.type = config[1]
        repo.name = config[2]
        repo.url = config[3]
        @repos[repo.location.to_sym] << repo
      end
    end
  end

  def get_repos_for location
    return @repos[location]
  end
  
end
