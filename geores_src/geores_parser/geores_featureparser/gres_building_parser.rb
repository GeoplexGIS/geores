# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_parser/geores_featureparser/gres_site_parser.rb'
Sketchup::require 'geores_src/geores_schema/geores_attributes/simple_city_object_attribute.rb'
Sketchup::require 'geores_src/geores_debug/gres_cgmldebugger.rb'


class GRES_BuildingParser < GRES_SiteParser
 def initialize(cityobject,factory)
    super(cityobject, factory)
  end

  def tag_start name, attrs
    GRES_CGMLDebugger.writedebugstring("GRES_BuildingParser in tag_start mit " + name + "\n")
    b = super(name, attrs)
      if(b == false)
        return false
      end

       if(name.index("roofType") != nil or name.index("measuredHeight") != nil or name.index("storeysAboveGround") != nil  or name.index("storeysBelowGround") != nil or
           name.index("storeyHeightsAboveGround") != nil or name.index("storeyHeightsBelowGround") != nil)
        @currentSimpleAttribute = SimpleCityObjectAttribute.new(name, attrs)
        @isInSimpleAttribute = true
        GRES_CGMLDebugger.writedebugstring("GRES_BuildingParser create a simple Attribute with " + name + "@isInSimpleAttribute = true \n ")
        return false

      end
      if(name.index("Building") != nil)
         id = getattrvalue("gml:id", attrs)
         if(id != "")
           @cityObject.setgmlid(id)
           GRES_CGMLDebugger.writedebugstring("GRES_BuildingParser Set  GML:ID Type : " + id + "for " + @cityObject.theinternalname + "\n")
         end
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
          if( name.index("roofType") != nil or name.index("measuredHeight") != nil or name.index("storeysAboveGround") != nil  or name.index("storeysBelowGround") != nil or
           name.index("storeyHeightsAboveGround") != nil or name.index("storeyHeightsBelowGround") != nil)
                @cityObject.addSimpleAttribute(@currentSimpleAttribute)
                @isInSimpleAttribute = false
                @currentSimpleAttribute = nil
                 GRES_CGMLDebugger.writedebugstring("GRES_BuildingParser found end tag of simple Attribute " + name + " add Attribute to CityObject: " + @cityObject.theinternalname + " @isInSimpleAttribute  =  false and @currentSimpleAttribute = nil \n")
               return false
           end
       return true
     end



end
