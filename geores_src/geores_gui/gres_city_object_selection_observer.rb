# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'sketchup.rb'
Sketchup::require 'geores_src/geores_gui/gres_city_object_dialog.rb'
Sketchup::require 'geores_src/geores_gui/geores_selection/gres_selectable_city_object.rb'

class GRES_CityObjectSelectionObserver < Sketchup::SelectionObserver
  def initialize gui
    super()
    @gui = gui
  end

  def onSelectionBulkChangeFace(entity, objects,lods)
    puts "Start onSelectionBulkChangeFace\n"
     faceatts = entity.attribute_dictionary("faceatts")
     if(faceatts != nil)
           parent0 = faceatts["parent0"]

           if(parent0 == nil)
             return
           end
           currentSolidObject = nil
           cityobjectP0 = objects[parent0]

           if(cityobjectP0 == nil)
               cityobjectP0 = GRES_SelectableCityObject.new(parent0)
               objects[parent0] = cityobjectP0
           end
           currentSolidObject = cityobjectP0
           #Parent 1
           loop = 1
           cityObjectPI_Minus1 = cityobjectP0
           while (loop < 8)
             cityobjectPI = nil
             parentI = faceatts["parent" + loop.to_s]
             if(parentI != nil)
                cityobjectPI = cityObjectPI_Minus1.childs[parentI]
                if(cityobjectPI == nil)
                 cityobjectPI = GRES_SelectableCityObject.new(parentI)
                 cityObjectPI_Minus1.childs[parentI] = cityobjectPI
                end
                if(parentI.index("BuildingPart") != nil or parentI.index("TunnelPart") != nil or parentI.index("BridgePart") != nil)
                  currentSolidObject = cityobjectPI
                end
             end
             cityObjectPI_Minus1 = cityobjectPI
             loop = loop + 1
           end
       
           if(faceatts["lod1Solid"] != nil and lods.index("lod1") != nil)
             currentSolidObject.setlod1Solid true
           end
           if(faceatts["lod2Solid"] != nil and lods.index("lod2") != nil)
             currentSolidObject.setlod2Solid true
           end
           if(faceatts["lod3Solid"] != nil and lods.index("lod3") != nil)
             currentSolidObject.setlod3Solid true
           end
           if(faceatts["lod4Solid"] != nil and lods.index("lod4") != nil)
             currentSolidObject.setlod4Solid true
           end
     end
  end

  def onSelectionBulkChangeGroup(group, objects,lods)
    puts "Start onSelectionBulkChangeGroup\n"
     group.entities.each{ |entity|
              if(entity.class == Sketchup::Face)
                 onSelectionBulkChangeFace(entity, objects,lods)
              elsif(entity.class == Sketchup::Group)
                onSelectionBulkChangeGroup(entity, objects,lods)
              elsif(entity.class == Sketchup::ComponentInstance)
                onSelectionBulkChangeCompInst(entity, objects,lods)
              end
         }
  end

  def onSelectionBulkChangeCompInst(compInst, objects,lods)
    puts "Start onSelectionBulkChangeGroup\n"
     compInst.definition.entities.each{ |entity|
              if(entity.class == Sketchup::Face)
                 onSelectionBulkChangeFace(entity, objects,lods)
              elsif(entity.class == Sketchup::Group)
                onSelectionBulkChangeGroup(entity, objects,lods)
              elsif(entity.class == Sketchup::ComponentInstance)
                onSelectionBulkChangeCompInst(entity, objects,lods)
              end
         }
  end

  def onSelectionBulkChange(selection)

    begin
   # puts "Start onSelectionBulkChange\n"
    lods = GRES_CityObjectDialog.getlods
    objects = Hash.new()
    model = Sketchup.active_model
    dictionaries = model.attribute_dictionaries
    if(dictionaries == nil)
      return
    end

     selection.each{ |entity|
          if(entity.class == Sketchup::Face)
           onSelectionBulkChangeFace(entity, objects,lods)
          elsif(entity.class == Sketchup::Group)
            onSelectionBulkChangeGroup(entity, objects,lods)
          elsif(entity.class == Sketchup::ComponentInstance)
                onSelectionBulkChangeCompInst(entity, objects,lods)
           end
      }
      
#      dictionaries.each{ |dict|
#          parent = dict["parent"].to_s
#          if(parent != nil)
#            objects.each_key { |key|
#
#              if(parent.index(key) != nil)
#                co = objects[key]
#                child1 = nil
#                child2 = nil
#                child3 = nil
#                child4 = nil
#                child5 = nil
#                loop = 0
#                    parent.each_line('.'){|substr|
#                      substr = substr.chomp('.')
#                      if(substr != nil)
#                        if(loop == 1)
#                          child1 = co.childs[substr]
#                          if(child1 == nil)
#                            child1 = GRES_SelectableCityObject.new(substr)
#                            co.childs[substr] = child1
#                          end
#                        elsif(loop == 2)
#                          child2 = child1.childs[substr]
#                          if(child2 == nil)
#                            child2 = GRES_SelectableCityObject.new(substr)
#                            child1.childs[substr] = child2
#                          end
#                       elsif(loop == 3)
#                          child3 = child2.childs[substr]
#                          if(child3 == nil)
#                            child3 = GRES_SelectableCityObject.new(substr)
#                            child2.childs[substr] = child3
#                          end
#                      elsif(loop == 4)
#                          child4 = child3.childs[substr]
#                          if(child4 == nil)
#                            child4 = GRES_SelectableCityObject.new(substr)
#                            child3.childs[substr] = child4
#                          end
#                      elsif(loop == 5)
#                          child5 = child4.childs[substr]
#                          if(child5 == nil)
#                            child5 = GRES_SelectableCityObject.new(substr)
#                            child4.childs[substr] = child5
#                          end
#                      end
#                      end
#                      loop = loop + 1
#                    }
#                if(child5 != nil)
#                  child5.childs[dict.name] = GRES_SelectableCityObject.new(dict.name)
#                elsif(child4 != nil)
#                  child4.childs[dict.name] = GRES_SelectableCityObject.new(dict.name)
#                elsif(child3 != nil)
#                  child3.childs[dict.name] = GRES_SelectableCityObject.new(dict.name)
#                elsif(child2 != nil)
#                  child2.childs[dict.name] = GRES_SelectableCityObject.new(dict.name)
#                elsif(child1 != nil)
#                  child1.childs[dict.name] = GRES_SelectableCityObject.new(dict.name)
#                else
#                  co.childs[dict.name] = GRES_SelectableCityObject.new(dict.name)
#                end
#              end
#            }
#          end
#        }


     
      # puts "before gui clear \n"
     @gui.clear()
     #puts "after gui clear \n"
     objects.each { |key,value|
       @gui.buildMainObject(key, value.lod1Solid, value.lod2Solid, value.lod3Solid, value.lod4Solid)
        @gui.selectionCallBack(value.childs, 0,key)
     }
     
     @gui.buildNewList();
     # puts "after selectionCallBack \n"
    rescue=>err
       puts "GRES_CityObjectSelectionObserver Fehler: " + err.backtrace.to_s + "\n\n"
       return
    end
  end



end
