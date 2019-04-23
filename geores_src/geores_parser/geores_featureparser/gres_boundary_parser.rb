# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_parser/cityobjectparser.rb'
Sketchup::require 'geores_src/geores_debug/gres_cgmldebugger.rb'

class GRES_BoundaryParser < CityObjectParser
  


  def initialize(cityobject,factory)
    super(cityobject, factory)
    @currentGRES_OpeningParser = nil
     @isInOpening = false

     @nextisclassname = false
  end

   def tag_start name, attrs

     GRES_CGMLDebugger.writedebugstring("GRES_BoundaryParser in tag_start mit " + name + "\n")

       if(@isInOpening == true)
         if(@nextisclassname == true)
           @nextisclassname = false
           @currentGRES_OpeningParser = @factory.getCityObjectParserForName(name)
         end
        @currentGRES_OpeningParser.tag_start(name, attrs)
        return false
      end
      if(name.index("RoofSurface") != nil or name.index("WallSurface") != nil or name.index("GroundSurface") != nil or name.index("ClosureSurface") != nil or
         name.index("CeilingSurface") != nil or name.index("FloorSurface") != nil)
         @cityObject.setboundarytype(name)
         GRES_CGMLDebugger.writedebugstring("GRES_BoundaryParser: Set Boundary Type : " + name + "\n")
          id = getattrvalue("gml:id", attrs)
         if(id != "")
           @cityObject.setgmlid(id)
           GRES_CGMLDebugger.writedebugstring("GRES_BoundaryParser: Set  GML:ID Type : " + id + "for " + @cityObject.theinternalname + "\n")
         end
      end

      if(super(name,attrs) == false)
        return false
      end

     if(name.index("opening") != nil)
       @nextisclassname = true
        @isInOpening = true
        return false
      end
      return true
   end

    def text text
      if(@isInOpening == true and @currentGRES_OpeningParser!= nil)
            @currentGRES_OpeningParser.text(text)
            return false
          end
          if(super(text) == false)
            return false
          end
          return true
     end

     def tag_end name
          if(name.index("opening") != nil)
              @cityObject.addOpening(@currentGRES_OpeningParser.cityObject)
              @isInOpening = false
              @currentGRES_OpeningParser = nil
              GRES_CGMLDebugger.writedebugstring("GRES_BoundaryParser: found end tag of opening " + name + " add Opening to " + @cityObject.theinternalname + " @isInAddress= false \n")
              return false
           end
           if(@isInOpening == true and @currentGRES_OpeningParser != nil)
                @currentGRES_OpeningParser.tag_end(name)
                return false
            end
          if(super(name) == false)
                return false
           end
           return true
     end


end
