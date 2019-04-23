# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_parser/geores_geo/grs_geoparser.rb'
Sketchup::require 'geores_src/geores_schema/geores_geo/gres_solidgeometry.rb'
Sketchup::require 'geores_src/geores_debug/gres_cgmldebugger.rb'

class SolidGeometryParser < GRS_GeoParser
  
  def initialize
    super()
    @solid = nil
  end

   def tag_start name, attrs
      
     if(name == "gml:Solid")
       
       gmlid = getattrvalue("gml:id", attrs)
       GRES_CGMLDebugger.writedebugstring("found gml:solid tag with gml:id" + gmlid.to_s  + " init new SolidGeometry Object \n")
       @solid = GRES_SolidGeometry.new()
       @solid.setgmlid(gmlid)
       return false
     end
     return super(name, attrs)

   end

    def text text
      return super(text)
    end

     def tag_end name
       if(name == "gml:Solid")
         GRES_CGMLDebugger.writedebugstring("found gml:solid end tag. add Geometries to Solid \n")
         @solid.addGeometries(@geometries)
        return false
       end
       return super(name)
     end

     attr_reader :solid
end
