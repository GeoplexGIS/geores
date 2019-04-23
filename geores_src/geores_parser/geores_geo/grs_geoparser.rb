# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'sketchup.rb'
Sketchup::require 'geores_src/geores_schema/geores_geo/gres_linear_ring.rb'
Sketchup::require 'geores_src/geores_schema/geores_geo/gres_surface.rb'
Sketchup::require 'geores_src/geores_debug/gres_cgmldebugger.rb'

class GRS_GeoParser

  
  @surface = nil
  @isInCurrentSurface = false
  @currentRing = nil

  def initialize
    @geometries = Array.new()
  end

  attr_reader :geometries

   def tag_start name, attrs
     @currenttag = name
     if(name == "gml:surfaceMember")
       @surface = GRES_Surface.new()
       xlink = getattrvalue("xlink:href", attrs)
       @surface.setxlink(xlink.delete("#"))
       @isInCurrentSurface = true
       return false
     end
     if(@isInCurrentSurface == true and name == "gml:Polygon")
       gmlid = getattrvalue("gml:id", attrs)
       @surface.setgmlid(gmlid)
       return false
     end

      if(@isInCurrentSurface == true and name == "gml:LinearRing")
        gmlid = getattrvalue("gml:id", attrs)
        puts "initialisiere currentRing"
        @currentRing = GRES_LinearRing.new()
        @currentRing.setgmlid(gmlid)
        return false
      end

     return true
   end

    def text text
      if(@currenttag == "gml:pos" or @currenttag == "gml:posList")
        puts "coord posistions are " + text
        coords = text.split(" ")
         puts "array with posistions are " + coords.to_s
        i = 0
        while i < coords.length-2
           x = coords[i].to_f
           y = coords[i+1].to_f
           z = coords[i+2].to_f

           po3d = Geom::Point3d.new x,y,z
           puts "Punkt " + po3d.to_s
           puts "currentRing " + @currentRing.to_s
           @currentRing.addPoint(po3d)
          i = i+3
        end
        return false
      end
      return true
    end

     def tag_end name
       if(name == "gml:surfaceMember")
         if(@surface == nil)
           GRES_CGMLDebugger.writedebugstring("Fehler @surface == nil beim parsen\n")
         end
         @geometries.push(@surface)
         puts "ein Polygon gefunden"
         @isInCurrentSurface = false
       return false
     end
      if(@isInCurrentSurface == true and name == "gml:exterior")
        @surface.addExternalRing(@currentRing)
        return false
     end
     if(@isInCurrentSurface == true and name == "gml:interior")
        @surface.addInternalRing(@currentRing)
         return false
     end
     return true
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
