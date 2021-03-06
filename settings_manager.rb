
require 'error_manager'
require 'location_manager'

# internal function, to get managers easier
def get_manager object, repo_type = nil
  manager = nil
  if object.class == Location
    manager = GitLocationManager.new(object) if repo_type.to_sym == :git
  elsif object.class == Repo
    manager = GitManager.new(object) if object.repo_type.to_sym == :git
  end
  
  if manager == nil
    puts "WARNING: no manager found for object #{object} of type #{repo_type}. Please report a bug" # TODO Better text
  end
  return manager
end

class Location
  attr_accessor :name, :path

  def initialize
    @repos = Array.new
    @managers = Hash.new
  end
  
  def uid
    return name.to_sym
  end
  
  def add_repo repo
    @repos << repo if repo.class == Repo
  end
  
  # True if we have at least one repo of type repo_type
  def uses? repo_type
    @repos.each do |r|
      return true if r.repo_type.to_sym == repo_type.to_sym
    end
    return false
  end
  
  # Returns a LocationManager of the type 'repo_type' (symbol), nil if we have no such thing.
  def manager_for repo_type
    return nil unless self.uses? repo_type
    if @managers[repo_type] == nil
      @managers[repo_type] = get_manager self, repo_type
    end
    return @managers[repo_type]
  end
  
  def get_repos_for_type repo_type = :any
    return @repos if repo_type == :any
    return @repos.find_all {|x| x.repo_type.to_sym == repo_type.to_sym }
  end
  
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
    @manager = nil
  end
  
  def add_remote remote
    @remotes << remote
  end
  
  def manager
    if @manager == nil
      @manager = get_manager self
    end
    return @manager
  end
  
  def complete?
    begin
      if !name.empty? && !url.empty? &&
         location.complete?
        return true
      end
    rescue NoMethodError
    end
    return false
  end
end

class SettingsManager

  def initialize filename
    @repos = Array.new
    @locations = Array.new
    @filename = filename
    parse_config
  end

  def parsed_location? line
    if line.start_with? '['
      c = line.split('=')
      c[0].gsub!('[', '').gsub!(']', '')
      l = Location.new
      l.name = c[0]
      l.path = c[1]
      @locations << l
      if !l.complete?
        ErrorManager.abort_malformed_config_line i, line
        return false # We'll exit here anyways, just for code clarity.
      end
      return true
    end
    return false
  end
  
  def parse_repo line
      config = line.split(',')
      repo = Repo.new
      repo.location = @locations.find {|x| x.name == config[0] }
      begin
        repo.repo_type = config[1].downcase.to_sym
      rescue ArgumentError # means that repo_type == ""
        ErrorManager.abort_malformed_config_line i, line
      end
      repo.name = config[2]
      repo.url = config[3]
      repo.location.add_repo repo # Associate the repo to the location
      @repos << repo
      if !repo.complete?
        ErrorManager.abort_malformed_config_line i, line
      end
  end
  
  def parse_config
    i = 0
    IO.foreach(@filename) do |line|
      # line counter
      i = i + 1
      
      # don't parse carriage returns and extra spaces!
      line.strip!
      
      # skip comments, empty line
      next if line.start_with? '#'
      next if line.empty?
      
      next if line.include? 'config.'
      
      # first, locations!
      next if parsed_location? line
      
      # if we arrive here, it's a repo config.
      parse_repo line
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

  # Returns all repos for a certain location. Deprecated, use location.repos
  def get_repos_for location, repo_type = :all
    temp = @repos.find_all {|x| x.location.name == location.name }
    unless repo_type == :all
      temp = temp.find_all {|x| x.repo_type == repo_type.to_s }
    end
    return temp
  end
end
