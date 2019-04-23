# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_schema/geores_attributes/simple_city_object_attribute.rb'
Sketchup::require 'geores_src/geores_schema/geores_attributes/gres_generic_city_object_attribute.rb'
Sketchup::require 'geores_src/geores_parser/geores_specific/gres_appearance_parser.rb'
Sketchup::require 'geores_src/geores_parser/geores_specific/gres_address_parser.rb'
Sketchup::require 'geores_src/geores_parser/geores_specific/gres_external_reference_parser.rb'
Sketchup::require 'geores_src/geores_parser/geores_geo/grs_multi_geometry_parser.rb'
Sketchup::require 'geores_src/geores_parser/geores_geo/grs_solid_geometry_parser.rb'
Sketchup::require 'geores_src/geores_debug/gres_cgmldebugger.rb'

class CityObjectParser

   

    

    def initialize(cityobject,factory)
      @cityObject = cityobject
      @factory = factory
      
      @currentSimpleAttribute = nil
      @isInSimpleAttribute = false

      @currentExternalReferenceParser = nil
      @isInExternalReference = false

      @currentAddressParser = nil
      @isInAddress= false

      @isInGenericAttribute = false
      @currentGenericAttribute = nil

      @isInAppSubHandler = false
      @currentAppearanceParser = nil
      @parsedAppearances = Array.new()

      @currentSolidGeometryParser = nil
      @isInSolidGeometry = false

      @currentGRS_MultiGeometryParser = nil
      @isInMultiGeometry = false
    end



  	def tag_start name, attrs
      GRES_CGMLDebugger.writedebugstring("CityObjectParser: in tag_start with" + name + " \n")
      if(@isInAddress == true)
        #GRES_CGMLDebugger.writedebugstring("@isInAddress = true . go in tag_start of addressparser \n")
        @currentAddressParser.tag_start(name, attrs)
        return false
      end
      if(@isInExternalReference == true)
        #GRES_CGMLDebugger.writedebugstring("@isInExternalReference = true . go in tag_start of external reference parser \n")
        @currentExternalReferenceParser.tag_start(name, attrs)
        return false
      end
       if(@isInAppSubHandler == true)
            #GRES_CGMLDebugger.writedebugstring("@isInAppSubHandler = true . go in tag_start of appearance parser \n")
            @currentAppearanceParser.tag_start(name, attrs)
            return false
       end
       if(@isInSolidGeometry == true and @currentSolidGeometryParser != nil)
              #GRES_CGMLDebugger.writedebugstring("@isInSolidGeometry = true . go in tag_start of @currentSolidGeometryParser \n")
              @currentSolidGeometryParser.tag_start(name, attrs)
              return false
        end
       if(@isInMultiGeometry == true and @currentGRS_MultiGeometryParser != nil)
              #GRES_CGMLDebugger.writedebugstring("@isInMultiGeometry = true . go in tag_start of @currentGRS_MultiGeometryParser \n")
              @currentGRS_MultiGeometryParser.tag_start(name, attrs)
              return false
       end
       #GRES_CGMLDebugger.writedebugstring("not in a subhandler of CityObjectParser \n")
      if(name.index("gml:name") != nil or name.index("creationDate") != nil or name.index("terminationDate") != nil)
        GRES_CGMLDebugger.writedebugstring("CityObjectParser: create a simple Attribute with " + name + "@isInSimpleAttribute = true \n ")
        @currentSimpleAttribute = SimpleCityObjectAttribute.new(name, attrs)
        @isInSimpleAttribute = true
        return false
      end
      if(name.index("gen:stringAttribute") != nil or name.index("gen:intAttribute") != nil or name.index("gen:dateAttribute") != nil or
            name.index("gen:doubleAttribute") != nil or name.index("gen:uriAttribute") != nil or name.index("gen:measureAttribute") != nil)
         GRES_CGMLDebugger.writedebugstring("CityObjectParser: create a generic Attribute with " + name + "@isInGenericAttribute = true \n ")
        @isInGenericAttribute = true
        @currentGenericAttribute =  GRES_GenericCityObjectAttribute.new(name, attrs)
        return false
      end

      if(name == "Address" or name == "core:Address")
        @isInAddress =  true
         GRES_CGMLDebugger.writedebugstring("CityObjectParser: found Address . create AddressParser  @isInAddress= true \n")
        @currentAddressParser = GRES_AddressParser.new()
        return false
      end

      if(name.index("externalReference") != nil)
        @isInExternalReference = true
         GRES_CGMLDebugger.writedebugstring("CityObjectParser: found external Reference . create ExRefParser  @isInExternalReference true \n")
        @currentExternalReferenceParser = GRES_ExternalReferenceParser.new()
        return false
      end
      if(name.index("surfaceDataMember") != nil)
        @isInAppSubHandler = true;
        GRES_CGMLDebugger.writedebugstring("CityObjectParser: @isInAppSubHandler = true  and tag_start  Appearance Parser \n")
        @currentAppearanceParser = GRES_AppearanceParser.new()
        return false
      end

        if(name.index("lod1Solid") != nil or name.index("lod2Solid") != nil or name.index("lod3Solid") != nil or name.index("lod4Solid") != nil)
        GRES_CGMLDebugger.writedebugstring("CityObjectParser: found solid geometry with " + name + " . @isInSolidGeometry = true \n")
        @currentSolidGeometryParser = SolidGeometryParser.new()
        @isInSolidGeometry = true
        return false
     end
      if(name.index("lod1MultiSurface") != nil or name.index("lod2MultiSurface") != nil or name.index("lod3MultiSurface") != nil or name.index("lod4MultiSurface") != nil or
          name.index("lod1Geometry") != nil or name.index("lod2Geometry") != nil or name.index("lod3Geometry") != nil or name.index("lod4Geometry") != nil or
          name.index("wtr:lod2Surface") != nil or name.index("wtr:lod3Surface") != nil or name.index("wtr:lod4Surface") != nil)
        GRES_CGMLDebugger.writedebugstring("CityObjectParser: found MultiSurface geometry with " + name + " . @isInSolidGeometry = true \n")
        @currentGRS_MultiGeometryParser = GRS_MultiGeometryParser.new()
       @isInMultiGeometry = true
       return false
      end
      #GRES_CGMLDebugger.writedebugstring("CityObjectParser no matching tag found in tag_start- end with true")
      return true
    end

    def text text
          
          if(@isInAddress == true and @currentAddressParser != nil)
            #GRES_CGMLDebugger.writedebugstring("go to text with " + text + " in AddressParser @isInAddress= true \n")
            @currentAddressParser.text(text)
            return false
          end
          if(@isInExternalReference == true and @currentExternalReferenceParser != nil)
            #GRES_CGMLDebugger.writedebugstring("go to text with " + text + " in ExRefParser @isInExternalReference true \n")
            @currentExternalReferenceParser.text(text)
            return false
          end
          if(@isInSimpleAttribute == true and @currentSimpleAttribute != nil and text != "")
            GRES_CGMLDebugger.writedebugstring("CityObjectParser: add value " + text + " to SimpleAttribute  @isInSimpleAttribute= true \n")
            @currentSimpleAttribute.addValue(text)
            return false
          end
          if(@isInGenericAttribute == true and @currentGenericAttribute != nil and text != "")
            GRES_CGMLDebugger.writedebugstring("CityObjectParser: add value " + text + " to GenericAttribute  @isInGenericAttribute true \n")
            @currentGenericAttribute.addValue(text)
            return false
          end
           if(@isInAppSubHandler == true and @currentAppearanceParser != nil)
             #GRES_CGMLDebugger.writedebugstring("go to text with " + text + " in AppearanceParser @isInAppSubHandler true \n")
                @currentAppearanceParser.text(text)
              return false
          end
            if(@isInSolidGeometry == true and @currentSolidGeometryParser != nil)
              #GRES_CGMLDebugger.writedebugstring("go to text with " + text + " in SolidParser @isInSolidGeometry true \n")
              @currentSolidGeometryParser.text(text)
              return false
            end
            if(@isInMultiGeometry == true and @currentGRS_MultiGeometryParser != nil)
              #GRES_CGMLDebugger.writedebugstring("go to text with " + text + " in MultiSurfaceParser @isInMultiGeometry true \n")
              @currentGRS_MultiGeometryParser.text(text)
              return false
            end
            #GRES_CGMLDebugger.writedebugstring("CityObjectParser no matching tag found in text method- end with true \n")
      return true
    end


     def tag_end name
      
          if(name == "Address" or name == "core:Address")
              @isInAddress =  false;
              @cityObject.addAddress(@currentAddressParser.address)
              @currentAddressParser = nil
              GRES_CGMLDebugger.writedebugstring("CityObjectParser: found end tag of Address " + name + " add Address to CityObject: " + @cityObject.theinternalname +  " @isInAddress= false \n")
              return false
          end
            if(name.index("externalReference") != nil)
                @isInExternalReference = false
                @cityObject.addExternalReference(@currentExternalReferenceParser.externalReference)
                @currentExternalReferenceParser = nil
                GRES_CGMLDebugger.writedebugstring("CityObjectParser: found end tag of external Reference " + name + " add Reference to CityObject: " + @cityObject.theinternalname +  " @isInExternalReference =  false \n")
              return false
            end

        if(name.index("app:surfaceDataMember") != nil)
            @isInAppSubHandler = false;
            @parsedAppearances.push(@currentAppearanceParser.appearance)
            GRES_CGMLDebugger.writedebugstring("CityObjectParser: found end tag of Appearance " + name + " add Appearance to CityObject: " + @cityObject.theinternalname + " @isInAppearanceHandler =  false \n")
            @currentAppearanceParser = nil
            return false
         end
         if(@isInAppSubHandler == true and @currentAppearanceParser != nil)
               @currentAppearanceParser.tag_end(name)
            return;
          end

   
         if(name.index("gml:name") != nil or name.index("creationDate") != nil or name.index("terminationDate") != nil)
          @cityObject.addSimpleAttribute(@currentSimpleAttribute)
          GRES_CGMLDebugger.writedebugstring("CityObjectParser: found end tag of simple Attribute " + name + " add Attribute to CityObject: " + @cityObject.theinternalname + " @isInSimpleAttribute  =  false and @currentSimpleAttribute = nil \n")
          @isInSimpleAttribute = false
          @currentSimpleAttribute = nil
          return false
         end
          if(name.index("gen:stringAttribute") != nil or name.index("gen:intAttribute") != nil or name.index("gen:dateAttribute") != nil or
                name.index("gen:doubleAttribute") != nil or name.index("gen:uriAttribute") != nil or name.index("gen:measureAttribute") != nil)
          @cityObject.addGenericAttribute(@currentGenericAttribute)
          GRES_CGMLDebugger.writedebugstring("CityObjectParser: found end tag of generic Attribute " + name + " add Attribute to CityObject: " + @cityObject.theinternalname + " @isInGenericAttribute  =  false and @currentGenericAttribute = nil \n")
          @isInGenericAttribute = false
          @currentGenericAttribute = nil
            return false
          end
             if(name.index("lod1Solid") != nil or name.index("lod2Solid") != nil or name.index("lod3Solid") != nil or name.index("lod4Solid") != nil)
                GRES_CGMLDebugger.writedebugstring("CityObjectParser: found end tag of solid geometry " + name + " add Geometry to CityObject: " + @cityObject.theinternalname + " @isInSolidGeometry  =  false and @currentSolidGeometryParser = nil \n")
                @cityObject.addSolid(@currentSolidGeometryParser.solid,name)
                @isInSolidGeometry = false
                @currentSolidGeometryParser = nil
                return false
            end
           if(@isInSolidGeometry == true and @currentSolidGeometryParser != nil)
              #GRES_CGMLDebugger.writedebugstring("got to tag_end of SolidGeometryParser " + name + " @isInSolidGeometry = true \n")
              @currentSolidGeometryParser.tag_end(name)
              return false
          end

             if(name.index("lod1MultiSurface") != nil or name.index("lod2MultiSurface") != nil or name.index("lod3MultiSurface") != nil or name.index("lod4MultiSurface") != nil or
              name.index("lod1Geometry") != nil or name.index("lod2Geometry") != nil or name.index("lod3Geometry") != nil or name.index("lod4Geometry") != nil or
              name.index("wtr:lod2Surface") != nil or name.index("wtr:lod3Surface") != nil or name.index("wtr:lod4Surface") != nil)
               if(@currentGRS_MultiGeometryParser.multisurface == nil)
                  GRES_CGMLDebugger.writedebugstring("Fehler: MultiSurface ist nil for " +name+ " and CityObject: " + @cityObject.theinternalname + "\n")
               end
               @cityObject.addMultiSurface(@currentGRS_MultiGeometryParser.multisurface,name)
               @isInMultiGeometry = false
               @currentGRS_MultiGeometryParser = nil
               GRES_CGMLDebugger.writedebugstring("CityObjectParser: found end tag of MultiSurface geometry " + name + " add Geometry to CityObject: " + @cityObject.theinternalname + " @isInMultiGeometry  =  false and @currentGRS_MultiGeometryParser = nil \n")
               return false
             end
               if(@isInMultiGeometry == true and @currentGRS_MultiGeometryParser != nil)
                 #GRES_CGMLDebugger.writedebugstring("got to tag_end of MutliSurfaceGeometryParser " + name + " @isInMultiGeometry = true \n")
                @currentGRS_MultiGeometryParser.tag_end(name)
                return false
              end
               #GRES_CGMLDebugger.writedebugstring("CityObjectParser no matching tag found in tag_end method - end with true \n")
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

       attr_reader :parsedAppearances, :cityObject, :factory
end
