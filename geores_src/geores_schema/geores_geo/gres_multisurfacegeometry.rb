# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_schema/geores_geo/gres_geometry_collection.rb'

class GRES_MultiSurfaceGeometry < GRES_GeometryCollection
  def initialize
    super()
  end

   def writeToCityGML
     retString = ""
     retString << "<gml:MultiSurface>\n"

     @geometries.each { |g|
        retString << g.writeToCityGML
     }
    retString << "</gml:MultiSurface>\n"

     return retString
  end

   def build(group, appearances, citygmlloader, parentnames, lod, layer, isimpl)
     @geometries.each { |g|
       g.build(group,appearances, citygmlloader, parentnames, @gmlid, lod, layer, isimpl, false)
     }
  end
end
