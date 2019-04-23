# To change this template, choose Tools | Templates
# and open the template in the editor.
# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_schema/geores_feature/gres_cityobject.rb'
Sketchup::require 'sketchup.rb'
Sketchup::require 'geores_src/geores_debug/gres_cgmldebugger.rb'
Sketchup::require 'geores_src/geores_parser/layer_creator.rb'

class GRES_WaterBody < GRES_CityObject



  def initialize
    super()
    @boundaries = Hash.new()
  end


  def addBoundary b
    @boundaries[b.theinternalname] = b
  end

  def buildToSKP(parent, entity, dictname, counter)
     GRES_CGMLDebugger.writedebugstring("in buildToSKP WaterBody\n")
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
     @boundaries.each_value { |boundary|
       puts "try to build Boundary Water Surface"
       boundary.buildToSKP(parentname, entity, boundary.theinternalname, counter)
       counter = counter +1
     }

     if(parent != "")
       dictionary["parent"] = parent
     end

   end

    def buildFromSKP(entity, dictname)

   end

     def buildgeometries(entities, appearances, citygmlloader, parentnames)
       parents = Array.new()
       if(parentnames != nil)
         parents.concat(parentnames)
       end
       parents.push(@theinternalname)
       layer_creator = citygmlloader.layercreator
       lod1SolidGroup = nil
        lod2SolidGroup = nil
        lod1MultiGroup = nil
        lod3SolidGroup = nil
        lod4SolidGroup = nil
      layer_creator = citygmlloader.layercreator
     if(@lod2Solid.length > 0)
          lod2SolidGroup = entities.add_group
          lod2SolidGroup.name = self.theinternalname + ".lod2Solid"
          buildlod2solidgeometry(lod2SolidGroup, appearances, citygmlloader, parents, layer_creator.lod2layer)
          transform = Geom::Transformation.scaling 39.370078740157477
          lod2SolidGroup.transformation = transform
     end
     if(@lod1MultiSurface.length > 0)
          lod1MultiGroup = entities.add_group
          lod1MultiGroup.name = self.theinternalname + ".lod1MultiSurface"
          buildlod1multisurfacegeometry(lod1MultiGroup, appearances, citygmlloader, parents, layer_creator.lod1layer)
          transform = Geom::Transformation.scaling 39.370078740157477
          lod1MultiGroup.transformation = transform
     end
     if(@lod3Solid.length > 0)
          lod3SolidGroup = entities.add_group
          lod3SolidGroup.name = self.theinternalname + ".lod3Solid"
          buildlod3solidgeometry(lod3SolidGroup, appearances, citygmlloader, parents, layer_creator.lod3layer)
          transform = Geom::Transformation.scaling 39.370078740157477
          lod3SolidGroup.transformation = transform
     end

      if(@lod4Solid.length > 0)
          lod4SolidGroup = entities.add_group
          lod4SolidGroup.name = self.theinternalname + ".lod4Solid"
          buildlod4solidgeometry(lod4SolidGroup, appearances, citygmlloader, parents, layer_creator.lod4layer)
          transform = Geom::Transformation.scaling 39.370078740157477
          lod4SolidGroup.transformation = transform
     end

       if(@boundaries.length > 0)
         lod2MultiGroup = entities.add_group
          lod2MultiGroup.name = self.theinternalname + ".lod2MultiSurface"
          buildlod2multisurfacegeometry(lod2MultiGroup, appearances, citygmlloader, parents, layer_creator.lod2layer)
          transform = Geom::Transformation.scaling 39.370078740157477
          lod2MultiGroup.transformation = transform

         lod3MultiGroup = entities.add_group
          lod3MultiGroup.name = self.theinternalname + ".lod3MultiSurface"
          buildlod3multisurfacegeometry(lod3MultiGroup, appearances, citygmlloader, parents, layer_creator.lod3layer)
          transform = Geom::Transformation.scaling 39.370078740157477
          lod3MultiGroup.transformation = transform

         lod4MultiGroup = entities.add_group
          lod4MultiGroup.name = self.theinternalname + ".lod4MultiSurface"
          buildlod4multisurfacegeometry(lod4MultiGroup, appearances, citygmlloader, parents, layer_creator.lod2layer)
          transform = Geom::Transformation.scaling 39.370078740157477
          lod4MultiGroup.transformation = transform
       end
     end

     def buildlod2multisurfacegeometry group, appearances, citygmlloader, parentnames, layer

        layer_creator = citygmlloader.layercreator
        @boundaries.each_value { |boundary|

          boundary.buildlod2multisurfacegeometry(group, appearances, citygmlloader, parentnames,layer_creator.water)
      }

   end



    def buildlod3multisurfacegeometry group, appearances, citygmlloader, parentnames, layer
      layer_creator = citygmlloader.layercreator

      @boundaries.each_value { |boundary|
        boundary.buildlod3multisurfacegeometry(group, appearances, citygmlloader, parentnames,layer_creator.water)
      }


   end


    def buildlod4multisurfacegeometry group, appearances, citygmlloader, parentnames, layer
       layer_creator = citygmlloader.layercreator
      @boundaries.each_value { |boundary|
        boundary.buildlod4multisurfacegeometry(group, appearances, citygmlloader, parentnames,layer_creator.water)
      }

   end
     attr_reader :boundaries

