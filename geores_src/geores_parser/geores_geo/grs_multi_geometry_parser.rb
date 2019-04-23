# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_parser/geores_geo/grs_geoparser.rb'
Sketchup::require 'geores_src/geores_schema/geores_geo/gres_multisurfacegeometry.rb'
Sketchup::require 'geores_src/geores_debug/gres_cgmldebugger.rb'

class GRS_MultiGeometryParser < GRS_GeoParser
 
  def initialize
    super()
    @multisurface = nil
  end

   def tag_start name, attrs

     if(name == "gml:MultiSurface" or name == "gml:CompositeSurface")
       puts "bin nun in MultiSurface Parser"
       gmlid = getattrvalue("gml:id", attrs)
       @multisurface = GRES_MultiSurfaceGeometry.new()
       @multisurface.setgmlid(gmlid)
       return false
     end
     return super(name, attrs)

   end

    def text text
      return super(text)
    end

     def tag_end name
       if(name == "gml:MultiSurface" or name == "gml:CompositeSurface")
         @multisurface.addGeometries(@geometries)
        return false
       end
       return super(name)
     end

     attr_reader :multisurface
end
