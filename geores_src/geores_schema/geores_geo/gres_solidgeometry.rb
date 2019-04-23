# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_schema/geores_geo/gres_geometry_collection.rb'

class GRES_SolidGeometry < GRES_GeometryCollection
  def initialize
    super()
  end

  def writeToCityGML
     retString = ""
     retString << "<gml:Solid>\n"
     retString << "<gml:exterior>\n"
     retString << "<gml:CompositeSurface gml:id=\"" + @gmlid + "\">\n"

     @geometries.each { |g|
        retString << g.writeToCityGML
     }
    retString << "</gml:CompositeSurface>\n"
    retString << "</gml:exterior>\n"
    retString << "</gml:Solid>\n"

     return retString
  end

  def build(group, appearances, citygmlloader, parentnames, lod, layer, isimpl)
     @geometries.each { |g|
       g.build(group,appearances, citygmlloader, parentnames, @gmlid, lod, layer, isimpl, true)
     }
  end
end
