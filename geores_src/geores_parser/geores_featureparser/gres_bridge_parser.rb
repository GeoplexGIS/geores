# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_parser/geores_featureparser/gres_site_parser.rb'
Sketchup::require 'geores_src/geores_schema/geores_attributes/simple_city_object_attribute.rb'
Sketchup::require 'geores_src/geores_parser/geores_featureparser/gres_installation_parser.rb'
Sketchup::require 'geores_src/geores_debug/gres_cgmldebugger.rb'

class GRES_BridgeParser < GRES_SiteParser



  def initialize(cityobject,factory)
    super(cityobject, factory)
    @currentBridgeConstructionParser = nil
    @isInBridgeConstruction = false
    @nextisclassname = false
  end

  def tag_start name, attrs

    GRES_CGMLDebugger.writedebugstring("BridgeParser in tag_start mit " + name + "\n")

     if(@isInBridgeConstruction == true)
       if(@nextisclassname == true)
         @nextisclassname = false
         GRES_CGMLDebugger.writedebugstring("GRES_BridgeParser: found outerBridgeConstruction . create BridgeInstallation Parser  @isInBridgeConstruction true \n")
         @currentBridgeConstructionParser = @factory.getCityObjectParserForName(name)
       end
        @currentBridgeConstructionParser.tag_start(name, attrs)
        return false
      end
      if(super(name,attrs) == false)
        return false
      end
     
      if(name.index("outerBridgeConstruction") != nil)
        @nextisclassname = true
        @isInBridgeConstruction = true

        return false
      end
     
   
       if( name.index("isMovable") != nil)
        @currentSimpleAttribute = SimpleCityObjectAttribute.new(name, attrs)
        @isInSimpleAttribute = true
        GRES_CGMLDebugger.writedebugstring("GRES_BridgeParser: create a simple Attribute with " + name + "@isInSimpleAttribute = true \n ")
        return false
      end
      if(name.index("Bridge") != nil)
         id = getattrvalue("gml:id", attrs)
         if(id != "")
           @cityObject.setgmlid(id)
           GRES_CGMLDebugger.writedebugstring("GRES_BridgeParser: Set  GML:ID Type : " + id + "for " + @cityObject.theinternalname + "\n")
         end
         return false
      end
      return true
     
    end

    def text text
       if(@isInBridgeConstruction == true and @currentBridgeConstructionParser != nil)
        @currentBridgeConstructionParser.text(text)
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
         
          
            if(name.index("outerBridgeConstruction") != nil)
              @cityObject.addBridgeConstruction(@currentBridgeConstructionParser.cityObject)
              GRES_CGMLDebugger.writedebugstring("GRES_BridgeParser: found end tag of outerBridgeConstruction " + name + " add outerBridgeConstruction to CityObject: " + @cityObject.theinternalname +  " @isInBridgeConstruction false \n")
              @isInBridgeConstruction = false
              @currentBridgeConstructionParser = nil
              return false
           end
           if(@isInBridgeConstruction == true and @currentBridgeConstructionParser != nil)
                @currentBridgeConstructionParser.tag_end(name)
                return false
            end
            if(super(name) == false)
              return false
            end
           if(name.index("isMovable") != nil)
                @cityObject.addSimpleAttribute(@currentSimpleAttribute)
                GRES_CGMLDebugger.writedebugstring("GRES_BridgeParser: found end tag of simple Attribute " + name + " add Attribute to CityObject: " + @cityObject.theinternalname + " @isInSimpleAttribute  =  false and @currentSimpleAttribute = nil \n")
                @isInSimpleAttribute = false
                @currentSimpleAttribute = nil
               return false
           end
       return true
     end

end
