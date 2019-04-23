# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_parser/cityobjectparser.rb'
Sketchup::require 'geores_src/geores_debug/gres_cgmldebugger.rb'
Sketchup::require 'geores_src/geores_schema/geores_attributes/simple_city_object_attribute.rb'

class GRES_Water_BoundaryParser < CityObjectParser



  def initialize(cityobject,factory)
    super(cityobject, factory)
  end

   def tag_start name, attrs

     GRES_CGMLDebugger.writedebugstring("WaterGRES_BoundaryParser in tag_start mit " + name + "\n")


      if(name.index("WaterClosureSurface") != nil or name.index("WaterSurface") != nil or name.index("WaterGroundSurface"))
         @cityObject.setboundarytype(name)
          id = getattrvalue("gml:id", attrs)
         if(id != "")
           @cityObject.setgmlid(id)
         end
      end

      if(super(name,attrs) == false)
        return false
      end

      if(name.index("waterLevel") != nil)
        @currentSimpleAttribute = SimpleCityObjectAttribute.new(name, attrs)
        @isInSimpleAttribute = true
        return false
      end


      return true
   end

    def text text

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

          if(super(name) == false)
                return false
           end
            if(name.index("waterLevel") != nil)
                @cityObject.addSimpleAttribute(@currentSimpleAttribute)
                @isInSimpleAttribute = false
                @currentSimpleAttribute = nil
               return false
           end
           return true
     end
end
