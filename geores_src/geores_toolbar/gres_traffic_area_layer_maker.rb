# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'sketchup.rb'
Sketchup::require 'geores_src/geores_gui/gres_city_object_dialog.rb'

class GRES_TrafficAreaLayerMaker
 def initialize
   @updates = Hash.new()

  end

  def createTrafficArea(type)
     model = Sketchup.active_model
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
     #puts "selection: " + ent.class.to_s
     if(ent.class == Sketchup::Face)

        connected = ent.all_connected
        connected.each{|con_ent|
          if(con_ent.class == Sketchup::Face)
            #puts "call handleconnectedfaceopening with" + con_ent.entityID.to_s
            handleconnectedface(con_ent, parentConnections, lods)
          end
        }
     elsif(ent.class == Sketchup::Group)
        handleconnectedgroup(ent, parentConnections, lods)
     elsif(ent.class == Sketchup::ComponentInstance)
       handleconnectedcompInst(ent, parentConnections, lods)
     end
   }


   if(parentConnections.length == 0)
      UI.messagebox "Es konnte kein CityObject des Typs Road, Track, Railway oder Square gefunden werden" , MB_OK
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
       UI.messagebox "TrafficArea Objekte können erst ab LoD2 angelegt werden" , MB_OK
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


 end

 def handleconnectedgroup(group, parentConnections, lods)
  ents_to_delete = Array.new()
    #puts "handleconnectedgroupopening"
   group.make_unique
   group2 = group.copy
   group2.make_unique
   entities = group2.explode

   entities.each{|con_ent|
          if(con_ent.class == Sketchup::Face)

            entityID = con_ent.entityID
            edges = con_ent.edges
            edges.each { |edge|
                faces = edge.faces
                if(faces != nil)
                  faces.each { |f|
                    if(f.entityID != entityID)

                       handleconnectedface(f, parentConnections, lods)
                    end
                  }
                end

            }

          elsif(con_ent.class == Sketchup::Group)
             handleconnectedgroup(con_ent, parentConnections, lods)
            # puts "call handleconnectedgroupopening with" + con_ent.entityID.to_s
          end
     }

     ents_to_delete.push(entities)

     ents_to_delete.each { |item|
     item.each { |ent|
       #or ent.class == Sketchup::Edge
       if((ent.class == Sketchup::Face or ent.class == Sketchup::Group ) and ent.deleted? == false)
          ent.erase!
       end
     }
   }
   ents_to_delete.each { |item|
       item.each { |ent|
           #or ent.class == Sketchup::Edge
           if((ent.class == Sketchup::Edge) and ent.deleted? == false)
              if(ent.faces.length == 0)
                  ent.erase!
              end
           end
         }

   }
 end

 def handleconnectedcompInst(comp_inst, parentConnections, lods)
  ents_to_delete = Array.new()
   comp_inst.make_unique
   main_entities = Sketchup.active_model.active_entities
   comp_inst2 = main_entities.add_instance(comp_inst.definition, comp_inst.transformation)

   comp_inst2.make_unique
   entities = comp_inst2.explode

   entities.each{|con_ent|
         if(con_ent.class == Sketchup::Face)

            entityID = con_ent.entityID
            edges = con_ent.edges
            edges.each { |edge|
                faces = edge.faces
                if(faces != nil)
                  faces.each { |f|
                    if(f.entityID != entityID)

                       handleconnectedface(f, parentConnections, lods)
                    end
                  }
                end

            }

          elsif(con_ent.class == Sketchup::Group)
             handleconnectedgroup(con_ent, parentConnections, lods)
             #puts "call handleconnectedgroupopening with" + con_ent.entityID.to_s
          end
     }

     ents_to_delete.push(entities)

      ents_to_delete.each { |item|
     item.each { |ent|
       #or ent.class == Sketchup::Edge
       if((ent.class == Sketchup::Face or ent.class == Sketchup::Group ) and ent.deleted? == false)
          ent.erase!
       end
     }
   }
   ents_to_delete.each { |item|
       item.each { |ent|
           #or ent.class == Sketchup::Edge
           if((ent.class == Sketchup::Edge) and ent.deleted? == false)
              if(ent.faces.length == 0)
                  ent.erase!
              end
           end
         }

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

     def isParentCityObjectString parent_string
      if(parent_string.index("Road") != nil or parent_string.index("Track") != nil or parent_string.index("Railway") != nil or parent_string.index("Square") != nil)
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
   end

 end

       def createUUID (type)
         return  "UUID_"+type + "_" + rand(2000).to_s + "_" + rand(900000).to_s+"_"+rand(432222).to_s
     end

end

