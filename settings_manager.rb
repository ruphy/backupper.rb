
require 'error_manager'

class Location
  attr_accessor :name, :path
  
  def complete?
    begin
      if !name.empty? and !path.empty?
        return true
      end
    rescue NoMethodError
    end
    return false
  end
end

class Repo
  attr_accessor :location, :repo_type,
                :name, :url

  attr_reader :remotes
  
  def initialize
    @remotes = Array.new
  end
  
  def add_remote remote
    @remotes << remote
  end
  
  def complete?
    begin
      if !name.empty? && !url.empty? &&
         location.complete? && !repo_type.empty?
        return true
      end
    rescue NoMethodError
    end
    return false
  end
end

class SettingsManager

  def initialize
    @repos = Array.new
    @locations = Array.new
    parse_config
  end

  def parse_config
    i = 0
    IO.foreach($config_file) do |line|
      # counter
      i = i + 1
      
      # don't parse carriage returns and extra spaces!
      line.strip!
      
      # skip comments, empty line
      next if line.start_with? '#'
      next if line.empty?
      
      # first, locations!
      if line.start_with? '['
        c = line.split('=')
        c[0].gsub!('[', '').gsub!(']', '')
        l = Location.new
        l.name = c[0]
        l.path = c[1]
        @locations << l
        if !l.complete?
          ErrorManager.abort_malformed_config_line i, line
        end
        next
      end
      
      # if we arrive here, it's a repo config.
      config = line.split(',')
      repo = Repo.new
      repo.location = @locations.find {|x| x.name == config[0] }
      repo.repo_type = config[1]
      repo.name = config[2]
      repo.url = config[3]
      @repos << repo
      if !repo.complete?
        ErrorManager.abort_malformed_config_line i, line
      end
    end
  end

  def locations
    return @locations
  end

  def repos repo_type = :all
    temp = @repos
    unless repo_type == :all
      temp = temp.find_all {|x| x.repo_type == repo_type.to_s }
    end
    return temp
  end

  def repo_types
    return @repo_types
  end

  # Returns all repos for a certain location
  def get_repos_for location, repo_type = :all
    temp = @repos.find_all {|x| x.location.name == location.name }
    unless repo_type == :all
      temp = temp.find_all {|x| x.repo_type == repo_type.to_s }
    end
    return temp
  end
  
  # Return a random repo for the specified location.
  def get_random_repo_for location, repo_type = :all
    if repo_type == :all
      return @repos.find {|x| x.location.name == location.name }
    end
    return @repos.find {|x| x.location.name == location.name &&
                            x.repo_type == repo_type.to_s}
  end
  
#   def save
  
#   end

end
