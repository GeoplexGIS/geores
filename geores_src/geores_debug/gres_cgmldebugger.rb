# Hilfsdebugger fuer die Ausgabe von Strings in eine Textdatei
# Für die Benutzung die Kommentare in den Methoden entfernen und einen passenden Dateipfad angeben.

class GRES_CGMLDebugger
  def initialize
    
  end

  def self.init()
    #@@filestream = File.open("D:/debugSketchup.txt", "w")
  end

  def self.writedebugstring(str)
    #@@filestream << str
  end

  def self.close()
  # @@filestream.close()
  end
end
