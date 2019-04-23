# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'sketchup.rb'
Sketchup::require 'geores_src/geores_parser/geores_geo/grs_multi_geometry_parser.rb'
Sketchup::require 'geores_src/geores_parser/geores_geo/grs_implicit_geometry_parser.rb'
Sketchup::require 'geores_src/geores_schema/geores_geo/gres_implicitgeometry.rb'
Sketchup::require 'geores_src/geores_debug/gres_cgmldebugger.rb'

class GRS_ImplicitGeometryParser
    def initialize
      @geometry = GRES_ImplicitGeometry.new()
      @GRS_GeoParser = nil
    end

attr_reader :geometry

   def tag_start name, attrs
     @currenttagname = name
     if(name == "core:relativeGMLGeometry")
       xlink = getattrvalue("xlink:href",attrs)
       if(xlink == "")
          xlink = getattrvalue("xlk:href",attrs)
       end
       if(xlink != "" )
         @geometry.setxlink(xlink.delete("#"))
       end
     end
      if(name.index("gml:MultiSurface") != nil)
        id = getattrvalue("gml:id", attrs)
       @geometry.setid(id)
       @GRS_GeoParser = GRS_MultiGeometryParser.new()
       @isInMultiGeometry = true
      end
      if(@isInMultiGeometry == true)
       @GRS_GeoParser.tag_start(name,attrs)
       return
     end
   end

   def text text
     if(@isInMultiGeometry == true)
       @GRS_GeoParser.text(text)
       return
     end
     if(@currenttagname == "core:transformationMatrix")
       trafoarray = []
       arraytext = text.split(" ")
       i = 0
       arraytext.each { |a|
         trafoarray[i] = a.to_f
         i = i+1
       }
       trafo = Geom::Transformation.new(trafoarray)
       @geometry.settransformation(trafo)
       return
     end
     if(@currenttagname == "gml:pos")
       coords = text.split(" ")
       x = coords[0].to_f
       y = coords[1].to_f
       z = coords[2].to_f
       po = Geom::Point3d.new x,y,z
       #trafo = Geom::Transformation.new po
       @geometry.settransformationpoint(po)
     end
   end

    def tag_end name
        if(name.index("gml:MultiSurface") != nil)

           @geometry.addGeometries(@GRS_GeoParser.geometries)
           @isInMultiGeometry = false
         return
        end
        if(@isInMultiGeometry == true)
          @GRS_GeoParser.tag_end(name)
        return
        end

    end

    def getattrvalue(name, array)
           array.each{|arr|
             if(arr[0] == name)
               return arr[1]
             end
           }
     return ""
    end
end
