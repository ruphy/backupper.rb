
$ui_file = "backupper.ui"
$config_file = "backup_places.cfg"

require 'korundum4'
require 'settings_manager.rb'
require 'git_manager.rb'
# compile the rb file each time from the ui, so we make sure it's
# up to date. it's very cheap, and easier for development
system("rbuic4 #{$ui_file} > backupper_ui.rb")
require 'backupper_ui.rb'

# dev variables
$debug = true
$dry_run = true

def debug string
  puts "--- #{Dir.pwd} ### #{string}" if $debug
end

# Force run, even in dry_run mode
def f_run c
  run c, true
end

def run command, force_run = false
  debug "pretending to run -- #{command}" if ($dry_run and !force_run)
  debug "running '" + command +"'" unless ($dry_run and !force_run)
  `#{command}` unless ($dry_run and !force_run)
end

def cd path
  path = File.expand_path path
  unless File.directory? path
    puts "#{path} is not a valid directory, not CD'ing into it..."
    return
  end
  return if Dir.pwd == path
  debug("Dir.chdir #{path}")
  Dir.chdir path
end

class Widget < Qt::Widget

  def initialize parent = nil
    super(parent)

    @git = Hash.new
    
    @settings = SettingsManager.new    
    @settings.locations.each do |l|
      @git[l.uid] = l.manager_for(:git) if l.uses? :git
    end
      
    l = Qt::VBoxLayout.new
    ui_widget = Qt::Widget.new
    @ui = Ui::Form.new
    @ui.setup_ui ui_widget

    add_gits

    l.addWidget Qt::Label.new "<big><center><b>ruphy</b>'s Backup Manager!</center></big>"
    l.addWidget ui_widget

    setLayout(l)
  end

  def add_gits
    @settings.locations.each do |location|
      l_sym = location.name.to_sym
      title = "#{location.name.capitalize}"
      title += " (home)" if location.name == "gibak"
      group_box = Qt::GroupBox.new title
      status_label = Qt::Label.new
      buttons_header = Qt::Label.new "Git commands:"
      status_button = Qt::PushButton.new "status"
      commit_button = Qt::PushButton.new "add and commit"
      commit_button.text = "gibak commit" if location.name == "gibak"
      push_button = Qt::PushButton.new "push (...)"
      v_layout = Qt::VBoxLayout.new
      v_layout.add_widget buttons_header
      v_layout.add_widget status_button
      v_layout.add_widget commit_button
      v_layout.add_widget push_button
      h_layout = Qt::HBoxLayout.new
      h_layout.add_widget status_label
      h_layout.add_item v_layout
      group_box.layout = h_layout

      set_status_label_clean(status_label, @git[location.uid].working_dir_clean?)

      status_button.connect(SIGNAL :clicked) do
        show_index_status_dialog @git[location.uid].status
      end

      push_button.connect(SIGNAL :clicked) do
        git_push_dialog location
      end

      commit_button.connect(SIGNAL :clicked) do
        if git_commit location
          set_status_label_clean(status_label, @git[location.uid].working_dir_clean?)
        end
      end

      @ui.git_layout.add_widget group_box
    end

    @ui.git_layout.add_stretch
  end

  def git_commit location
    log = String.new
    d = KDE::Dialog.new self
    repo_sym = @settings.get_random_repo_for location, :git
    
    if repo_sym == :gibak
      label = Qt::Label.new "Really commit?"
      d.main_widget = label
      
      if d.result == Qt::Dialog::Accepted then
        @git[location.uid].commit "" # gibak commit
        return true
      end
      return false
      
    else
      t = Qt::TextEdit.new
      t.plain_text = "# log message \ncommit status as of:\n" + Time.now.to_s
      d.main_widget = t
      if log.empty? && !location.name.to_sym == :gibak
        log = "Empty log"
      end
      d.exec
      
      log = t.to_plain_text
      clean_log = ""
      log.split("\n").each do |line|
        next if line.strip.start_with? '#'
        clean_log += "#{line}\n"
      end
      clean_log.strip!
      
      if d.result == Qt::Dialog::Accepted then
        @git[location.uid].add
        @git[location.uid].commit clean_log
        return true
      end
      return false
    end
    return false # we should never arrive here.
  end

  def set_status_label_clean label, clean
    if clean
      label.text = "The index is <b style=\"color:#55aa00;\">clean</b>."
    else
      label.text = "The index is <b style=\"color:red;\">dirty</b>."
    end
  end

  def show_index_status_dialog text
    d = KDE::Dialog.new self
    t = Qt::TextEdit.new
    t.text = text
    t.read_only = true
    d.size_grip_enabled = true
    d.main_widget = t
    d.show
  end
  
  def git_push_dialog location
    d = KDE::Dialog.new self

    w = Qt::Widget.new
    l = Qt::VBoxLayout.new
    label = Qt::Label.new("Please select the repos where you want to push:")
    l.add_widget label

    checkboxes = Hash.new

    group_box = Qt::GroupBox.new "Push into individual repos"
    group_box.layout = Qt::VBoxLayout.new
    group_box.checkable = true
    group_box.checked = false

    l.add_widget group_box
    @settings.get_repos_for(location).each do |repo|
      checkboxes[repo] = Qt::CheckBox.new(
                         "#{repo.name} - (#{repo.repo_type.to_s})",
                         group_box)
      
      group_box.layout.add_widget checkboxes[repo]
    end

    w.layout = l

    d.size_grip_enabled = true
    d.main_widget = w
    d.exec

    if d.result == Qt::Dialog::Accepted then
      if group_box.checked
        @settings.get_repos_for(location).each do |repo|
          if checkboxes[repo].is_checked
            @gits[location.name.to_sym].push repo.remote
          end
        end
      else
        @settings.get_repos_for(location).each do |repo|
            repo.manager.push
        end
      end
    end
  end

end

