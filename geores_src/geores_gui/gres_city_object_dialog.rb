# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'sketchup.rb'
Sketchup::require 'geores_src/geores_gui/gres_city_object_selection_observer.rb'
Sketchup::require 'geores_src/geores_gui/gres_app_observer.rb'
Sketchup::require 'geores_src/geores_gui/geores_selection/gres_selectable_city_object.rb'
Sketchup::require 'geores_src/geores_parser/layer_creator.rb'
Sketchup::require 'geores_src/geores_toolbar/city_g_m_l_layer_maker.rb'
Sketchup::require 'geores_src/g_r_e_s_context_tools.rb'

class GRES_CityObjectDialog < UI::WebDialog

  @@theinstance = nil
  #@@hash_temp_sel = Hash.new()
  #@@globalcounter = 0
  @@lods = Array.new()
  @@observer = nil
  @@appObserver = nil
  @@objectfixed = false

  def initialize dialog_title, scrollable, pref_key, width, height, left, top, resizable
    super(dialog_title, scrollable, pref_key, width, height, left, top, resizable)
    model = Sketchup.active_model
    @@observer = GRES_CityObjectSelectionObserver.new(self)
    
    model.selection.add_observer(@@observer)
    #select = model.layers.add "select"
    #colorselect = Sketchup::Color.new(255, 255, 0)
    #colorselect.alpha = 128
   # select.color = colorselect
    @@appObserver = GRES_AppObserver.new(self)
    Sketchup.add_observer(@@appObserver)
    @@theinstance = self
    @@lods.push("lod1")
    @@lods.push("lod2")
    @@lods.push("lod3")
    @@lods.push("lod4")

  end

  def self.getobserver
    return @@observer
  end

  def self.getlods
    return @@lods
  end

  def self.get_instance
    return @@theinstance
  end




  def handleobserver ischecked
    if(ischecked == "true")
       model = Sketchup.active_model
       model.selection.remove_observer(@@observer)
       @@objectfixed = true
       #opts = model.rendering_options
       #opts['DisplayColorByLayer']= true
    else
       model = Sketchup.active_model
       model.selection.add_observer(@@observer)
       @@objectfixed = false
       #opts = model.rendering_options
       #opts['DisplayColorByLayer']= false
       #removeSelection()
    end
  end

  def showlod(lod, checked)
    if(checked == "false")
      @@lods.delete(lod)
    else
      if(@@lods.index(lod) == nil)
        @@lods.push(lod)
      end
    end
     model = Sketchup.active_model
        model.entities.each do |entity|
          showlodentity(entity, lod, checked)
       end
  end

