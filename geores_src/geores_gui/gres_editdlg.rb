# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'sketchup.rb'
Sketchup::require 'geores_src/geores_gui/gres_city_object_dialog.rb'

if(not $tool_command_loaded_edit)

    cmd_edit = UI::Command.new("GEORES CityGML Objekt Dialog") {


          gui = GRES_CityObjectDialog.new("CityGML Objekt Dialog (GEORES)", true, "EDITDIALOG", 430, 550, 15, 15, true)
          #htmldialog = CityGMLWriterDialog.new()
          #gui.set_html(htmldialog.gethtmldialog())
          gui.set_file(File.dirname(__FILE__) + "/cityobjects_dlg.html");
          gui.show()
          
          gui.add_action_callback("showlod") {| dialog , params |

              ps = params.split('&')
              lod = "lod" + ps[0].to_s
              checked = ps[1].to_s
              dialog.showlod(lod,checked)
             
          }

          
          gui.add_action_callback("refresh") {| dialog, params |
            dialog.refresh()
          }

          gui.add_action_callback("get_attributes") {| dialog, params |

                dialog.get_attributes(params)
          }

          gui.add_action_callback("get_attribute_content") {| dialog, params |
            ps = params.split('&')
           dictname = ps[0].to_s
           attribute= ps[1].to_s
           dialog.get_attribute_content(dictname, attribute)
          }

          gui.add_action_callback("save_attribute_content") {| dialog, params |
            ps = params.split('&')
           dictname = ps[0].to_s
           attribute= ps[1].to_s
           value = ps[2].to_s
           dialog.save_attribute_content(dictname, attribute, value)
          }

         
          gui.add_action_callback("handleobserver"){| dialog, params |
           dialog.handleobserver(params)
          } 
           gui.add_action_callback("delete"){| dialog, params |
              ps = params.split('&')
            objectToDelete = ps[0].to_s
            mainObject = ps[1].to_s
            dialog.delete(objectToDelete, mainObject)
          }

        gui.set_on_close() {
          gui.clear
          #gui.makeOldVisual
        }
}

  cmd_edit.status_bar_text = "GEORES CityGML Objekt Dialog"
  cmd_edit.menu_text = "GEORES CityGML Objekt Dialog"
  #UI.menu("Tools").add_separator
  $plugmenu = UI.menu("Tools")
  $plugmenu.add_item(cmd_edit)
  $tool_command_loaded_edit = true
end