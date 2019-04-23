# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'sketchup.rb'

class GRES_ManualSelector
  def initialize
    @pickhelper = nil
    @hashselect = Hash.new()
    @model = Sketchup.active_model
    opts = @model.rendering_options
    @wasColorByLayer = opts['DisplayColorByLayer']
    opts['DisplayColorByLayer']= true
    @select = @model.layers["select"]
     if(@select == nil)
           @select = @model.layers.add "select"
           colorselect = Sketchup::Color.new(255, 255, 0)
           colorselect.alpha = 128
           @select.color = colorselect
     end
     @best_entity = nil
  end


  def activate

    view = Sketchup.active_model.active_view
    @pickhelper = view.pick_helper

    @activate = true
    @ended = false
   end

  def deactivate(view)
    @activate = false
    @ended = true
    clearSelection
    cleanup
  end

  def clearSelection()
     @hashselect.each_key { |key|
        value = @hashselect[key]
        key.layer= @model.layers[value]
     }
      @hashselect.clear
  end

  def onMouseMove(flags, x, y, view)
    if(@activate == true and @ended == false)
      clearSelection()
      @pickhelper.do_pick(x, y)
      @best_entity = @pickhelper.best_picked
      if(@best_entity != nil)
        @hashselect[@best_entity] = @best_entity.layer.name
        @best_entity.layer = @select
        if(@best_entity.class == Sketchup::Group)
          makeSelectionForEntities(@best_entity.entities)
        elsif(@best_entity.class == Sketchup::ComponentInstance)
          makeSelectionForEntities(@best_entity.defintion.entities)
        end
      end
    end
  end

  def makeSelectionForEntities(entities)
    entities.each { |ent|
        if(ent.class == Sketchup::Group)
          makeSelectionForEntities(ent.entities)
        elsif(ent.class == Sketchup::ComponentInstance)
          makeSelectionForEntities(ent.definition.entities)
        elsif(ent.class == Sketchup::Face)
          @hashselect[ent] = ent.layer.name
          ent.layer = @select
        end
    }
  end


  # The onLButtonDOwn method is called when the user presses the left mouse button.
def onLButtonDown(flags, x, y, view)
   if(@best_entity != nil and @activate == true and @ended == false)
      parentStrings = Hash.new()
      if(@best_entity.class == Sketchup::Group)
        getParentStringsGroup(@best_entity.entities, parentStrings)
      elsif(@best_entity.class == Sketchup::ComponentInstance)
        getParentStringsGroup(@best_entity.definition.entities, parentStrings)
      elsif(@best_entity.class == Sketchup::Face)
        getParentStringFace(@best_entity, parentStrings)
      end

    if(parentStrings.length == 0)
        UI.messagebox("Kein CityGML Objekt fuer die Zuordnung gefunden")
        clearSelection()
        @model.select_tool(nil)
        return
    end
    faceatts = nil
    if(parentStrings.length > 1)
       defaults = [""]
      prompts = ["Auswahl CityObject"]
      arrayString = ""
      parentStrings.each_key { |str|
        if(arrayString == "")
            arrayString = str
        else
          arrayString = arrayString + "|" + str
        end
      }
      #puts arrayString
      list =  [arrayString]
      arr = UI.inputbox prompts, defaults, list, "Auswahl des CityObjects"
      if(arr == false)
        return
      end
      parentString = arr[0]
      faceatts = parentStrings[parentString]
    else
      parentString = parentStrings.keys[0]
      faceatts = parentStrings[parentString]
    end
     result = UI.messagebox('Sollen die Elemente der Selektionsmenge dem CityGML Objekt ' + parentString + " zugewiesen werden?", MB_YESNO)
     clearSelection()
     if(result == 6)
       @model.selection.each { |ent|
         if(ent.class == Sketchup::Group)
           handleGroup(faceatts, ent.entities, @best_entity.layer)
         elsif(ent.class == Sketchup::ComponentInstance)
           handleGroup(faceatts, ent.definition.entities, @best_entity.layer)
         elsif(ent.class == Sketchup::Face)
           handleFace(faceatts, ent, @best_entity.layer)
         end
       }
       @activate = false
       @ended = true
     else
       @activate = false
       @ended = true
    end
    #clearSelection()
   cleanup()
   end
end

def getParentStringsGroup(entities, parentStrings)

  entities.each { |ent|

    if(@best_ententity.class == Sketchup::Group)
        getParentStringsGroup(ent.entities, parentStrings)
      elsif(ent.class == Sketchup::ComponentInstance)
        getParentStringsGroup(ent.definition.entities, parentStrings)
      elsif(ent.class == Sketchup::Face)
        getParentStringFace(ent, parentStrings)
      end
  }

end

def getParentStringFace (ent, parentStrings)
   faceatts = ent.attribute_dictionary("faceatts", false)
     if(faceatts == nil)
       return
     end
     parentString = ""
     counter = 0
     while(faceatts["parent" + counter.to_s] != nil)
       parentString = faceatts["parent" + counter.to_s]
       counter = counter + 1
     end
     parentStrings[parentString] = faceatts
end

def handleGroup(faceatts,entities,layer)
  entities.each { |ent|
         if(ent.class == Sketchup::Group)
           handleGroup(faceatts, ent.entities,layer)
         elsif(ent.class == Sketchup::ComponentInstance)
           handleGroup(faceatts, ent.definition.entities,layer)
         elsif(ent.class == Sketchup::Face)
           handleFace(faceatts, ent,layer)
         end
       }
end

def handleFace(faceatts, ent,layer)
  faceatts_ent = ent.attribute_dictionary("faceatts", true)
  faceatts_ent.keys.each{ |key|
    faceatts_ent.delete_key(key)
  }

  faceatts.each_pair { | key, value |
    faceatts_ent[key] = value
  }
  faceatts["id"] = "PolyGMLID " + "_" + rand(80000).to_s + "_" + rand(90000).to_s+"_" + rand(3212121).to_s + "_" + rand(1222222).to_s
  ent.layer = layer



end

# onCancel is called when the user hits the escape key
def onCancel(flag, view)
     @activate = false
     @ended = true
     clearSelection()
     cleanup()
   
end

def cleanup()
  if(@wasColorByLayer == false)
      opts = @model.rendering_options
     opts['DisplayColorByLayer']= false
  end
  @model.select_tool(nil)
end






end
