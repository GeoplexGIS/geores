# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_schema/abstract_all.rb'

class GRES_Address < AbstractAll
  def initialize
    super()
    @country = ""
    @town = ""
    @street = ""
    @streetnumber = ""
    @postalnumber = ""
    @points = Array.new()
  end

  attr_reader :country, :town, :street, :streetnumber ,:postalnumber, :points

  def setcountry c
    @country = c
  end
  def settown t
    @town = t
  end
  def setstreetname s
    @street = s
  end
  def setstreetnumber n
    @streetnumber = n
  end

  def setpostalnumber pn
    @postalnumber = pn
  end

  def addAddressPoint p0
    @points.push(p0)
  end

  def writeToCityGML namespace
    retString = ""
    retString << "<" + namespace + ":address>\n"
    retString << "<core:Address>\n"
    retString << "<core:xalAddress>\n"
    retString << "<xAL:AddressDetails>\n"
    retString << "<xAL:Country>\n"
    retString << "<xAL:CountryName>" + @country + "</xAL:CountryName>\n"
    retString << "<xAL:Locality Type=\"Town\">\n"
    retString << "<xAL:LocalityName>"+ @town + "</xAL:LocalityName>\n"
    if(@street != "")
          retString << "<xAL:Thoroughfare Type=\"Street\">\n"
          retString << "<xAL:ThoroughfareNumber>" + @streetnumber + "</xAL:ThoroughfareNumber>\n"
          retString << "<xAL:ThoroughfareName>" + @street +  " </xAL:ThoroughfareName>\n"
          retString << "</xAL:Thoroughfare>\n"
    end

    if(@postalnumber != "")
      retString << "<xAL:PostalCode>\n"
			retString << "<xAL:PostalCodeNumber>" + @postalnumber + "</xAL:PostalCodeNumber>\n"
			retString << "</xAL:PostalCode>\n"
    end
    retString <<  "</xAL:Locality>\n"
    retString << "</xAL:Country>\n"
    retString << "</xAL:AddressDetails>\n"
    retString << "</core:xalAddress>\n"
    if(@points.length > 0)
      retString << "<core:multiPoint>\n"
      retString << "<gml:MultiPoint>\n"
      @points.each { |p|
         retString << "<gml:pointMember>\n"
				 retString <<	 "<gml:Point>\n"
				 retString <<	 "<gml:pos srsDimension=\"3\">" +  p.x.to_f.to_s + " " + p.y.to_f.to_s + " " + p.z.to_f.to_s + "</gml:pos>\n"
			   retString <<	 "</gml:Point>\n"
					retString << "</gml:pointMember>\n"
      }
       retString << "</gml:MultiPoint>\n"
      retString << "</core:multiPoint>\n"
    end
    retString << "</core:Address>\n"
    retString << "</" + namespace + ":address>\n"
    return retString
  end

  def buildToSKP(parent, entity, dictname, counter)
     dictionary = entity.attribute_dictionary(dictname, true)
     dname = "Address" + counter.to_s
     namespace = "bldg"
     if(parent.index("Bridge") != nil)
       namespace = "brid"
     end
     if(parent.index("Tunnel") != nil)
       namespace = "tun"
     end

     dictionary[dname] = writeToCityGML namespace
   end

   def buildFromSKP(entity, dictname)
     
   end
end
