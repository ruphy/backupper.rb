
class Gui
  
  def Gui.widget= w
    @widget = w
  end
  
  def Gui.show_index_status_dialog text
    d = KDE::Dialog.new @widget
    t = Qt::TextEdit.new
    t.text = text
    t.read_only = true
    d.main_widget = t
    d.show
  end
end