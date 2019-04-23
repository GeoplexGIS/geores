# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_parser/cityobjectparser.rb'
Sketchup::require 'geores_src/geores_parser/geores_geo/grs_implicit_geometry_parser.rb'
Sketchup::require 'geores_src/geores_debug/gres_cgmldebugger.rb'

class GRES_SolVegParser < CityObjectParser
  @currentImplicitParser = nil
  @isInImplicitGeometry = false

  def initialize(cityobject,factory)
    super(cityobject, factory)
    end


   def tag_start name, attrs
      GRES_CGMLDebugger.writedebugstring("GRES_SolVegParser: in tag_start mit " + name + "\n")
      if(@isInImplicitGeometry == true and @currentImplicitParser != nil)
           @currentImplicitParser.tag_start(name,attrs)
           return false
      end
      if(name.index("SolitaryVegetationObject") != nil)
         id = getattrvalue("gml:id", attrs)
         if(id != "")
           @cityObject.setgmlid(id)
           GRES_CGMLDebugger.writedebugstring("GRES_SolVegParser: Set  GML:ID Type : " + id + "for " + @cityObject.theinternalname + "\n")
         end
         return false
      end

      if(super(name,attrs) == false)
        return false
      end

      if(name.index("class") != nil or name.index("function") != nil or name.index("usage") != nil or name.index("species") != nil or name.index("height") != nil or name.index("trunkDiameter") != nil or
       name.index("crownDiameter") != nil)
        @currentSimpleAttribute = SimpleCityObjectAttribute.new(name, attrs)
        @isInSimpleAttribute = true
         GRES_CGMLDebugger.writedebugstring("GRES_SolVegParser: create a simple Attribute with " + name + "@isInSimpleAttribute = true \n ")
        return false
      end
      if(name.index("ImplicitRepresentation") != nil)
        @currentImplicitParser = GRS_ImplicitGeometryParser.new()
        GRES_CGMLDebugger.writedebugstring("GRES_SolVegParser: found new ImplicitGeometry \n ")
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
                GRES_CGMLDebugger.writedebugstring("GRES_SolVegParser: found end tag of  ImplicitGeometry \n ")
                implicitGeometry = @currentImplicitParser.geometry
                if(implicitGeometry == nil)
                  GRES_CGMLDebugger.writedebugstring("GRES_SolVegParser Fehler : ImplicitGeometry is nil \n ")
                end
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
              if(name.index("class") != nil or name.index("function") != nil or name.index("usage") != nil or name.index("species") != nil or name.index("height") != nil or name.index("trunkDiameter") != nil or
              name.index("crownDiameter") != nil)
                @cityObject.addSimpleAttribute(@currentSimpleAttribute)
                @isInSimpleAttribute = false
                @currentSimpleAttribute = nil
               return false
           end
           return true
     end
end
