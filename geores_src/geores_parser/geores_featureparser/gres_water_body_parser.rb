# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_parser/cityobjectparser.rb'
Sketchup::require 'geores_src/geores_parser/geores_featureparser/gres_water_boundary_parser.rb'
Sketchup::require 'geores_src/geores_schema/geores_attributes/simple_city_object_attribute.rb'
Sketchup::require 'geores_src/geores_debug/gres_cgmldebugger.rb'

class GRES_WaterBodyParser < CityObjectParser



 def initialize(cityobject,factory)
    super(cityobject, factory)

      @currentGRES_BoundaryParser = nil
      @isInBoundary = false

      @nextisclassname = false
  end

   def tag_start name, attrs
     GRES_CGMLDebugger.writedebugstring("GRES_WaterBodyParser in tag_start mit " + name + "\n")

       if(@isInBoundary == true)
         if(@nextisclassname == true)
           puts "Name is " +name
          @currentGRES_BoundaryParser = @factory.getCityObjectParserForName(name);
          @nextisclassname = false
        end
        if(@currentGRES_BoundaryParser != nil)
          @currentGRES_BoundaryParser.tag_start(name, attrs)
        end
        return false
      end
       puts "try to go in to cityobject tag_start"
       b = super(name,attrs)
       puts b.to_s
       if(b == false)
         puts "tag_start of cityobject returned false"
         return false
       end
      puts "tag_start of cityobject returned true"


      if(name.index("boundedBy") != nil and name.index("gml:") == nil)
        puts "found a boundary"
         @nextisclassname = true
        @isInBoundary = true
        return false
      end

       if(name.index("class") != nil or name.index("function") != nil or name.index("usage") != nil)
        @currentSimpleAttribute = SimpleCityObjectAttribute.new(name, attrs)
        @isInSimpleAttribute = true
        return false
      end


      return true
   end


    def text text
      GRES_CGMLDebugger.writedebugstring("GRES_WaterBodyParser in text mit " + text + "\n")

      if(@isInBoundary == true and @currentGRES_BoundaryParser != nil)
        @currentGRES_BoundaryParser.text(text)
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


           if(name.index("boundedBy") != nil and name.index("gml:") == nil and @currentGRES_BoundaryParser != nil)
             puts "fuege dem CityObject eine Boundary hinzu"
              @cityObject.addBoundary(@currentGRES_BoundaryParser.cityObject)
              @isInBoundary = false
              @currentGRES_BoundaryParser = nil
              return false
           end
           if(@isInBoundary == true and @currentGRES_BoundaryParser != nil)
                @currentGRES_BoundaryParser.tag_end(name)
                return false
            end

             if(super(name) == false)
               "Gehe in Tag End von CityObject " + name
                return false
              end
             if(name.index("class") != nil or name.index("function") != nil or name.index("usage") != nil)
                @cityObject.addSimpleAttribute(@currentSimpleAttribute)
                @isInSimpleAttribute = false
                @currentSimpleAttribute = nil
               return false
           end
           return true
     end
end
