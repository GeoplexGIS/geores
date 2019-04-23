# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'sketchup.rb'
Sketchup::require 'geores_src/geores_gui/gres_city_object_dialog.rb'

class GRES_BoundaryLayerMaker
  def initialize
    
  end

  def createlayerboundary(type, issolid, supertype)

    model = Sketchup.active_model
    numberofnewobj = model.attribute_dictionaries.length

    selection = model.selection
    if( selection == nil || selection.length == 0)
      UI.messagebox "Bitte mindestens eine Geometrie selektieren" , MB_OK
      return
    end

   parentConnections = Array.new()
   lods = Array.new()
   tempSel = Array.new()

   selection.each { |ent|

     if(ent.class == Sketchup::Face)
        connected = ent.all_connected
        connected.each{|con_ent|
          if(con_ent.class == Sketchup::Face)
            handleconnectedface(con_ent, parentConnections, lods)
          end
        }
     end
     tempSel.push(ent)
   }
    if(tempSel.length == 0)
      UI.messagebox "Es konnte kein Sketchup Objekt vom Typ FACE in der Selektionsmenge gefunden werden. Bitte Selektieren sie eine oder mehrere Flächen -> keine Gruppen erlaubt." , MB_OK
      return
    end

   if(parentConnections.length == 0)
      UI.messagebox "Es konnte kein CityObject des Typs Building, Bridge, Tunnel oder WaterBody gefunden werden. Bitte erzeugen Sie zuerst ein Hauptobjekt" , MB_OK
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
      parentArray = UI.inputbox prompts, defaults, list, "Auswahl CityGML Objekt"
      parentString = parentArray[0]
    end
    lod = ""
    puts lods.to_s
    if(lods.length == 0 or lods.length > 1)
       defaults = ["lod2"]
      prompts = ["Auswahl LoD "]
      arrayString = "lod2|lod3|lod4"
      list =  [arrayString]
      lodArray = UI.inputbox prompts, defaults, list, "Auswahl des LoDs"
      lod = lodArray[0]
    else
      lod = lods[0]
    end
     if(lod == "lod1")
       UI.messagebox "In LoD1 können keine BoundarySurfaces erzuegt werden" , MB_OK
      return
    end

    updates = Hash.new()
    selection.each { |ent|

     if(ent.class == Sketchup::Face)
       newname = type + numberofnewobj.to_s
        #hier werden die falschen Dinge gelöscht
        faceatts = ent.attribute_dictionary("faceatts", true)

       clearOldEntries(ent, newname, parentString)


       ent.layer = getboundarylayerfortype(type)
       dictionary = model.attribute_dictionary(newname, true)
       dictionary["type"] = type
       dictionary["parent"] = parentString
       dictionary["gmlid"] = createUUID(type)

       faceatts["lod"] = lod.to_s
       faceatts["status"] = "sketchup"
       if(issolid == true and parentString.index("Installation") == nil and parentString.index("ConstructionElement") == nil)
         faceatts[lod.to_s+"Solid"] = "true"
       end
       parentcounter = 0
       parentString.each_line('.') { |substr|
          substr = substr.chomp('.')
          faceatts["parent" + parentcounter.to_s] = substr
          parentcounter = parentcounter + 1
        }
         faceatts["parent" + parentcounter.to_s] = newname

        numberofnewobj = numberofnewobj + 1
        updates[newname] = parentString
     end
   }

   tempSel.each { |item|
     if(item.valid? == true)
       model.selection.add item
     end
   }
   GRES_CityObjectDialog.update(updates)

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
       if(counter == 0)
         parentdictname = faceatts["parent" + counter.to_s]
       elsif(isParentCityObjectString(faceatts["parent" + counter.to_s]) == true)
         parentdictname = parentdictname  + "." + faceatts["parent" + counter.to_s]
       end

       counter = counter +1

     end
     if(parentdictname != "" and (parentConnections.include?(parentdictname) == false))
       parentConnections.push(parentdictname)
     end
    end

 end



 def clearOldEntries(ent, newname, parentname)

   faceatts = ent.attribute_dictionary("faceatts", false)
   if(faceatts != nil)
     counter = 0
     parentdictname = ""
     while((faceatts["parent" + counter.to_s]) != nil)
       parentdictname = faceatts["parent" + counter.to_s]
       faceatts.delete_key("parent" + counter.to_s)
       counter = counter +1
     end
     faceatts.delete_key("lod1Solid")
     faceatts.delete_key("lod2Solid")
     faceatts.delete_key("lod3Solid")
     faceatts.delete_key("lod4Solid")
   end
 end

  def getboundarylayerfortype(name)
    model = Sketchup.active_model
    layers = model.layers
    if(name.index("WaterGroundSurface") != nil or name.index("WaterSurface") != nil)
      return layers["waterbodies"]
    end
   if(name.index("InteriorWallSurface") != nil)
      return layers["interiorwalls"]
    end
    if(name.index("WallSurface") != nil)
      return layers["walls"]
    end
    if(name.index("RoofSurface") != nil)
      return layers["roofs"]
    end
    if(name.index("GroundSurface") != nil)
     return layers["grounds"]
    end
    if(name.index("ClosureSurface") != nil)
      return layers["closures"]
    end
    if(name.index("OuterCeilingSurface") != nil)
      return layers["outerceilings"]
    end
    if(name.index("CeilingSurface") != nil)
      return layers["ceilings"]
    end
    if(name.index("OuterFloorSurface") != nil)
      return layers["outerfloors"]
    end
    if(name.index("FloorSurface") != nil)
      return layers["floors"]
    end

    return layers["unknown"]

 end

     def isParentCityObjectString parent_string
      if(parent_string.index("Building") != nil or parent_string.index("Bridge") != nil or parent_string.index("Tunnel") != nil or parent_string.index("WaterBody") != nil)
        return true
      end
      return false
   end

     def createUUID (type)
         return  "UUID_"+type + "_" + rand(2000).to_s + "_" + rand(900000).to_s+"_"+rand(432222).to_s
     end

end
