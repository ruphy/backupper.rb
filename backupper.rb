
$ui_file = "backupper.ui"
$config_file = "backup_places.cfg"

require 'korundum4'
require 'settings_manager'
# compile the rb file each time from the ui, so we make sure it's
# up to date. it's very cheap, and easier for development
system("rbuic4 #{$ui_file} > backupper_ui.rb")
require 'backupper_ui.rb'

# commodity function
def new symbol
  return symbol.new
end

class GitManager

  def initialize path
    @path = path
  end
  
  def is_working_dir_clean?
    @output = `cd #{@path}; git status`
    @output.each do |line|
      next if line.start_with? '#'
      return true if line.include? "working directory clean"
    end
    return false
  end

  def status
    return `cd #{@path}; git status`
  end

end

class Widget < Qt::Widget

  def initialize parent = nil
    super(parent)
    
    @settings = SettingsManager.new
    
    l = Qt::VBoxLayout.new
    ui_widget = Qt::Widget.new
    @ui = Ui::Form.new #load_ui("backupper.ui")
    @ui.setup_ui ui_widget

    connect_slots
    update_labels

    l.addWidget Qt::Label.new "<big><center><b>ruphy</b>'s Backup Manager!</center></big>"
    l.addWidget ui_widget

    setLayout(l)
  end

  def update_labels
    home_git = GitManager.new '~'
    if home_git.is_working_dir_clean?
      @ui.gibak_label.text = "The index is <b style=\"color:#55aa00;\">clean</b>."
    else
      @ui.gibak_label.text = "The index is <b style=\"color:red;\">dirty</b>."
    end
  end
  
  def connect_slots
    @ui.gibak_status.connect(SIGNAL :clicked) { gibak_show_status }
    @ui.gibak_push.connect(SIGNAL :clicked) { dialog_git_push :home }
  end

  def gibak_show_status # TODO: make me better
    d = KDE::Dialog.new self
    t = Qt::TextEdit.new
    t.text = `cd; git status`
    t.read_only = true
    d.size_grip_enabled = true
    d.main_widget = t
    d.show
  end

  def dialog_git_push repo
    d = KDE::Dialog.new self

    w = Qt::Widget.new
    l = Qt::VBoxLayout.new
    label = Qt::Label.new("Please select the repos where you want to push:")
    l.addWidget label

    get_locations_for(repo).each do |location|
      checkbox = Qt::CheckBox.new "#{location.name} - (#{location.type})"
      l.addWidget checkbox
    end

    w.layout = l

    d.size_grip_enabled = true
    d.main_widget = w
    d.show
  end

  def get_locations_for location
    return @settings.get_repos_for location
  end

end

