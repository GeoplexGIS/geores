# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_parser/cityobjectparser.rb'
Sketchup::require 'geores_src/geores_debug/gres_cgmldebugger.rb'
Sketchup::require 'geores_src/geores_schema/geores_attributes/simple_city_object_attribute.rb'

class GRES_CityObjectGroupParser < CityObjectParser
    def initialize(cityobject,factory)
      super(cityobject, factory)
      @currenttag = ""
      @isInSubhandler = false  #hier wird gespeichert ob der Inhalt der folgenden Tags an eine Subroutine weitergereicht wird
      @nextIsClassName = false #hier wird gespeichert, dass als nächster Tag der Klassenname des CityObjektes kommt
      @currentObjectParser = nil
    end

    def setloader citygmlloader
      @citygmlloader = citygmlloader
    end

    def tag_start name, attrs
      @currenttag = name.strip
      GRES_CGMLDebugger.writedebugstring("GRES_CityObjectGroupParser: tag_start with name " + @currenttag + "\n")

    if(@isInSubhandler == true)
      if(@nextIsClassName == true)
        @currentObjectParser = @factory.getCityObjectParserForName(@currenttag);
        @nextIsClassName = false;
      end
       @currentObjectParser.tag_start(@currenttag, attrs)
       return false
    end
     if(name.index("groupMember") != nil)
        @isInSubhandler = true;
        @nextIsClassName = true;
         GRES_CGMLDebugger.writedebugstring("GRES_CityObjectGroupParser: Found GroupMember and set @isInSubhandler and @nextIsClassName = true \n")
        return false
     end
     if(name.index("gml:name") != nil or name.index("gml:description") != nil or name.index("function") != nil or name.index("usage") != nil or name.index("class") != nil)
        GRES_CGMLDebugger.writedebugstring("GRES_CityObjectGroupParser: create a simple Attribute with " + name + "@isInSimpleAttribute = true \n ")
        @currentSimpleAttribute = SimpleCityObjectAttribute.new(name, attrs)
        @isInSimpleAttribute = true
        return false
      end
      #GRES_CGMLDebugger.writedebugstring("CityObjectParser no matching tag found in tag_start- end with true")
      return true
    end

    def text text
       if(@isInSubhandler == true and @currentObjectParser != nil)
        @currentObjectParser.text(text)
       return false
       end
       if(@isInSimpleAttribute == true and @currentSimpleAttribute != nil and text != "")
            @currentSimpleAttribute.addValue(text)
            return false
      end

      return true
    end


     def tag_end name

      if(name.index("groupMember") != nil)
       
        @isInSubhandler = false;
        co = @currentObjectParser.cityObject
        co.setnameOfCityObjectGroup(@cityObject.theinternalname)

        if(co == nil)
          GRES_CGMLDebugger.writedebugstring("GRES_CityObjectGroupParser: Fehler: returniertes objekt des @currentObjectParser ist nil \n")
        end
        if(@citygmlloader == nil)
          GRES_CGMLDebugger.writedebugstring("GRES_CityObjectGroupParser: Fehler: @parsedCityObjects ist nil. Array nicht initialisiert \n")
        end
        GRES_CGMLDebugger.writedebugstring("GRES_CityObjectGroupParser: found end tag of groupMember. Add " + co.theinternalname + " to the citygmlloader\n")
        if(co.isImplicitObject == true)
          @citygmlloader.addImplicitObject(co)
          GRES_CGMLDebugger.writedebugstring("GRES_CityObjectGroupParser:Fuege CityObject " + co.theinternalname + "dem Array @parsedImplicitObjects hinzu \n")
        elsif(co.isImplicitReferenceObject == true)
          @citygmlloader.addImplicitReferenceObject(co)
          GRES_CGMLDebugger.writedebugstring("GRES_CityObjectGroupParser:Fuege CityObject " + co.theinternalname + "dem Array @parsedImplicitRefObjects hinzu \n")
        else
          @citygmlloader.addObject(co)
          GRES_CGMLDebugger.writedebugstring("GRES_CityObjectGroupParser:Fuege CityObject " + co.theinternalname + "dem Array @parsedCityObjects hinzu \n")
        end

        apps = @currentObjectParser.parsedAppearances
        GRES_CGMLDebugger.writedebugstring("GRES_CityObjectGroupParser: Hole interne Appearances \n")
        if(apps != nil and apps.length > 0)
          GRES_CGMLDebugger.writedebugstring( apps.length.to_s + "GRES_CityObjectGroupParser: Interne Appearances vorhanden. Dem Array @parsedAppearances hinzufuegen\n")
          @citygmlloader.addAppearances(apps)
        end
        @currentObjectParser = nil
        return false
      end
       if(@isInSubhandler == true and @currentObjectParser != nil)
        @currentObjectParser.tag_end(name)
       return false
      end
        if(name.index("gml:name") != nil or name.index("gml:description") != nil or name.index("function") != nil or name.index("usage") != nil or name.index("class") != nil)
          @cityObject.addSimpleAttribute(@currentSimpleAttribute)
          GRES_CGMLDebugger.writedebugstring("GRES_CityObjectGroupParser: found end tag of simple Attribute " + name + " add Attribute to CityObject with name " + @cityObject.theinternalname + " @isInSimpleAttribute  =  false and @currentSimpleAttribute = nil \n")
          @isInSimpleAttribute = false
          @currentSimpleAttribute = nil
          return false
         end
      return true
     end

end
