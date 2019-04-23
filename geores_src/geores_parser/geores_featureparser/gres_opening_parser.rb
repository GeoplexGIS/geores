# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_parser/cityobjectparser.rb'
Sketchup::require 'geores_src/geores_parser/geores_geo/grs_implicit_geometry_parser.rb'
Sketchup::require 'geores_src/geores_debug/gres_cgmldebugger.rb'

class GRES_OpeningParser < CityObjectParser
   @currentImplicitParser = nil
   @isInImplicitGeometry = false

  def initialize(cityobject,factory)
    super(cityobject, factory)
  end

   def tag_start name, attrs
      if(@isInImplicitGeometry == true and @currentImplicitParser != nil)
           @currentImplicitParser.tag_start(name,attrs)
           return false
      end
     if(name.index("Door") != nil or name.index("Window") != nil)
         @cityObject.setopeningtype(name)
         return false
     end
       if(super(name,attrs) == false)
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
     return true
    end

     def tag_end name

            if(name.index("ImplicitRepresentation") != nil)
                @cityObject.addImplicitGeometry(@currentImplicitParser.geometry,name)
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
         return true
     end

end
