Sketchup::require 'sketchup.rb'
Sketchup::require 'extensions.rb'
Sketchup::require 'geores_src/g_r_e_s_context_tools.rb'


#Register the Sandbox Tools with SU's extension manager
toolext1 = SketchupExtension.new "GEORES CityGML Import V2", "geores_src/geores_parser/citygml_import_main.rbs"
 
toolext1.description="Adds a CityGML Importer to Sketchup"

toolext1.version="2.0"
toolext1.creator = "GEORES"
toolext1.copyright = "2016, GEORES"
#test nur CityGML 2.0
#Default on in pro and off in free                        
Sketchup.register_extension toolext1, true

wt_extensionK = SketchupExtension.new("GEORES CityGML Edit Dialog V2", "geores_src/geores_gui/gres_editdlg.rb")

wt_extensionK.description = "GEORES CityGML Objekt Dialog"
wt_extensionK.version = "2.0"
wt_extensionK.creator = "GEORES"
wt_extensionK.copyright = "2016, GEORES"

# Register the extension with Sketchup.
Sketchup.register_extension wt_extensionK, true

toolbar_ext = SketchupExtension.new("GEORES CityGML Toolbars V2", "geores_src/geores_toolbar/LayerGenerator.rb")

toolbar_ext.description = "GEORES CityGML Toolbars"
toolbar_ext.version = "2.0"
toolbar_ext.creator = "GEORES"
toolbar_ext.copyright = "2016, GEORES"

# Register the extension with Sketchup.
Sketchup.register_extension toolbar_ext, true

UI.add_context_menu_handler do |menu|

        menu.add_item("GEORES CityGML Kopiere LoD") {
            tools = GRES_ContextTools.new()
            tools.copylod()
      }
      menu.add_item("GEORES CityGML Info") {
            tools = GRES_ContextTools.new()
            tools.info()
      }
       menu.add_item("GEORES CityGML Manuell zuweisen") {
            tools = GRES_ContextTools.new()
            tools.manual()
      }
     

end


wt_exp_extension = SketchupExtension.new("GEORES CityGML Export V2",  "geores_src/geores_export/gres_export_main.rbs")

wt_exp_extension.description = "GEORES CityGML Export"
wt_exp_extension.version = "2.0"
wt_exp_extension.creator = "GEORES"
wt_exp_extension.copyright = "2016, GEORES"

# Register the extension with Sketchup.
Sketchup.register_extension wt_exp_extension, true


