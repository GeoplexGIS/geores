# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'sketchup.rb'
Sketchup::require 'geores_src/geores_parser/citygml_loader.rb'
Sketchup::require 'geores_src/geores_gui/time.rb'

class CityGMLImportMainGML < Sketchup::Importer
    # This method is called by SketchUp to determine the description that
       # appears in the File > Import dialog's pulldown list of valid
       # importers.
       def description
         return "CityGML GEORES Import V2 (*.gml)"
       end

       # This method is called by SketchUp to determine what file extension
       # is associated with your importer.
       def file_extension
         return "gml"
       end

       # This method is called by SketchUp to get a unique importer id.
       def id
         return "com.sketchup.importers.geores_cgml_v2"
       end

       # This method is called by SketchUp to determine if the "Options"
       # button inside the File > Import dialog should be enabled while your
       # importer is selected.
       def supports_options?
         return true
       end

       # This method is called by SketchUp when the user clicks on the
       # "Options" button inside the File > Import dialog. You can use it to
       # gather and store settings for your importer.
       def do_options
         @my_settings = UI.inputbox(['Vorhandene Verschiebung nutzen? '], ['Nein','Ja'], ['Nein|Ja'] , "Import Optionen")
         @my_translHeight = UI.inputbox(['Hoehenwerte verschieben'], ['Ja','Nein'], ['Ja|Nein'] , "Import Optionen")
         @my_SimpleLoad = UI.inputbox(['Import ohne Semantik'], ['Nein','Ja'], ['Nein|Ja'] , "Import Optionen")
         
       end

       # This method is called by SketchUp after the user has selected a file
       # to import. This is where you do the real work of opening and
       # processing the file.
       def load_file(file_path, status)
       #  UI.messagebox(file_path)
         # Eine XML-Datei laden
      # t = Time.now()
       # m = t.month()
       #  y = t.year()
       #  if(y != 2017 or m > 7 )
       #    UI.messagebox "Testversion abgelaufen. Bitte nehmen Sie mit uns Kontakt auf. info@geores.de" , MB_OK
       #    return 0
       #  end
        begin
         puts "initialize CityGMLLoader"
         reader = CityGMLLoader.new()
         puts "initialized CityGMLLoader"
         keep_transl = "Nein"
         if(@my_settings != nil)
           begin
             keep_transl = @my_settings[0]
             rescue =>e
                keep_transl = "Nein"
             end
         end
         translheight = "Ja"
         if(@my_translHeight != nil)
           begin
             translheight = @my_translHeight[0]
             rescue =>e
                translheight = "Ja"
             end
         end
         isSimple = "Nein"
         if(@my_SimpleLoad != nil)
           begin
             isSimple = @my_SimpleLoad[0]
             rescue =>e
                isSimple = "Nein"
             end
         end

         #TODO wieder rausnehmen -> speziell für VCS
         #doboundarysinglelayer = "Yes"
         # puts "go in load method with " + file_path
         reader.load(file_path, keep_transl, translheight, isSimple)
        rescue =>e
         UI.messagebox "Fehler beim Parsen des Dokumentes" + e.to_s, MB_OK
        end
          # Ausgabe der XML-Datei
         #puts doc.to_s
         return 0 # 0 is the code for a successful import
       end
     end

class CityGMLImportMainXML < CityGMLImportMainGML
    # This method is called by SketchUp to determine the description that
       # appears in the File > Import dialog's pulldown list of valid
       # importers.
       def description
         return "CityGML GEORES Import V2 (*.xml)"
       end

       # This method is called by SketchUp to determine what file extension
       # is associated with your importer.
       def file_extension
         return "xml"
       end

       # This method is called by SketchUp to get a unique importer id.
       def id
         return "com.sketchup.importers.geores_cgml_v2_xml"
       end
     end

Sketchup.register_importer(CityGMLImportMainGML.new)
Sketchup.register_importer(CityGMLImportMainXML.new)
