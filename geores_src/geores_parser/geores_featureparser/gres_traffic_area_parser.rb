# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_parser/cityobjectparser.rb'
Sketchup::require 'geores_src/geores_debug/gres_cgmldebugger.rb'

class GRES_TrafficAreaParser < CityObjectParser



  def initialize(cityobject,factory)
    super(cityobject, factory)
  end

   def tag_start name, attrs
    GRES_CGMLDebugger.writedebugstring("GRES_TrafficAreaParser in tag_start mit " + name + "\n")
      if(name.index("AuxiliaryTrafficArea") != nil or name.index("TrafficArea") != nil)
         @cityObject.setTrafficType(name)
         GRES_CGMLDebugger.writedebugstring("GRES_TrafficAreaParser Set TrafficTyoe : " + name + " for " + @cityObject.theinternalname + "\n")

          id = getattrvalue("gml:id", attrs)
         if(id != "")
           @cityObject.setgmlid(id)
           GRES_CGMLDebugger.writedebugstring("GRES_TrafficAreaParser Set  GML:ID Type : " + id + " for " + @cityObject.theinternalname + "\n")
         end
      end

      if(super(name,attrs) == false)
        return false
      end
        if(name.index("class") != nil or name.index("function") != nil or name.index("usage") != nil or name.index("surfaceMaterial") != nil)
        @currentSimpleAttribute = SimpleCityObjectAttribute.new(name, attrs)
        @isInSimpleAttribute = true
        GRES_CGMLDebugger.writedebugstring("GRES_TrafficAreaParser create a simple Attribute with " + name + "@isInSimpleAttribute = true \n ")
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
            if(name.index("class") != nil or name.index("function") != nil or name.index("usage") != nil or name.index("surfaceMaterial") != nil)
                @cityObject.addSimpleAttribute(@currentSimpleAttribute)
                @isInSimpleAttribute = false
                @currentSimpleAttribute = nil
               return false
           end
           return true
     end
end
