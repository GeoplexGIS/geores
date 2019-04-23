# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'sketchup.rb'
Sketchup::require 'geores_src/geores_parser/layer_creator.rb'
Sketchup::require 'geores_src/geores_toolbar/geores_layergensrc/name_tester.rb'
Sketchup::require 'geores_src/geores_toolbar/geores_layergensrc/number_generator.rb'
Sketchup::require 'geores_src/geores_gui/geores_selection/gres_selectable_city_object.rb'
Sketchup::require 'geores_src/geores_gui/gres_city_object_dialog.rb'
Sketchup::require 'geores_src/geores_toolbar/gres_boundary_layer_maker.rb'
Sketchup::require 'geores_src/geores_toolbar/gres_opening_layer_maker.rb'
Sketchup::require 'geores_src/geores_toolbar/gres_installation_layer_maker.rb'
Sketchup::require 'geores_src/geores_toolbar/gres_traffic_area_layer_maker.rb'

class CityGMLLayerMaker

@@currentParentString = ""

  def initialize()

    @numbergenerator = NumberGenerator.new()
    @numbergenerator.updatenumbers(Sketchup.active_model)
    @nametester = NameTester.new
    lm = LayerCreator.new()
    @updates = Hash.new()
  end

  def self.setcurrentParentObject parent
    @@currentParentString = parent
  end




  def createlayeropening(type)
     #inst = GRES_CityObjectDialog.get_instance
     #if(inst != nil)
      # inst.removeSelection
     #end
     layermaker = GRES_OpeningLayerMaker.new()
      layermaker.createlayeropening(type)


 end




  


 def createlayerboundary(type, issolid, supertype)
   #inst = GRES_CityObjectDialog.get_instance
     #if(inst != nil)
       #inst.removeSelection
     #end
   layermaker = GRES_BoundaryLayerMaker.new()
   layermaker.createlayerboundary(type, issolid, supertype)

 end

 def createImplicitObject name
  model = Sketchup.active_model
  selection = model.selection
  if( selection == nil || selection.length == 0)
      UI.messagebox "Bitte mindestens eine Gruppe oder Komponente selektieren" , MB_OK
      return
  end
  if(selection.length > 1)
    UI.messagebox "Bitte beachten Sie dass alle selektierten Elemente demselben neuen Objekt zugewiesen werden" , MB_OK
  end
  numberofnewobj = model.attribute_dictionaries.length
   selection.each { |i|
     newgroupdict = i.attribute_dictionary("groupatts", false)
     if(newgroupdict != nil)
          internalname = name + numberofnewobj.to_s
          newgroupdict["isReference"] = "false"
          newgroupdict["internalname"] = internalname
          newdict = model.attribute_dictionary(internalname, true)
          newdict["gmlid"] = createUUID(name)
     else
       UI.messagebox "Objekt mit impliziter Referenzierung konnte nicht erstellt werden, da das Ausgangsobjekt keine implizite Geometrie enthält!" , MB_OK
       return
     end
   }
 end

 def createImplicitRefObject name
  model = Sketchup.active_model
  selection = model.selection
  if( selection == nil || selection.length != 1)
      UI.messagebox "Bitte genau eine Gruppe oder Komponente selektieren" , MB_OK
      return
  end
  dictionaries = model.attribute_dictionaries
  potentialParentObjects = Hash.new()
  dictionaries.each { |dict|
    if(dict.name.index(name) != nil)
     isref = dict["isImplicitReference"]
     if(isref != nil and isref == "true")
       potentialParentObjects[dict.name] = dict.name
     end
    end
  }
  newNameString = "Neues " + name + "Objekt"
  potentialParentObjects[newNameString] = newNameString
  numberofnewobj = model.attribute_dictionaries.length

  selection.each { |i|
      defaults = ["lod1"]
      prompts = ["Auswahl LoD "]
      arrayString = "lod1|lod2|lod3|lod4"
      list =  [arrayString]
      lod = UI.inputbox prompts, defaults, list, "Auswahl des LoDs "
      if(lod == false)
        return
      end

      defaults = [newNameString]
      prompts = ["Auswahl des CityGML Objektes "]
      arrayString = ""
      potentialParentObjects.each_key { |key|
          if(arrayString == "")
            arrayString = key
          else
            arrayString = arrayString + "|" + key
          end
      }

      list =  [arrayString]
      co = UI.inputbox prompts, defaults, list, "Auswahl des CityGML Objektes "
      if(co == false)
        return
      end
      if(co[0] == newNameString)
        newNameString = name + numberofnewobj.to_s
        newdict = model.attribute_dictionary(newNameString, true)
        newdict["isImplicitReference"] = "true"
        newdict["gmlid"] = createUUID(name)
      else
        newNameString = co[0]
      end
      newgroupdict = i.attribute_dictionary("groupatts", true)
      newgroupdict["isReference"] = "true"
      newgroupdict["referencename"] = newNameString
      if(lod.index("lod1") != nil)
        newgroupdict["lod"] = "lod1"
      elsif(lod.index("lod2") != nil)
        newgroupdict["lod"] = "lod2"
     elsif(lod.index("lod3") != nil)
        newgroupdict["lod"] = "lod3"
     elsif(lod.index("lod4") != nil)
        newgroupdict["lod"] = "lod4"
      end
     newgroupdict["internalname"] = newNameString
   }

 end

 


 
     def isParentCityObjectString parent_string

       if(@type.index("Bridge") != nil and parent_string.index("Bridge") != nil)
         return true
       end
       if(@type.index("Tunnel") != nil and parent_string.index("Tunnel") != nil)
         return true
       end
       if(@type.index("Building") != nil and parent_string.index("Building") != nil)
         return true
       end

      return false
   end



  def handleconnectedface(ent, parentConnections, lods)
   faceatts = ent.attribute_dictionary("faceatts", false)
    if(faceatts != nil)
     counter = 0
     parentdictname = ""
     lod = faceatts["lod"]
     if(lod != nil and (lods.include?(lod) == false))
       lods.push(lod)
     end
     while((faceatts["parent" + counter.to_s]) != nil)
        if(isParentCityObjectString(faceatts["parent" + counter.to_s]) == true)
           if(counter == 0)
              parentdictname = faceatts["parent" + counter.to_s]
          else
              parentdictname = parentdictname  + "." + faceatts["parent" + counter.to_s]
          end
          if(parentdictname != "" and (parentConnections.include?(parentdictname) == false))
              parentConnections.push(parentdictname)
          end
        end
      
       counter = counter +1

     end
    
    end

 end






  def createlayerinstallation(type)
    #inst = GRES_CityObjectDialog.get_instance
     #if(inst != nil)
     #  inst.removeSelection
    # end
    inst = GRES_InstallationLayerMaker.new()
    inst.createlayerinstallation(type)
  end


  

  def createtin()
   model = Sketchup.active_model
  layers = model.layers
  selection = model.selection
  if( selection == nil || selection.length == 0)
      UI.messagebox "Bitte mindestens eine Geometrie selektieren" , MB_OK
      return
  end

    dictionary = model.attribute_dictionary("TIN", true)
    selection.each { |ent|
     if(ent.class == Sketchup::Face)
        createTINFace(ent,layers,"TIN")

     elsif(ent.class == Sketchup::Group)
       createTINGroup(ent,layers,"TIN")

     end
    }
  end

  def createTINFace(ent,layers,name)
      faceatts = ent.attribute_dictionary("faceatts", true)
        faceatts.each_key{|key|
          faceatts.delete_key(key)
        }
       ent.layer = layers["dtm"]

      faceatts["parent0"] = name
      faceatts["lod"] = "lod0"
      faceatts["status"] = "sketchup"
  end

  def createTINGroup(ent,layers,name)
   ent.entities.each { |group_ent|

     if(group_ent.class == Sketchup::Face)
        createTINFace(group_ent,layers,"TIN")

     elsif(group_ent.class == Sketchup::Group)
       createTINGroup(group_ent,layers,"TIN")

     end
   }
