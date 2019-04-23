# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'sketchup.rb'
Sketchup::require 'geores_src/geores_gui/gres_city_object_dialog.rb'

class GRES_InstallationLayerMaker
   def initialize
     @updates = Hash.new()
   end



  def createlayerinstallation(type)
     model = Sketchup.active_model
     @type = type
    numberofnewobj = model.attribute_dictionaries.length

    selection = model.selection
    if( selection == nil || selection.length == 0)
      UI.messagebox "Bitte mindestens eine Geometrie selektieren" , MB_OK
      return
    end


      #hier noch eckige Klammern und Anführungszeichen löschen

   parentConnections = Array.new()
   lods = Array.new()

   selection.each { |ent|
     puts "selection: " + ent.class.to_s
     if(ent.class == Sketchup::Face)
        handleconnectedface(ent, parentConnections, lods)
     elsif(ent.class == Sketchup::Group)
        handleconnectedgroup(ent.entities, parentConnections, lods)
     elsif(ent.class == Sketchup::ComponentInstance)
       handleconnectedgroup(ent.definition.entities, parentConnections, lods)
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
      parentArray = UI.inputbox prompts, defaults, list, "Auswahl CityGML Objekt"
      parentString = parentArray[0]
      if(parentString == nil)
        UI.messagebox "Bitte ein entsprechendes CityObjekt auswählen." , MB_OK
        return
      end
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
       UI.messagebox "Installation Objekte können erst ab LoD2 angelegt werden" , MB_OK
      return
    end

layers = model.layers
    selection.each { |ent|

     if(ent.class == Sketchup::Face)
       numberofnewobj = handleselectedface(ent, type, parentString, model, lod, numberofnewobj, layers)
     elsif(ent.class == Sketchup::Group)
        numberofnewobj = handleselectedgroup(ent, type, parentString, model, lod, numberofnewobj, layers)
     elsif(ent.class == Sketchup::ComponentInstance)
        numberofnewobj = handleselectedcompInst(ent, type, parentString, model, lod, numberofnewobj, layers)
     end
   }
   GRES_CityObjectDialog.update(@updates)
   #selection.clear
   # puts ents_to_delete.length.to_s
   #model_entities = model.entities
  # ents_to_delete.each { |item|
   #    puts item.length.to_s
   #     model_entities.erase_entities item
 #  }

 end

 def handleconnectedgroup(entities, parentConnections, lods)
 
   entities.each{|con_ent|
     if(con_ent.class == Sketchup::Face)
        handleconnectedface(con_ent, parentConnections, lods)
     elsif(con_ent.class == Sketchup::Group)
        handleconnectedgroup(con_ent.entities, parentConnections, lods)
     elsif(con_ent.class == Sketchup::ComponentInstance)
       handleconnectedgroup(con_ent.definition.entities, parentConnections, lods)
     end
     }


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
       end

       counter = counter +1

     end
     if(parentdictname != "" and (parentConnections.include?(parentdictname) == false))
       parentConnections.push(parentdictname)
     end
    end

 end

     def isParentCityObjectString parent_string

       if(@type.index("Bridge") != nil and parent_string.index("Bridge") != nil and parent_string.index("BridgeInstallation") == nil and parent_string.index("BridgeConstructionElement") == nil)
         return true
       end
       if(@type.index("Tunnel") != nil and parent_string.index("Tunnel") != nil and parent_string.index("TunnelInstallation") == nil)
         return true
       end
       if(@type.index("Building") != nil and parent_string.index("Building") != nil and parent_string.index("BuildingInstallation") == nil)
         return true
       end
      
      return false
   end


  def handleselectedface(ent, type, parentString, model, lod, numberofnewobj, layers)
        newname = type + numberofnewobj.to_s
        #hier werden die falschen Dinge gelöscht
        faceatts = ent.attribute_dictionary("faceatts", true)

       clearOldEntries(ent, newname, parentString)


        ent.layer = layers["unknown"]
       
       

       dictionary = model.attribute_dictionary(newname, true)
       dictionary["type"] = type
       dictionary["parent"] = parentString
       dictionary["gmlid"] = createUUID(type)


       faceatts["lod"] = lod.to_s
       faceatts["status"] = "sketchup"
       parentcounter = 0
       parentString.each_line('.') { |substr|
          substr = substr.chomp('.')
          faceatts["parent" + parentcounter.to_s] = substr
          parentcounter = parentcounter + 1
        }
         faceatts["parent" + parentcounter.to_s] = newname
       @updates[newname] = parentString

        return numberofnewobj
  end

   def handleselectedgroup(ent, type, parentString, model, lod, numberofnewobj, layers)
    ent.entities.each { |group_ent|

     if(group_ent.class == Sketchup::Face)
       numberofnewobj = handleselectedface(group_ent, type, parentString, model, lod, numberofnewobj, layers)
     elsif(group_ent.class == Sketchup::Group)

       numberofnewobj = handleselectedgroup(group_ent, type, parentString, model, lod, numberofnewobj, layers)

     end
   }
   return numberofnewobj + 1
  end

  def handleselectedcompInst(ent, type, parentString, model, lod, numberofnewobj, layers)
    ent.definition.entities.each { |group_ent|

     if(group_ent.class == Sketchup::Face)
       numberofnewobj = handleselectedface(group_ent, type, parentString, model, lod, numberofnewobj, layers)
     elsif(group_ent.class == Sketchup::Group)

       numberofnewobj = handleselectedgroup(group_ent, type, parentString, model, lod, numberofnewobj, layers)

     end
   }
   return numberofnewobj + 1
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

       def createUUID (type)
         return  "UUID_"+type + "_" + rand(2000).to_s + "_" + rand(900000).to_s+"_"+rand(432222).to_s
     end


end

