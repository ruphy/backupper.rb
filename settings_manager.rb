
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
    @repos = Hash.new
    @locations = Hash.new
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
        @locations[l.name.to_sym] = l
        @repos[l.name.to_sym] = Array.new
        if !l.complete?
          ErrorManager.abort_malformed_config_line i, line
        end
        next
      end
      
      # if we arrive here, it's a repo config.
      config = line.split(',')
      repo = Repo.new
      repo.location = @locations[config[0].to_sym]
      repo.repo_type = config[1]
      repo.name = config[2]
      repo.url = config[3]
      @repos[repo.location.name.to_sym] << repo
      if !repo.complete?
        ErrorManager.abort_malformed_config_line i, line
      end
    end
  end

  def locations
    return @locations.values
  end

  def repos repo_type = :all
    if repo_type == :all
      return @repos.values
    else
      temp = Array.new
      @repos.values.each do |repo|
        temp << repo if repo.repo_type == repo_type.to_s
      end
      return temp
    end

  end

  def repo_types
    return @repo_types
  end
  
  def get_repos_for location, repo_type = :all
    if repo_type == :all
      return @repos[location.name.to_sym]
    else
      temp = Array.new
      @repos[location.name.to_sym].each do |repo|
        temp << repo if repo.repo_type == repo_type.to_s
      end
      return temp
    end
  end

end