end

  def createtrafficArea type
   # inst = GRES_CityObjectDialog.get_instance
     #if(inst != nil)
     ##  inst.removeSelection
    # end
        lm = GRES_TrafficAreaLayerMaker.new()
        lm.createTrafficArea(type)
  end

  
def handleconnectedgroup(entities, parentConnections, lods)
  #ents_to_delete = Array.new()
   # puts "handleconnectedgroupopening"
  # group.make_unique
  # group2 = group.copy
  # group2.make_unique
  # entities = group2.explode

   entities.each{|con_ent|
          if(con_ent.class == Sketchup::Face)
             handleconnectedface(con_ent, parentConnections, lods)
          elsif(con_ent.class == Sketchup::Group)
             handleconnectedgroup(con_ent.entities, parentConnections, lods)
           elsif(con_ent.class == Sketchup::ComponentInstance)
             handleconnectedgroup(con_ent.definition.entities, parentConnections, lods)
             #puts "call handleconnectedgroupopening with" + con_ent.entityID.to_s
          end
     }

 end

def containsID(entities, id)
  entities.each { |ent|
    if(ent.class == Sketchup::Face and ent.entityID == id)
      return true
    end
  }
  return false
end




def createSite type
    model = Sketchup.active_model
    layers = model.layers
    dictionaries = model.attribute_dictionaries

    numberofnewobj = model.attribute_dictionaries.length
    selection = model.selection
    if( selection == nil || selection.length == 0)
      UI.messagebox "Bitte mindestens eine Geometrie selektieren" , MB_OK
      return
    end
   
      defaults = ["lod1"]
      prompts = ["Auswahl LoD "]
      arrayString = "lod1|lod2|lod3|lod4"
      list =  [arrayString]
      lod = UI.inputbox prompts, defaults, list, "Auswahl des LoDs"
      if(lod == false)
        return
      end

      defaults = ["Solid"]
      prompts = ["Auswahl des Geometrietyps "]
      arrayString = "Solid|MultiSurface"
      list =  [arrayString]
      solid = UI.inputbox prompts, defaults, list, "Auswahl des Geometrietyps"
      if(solid == false)
        return
      end


     newname = type + numberofnewobj.to_s
     dictionary = model.attribute_dictionary(newname, true)
     dictionary["type"] = type
     dictionary["gmlid"] = createUUID(type)
    selection.each { |ent|

     if(ent.class == Sketchup::Face)
        createSiteFace(ent,lod,type,layers, model,newname,solid)
      
     elsif(ent.class == Sketchup::Group)
        createSiteGroup(ent.entities,lod,type,layers, model,newname,solid)
    elsif(ent.class == Sketchup::ComponentInstance)
        createSiteGroup(ent.definition.entities,lod,type,layers, model,newname,solid)
     end
   }


