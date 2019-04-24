# Die Hauptklasse des Exportes
# Hier wird der Exportdialog gestartet und die Funktionen zum Befüllen des Dialogs aus Attributen
# sowie der Start des Exportes aufgerufen

Sketchup::require 'sketchup.rb'
Sketchup::require 'geores_src/geores_export/gres_citygml_exporter.rb'
Sketchup::require 'geores_src/geores_gui/time.rb'



    cmd = UI::Command.new("GEORES CityGML Export") {
          version = Sketchup.version.to_f

          if(version < 7.0)
            UI.messagebox("Sketchup 7 is required for this Plugin, please Update your Version from http://sketchup.google.com/intl/de/product/")
            return
          end
       
          #Aufruf des Dialogs
          gui = UI::WebDialog.new("CityGML Export Dialog (GEORES)", true, "Export Dialog", 430, 550, 15, 15, true)
          gui.set_file(File.dirname(__FILE__) + "/export_dlg.html");
          gui.show()


          gui.add_action_callback("Start") {| dialog , params |
              #Diese Funktion wird aufgerufen, wenn im Exportdialog der Start Knopf gedrückt wird.
              #Die Parameter werden in einem String geliefert. Einzelne Attribute werden mit & getrennt
              ps = params.split('&')
              #Im ersten String sollten nun die Transformationsparameter für x, y und z abgelegt sein.
              #Diese Parameter sind mit einem | getrennt
              translationArray = ps[0].split('|')

              dx = translationArray[0].to_f
              dy = translationArray[1].to_f
              dz = translationArray[2].to_f
              #für die Ausgabe in die Ruby Konsole
              #puts dx.to_s
              #puts dy.to_s
              #puts dz.to_s

              #Auszugebende LOD Stufen
              lod = ps[1].to_s
              #puts lod.to_s
              #Soll ein WFST Wexport gestartet werden
              iswfst = ps[2].to_s
              #puts iswfst.to_s
              #CityGML Version
              cgml = ps[3].to_s
              #puts cgml.to_s
              #Hier werden die zu exportierenden CityGML Klassen gefiltert. Diese befinden Sich in einem
              #String, der durhc | getrennt ist
              classArray = ps[4].split('|')
              classesToExport = Array.new()
              classArray.each { |name|
                  classname = name.gsub('|' , '')
                  if(classname != "")
                   # puts classname.to_s
                    classesToExport.push(classname)
                  end

              }


             #Der Ausgabepfad
             @filepath = ps[5].to_s
             #puts @filepath.to_s
             #Der Pfad zum Texturordner
             texfolder = ps[6].to_s
             # puts texfolder.to_s
             #Anpassungen des Ausgabepfades - ggf. hinzufügen von .xml
            filestring = @filepath.gsub('\\' , '/')
            if(filestring.end_with?(".xml") == false and filestring.end_with?(".gml") == false)
              filestring = filestring + ".xml"
            end
            srsname = ps[7].to_s
            #Aufruf der Exporterklasse mit den entsprechenden Parametern
            exporter = GRESCityGMLExporter.new(filestring,dx,dy,dz,lod,cgml,iswfst,classesToExport, texfolder,srsname)
            exporter.writetoCityGML

          }
     

          gui.add_action_callback("OpenFile") {| dialog, params |
            #Wird aufgerufen, wenn der "Save as" Knopf gedrückt wird
            filepath = UI.savepanel "Save CityGML File", "", "mydata.xml"
            filestring = filepath.gsub('\\' , '/')
            texfolder = "texturen"
            #Aufruf der JAVAScript Funktion um den Dialog zu befüllen.
            js_command = "UpdateFileField(\"" + filestring + "\", \"" + texfolder + "\");"
            dialog.execute_script(js_command)
               
          #puts js_command.to_s         
          }

          gui.add_action_callback("AddTranslation"){| dialog, params |
                  #Hier wird die Verschiebung ausgelesen.
                  #Sollten Verschiebungen vorhanden sein, so sind diese am Sketchup Model als Attribute gespeichert.
                  model = Sketchup.active_model
                  dx = model.get_attribute "translation", "dx", 0
                  dy = model.get_attribute "translation", "dy", 0
                  dz = model.get_attribute "translation", "dz", 0
                  #Aufruf der JAVAScript Funktion zum Befüllen des Dialogs
                  js_command = "UpdateTranslation(\"" + dx.to_s + "\",\"" + dy.to_s + "\",\"" + dz.to_s + "\");"
                  dialog.execute_script(js_command)
          }



    }

  #Hiermit wird das Export Kommando in die Toolbar von Sketchup integriert
  cmd.status_bar_text = "GEORES CityGML Export 2.0"
  cmd.menu_text = "GEORES CityGML Export 2.0"
  UI.menu("Tools").add_separator
  $plugmenu = UI.menu("Tools")
  $plugmenu.add_item(cmd)