def writeToCityGML isWFST, namespace
    retstring = ""
    #if(isWFST == "true")
     # return writeToCityGMLWFST(namespace)
    #end
  retstring << "<core:cityObjectMember>\n"
   retstring << "<wtr:WaterBody gml:id=\"" + @gmlid + "\">\n"


    @simpleCityObjectAttributes.each { |att|

      retstring << att.value
    }

      if(@lod1MultiSurface.length > 0)
        retstring  << "<" + namespace + "lod1MultiSurface>\n"
        retstring << "<gml:MultiSurface>\n"
       @lod1MultiSurface.each{ |geo|
       retstring << geo.writeToCityGML
      }
       retstring << "</gml:MultiSurface>\n"
       retstring  << "</" + namespace + "lod1MultiSurface>\n"

     end
      if(@lod1Solid.length > 0)
        retstring << "<wtr:lod1Solid>\n"
        retstring << "<gml:Solid>\n"
        retstring << "<gml:exterior>\n"
        retstring << "<gml:CompositeSurface>\n"
       @lod1Solid.each{ |geo|
       retstring << geo.writeToCityGML
      }
        retstring << "</gml:CompositeSurface>\n"
       retstring << "</gml:exterior>\n"
       retstring << "</gml:Solid>\n"
       retstring << "</wtr:lod1Solid>\n"

     end

     if(@lod2Solid.length > 0)
        retstring << "<wtr:lod2Solid>\n"
        retstring << "<gml:Solid>\n"
        retstring << "<gml:exterior>\n"
        retstring << "<gml:CompositeSurface>\n"
       @lod2Solid.each{ |geo|
       retstring << geo.writeToCityGML
      }
        retstring << "</gml:CompositeSurface>\n"
       retstring << "</gml:exterior>\n"
       retstring << "</gml:Solid>\n"
       retstring << "</wtr:lod2Solid>\n"

     end
      if(@lod3Solid.length > 0)
        retstring << "<wtr:lod3Solid>\n"
        retstring << "<gml:Solid>\n"
        retstring << "<gml:exterior>\n"
        retstring << "<gml:CompositeSurface>\n"
       @lod3Solid.each{ |geo|
       retstring << geo.writeToCityGML
      }
        retstring << "</gml:CompositeSurface>\n"
       retstring << "</gml:exterior>\n"
       retstring << "</gml:Solid>\n"
       retstring << "</wtr:lod3Solid>\n"

     end
      if(@lod4Solid.length > 0)
        retstring << "<wtr:lod4Solid>\n"
        retstring << "<gml:Solid>\n"
        retstring << "<gml:exterior>\n"
        retstring << "<gml:CompositeSurface>\n"
       @lod4Solid.each{ |geo|
       retstring << geo.writeToCityGML
      }
        retstring << "</gml:CompositeSurface>\n"
       retstring << "</gml:exterior>\n"
       retstring << "</gml:Solid>\n"
       retstring << "</wtr:lod4Solid>\n"

     end

    bbstring = ""

     @boundaries.each_value { |boundary|
        bbstring << boundary.writeToCityGML(isWFST, "wtr:")
     }
     retstring << bbstring
     retstring << "</wtr:WaterBody>\n"
     retstring << "</core:cityObjectMember>\n"

    return retstring


  end

  
end

