# To change this template, choose Tools | Templates
# and open the template in the editor.

Sketchup::require 'geores_src/geores_parser/geores_featureparser/gres_site_parser.rb'
Sketchup::require 'geores_src/geores_schema/geores_attributes/simple_city_object_attribute.rb'
Sketchup::require 'geores_src/geores_debug/gres_cgmldebugger.rb'


class GRES_TunnelParser < GRES_SiteParser
 def initialize(cityobject,factory)
    super(cityobject, factory)
  end

  def tag_start name, attrs
    GRES_CGMLDebugger.writedebugstring("GRES_TunnelParser in tag_start mit " + name + "\n")
    b = super(name, attrs)
      if(b == false)
        return false
      end

      if(name.index("Tunnel") != nil)
         id = getattrvalue("gml:id", attrs)
         if(id != "")
           @cityObject.setgmlid(id)
         end
         return false
      end
      return true
  end

   def text text
      if(super(text) == false)
        return false
      end

      return true
    end




     def tag_end name

            if(super(name) == false)
              "Gehe in Tag End von Site " + name
              return false
            end
         
       return true
     end



end
