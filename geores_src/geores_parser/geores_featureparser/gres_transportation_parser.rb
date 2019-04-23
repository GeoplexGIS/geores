# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_parser/cityobjectparser.rb'
Sketchup::require 'geores_src/geores_parser/geores_geo/grs_implicit_geometry_parser.rb'
Sketchup::require 'geores_src/geores_debug/gres_cgmldebugger.rb'

class GRES_TransportationParser < CityObjectParser

    @currentGRES_TrafficAreaParser = nil
    @isInTrafficArea = false
    @nextisclassname = false


  def initialize(cityobject,factory)
    super(cityobject, factory)
    end


   def tag_start name, attrs
      GRES_CGMLDebugger.writedebugstring("GRES_TransportationParser in tag_start mit " + name + "\n")
       if(@isInTrafficArea == true)
         if(@nextisclassname == true)
           GRES_CGMLDebugger.writedebugstring("GRES_TransportationParser Get Parser for TrafficArea\n")
          @currentGRES_TrafficAreaParser = @factory.getCityObjectParserForName(name);
          @nextisclassname = false
        end
        if(@currentGRES_TrafficAreaParser != nil)
          @currentGRES_TrafficAreaParser.tag_start(name, attrs)
        end
        return false
      end

      if(name.index("Road") != nil or name.index("Track") != nil or name.index("Square") != nil or name.index("Railway") != nil)
         id = getattrvalue("gml:id", attrs)
         @cityObject.setTransportType(name)
          GRES_CGMLDebugger.writedebugstring("GRES_TransportationParser Set TransportType : " + name + " for " + @cityObject.theinternalname + "\n")
         if(id != "")
           @cityObject.setgmlid(id)
           GRES_CGMLDebugger.writedebugstring("GRES_TransportationParser Set  GML:ID Type : " + id + " for " + @cityObject.theinternalname + "\n")
         end
         return false
      end

      if(super(name,attrs) == false)
        return false
      end
       if(name.index("trafficArea") != nil or name.index("auxiliaryTrafficArea") != nil )
        @nextisclassname = true
        @isInTrafficArea = true
        GRES_CGMLDebugger.writedebugstring("GRES_TransportationParser Found TrafficAraea  @nextisclassname = true and @isInTrafficArea = true\n")
        return false
      end

      if(name.index("class") != nil or name.index("function") != nil or name.index("usage") != nil)
        @currentSimpleAttribute = SimpleCityObjectAttribute.new(name, attrs)
        @isInSimpleAttribute = true
        GRES_CGMLDebugger.writedebugstring("GRES_TransportationParser create a simple Attribute with " + name + "@isInSimpleAttribute = true \n ")
        return false
      end

      return true
    end

    def text text
        if(@isInTrafficArea == true and @currentGRES_TrafficAreaParser != nil)
                @currentGRES_TrafficAreaParser.text(text)
                return false
              end

          if(super(text) == false)
            return false
          end

          if(@isInSimpleAttribute == true and @currentSimpleAttribute != nil)
            @currentSimpleAttribute.addValue(text)
            return false
          end
          return true
     end

     def tag_end name

        if((name.index("trafficArea") != nil or name.index("auxiliaryTrafficArea") != nil ) and @currentGRES_TrafficAreaParser != nil)
              GRES_CGMLDebugger.writedebugstring("GRES_TransportationParser found end tag TraffiCArea " + name + " add TrafficARea to " + @cityObject.theinternalname + " @isInAddress= false \n")
              @cityObject.addTrafficArea(@currentGRES_TrafficAreaParser.cityObject)
              @isInTrafficArea = false
              @currentGRES_TrafficAreaParser = nil
              return false
           end
           if(@isInTrafficArea == true and @currentGRES_TrafficAreaParser != nil)
                @currentGRES_TrafficAreaParser.tag_end(name)
                return false
            end

             if(super(name) == false)
                return false
              end
             if(name.index("class") != nil or name.index("function") != nil or name.index("usage") != nil )
                @cityObject.addSimpleAttribute(@currentSimpleAttribute)
                @isInSimpleAttribute = false
                @currentSimpleAttribute = nil
               return false
           end
           return true
     end


end
