
$ui_file = "backupper.ui"
$config_file = "backup_places.cfg"

require 'korundum4'
require 'settings_manager'
require 'location_manager'
require 'git_manager'
require 'gui'
require 'git_gui'

require 'common'
# Sets $types, $debug and $dry_run
read_global_vars $config_file

# compile the rb file each time from the ui, so we make sure it's
# up to date. it's very cheap, and easier for development-
system("rbuic4 #{$ui_file} > backupper_ui.rb") if $debug
require 'backupper_ui.rb'


class Widget < Qt::Widget

  def initialize parent = nil
    super(parent)

    @git = Hash.new
    
    @settings = SettingsManager.new $config_file
    @settings.locations.each do |l|
      @git[l.uid] = l.manager_for(:git) if l.uses? :git
    end
    
    Gui.widget = self
    GitGui.settings = @settings
    
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
      title += " (home)" if @git[location.uid].is_gibak
      group_box = Qt::GroupBox.new title
      status_label = Qt::Label.new
      status_button = Qt::PushButton.new "status"
      commit_button = Qt::PushButton.new "add and commit"
      commit_button.text = "gibak commit" if @git[location.uid].is_gibak
      push_button = Qt::PushButton.new "push (...)"
      status_layout = Qt::VBoxLayout.new
      status_layout.add_widget Qt::Label.new "Last pushes:", group_box
      v_layout = Qt::VBoxLayout.new
      v_layout.add_widget status_button
      v_layout.add_widget commit_button
      v_layout.add_widget push_button
      left_layout = Qt::VBoxLayout.new
      left_layout.add_widget status_label
      left_layout.add_stretch
      left_layout.add_item status_layout
      h_layout = Qt::HBoxLayout.new
      h_layout.add_item left_layout
      h_layout.add_item v_layout
      group_box.layout = h_layout

      @settings.get_repos_for(location).each do |repo|
        string = "#{repo.name} - "#{lookup_lastest_push_for repo}"
        status_layout.add_widget Qt::Label.new string, group_box
      end
      
      set_status_label_clean(status_label, @git[location.uid].working_dir_clean?)

      status_button.connect(SIGNAL :clicked) do
        Gui.show_index_status_dialog @git[location.uid].status
      end

      push_button.connect(SIGNAL :clicked) do
        GitGui.push_dialog location
      end

      commit_button.connect(SIGNAL :clicked) do
        if GitGui.commit_ok? @git[location.uid], location
          set_status_label_clean(status_label, @git[location.uid].working_dir_clean?)
        end
      end

      @ui.git_layout.add_widget group_box
    end

    @ui.git_layout.add_stretch
  end

  def set_status_label_clean label, clean
    if clean
      label.text = "The index is <b style=\"color:#55aa00;\">clean</b>."
    else
      label.text = "The index is <b style=\"color:red;\">dirty</b>."
    end
  end

end