end

def createSitePart type
    @type = type
    @updates = Hash.new()
    model = Sketchup.active_model
    dictionaries = model.attribute_dictionaries

    numberofnewobj = model.attribute_dictionaries.length
    selection = model.selection
    newname = type + numberofnewobj.to_s
    dictionary = model.attribute_dictionary(newname, true)
    dictionary["type"] = type
    dictionary["gmlid"] = createUUID(type)
    parentConnections = Array.new()
    lods = Array.new()
    selection.each{ |ent|
      if(ent.class == Sketchup::Face)
        handleconnectedface(ent, parentConnections, lods)
     elsif(ent.class == Sketchup::Group)
        handleconnectedgroup(ent.entities,parentConnections, lods)
    elsif(ent.class == Sketchup::ComponentInstance)
        handleconnectedgroup(ent.definition.entities,parentConnections, lods)
     end
    }
     if(parentConnections.length == 0)
      UI.messagebox "Es konnte kein CityObject des Typs Building, Bridge oder Tunnel gefunden werden. Bitte erzeugen Sie zuerst ein Hauptobjekt oder nutzen Sie die manuelle Zuordnung" , MB_OK
      return
    end
    #puts parentConnections.to_s
     parentString = ""
    if(parentConnections.length == 1)
      parentString = parentConnections[0]
    end

    if(parentConnections.length > 1)
      defaults = [""]
      prompts = ["Auswahl CityGML Objekt "]
      arrayString = ""
      parentConnections.each { |str|
        if(arrayString == "")
            arrayString = str
        else
          arrayString = arrayString + "|" + str
        end
      }
      puts arrayString
      list =  [arrayString]
      arr = UI.inputbox prompts, defaults, list, "Auswahl des CityGML Objektes"
      if(arr == false)
        return
      end
      parentString = arr[0]
    end
      defaults = ["lod1"]
      prompts = ["Auswahl LoD "]
      arrayString = "lod1|lod2|lod3|lod4"
      list =  [arrayString]
      lod = UI.inputbox prompts, defaults, list, "Auswahl des LoDs"
      if(lod == false)
        return
      end

      defaults = ["Solid"]
      prompts = ["Auswahl des Geometrietyps "]
      arrayString = "Solid|MultiSurface"
      list =  [arrayString]
      solid = UI.inputbox prompts, defaults, list, "Auswahl des Geometrietyps"
      if(solid == false)
        return
      end

      dictionary["parent"] = parentString
    
    selection.each { |ent|

     if(ent.class == Sketchup::Face)
        createSitePartFace(ent,newname,parentString,lod,solid,model.layers)

     elsif(ent.class == Sketchup::Group)
        createSitePartGroup(ent,newname,parentString,lod,solid,model.layers)

     end
   }
  #updates[newname] = parentString
   #GRES_CityObjectDialog.update(@updates)
   observer = GRES_CityObjectDialog.getobserver
   if(observer != nil)
     observer.onSelectionBulkChange(selection)
   end
