# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_schema/geores_feature/gres_cityobject.rb'
Sketchup::require 'geores_src/geores_debug/gres_cgmldebugger.rb'
Sketchup::require 'geores_src/geores_parser/layer_creator.rb'
Sketchup::require 'sketchup.rb'

class GRES_Transportation < GRES_CityObject
  def initialize
    super()
    @transportationType = ""
    @trafficAreas = Hash.new()
  end


  def setTransportType ttype
    @transportationType = ttype
  end

  def addTrafficArea trafficarea
    @trafficAreas[trafficarea.theinternalname] = trafficarea
  end

  def buildToSKP(parent, entity, dictname, counter)
     GRES_CGMLDebugger.writedebugstring("in buildToSKP Transportation\n")
     super(parent, entity, dictname, counter)
     GRES_CGMLDebugger.writedebugstring("ended buildToSKP of Super Class\n")
     if(dictname == nil)
       GRES_CGMLDebugger.writedebugstring("Fehler dictname String ist nil \n")
     end
     GRES_CGMLDebugger.writedebugstring("Current dictionary name is " + dictname + "\n")
     dictionary = entity.attribute_dictionary(dictname, true)
     parentname = @theinternalname
     if(@theinternalname == nil)
       GRES_CGMLDebugger.writedebugstring("Fehler @internalname String ist nil\n")
     end
     GRES_CGMLDebugger.writedebugstring("parentname is " + parentname + "\n")
     if(parent == nil)
       GRES_CGMLDebugger.writedebugstring("Fehler parent String ist nil \n")
     end
     if(parent != "")
       GRES_CGMLDebugger.writedebugstring("Fuege parent " + parent + " dem Element " + @theinternalname + " hinzu\n")
       dictionary["parent"] = parent
       parentname = parent + "." + @theinternalname
     end
     @trafficAreas.each_value { |area|
       puts "try to build TrafficArea"
       area.buildToSKP(parentname, entity, area.theinternalname, counter)
       counter = counter +1
     }
     dictionary["transportationtype"] = @transportationType
     if(parent != "")
       dictionary["parent"] = parent
     end
   end

   def buildgeometries(entities, appearances, citygmlloader, parentnames)
     parents = Array.new()
     if(parentnames != nil)
         parents.concat(parentnames)
       end
       parents.push(@theinternalname)
       layer_creator = citygmlloader.layercreator
       if(@lod1MultiSurface.length > 0)
         group = entities.add_group
         group.name = @theinternalname + ".@lod1MultiSurface"
         buildlod1multisurfacegeometry(group, appearances, citygmlloader, parents, layer_creator.lod1layer)
          transform = Geom::Transformation.scaling 39.370078740157477
         group.transformation = transform
       end


     lod2MultiGroup = nil
     lod3MultiGroup = nil
     lod4MultiGroup = nil
      layer_creator = citygmlloader.layercreator
   
     if(@lod2MultiSurface.length > 0 or @trafficAreas.length > 0)
          lod2MultiGroup = entities.add_group
          lod2MultiGroup.name = self.theinternalname + ".lod2MultiSurface"
          buildlod2multisurfacegeometry(lod2MultiGroup, appearances, citygmlloader, parents, layer_creator.lod2layer)
          transform = Geom::Transformation.scaling 39.370078740157477
          lod2MultiGroup.transformation = transform
     end
   
     if(@lod3MultiSurface.length > 0 or @trafficAreas.length > 0)
          lod3MultiGroup = entities.add_group
          lod3MultiGroup.name = self.theinternalname + ".lod3MultiSurface"
          buildlod3multisurfacegeometry(lod3MultiGroup, appearances, citygmlloader, parents, layer_creator.lod3layer)
          transform = Geom::Transformation.scaling 39.370078740157477
          lod3MultiGroup.transformation = transform
     end
    
     if(@lod4MultiSurface.length > 0 or @trafficAreas.length > 0)
          lod4MultiGroup = entities.add_group
          lod4MultiGroup.name = self.theinternalname + ".lod4MultiSurface"
          buildlod4multisurfacegeometry(lod4MultiGroup, appearances, citygmlloader, parents, layer_creator.lod4layer)
          transform = Geom::Transformation.scaling 39.370078740157477
          lod4MultiGroup.transformation = transform
     end

    end


  def buildlod2multisurfacegeometry group, appearances, citygmlloader, parentnames, layer

    layer_creator = citygmlloader.layercreator
    @trafficAreas.each_value { |area|
      area.buildlod2multisurfacegeometry(group, appearances, citygmlloader, parentnames,layer_creator.trafficareas)
    }
    
    super(group, appearances, citygmlloader, parentnames, layer)
   end



    def buildlod3multisurfacegeometry group, appearances, citygmlloader, parentnames, layer
      layer_creator = citygmlloader.layercreator

      @trafficAreas.each_value { |areas|
        areas.buildlod3multisurfacegeometry(group, appearances, citygmlloader, parentnames,layer_creator.trafficareas)
      }

      super(group, appearances, citygmlloader, parentnames, layer)

   end


    def buildlod4multisurfacegeometry group, appearances, citygmlloader, parentnames, layer
       layer_creator = citygmlloader.layercreator
      @trafficAreas.each_value { |area|
        area.buildlod4multisurfacegeometry(group, appearances, citygmlloader, parentnames,layer_creator.trafficareas)
      }
      super(group, appearances, citygmlloader, parentnames, layer)
   end


    attr_reader :trafficAreas

     def writeToCityGML isWFST, namespace

    retstring = ""
    retstring << "<core:cityObjectMember>\n"
    lastString = ""
    if(@theinternalname.index("Road") != nil)
      retstring << "<tran:Road" + " gml:id=\"" + @gmlid + "\">\n"
      lastString << "</tran:Road>\n"
    elsif(@theinternalname.index("Square") != nil)
        retstring << "<tran:Square" + " gml:id=\"" + @gmlid + "\">\n"
      lastString << "</tran:Square>\n"
    elsif(@theinternalname.index("Railway") != nil)
        retstring << "<tran:Railway" + " gml:id=\"" + @gmlid + "\">\n"
      lastString << "</tran:Railway>\n"
     elsif(@theinternalname.index("Track") != nil)
        retstring << "<tran:Track" + " gml:id=\"" + @gmlid + "\">\n"
      lastString << "</tran:Track>\n"
    else
      #not implemented!?
      return
    end

    @simpleCityObjectAttributes.each { |att|

      retstring << att.value
    }

      if(@lod1MultiSurface.length > 0)
        retstring  << "<tran:lod1MultiSurface>\n"
        retstring << "<gml:MultiSurface>\n"
       @lod1MultiSurface.each{ |geo|
       retstring << geo.writeToCityGML
      }
       retstring << "</gml:MultiSurface>\n"
       retstring  << "</tran:lod1MultiSurface>\n"

     end
       if(@lod2MultiSurface.length > 0)
        retstring  << "<tran:lod2MultiSurface>\n"
        retstring << "<gml:MultiSurface>\n"
       @lod2MultiSurface.each{ |geo|
       retstring << geo.writeToCityGML
      }
       retstring << "</gml:MultiSurface>\n"
       retstring  << "</tran:lod2MultiSurface>\n"

     end
       if(@lod3MultiSurface.length > 0)
        retstring  << "<tran:lod3MultiSurface>\n"
        retstring << "<gml:MultiSurface>\n"
       @lod3MultiSurface.each{ |geo|
       retstring << geo.writeToCityGML
      }
       retstring << "</gml:MultiSurface>\n"
       retstring  << "</tran:lod3MultiSurface>\n"

     end
       if(@lod4MultiSurface.length > 0)
        retstring  << "<tran:lod4MultiSurface>\n"
        retstring << "<gml:MultiSurface>\n"
       @lod4MultiSurface.each{ |geo|
       retstring << geo.writeToCityGML
      }
       retstring << "</gml:MultiSurface>\n"
       retstring  << "</tran:lod4MultiSurface>\n"

     end


    bbstring = ""

     @trafficAreas.each_value { |boundary|
        bbstring << boundary.writeToCityGML(isWFST, namespace)
     }
     retstring << bbstring

     retstring << lastString
      retstring << "</core:cityObjectMember>\n"
    return retstring
  end

end
