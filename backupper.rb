
$ui_file = "backupper.ui"
$config_file = "backup_places.cfg"

require 'korundum4'
require 'settings_manager.rb'
require 'git_manager.rb'
# compile the rb file each time from the ui, so we make sure it's
# up to date. it's very cheap, and easier for development
system("rbuic4 #{$ui_file} > backupper_ui.rb")
require 'backupper_ui.rb'

# commodity function
def new symbol
  return symbol.new
end

class Widget < Qt::Widget

  def initialize parent = nil
    super(parent)

    @gits = Hash.new
    
    @settings = SettingsManager.new
    @settings.repos("git").each do |r|
      next if !r.complete?
      s = r.location.name.to_sym
      @gits[s] = GitManager.new(r) if @gits[s] == nil
      @gits[s].add_remote r.url
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
      title = "#{location.name.capitalize}"
      title += " (gibak)" if location.name == "home"
      group_box = Qt::GroupBox.new title
      status_label = Qt::Label.new
      status_button = Qt::PushButton.new "Verbose status"
      push_button = Qt::PushButton.new "Push to..."
      v_layout = Qt::VBoxLayout.new
      v_layout.add_widget status_button
      v_layout.add_widget push_button
      h_layout = Qt::HBoxLayout.new
      h_layout.add_widget status_label
      h_layout.add_item v_layout
      group_box.layout = h_layout

      git_update_status_label(status_label, location)
      status_button.connect(SIGNAL :clicked) { git_status_dialog location }
      push_button.connect(SIGNAL :clicked) { git_push_dialog location }

      @ui.git_layout.add_widget group_box
    end

    @ui.git_layout.add_stretch
  end

  def git_update_status_label label, location
    if @gits[location.name.to_sym].working_dir_clean?
      label.text = "The index is <b style=\"color:#55aa00;\">clean</b>."
    else
      label.text = "The index is <b style=\"color:red;\">dirty</b>."
    end
  end

  def git_status_dialog location
    d = KDE::Dialog.new self
    t = Qt::TextEdit.new
    t.text = @gits[location.name.to_sym].status
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
    l.addWidget label

    @settings.get_repos_for(location).each do |repo|
      checkbox = Qt::CheckBox.new "#{repo.name} - (#{repo.repo_type.to_s})"
      l.addWidget checkbox
    end

    w.layout = l

    d.size_grip_enabled = true
    d.main_widget = w
    d.show
  end

end

