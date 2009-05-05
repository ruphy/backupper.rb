
class Location
  attr_accessor :name, :path
  
  def complete?
    begin
      if !name.empty? and !path.empty?
        return true
      end
    rescue NoMethodError
      return false
    end
  end
end

class Repo
  attr_accessor :location, :type,
                :name, :url
  
  def complete?
    begin
      if !name.empty? && !url.empty? &&
         location.complete? && !type.empty?
        return true
      end
    rescue NoMethodError
      return false
    end
  end
end

class SettingsManager

  def initialize
    @repos = Hash.new
    @locations = Hash.new
    reparse_config
  end

  def reparse_config
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
          puts "Malformed configuration line -- #{$config_file}:#{i}"
          puts ">> #{line}"
          exit 1
        end
        next
      end
      
      # if we arrive here, it's a repo config.
      config = line.split(',')
      repo = Repo.new
      repo.location = @locations[config[0].to_sym]
      repo.type = config[1]
      repo.name = config[2]
      repo.url = config[3]
      @repos[repo.location.name.to_sym] << repo
      if !repo.complete?
        puts "Malformed configuration line -- #{$config_file}:#{i}"
        puts ">> #{line}"
        exit 1
      end
    end
  end

  def get_repos_for location
    return @repos[location]
  end
  
end
