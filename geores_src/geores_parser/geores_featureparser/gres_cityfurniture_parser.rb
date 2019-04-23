# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_parser/cityobjectparser.rb'
Sketchup::require 'geores_src/geores_parser/geores_geo/grs_implicit_geometry_parser.rb'
Sketchup::require 'geores_src/geores_debug/gres_cgmldebugger.rb'

class GRES_CityFurnitureParser < CityObjectParser
  @currentImplicitParser = nil
  @isInImplicitGeometry = false

  def initialize(cityobject,factory)
    super(cityobject, factory)
    end


   def tag_start name, attrs
      GRES_CGMLDebugger.writedebugstring("GRES_CityFurnitureParser in tag_start mit " + name + "\n")
      if(@isInImplicitGeometry == true and @currentImplicitParser != nil)
           @currentImplicitParser.tag_start(name,attrs)
           return false
      end
      if(name.index("CityFurniture") != nil)
         id = getattrvalue("gml:id", attrs)
         if(id != "")
           @cityObject.setgmlid(id)
         end
         return false
      end

      if(super(name,attrs) == false)
        return false
      end

      if(name.index("class") != nil or name.index("function") != nil or name.index("usage") != nil)
        @currentSimpleAttribute = SimpleCityObjectAttribute.new(name, attrs)
        @isInSimpleAttribute = true
        return false
      end
      if(name.index("ImplicitRepresentation") != nil)
        @currentImplicitParser = GRS_ImplicitGeometryParser.new()
        @isInImplicitGeometry = true
        return false
      end
      return true
    end

    def text text

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

            if(name.index("ImplicitRepresentation") != nil)

                implicitGeometry = @currentImplicitParser.geometry
                if(implicitGeometry.isreferenceobject == true)
                  @cityObject.setisImplicitReferenceObject(true)
                else
                  @cityObject.setisImplicitObject(true)
                end
                @cityObject.addImplicitGeometry(implicitGeometry, name)
                @isInImplicitGeometry = false
                @currentImplicitParser = nil
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