end

def createSitePartFace(ent,newname,parentString,lod,solid,layers)
   faceatts = ent.attribute_dictionary("faceatts", true)
   arrParents = parentString.split(".")
   counter = 0
   arrParents.each { |i|
        faceatts["parent" + counter.to_s] = i
        counter = counter + 1
   }
   faceatts["parent" + counter.to_s] = newname
  counter = counter + 1
   while(faceatts["parent" + counter.to_s] != nil)
     faceatts.delete_key("parent" + counter.to_s)
     counter = counter + 1
   end
    if(lod.index("lod1") != nil)
         faceatts["lod"] = "lod1"
         ent.layer = layers["lod1Geometries"]
         if(solid.index("Solid") != nil)
          faceatts["lod1Solid"] = "true"
        end
       end
       if(lod.index("lod2") != nil)
         faceatts["lod"] = "lod2"
         ent.layer = layers["lod2Geometries"]
         if(solid.index("Solid") != nil)
          faceatts["lod2Solid"] = "true"
         end
       end
       if(lod.index("lod3") != nil)
         faceatts["lod"] = "lod3"
         ent.layer = layers["lod3Geometries"]
         if(solid.index("Solid") != nil)
          faceatts["lod3Solid"] = "true"
        end
       end
       if(lod.index("lod4") != nil)
         faceatts["lod"] = "lod4"
         ent.layer = layers["lod4Geometries"]
         if(solid.index("Solid") != nil)
          faceatts["lod14Solid"] = "true"
        end
       end
     
end

def createSitePartGroup(ent,newname,parentString,lod,solid,layers)
   ent.entities.each { |group_ent|

     if(group_ent.class == Sketchup::Face)
        createSitePartFace(group_ent,newname,parentString,lod,solid,layers)

     elsif(group_ent.class == Sketchup::Group)
        createSitePartGroup(group_ent,newname,parentString,lod,solid,layers)

     end
   }
end

def createSiteFace(ent,lod,type,layers, model,newname,solid)
   faceatts = ent.attribute_dictionary("faceatts", true)
        faceatts.each_key{|key|
          faceatts.delete_key(key)
        }

      faceatts["parent0"] = newname
       
       if(lod.index("lod1") != nil)
         faceatts["lod"] = "lod1"
         ent.layer = layers["lod1Geometries"]
         if(solid.index("Solid") != nil)
          faceatts["lod1Solid"] = "true"
        end
       end
       if(lod.index("lod2") != nil)
         faceatts["lod"] = "lod2"
         ent.layer = layers["lod2Geometries"]
         if(solid.index("Solid") != nil)
          faceatts["lod2Solid"] = "true"
         end
       end
       if(lod.index("lod3") != nil)
         faceatts["lod"] = "lod3"
         ent.layer = layers["lod3Geometries"]
         if(solid.index("Solid") != nil)
          faceatts["lod3Solid"] = "true"
        end
       end
       if(lod.index("lod4") != nil)
         faceatts["lod"] = "lod4"
         ent.layer = layers["lod4Geometries"]
         if(solid.index("Solid") != nil)
          faceatts["lod14Solid"] = "true"
        end
       end
       
       
       faceatts["status"] = "sketchup"
end

def createSiteGroup(entities,lod,type,layers, model,newname,solid)
   entities.each { |group_ent|

     if(group_ent.class == Sketchup::Face)
        createSiteFace(group_ent,lod,type,layers, model,newname,solid)

     elsif(group_ent.class == Sketchup::Group)
      clearGroupAtts(group_ent)
      createSiteGroup(group_ent.entities,lod,type,layers, model,newname,solid)
    elsif(group_ent.class == Sketchup::ComponentInstance)
      clearGroupAtts(group_ent)
      createSiteGroup(group_ent.definition.entities,lod,type,layers, model,newname,solid)
     end
   }
