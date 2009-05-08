
$ui_file = "backupper.ui"
$config_file = "backup_places.cfg"

require 'korundum4'
require 'settings_manager.rb'
require 'git_manager.rb'
# compile the rb file each time from the ui, so we make sure it's
# up to date. it's very cheap, and easier for development
system("rbuic4 #{$ui_file} > backupper_ui.rb")
require 'backupper_ui.rb'

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
      l_sym = location.name.to_sym
      title = "#{location.name.capitalize}"
      title += " (home)" if location.name == "gibak"
      group_box = Qt::GroupBox.new title
      status_label = Qt::Label.new
      status_button = Qt::PushButton.new "status"
      commit_button = Qt::PushButton.new "add and commit"
      commit_button.text = "gibak commit" if location.name == "gibak"
      push_button = Qt::PushButton.new "push (...)"
      v_layout = Qt::VBoxLayout.new
      v_layout.add_widget status_button
      v_layout.add_widget commit_button
      v_layout.add_widget push_button
      h_layout = Qt::HBoxLayout.new
      h_layout.add_widget status_label
      h_layout.add_item v_layout
      group_box.layout = h_layout

      set_status_label_clean(status_label, @gits[l_sym].working_dir_clean?)

      status_button.connect(SIGNAL :clicked) {
        show_index_status_dialog @gits[l_sym].status
      }

      push_button.connect(SIGNAL :clicked) { git_push_dialog location }

      commit_button.connect(SIGNAL :clicked) {
        if git_commit(location)
          set_status_label_clean(status_label, @gits[l_sym].working_dir_clean?)
        end
      }

      @ui.git_layout.add_widget group_box
    end

    @ui.git_layout.add_stretch
  end

  def git_commit location
    log = String.new
    d = KDE::Dialog.new self
    unless location.name.to_sym == :gibak
      t = KDE::LineEdit.new
      t.text = "<log message...>"
      d.main_widget = t
      puts d.exec
      log = t.text()
    end
    if log == "" && !location.name.to_sym == :gibak
      log = "Empty log"
    end

    if d.result == Qt::Dialog::Accepted then
      @gits[location.name.to_sym].add
      @gits[location.name.to_sym].commit log
      return true
    end
    return false
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

