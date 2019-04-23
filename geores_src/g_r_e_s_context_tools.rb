# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'sketchup.rb'
Sketchup::require 'geores_src/geores_gui/geores_selection/gres_selectable_city_object.rb'
Sketchup::require 'geores_src/geores_toolbar/gres_manual_selector.rb'

class GRES_ContextTools
  @@currentParentString = ""
  
  def initialize
  end

 def self.setcurrentParentObject parent
    @@currentParentString = parent
  end

  def info()
    model = Sketchup.active_model
    selection = model.selection
    info = ""
    selection.each { |entity|

       if(entity.class == Sketchup::Face)
            faceatts = entity.attribute_dictionary("faceatts", false)
            if(faceatts != nil)
              counter = 0
              while(faceatts["parent" + counter.to_s] != nil)
                info = faceatts["parent" + counter.to_s]
                counter = counter + 1
              end
            end
       end
    }
    if(info == "")
      UI.messagebox("Keine CityGML Information fuer diese Selektionsmenge vorhanden:")
      return
    end
    UI.messagebox("Face gehoert zu CityGML Objekt: " + info)
  end

  def manual()

    manualselector = GRES_ManualSelector.new
    Sketchup.active_model.select_tool(manualselector)

   # selection.each { |entity|

    # if(entity.class == Sketchup::Group)
    #        handleManualGroup(entity.entities,parentString,lodString,isSolid)
     # elsif(entity.class == Sketchup::ComponentInstance)
    #      handleManualGroup(entity.definition.entities,parentString,lodString,isSolid)
    # elsif(entity.class == Sketchup::Face)
    #      handleManualFace(entity,parentString,lodString,isSolid)
    #  end
     # }
      # inst = GRES_CityObjectDialog.get_instance
    # if(inst != nil)
     #  inst.removeSelection
    # end

  end


  def handleManualGroup (entities,parentString,lodString,isSolid)
     entities.each { |entity|

     if(entity.class == Sketchup::Group)
            handleManualGroup(entity.entities,parentString,lodString,isSolid)
      elsif(entity.class == Sketchup::ComponentInstance)
          handleManualGroup(entity.definition.entities,parentString,lodString,isSolid)
     elsif(entity.class == Sketchup::Face)
          handleManualFace(entity,parentString,lodString,isSolid)
      end
      }
  end

  def handleManualFace(ent,parentString,lodString,isSolid)
     faceatts = ent.attribute_dictionary("faceatts", true)
     faceatts.each_key{|key|
          faceatts.delete_key(key)
     }
     parents = parentString.split(".")
     counter = 0
     parents.each { |str|
       str = str.gsub(".", "")
       faceatts["parent" + counter.to_s] = str
       counter = counter + 1
     }
     faceatts["lod"] = lodString
     if(isSolid == true)
       faceatts[lodString + "Solid"] = "true"
     end

  end



  def copylod
    model = Sketchup.active_model
    selection = model.selection
    old_lod = ""
    selection.each { |entity|

       if(entity.class == Sketchup::Group)
            old_lod = checklodgroup(entity)
       elsif(entity.class == Sketchup::ComponentInstance)
          entity.definition.entities.each { |e|
                if(e.class == Sketchup::Face)
                       old_lod = checklodface(entity)
                    elsif(e.class == Sketchup::Group)
                       old_lod = checklodgroup(entity)
                  end

          }
       end
    }
    defaults = ["lod2"]
     prompts = ["Kopiere Auswahl von " + old_lod + " nach "]
     arrayString = ""
     if(old_lod == "lod1")
       defaults = ["lod2"]
       arrayString = "lod2|lod3|lod4"
     end
     if(old_lod == "lod2")
       defaults = ["lod3"]
       arrayString = "lod3|lod4"
     end
     if(old_lod == "lod3")
       defaults = ["lod4"]
       arrayString = "lod4"
     end
     if(old_lod == "lod4")
       UI.messagebox "Geoemtrien sind bereits in der höchsten Detailstufe vorhanden" , MB_OK
      return
     end
     
     list =  [arrayString]
     lod = UI.inputbox prompts, defaults, list, "Kopiere LoD"
     if(lod == nil)
       return
     end
     lodstring = lod[0].to_s
     selection.each { |entity|
         
       if(entity.class == Sketchup::Group)
            newgroup = entity.copy
            new_name = entity.name.to_s
            newgroup.name= new_name.sub(old_lod, lodstring)
            groupatts = entity.attribute_dictionary("groupatts", false)
            if(groupatts != nil and groupatts["lod"] != nil)
              #nur Gruppenattribute kopieren
              newgroupatts = newgroup.attribute_dictionary("groupatts", true)
              groupatts.each_key { |key|
                  if(key == "lod")
                    newgroupatts[key] = lodstring
                  else
                    newgroupatts[key] = groupatts[key]
                  end

              }

            else
                handlecopygroup(newgroup, lodstring, old_lod)
            end

       elsif(entity.class == Sketchup::ComponentInstance)
          
          newgroup = model.active_entities.add_instance(entity.definition, entity.transformation)
          newgroup.make_unique
          newgroup.name= entity.name.sub(old_lod, lodstring)
           groupatts = entity.attribute_dictionary("groupatts", false)
            if(groupatts != nil and groupatts["lod"] != nil)
              #nur Gruppenattribute kopieren
              newgroupatts = newgroup.attribute_dictionary("groupatts", true)
              groupatts.each_key { |key|
                  if(key == "lod")
                    newgroupatts[key] = lodstring
                  else
                    newgroupatts[key] = groupatts[key]
                  end

              }

            else
               newgroup.definition.entities.each { |e|
                if(e.class == Sketchup::Face)
                       handlecopyface e, lodstring, old_lod
                    elsif(e.class == Sketchup::Group)
                      handlecopygroup(e, lodstring, old_lod)
                  end

                }
            end
       end
    }
  end

  def checklodface(entity)
    faceatts = entity.attribute_dictionary("faceatts", false)
    if(faceatts != nil)
      return faceatts["lod"]
    end
    return ""
  end

  def checklodgroup(entity)
     entity.entities.each { |e|
                if(e.class == Sketchup::Face)
                       return checklodface(e)
                    elsif(e.class == Sketchup::Group)
                       return checklodgroup(e)
                  end

          }
          return ""
  end

  def checklod_replace str
    if(str.index("lod1") != nil)
      return "lod1"
    end
    if(str.index("lod2") != nil)
      return "lod2"
    end
    if(str.index("lod3") != nil)
      return "lod3"
    end
    if(str.index("lod4") != nil)
      return "lod4"
    end
    return "lodx"
  end


  def handlecopygroup group, lod, old_lod
     
     group.name= group.name.sub(old_lod, lod)
     group.entities.each { |e|
              if(e.class == Sketchup::Face)
                  handlecopyface e, lod, old_lod
              elsif(e.class == Sketchup::Group)
                handlecopygroup(e, lod, old_lod)
              end
      }
  end

  def handlecopyface face, lod, old_lod
    faceatts = face.attribute_dictionary("faceatts", true)
    faceatts["lod"] = lod
    puts "Old LoD " + old_lod.to_s + "Solid"
    if(faceatts[old_lod.to_s + "Solid"] != nil)
      faceatts.delete_key(old_lod.to_s + "Solid")
      faceatts[lod.to_s+ "Solid"] = true
    end
  end
end
