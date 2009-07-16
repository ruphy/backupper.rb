
# Class to handle git operations with a friendly GUI.
# Before using it, make sure to call GitGui.settings = the SettingsManager you're using.
# GitGui.widget can also be used to set the parent of the dialogs

class GitGui
  
  def GitGui.widget= w
    @widget = w
  end
  
  def GitGui.settings= s
    @settings = s
  end
  
  def GitGui.commit_ok? manager, location
    log = String.new
    d = KDE::Dialog.new @widget
    is_gibak = manager.is_gibak
    
    if is_gibak
      label = Qt::Label.new "Really commit?" ## TODO better text
      d.main_widget = label
      d.exec
      
      if d.result == Qt::Dialog::Accepted then
        manager.commit "" # gibak commit, log is not important
        return true
      end
      return false
      
    else
      t = Qt::TextEdit.new
      t.plain_text = "# log message \ncommit status as of:\n" + Time.now.to_s
      d.main_widget = t
      if log.empty? && is_gibak
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
        manager.add
        manager.commit clean_log
        return true
      end
      return false
    end
    return false # we should never arrive here.
  end
  
  def GitGui.push_dialog location
    d = KDE::Dialog.new @widget

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
    
    d.main_widget = w
    d.exec

    if d.result == Qt::Dialog::Accepted then
      @settings.get_repos_for(location).each do |repo|
        repo.manager.push if !group_box.checked or checkboxes[repo].is_checked
      end
    end
  end

end

