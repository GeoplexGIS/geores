# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_schema/geores_attributes/gres_address.rb'
Sketchup::require 'geores_src/geores_debug/gres_cgmldebugger.rb'
Sketchup::require 'sketchup.rb'

class GRES_AddressParser
  def initialize
    @address = GRES_Address.new()
    @currenttag = ""
  end
  
  attr_reader :address

  def tag_start name, attrs
    @currenttag = name
  end

   def text text
     if(@currenttag.index("CountryName") != nil and text != "")
       GRES_CGMLDebugger.writedebugstring("found Country " + text  + " \n")
       @address.setcountry(text)
     end
      if(@currenttag.index("LocalityName") != nil and text != "")
        GRES_CGMLDebugger.writedebugstring("found Town " + text  + " \n")
       @address.settown(text)
     end
      if(@currenttag.index("ThoroughfareNumber") != nil and text != "")
        GRES_CGMLDebugger.writedebugstring("found Number " + text  + " \n")
       @address.setstreetnumber(text)
     end
      if(@currenttag.index("ThoroughfareName") != nil and text != "")
        GRES_CGMLDebugger.writedebugstring("found Street Name " + text  + " \n")
       @address.setstreetname(text)
     end
      if(@currenttag.index("PostalCodeNumber") != nil and text != "")
        GRES_CGMLDebugger.writedebugstring("found postal code " + text  + " \n")
       @address.setpostalnumber(text)
     end
      if(@currenttag == "gml:pos")
         coords = text.split(" ")
         if(coords.length == 2)
             x = coords[0].to_f
             y = coords[1].to_f
             p0 = Geom::Point3d.new x,y,0
         @address.addAddressPoint(p0)
         GRES_CGMLDebugger.writedebugstring("found address point" + p0.to_s  + " \n")
         elsif(coords.length == 3)
            x = coords[0].to_f
            y = coords[1].to_f
            z = coords[2].to_f
            p0 = Geom::Point3d.new x,y,z
            @address.addAddressPoint(p0)
            GRES_CGMLDebugger.writedebugstring("found address point" + p0.to_s  + " \n")
         end

      end
   end

end
