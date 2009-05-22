
class GitGui
  def initialize git_manager
    @git = git_manager
  end

  def commit_dialog location
    log = String.new
    d = KDE::Dialog.new
    unless location.name.to_sym == :gibak
      t = Qt::TextEdit.new
      t.plain_text = "# log message \ncommit status as of:\n" + Time.now.to_s
      d.main_widget = t
    end
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
      @git.add
      @git.commit clean_log
      return true
    end
    return false
  end
  
  def push_dialog repos
    d = KDE::Dialog.new
    
    w = Qt::Widget.new
    l = Qt::VBoxLayout.new
    label = Qt::Label.new("Press OK to push in the selected repos.")
    l.add_widget label
    
    checkboxes = Hash.new
    
    group_box = Qt::GroupBox.new "Select individual repos..."
    group_box.layout = Qt::VBoxLayout.new
    group_box.checkable = true
    group_box.checked = false
    
    l.add_widget group_box
    repos.each do |repo|
      checkboxes[repo] = Qt::CheckBox.new(
        "#{repo.name} - (#{repo.repo_type.to_s})",
        group_box)
      checkboxes[repo].checked = true
      
      group_box.layout.add_widget checkboxes[repo]
    end
    
    w.layout = l
    
    d.size_grip_enabled = true
    d.main_widget = w
    d.exec
    
    if d.result == Qt::Dialog::Accepted then
      if group_box.checked
        repos.each do |repo|
          if checkboxes[repo].is_checked
            @git.push repo.remote
          end
        end
      else
        @git.push
      end
    end
  end

end