#  def removeSelection
#    model = Sketchup.active_model
#     @@hash_temp_sel.each_key { |key|
#        ent = @@hash_temp_sel[key]
#        loop = 0
#        key.each_line('.'){|substr|
#           substr = substr.chomp('.')
#            if(substr != nil and loop == 0)
#              puts "search layer for " + substr
#              oldlayer = model.layers[substr]
#              if(oldlayer != nil and ent.valid? and ent.deleted? == false)
#                ent.layer = oldlayer
#              end
#
#            end
#            loop = loop + 1
#            }
#
#        }
#
#
#      @@hash_temp_sel.clear
#  end

  def delete(objectToDelete, mainObject)
    model = Sketchup.active_model
    dictionaries = model.attribute_dictionaries
    dictionaries.delete(objectToDelete)
    model.attribute_dictionary("deleted_" + objectToDelete, true)
    dictionaries.each{ |dict|
      parentname = dict["parent"]
      if(parentname != nil and parentname.index(mainObject) != nil and parentname.index("." + objectToDelete) != nil)
        newparentname = parentname.gsub("." + objectToDelete, "")
        dict["parent"] = newparentname
      end
    }

    entities = model.active_entities

    entities.each{ |ent|
      if(ent.class == Sketchup::Face)
        handleDeleteObjectFace(ent, objectToDelete, mainObject)
      elsif(ent.class == Sketchup::Group)
         handleDeleteObjectGroup(ent, objectToDelete, mainObject)
       elsif(ent.class == Sketchup::ComponentInstance)

        end
    }

 
  GRES_CityObjectDialog.delete(objectToDelete)
  end
  
 def handleDeleteObjectGroup(group, tagname,mainobjectname)
     group.entities.each{ |e1|
          if(e1.class == Sketchup::Face)
            handleDeleteObjectFace(e1, tagname,mainobjectname)
          elsif(e1.class == Sketchup::Group)
            handleDeleteObjectGroup(e1, tagname,mainobjectname)
          end
     }
  end
  
  def handleDeleteObjectFace(entity, tagname,mainobjectname)
     entdict = entity.attribute_dictionary "faceatts"
     if(entdict == nil)
       return
     end
     parent0 = entdict["parent0"]
     if(parent0 == nil)
       return
     end
     if(parent0 == mainobjectname)

                counter = 1
                deletedcounter = -1
                while(counter < 7)
                  parentname = entdict["parent" + counter.to_s]
                  if(parentname != nil)
                    if(parentname == tagname)
                      entdict.delete_key("parent" + counter.to_s)
                      deletedcounter = counter
                    else
                      if(deletedcounter != -1)
                        entdict["parent" + (counter-1).to_s] = parentname
                        entdict.delete_key("parent" + counter.to_s)
                      end
                    end
                  end
                  counter = counter +1
                end
     
    end
  end



  def get_attributes tagname
     model = Sketchup.active_model
     #opts = model.rendering_options
     #opts['DisplayColorByLayer']= true
      js_command = "clearAttributeList();"
      self.execute_script(js_command)
      if(tagname == nil)
        return
      end
      parentobjectname = tagname
      if(tagname.index("@") != nil)
         arr= tagname.split("@")
        parentobjectname = arr[arr.length-1]
        if(parentobjectname.index("Solid") != nil)
           parentobjectname = arr[arr.length-2] + "@" + arr[arr.length-1]
        end
      end
      puts parentobjectname
     
     #removeSelection()
     CityGMLLayerMaker.setcurrentParentObject(parentobjectname)
     GRES_ContextTools.setcurrentParentObject(parentobjectname)
     self.execute_script(js_command)
     dictionaries = model.attribute_dictionaries
     dictionary = dictionaries[parentobjectname]
     if(dictionary != nil)
       dictionary.each_key{ |key|
         if(key != "parent" and key != "type")
             js_command = "selection_attributecall(\"" + key + "\");"
             self.execute_script(js_command)
         end
       }

     end

    entities = model.active_entities
    #if(@@objectfixed == true)
      model.selection.clear()
      entities.each{ |ent|
      if(ent.class == Sketchup::Face)
        handleselectionface(ent, parentobjectname)
      elsif(ent.class == Sketchup::Group)
            handleselectiongroup(ent, parentobjectname)
       elsif(ent.class == Sketchup::ComponentInstance)
         handleselectionCompInst(ent, parentobjectname)
        end
    }
    #end
    

  end



  def handleselectionface(entity, tagname)
     entdict = entity.attribute_dictionary "faceatts"
      model = Sketchup.active_model
      selection = model.selection
     # select = model.layers["select"]
     #if(select == nil)
      #     select = model.layers.add "select"
      #     colorselect = Sketchup::Color.new(255, 255, 0)
      #     colorselect.alpha = 128
      #     select.color = colorselect
     #end
      newtagname = tagname
      if(entdict != nil)
        if(tagname.index("Solid") != nil)
          arraynames = tagname.split("@")
          newtagname = arraynames[0].gsub("@", "")
          puts "Beim Splitten hier der Tagname " + tagname
          lodname = arraynames[1].gsub("@", "")
          puts "Beim Splitten hier der lodname " + lodname
          if(entdict[lodname] == nil or entdict[lodname] == "false")
              return
           end
         end
                counter = 0
                addToSelection = false
                while(counter < 7)
                  parentname = entdict["parent" + counter.to_s]
                  if(parentname != nil)
                    if(parentname == newtagname)
                       #puts "Parentname == tagname is true"
                      #@@hash_temp_sel[entity.layer.name + "." + @@globalcounter.to_s] = entity
                      #puts "new key is " + entity.layer.name + "." + @@globalcounter.to_s
                      #entity.layer = select
                      addToSelection = true
                      
                      #@@globalcounter = @@globalcounter +1
                    elsif(tagname.index("Solid") != nil and parentname != newtagname)
                      if(parentname.index("BuildingPart") != nil or parentname.index("BridgePart") != nil or parentname.index("TunnelPart") != nil)
                        addToSelection = false
                      end
                    end
                    end
                  counter = counter +1
                end

            end
            if(addToSelection == true)
              selection.add(entity)
            end
  end

  def handleselectiongroup(group, tagname)
     group.entities.each{ |ent|
          if(ent.class == Sketchup::Face)
              handleselectionface(ent, tagname)
        elsif(ent.class == Sketchup::Group)
            handleselectiongroup(ent, tagname)
          elsif(ent.class == Sketchup::ComponentInstance)
              handleselectionCompInst(ent, tagname)
        end
     }
  end

    def handleselectionCompInst(group, tagname)
     group.definition.entities.each{ |ent|
          if(ent.class == Sketchup::Face)
              handleselectionface(ent, tagname)
        elsif(ent.class == Sketchup::Group)
            handleselectiongroup(ent, tagname)
          elsif(ent.class == Sketchup::ComponentInstance)
              handleselectionCompInst(ent, tagname)
        end
     }
  end

    def save_attribute_content dictname, attname, value
     model = Sketchup.active_model
     dictionaries = model.attribute_dictionaries
     dictionary = dictionaries[dictname]
     if(dictionary != nil)
       dictionary[attname] = value
     end
    end


    def get_attribute_content dictname, attname
     model = Sketchup.active_model
      js_command = "clearAttributeContentList();"
      puts "get_attribute_content called with " + dictname + " and " + attname
      
     self.execute_script(js_command)
     dictionaries = model.attribute_dictionaries
     dictionary = dictionaries[dictname]
     if(dictionary != nil)
       value = dictionary[attname]
            if(value != nil)
             
             value = value.gsub("\"", "\\\"")
             values = value.split("\n")
             values.each { |v|
                js_command = "selection_attribute_contentcall(\"" + v + "\");"
                self.execute_script(js_command)
             }
             
         end
       
     end
  end

  def showlodentity (entity, lod, checked)
     if(entity.class == Sketchup::Face)
          entdict = entity.attribute_dictionary "faceatts"
          if(entdict != nil)
               value = entdict["lod"]
               if(value == nil)
                 return
               end
               if(value.index(lod) != nil)
                  if(checked == "true")
                    entity.hidden = false
                     edges = entity.edges
                    edges.each{|edge|
                      edge.hidden = false
                    }
                  else
                    entity.hidden = true
                    edges = entity.edges
                    edges.each{|edge|
                      edge.hidden = true
                    }
                  end
                end
           end

              elsif(entity.class == Sketchup::Group)
                if(entity.name.index(lod) != nil)
                  if(checked == "true")
                    entity.hidden = false
                  else
                    entity.hidden = true
                  end
                else
                  entity.entities.each{ |ent|
                    showlodentity(ent, lod, checked)
                  }
                end
              elsif(entity.class == Sketchup::ComponentInstance)
                entity.definition.entities.each{ |ent|
                    showlodentity(ent, lod, checked)
                  }
              end
  end

  def buildNewList
    js_command = "fillListWithCurrentObjects();"
     self.execute_script(js_command)
  end

  def buildMainObject(name, isLoD1, isLoD2, isLoD3, isLoD4)
    js_command = "createMainObject(\"" + name + "\"" + "," + isLoD1.to_s + "," + isLoD2.to_s + "," + isLoD3.to_s + "," + isLoD4.to_s + ");"
    puts js_command
     self.execute_script(js_command)
  end

  
  def selectionCallBack objects, hierarchy, parent
    js_command = ""

    objects.each_value { |obj|
       if(obj.name.index("BuildingPart") != nil or obj.name.index("TunnelPart") != nil or obj.name.index("BridgePart") != nil)
         js_command = "addPart(\"" + parent + "\",\"" + obj.name + "\"," + obj.lod1Solid.to_s + "," + obj.lod2Solid.to_s + "," + obj.lod3Solid.to_s + "," + obj.lod4Solid.to_s + ");"
         self.execute_script(js_command)
       elsif(obj.name.index("WallSurface") != nil or obj.name.index("GroundSurface") != nil or obj.name.index("RoofSurface") != nil or
         obj.name.index("FloorSurface") != nil or obj.name.index("ClosureSurface") != nil or obj.name.index("CeilingSurface") != nil or
         obj.name.index("WaterSurface") != nil or obj.name.index("WaterGroundSurface") != nil )

          js_command = "addBoundary(\"" + parent + "\",\"" + obj.name + "\");"
         
         self.execute_script(js_command)
       elsif(obj.name.index("BuildingInstallation") != nil or obj.name.index("BridgeInstallation") != nil or obj.name.index("TunnelInstallation") != nil)
          js_command = "addInstallation(\"" + parent + "\",\"" + obj.name + "\");"
         self.execute_script(js_command)
       elsif(obj.name.index("BridgeConstructionElement") != nil )
          js_command = "addConstruction(\"" + parent + "\",\"" + obj.name + "\");"
         self.execute_script(js_command)
       elsif(obj.name.index("Door") != nil or obj.name.index("Window") != nil )
          js_command = "addOpening(\"" + parent + "\",\"" + obj.name + "\");"
         self.execute_script(js_command)
        elsif(obj.name.index("TrafficArea") != nil)
          js_command = "addTrafficArea(\"" + parent + "\",\"" + obj.name + "\");"
         self.execute_script(js_command)
       end
       
       #puts js_command.to_s
       #self.execute_script(js_command)
       newhierarchy = hierarchy + 1
       selectionCallBack(obj.childs, newhierarchy, obj.name)
    }
  end

  def clear
    js_command = "clearOptionGroup();"
    #removeSelection()
     self.execute_script(js_command)
     js_command = "clear();"
    #removeSelection()
     self.execute_script(js_command)
     
  end

  def makeOldVisual
    model = Sketchup.active_model
    opts = model.rendering_options
     opts['DisplayColorByLayer']= false
  end

  def self.addchild(entity, newname)
    js_command = "addchild(\"" + newname+ "\");"
    model = Sketchup.active_model
    #select = model.layers["select"]
    if(@@theinstance != nil)
      @@theinstance.execute_script(js_command)
      #@hash_temp_sel[entity.layer.name + "." + @@globalcounter.to_s] = entity
       #entity.layer = select
       #@@globalcounter = @@globalcounter +1
    end
     
  end

  def self.removechild(name)
    js_command = "removechild(\"" + name+ "\");"
    if(@@theinstance != nil)
      @@theinstance.execute_script(js_command)
    end
  end

  def self.update(updates_hash)
    if(@@observer == nil )
      return
    end
    updates_hash.each_key { |key|

      parentname = updates_hash[key]
      parents = parentname.gsub(".", "@")
      puts parents
      #parentname = parents[parents.length-1].gsub(".", "")
     js_command = "addchildNew(\"" + key+ "\",\"" + parents + "\");"
     puts "call " + js_command
      if(@@theinstance != nil)
          @@theinstance.execute_script(js_command)
      end
    }

  end



end
