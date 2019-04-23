# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_parser/cityobjectparser.rb'
Sketchup::require 'geores_src/geores_parser/geores_geo/grs_triangulated_surface_parser.rb'
Sketchup::require 'geores_src/geores_schema/geores_feature/gres_t_i_n_relief.rb'
Sketchup::require 'geores_src/geores_schema/geores_feature/gres_raster_relief.rb'

class GRES_ReliefFeatureParser < CityObjectParser
   def initialize(cityobject,factory)
    super(cityobject, factory)
    @currentGRS_GeoParser = nil
    @isInGRS_GeoParser = false
  end

    def tag_start name, attrs
      GRES_CGMLDebugger.writedebugstring("GRES_ReliefFeatureParser in tag_start mit " + name + "\n")
      @currenttagname = name
      if(@isInGRS_GeoParser == true)
        @currentGRS_GeoParser.tag_start(name, attrs)
        return false
      end
      if(name == "dem:RasterRelief")
        @cityObject = GRES_RasterRelief.new()
        @cityObject.setname("TIN")
        GRES_CGMLDebugger.writedebugstring("GRES_ReliefFeatureParser: Rasterrelief gefunden. Erzeuge entsprechendes CityObject. \n")
        id = getattrvalue("gml:id", attrs)
         if(id != "")
           @cityObject.setgmlid(id)
         end
        return false
      elsif(name == "dem:TINRelief")
        @cityObject = GRES_TINRelief.new()
        @cityObject.setname("TIN")
         GRES_CGMLDebugger.writedebugstring("GRES_ReliefFeatureParser: TINRelief gefunden. Erzeuge entsprechendes CityObject. \n")
        id = getattrvalue("gml:id", attrs)
         if(id != "")
           @cityObject.setgmlid(id)
         end
        return false
      end
      if(name == "gml:TriangulatedSurface")
        @isInGRS_GeoParser = true
        GRES_CGMLDebugger.writedebugstring("GRES_ReliefFeatureParser: gml:TriangulatedSurface gefunden. Erzeuge den GRS_TriangulatedSurfaceParser. @isInGRS_GeoParser = true \n")
        @currentGRS_GeoParser = GRS_TriangulatedSurfaceParser.new()
        @currentGRS_GeoParser.tag_start(name, attrs)
        return false
      end
     return true
   end


    def text text
      GRES_CGMLDebugger.writedebugstring("GRES_ReliefFeatureParser in text mit " + @currenttagname + " and text" + text + "\n")
       if(@isInGRS_GeoParser == true)
        @currentGRS_GeoParser.text(text)
        return false
      end
      if(@currenttagname =="gml:low")
        vals = text.split(" ")
        if(vals.length >= 2)
          @cityObject.addposlow(vals[0], vals[1])
          GRES_CGMLDebugger.writedebugstring("GRES_ReliefFeatureParser: addposlow " + vals[0] + " , " + vals[1] +" \n")
        end
        return false
      end
     if(@currenttagname =="gml:high")
        vals = text.split(" ")
        if(vals.length >= 2)
          @cityObject.addposhigh(vals[0], vals[1])
          GRES_CGMLDebugger.writedebugstring("GRES_ReliefFeatureParser: addposhigh " + vals[0] + " , " + vals[1] +" \n")
        end
        return false
     end
    if(@currenttagname =="gml:pos")
        vals = text.split(" ")
        if(vals.length >= 2)
          @cityObject.addposorigin(vals[0], vals[1])
          GRES_CGMLDebugger.writedebugstring("GRES_ReliefFeatureParser: addposorigin " + vals[0] + " , " + vals[1] +" \n")
        end
        return false
    end
     if(@currenttagname == "gml:offsetVector")
        vals = text.split(" ")
        if(vals.length >= 2)
          if(@cityObject.posOffset1.length == 0)
            @cityObject.addposoffset1(vals[0], vals[1])
            GRES_CGMLDebugger.writedebugstring("GRES_ReliefFeatureParser: addposoffset1 " + vals[0] + " , " + vals[1] +" \n")
          else
            @cityObject.addposoffset2(vals[0], vals[1])
            GRES_CGMLDebugger.writedebugstring("GRES_ReliefFeatureParser: addposoffset2 " + vals[0] + " , " + vals[1] +" \n")
          end
        end
      return false
     end
    if(@currenttagname.index('gml:QuantityList') != nil)
        vals = text.split(" ")
        vals.each{|v|
          GRES_CGMLDebugger.writedebugstring("GRES_ReliefFeatureParser: addpointtolist " + v + " \n")
          @cityObject.addpointtolist(v)
        }
     end
     return true
    end

     def tag_end name
       GRES_CGMLDebugger.writedebugstring("GRES_ReliefFeatureParser in tag_end mit " + name + "\n")
      if(name == "gml:TriangulatedSurface")
        @isInGRS_GeoParser = false
        GRES_CGMLDebugger.writedebugstring("GRES_ReliefFeatureParser: Ende von  gml:TriangulatedSurface gefunden \n")
        @cityObject.addTriangles(@currentGRS_GeoParser.geometries)
        return false
      end
       if(@isInGRS_GeoParser == true)
        @currentGRS_GeoParser.tag_end(name)
        return false
      end
        return true
     end
end
