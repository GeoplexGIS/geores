# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_schema/geores_feature/gres_cityobject.rb'

class GRES_LandUse < GRES_CityObject
  def initialize
    super()
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
       if(@lod2MultiSurface.length > 0)
         group = entities.add_group
         group.name = @theinternalname + ".@lod2MultiSurface"
         buildlod2multisurfacegeometry(group, appearances, citygmlloader, parents, layer_creator.lod2layer)
         transform = Geom::Transformation.scaling 39.370078740157477
         group.transformation = transform
       end
       if(@lod3MultiSurface.length > 0)
         group = entities.add_group
         group.name = @theinternalname + ".@lod3MultiSurface"
         buildlod3multisurfacegeometry(group, appearances, citygmlloader, parents, layer_creator.lod3layer)
         transform = Geom::Transformation.scaling 39.370078740157477
         group.transformation = transform
       end
       if(@lod4MultiSurface.length > 0)
         group = entities.add_group
         group.name = @theinternalname + ".@lod4MultiSurface"
         buildlod4multisurfacegeometry(group, appearances, citygmlloader, parents, layer_creator.lod4layer)
         transform = Geom::Transformation.scaling 39.370078740157477
         group.transformation = transform
       end

   end

  def writeToCityGML isWFST, namespace

    retstring = ""


   retstring << "<core:cityObjectMember>\n"
   retstring << "<luse:LandUse gml:id=\"" + @gmlid + "\">\n"

    @simpleCityObjectAttributes.each { |att|

      retstring << att.value
    }
     if(@lod1MultiSurface.length > 0)
        retstring  << "<luse:lod1MultiSurface>\n"
        retstring << "<gml:MultiSurface>\n"
       @lod1MultiSurface.each{ |geo|
       retstring << geo.writeToCityGML
      }
       retstring << "</gml:MultiSurface>\n"
       retstring  << "</luse:lod1MultiSurface>\n"

     end
      if(@lod2MultiSurface.length > 0)
        retstring  << "<luse:lod2MultiSurface>\n"
        retstring << "<gml:MultiSurface>\n"
       @lod2MultiSurface.each{ |geo|
       retstring << geo.writeToCityGML
      }
       retstring << "</gml:MultiSurface>\n"
       retstring  << "</luse:lod2MultiSurface>\n"

     end
      if(@lod3MultiSurface.length > 0)
        retstring  << "<luse:lod3MultiSurface>\n"
        retstring << "<gml:MultiSurface>\n"
       @lod3MultiSurface.each{ |geo|
       retstring << geo.writeToCityGML
      }
       retstring << "</gml:MultiSurface>\n"
       retstring  << "</luse:lod3MultiSurface>\n"

     end
      if(@lod4MultiSurface.length > 0)
        retstring  << "<luse:lod4MultiSurface>\n"
        retstring << "<gml:MultiSurface>\n"
       @lod4MultiSurface.each{ |geo|
       retstring << geo.writeToCityGML
      }
       retstring << "</gml:MultiSurface>\n"
       retstring  << "</luse:lod4MultiSurface>\n"

     end


       retstring << "</luse:LandUse>\n"
       retstring << "</core:cityObjectMember>\n"

    return retstring
  end


end
