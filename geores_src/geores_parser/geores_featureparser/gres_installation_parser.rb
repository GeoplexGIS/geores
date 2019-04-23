# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_parser/cityobjectparser.rb'
Sketchup::require 'geores_src/geores_parser/geores_geo/grs_implicit_geometry_parser.rb'
Sketchup::require 'geores_src/geores_schema/geores_attributes/simple_city_object_attribute.rb'
Sketchup::require 'geores_src/geores_debug/gres_cgmldebugger.rb'

class GRES_InstallationParser < CityObjectParser

  @currentGRES_BoundaryParser = nil
  @isInBoundary = false

  @nextisclassname = false

  @currentImplicitParser = nil
  @isInImplicitGeometry = false

   def initialize(cityobject,factory)
    super(cityobject, factory)
  end

    def tag_start name, attrs
      GRES_CGMLDebugger.writedebugstring("GRES_InstallationParser in tag_start mit " + name + "\n")
      if(@isInBoundary == true)
         if(@nextisclassname == true)
            GRES_CGMLDebugger.writedebugstring("Current name is" + name +" get Parser for name\n")
          @currentGRES_BoundaryParser = @factory.getCityObjectParserForName(name);
           GRES_CGMLDebugger.writedebugstring("Name of CityObject in Parser is " + @currentGRES_BoundaryParser.cityObject.theinternalname + "\n" )
          @nextisclassname = false
        end
        @currentGRES_BoundaryParser.tag_start(name, attrs)
        return
      end
      if(@isInImplicitGeometry == true and @currentImplicitParser != nil)
           @currentImplicitParser.tag_start(name,attrs)
           return false
      end

      if(super(name,attrs) == false)
        return false
      end
      if(name.index("boundedBy") != nil and name.index("gml:") == nil)
        @nextisclassname = true
        @isInBoundary = true
        return false
      end
      if(name.index("class") != nil or name.index("function") != nil or name.index("usage") != nil)
        @currentSimpleAttribute = SimpleCityObjectAttribute.new(name, attrs)
        @isInSimpleAttribute = true
        return false
      end
       if(name.index("BuildingInstallation") != nil or name.index("BridgeInstallation") != nil or name.index("TunnelInstallation") != nil or name.index("BridgeConstructionElement") != nil )
          id = getattrvalue("gml:id", attrs)
         if(id != "")
           @cityObject.setgmlid(id)
           GRES_CGMLDebugger.writedebugstring("GRES_InstallationParser Set  GML:ID Type : " + id + "for " + @cityObject.theinternalname + "\n")
         end
      end
      if(name.index("ImplicitRepresentation") != nil)
        @currentImplicitParser = GRS_ImplicitGeometryParser.new()
        @isInImplicitGeometry = true
        return false
      end
      return true
    end

     def text text
          if(@isInBoundary == true and @currentGRES_BoundaryParser != nil)
            @currentGRES_BoundaryParser.text(text)
            return false
          end
          if(@isInImplicitGeometry == true and @currentImplicitParser != nil)
            @currentImplicitParser.text(text)
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
          if(name.index("boundedBy") != nil and name.index("gml:") == nil)
              if(@cityObject == nil)
                GRES_CGMLDebugger.writedebugstring("Fehler -> CityGML Objekt des GRES_InstallationParsers ist nil\n")
              end
              boundary = @currentGRES_BoundaryParser.cityObject
              if(boundary == nil)
                GRES_CGMLDebugger.writedebugstring("Fehler -> erzeugte Boundary des GRES_InstallationParser ist ist nil\n")
              end
              @cityObject.addBoundary(@currentGRES_BoundaryParser.cityObject)
              @isInBoundary = false
              @currentGRES_BoundaryParser = nil
              return false
           end
           if(@isInBoundary == true and @currentGRES_BoundaryParser != nil)
                @currentGRES_BoundaryParser.tag_end(name)
                return false
            end
            if(name.index("ImplicitRepresentation") != nil)
                @cityObject.addImplicitGeometry(@currentImplicitParser.geometry,name)
                @isInImplicitGeometry = false
                @currentImplicitParser  = nil
                return false
              end
               if(@isInImplicitGeometry == true and @currentImplicitParser != nil)
                 @currentImplicitParser.tag_end(name)
                  return false
                end
             if(super(name) == false)
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