end

def createGroup(entities,lod,type,layers, model,newname)
   entities.each { |group_ent|
      if(group_ent.class == Sketchup::Face)
        createFace(group_ent,lod,type,layers, model,newname)

     elsif(group_ent.class == Sketchup::Group)
         clearGroupAtts(group_ent)
        createGroup(group_ent.entiites,lod,type,layers, model,newname)
     elsif(group_ent.class == Sketchup::ComponentInstance)
      clearGroupAtts(group_ent)
      createGroup(group_ent.defintion.entities,lod,type,layers, model,newname)
     end
   }
end

def clearGroupAtts(ent)
   newgroupdict = ent.attribute_dictionary("groupatts", false)
     if(newgroupdict != nil)
                newgroupdict.each_key{|key|
          newgroupdict.delete_key(key)
        }
     end
end

def createFace(ent,lod,type,layers, model,newname)
   faceatts = ent.attribute_dictionary("faceatts", true)
        faceatts.each_key{|key|
          faceatts.delete_key(key)
        }
       ent.layer = getLayerForType(type, layers)

      faceatts["parent0"] = newname
       if(lod.index("lod0") != nil)
         faceatts["lod"] = "lod0"

       end
       if(lod.index("lod1") != nil)
         faceatts["lod"] = "lod1"


       end
       if(lod.index("lod2") != nil)
         faceatts["lod"] = "lod2"


       end
       if(lod.index("lod3") != nil)
         faceatts["lod"] = "lod3"


       end
       if(lod.index("lod4") != nil)
         faceatts["lod"] = "lod4"


       end


       faceatts["status"] = "sketchup"
end

def getLayerForType type, layers
  if(type == "GenericCityObject")
     return layers["generic_cityobjects"]

  end
  if(type == "SolitaryVegetationObject")
     return layers["solitary_vegetation_objects"]
  end
  if(type == "WaterBody")
     return layers["waterbodies"]
  end
  if(type == "PlantCover")
     return layers["plantcovers"]
  end
  if(type == "Road")
     return layers["road"]
  end
   if(type == "Track")
     return layers["tracks"]
  end
   if(type == "Square")
     return layers["squares"]
  end
   if(type == "Railway")
     return layers["railways"]
  end
   if(type == "LandUse")
     return layers["landuse"]
  end
   if(type == "CityFurniture")
     return layers["cityfurniture"]
  end
  return layers["unknown"]

end

def createlodobject type
  #inst = GRES_CityObjectDialog.get_instance
    # if(inst != nil)
    #   inst.removeSelection
   #  end
  model = Sketchup.active_model
  numberofnewobj = model.attribute_dictionaries.length
  layers = model.layers
  selection = model.selection
  if( selection == nil || selection.length == 0)
      UI.messagebox "Bitte mindestens eine Geometrie selektieren" , MB_OK
      return
  end
  lod = ""
  arrayString = "lod1|lod2|lod3|lod4"
  if(type == "WaterBody")
    arrayString = "lod0|lod1"
  elsif(type == "LandUse" or type == "GenericCityObject")
    arrayString = "lod0|lod1|lod2|lod3|lod4"
  end
    defaults = ["lod1"]
    prompts = ["Auswahl LoD "]
    list =  [arrayString]
    lodArray = UI.inputbox prompts, defaults, list, "Auswahl des LoDs"
    lod = lodArray[0]
    newname = type + numberofnewobj.to_s
     dictionary = model.attribute_dictionary(newname, true)
     dictionary["type"] = type
     dictionary["gmlid"] = createUUID(type);
    selection.each { |ent|

     if(ent.class == Sketchup::Face)
        createFace(ent,lod,type,layers, model,newname)

     elsif(ent.class == Sketchup::Group)
       clearGroupAtts(ent)
        createGroup(ent.entities,lod,type,layers, model,newname)
     elsif(ent.class == Sketchup::ComponentInstance)
       clearGroupAtts(ent)
        createGroup(ent.definition.entities,lod,type,layers, model,newname)
     end
    }

end

def createUUID (type)
  return  "UUID_"+type + "_" + rand(2000).to_s + "_" + rand(900000).to_s+"_"+rand(432222).to_s
end


end
