# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'sketchup.rb'
Sketchup::require 'geores_src/geores_schema/geores_geo/gres_linear_ring.rb'
Sketchup::require 'geores_src/geores_schema/geores_geo/gres_surface.rb'
Sketchup::require 'geores_src/geores_debug/gres_cgmldebugger.rb'

class GRS_TriangulatedSurfaceParser
  @surface = nil
  @isInCurrentSurface = false
  @currentRing = nil
  @gmlid = ""

  def initialize
    @geometries = Array.new()
  end

  attr_reader :geometries

   def tag_start name, attrs
     @currenttag = name
     if(name == "gml:Triangle")
       @surface = GRES_Surface.new()
       gmlid = getattrvalue("gml:id", attrs)
       if(gmlid != "")
         @surface.setgmlid(gmlid)
       end



       @isInCurrentSurface = true
       return false
     end
     if(name == "gml:TriangulatedSurface")
       @gmlid = getattrvalue("gml:id", attrs)
     end

      if(@isInCurrentSurface == true and name == "gml:LinearRing")
        @currentRing = GRES_LinearRing.new()
        gmlid = getattrvalue("gml:id", attrs)
        if(gmlid != "")
         @surface.setgmlid(gmlid)
         #model = Sketchup.active_model
         #TODO model.set_attribute("tinids", gmlid, gmlid)
       end
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
       if(name == "gml:Triangle")
         @surface.setparentgmlid(@gmlid)
         @geometries.push(@surface)
         puts "ein Polygon gefunden"
         @isInCurrentSurface = false
       return false
     end
      if(@isInCurrentSurface == true and name == "gml:exterior")
        @surface.addExternalRing(@currentRing)
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
