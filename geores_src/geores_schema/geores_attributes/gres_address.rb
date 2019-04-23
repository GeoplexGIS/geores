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

  def writeToCityGML
    retString = ""
    retString << "<core:Address>\n"
    retString << "<core:xalAddress>\n"
    retString << "<xAl:AddressDetails>\n"
    retString << "<xAl:Country>\n"
    retString << "<xAl:CountryName>" + @country + "</xAl:CountryName>\n"
    retString << "<xAl:Locality Type=\"Town\">\n"
    retString << "<xAl:LocalityName>"+ @town + "</xAl:LocalityName>\n"
    retString << "<xAl:Thoroughfare Type=\"Street\">\n"
    retString << "<xAl:ThoroughfareNumber>" + @streetnumber + "</xAl:ThoroughfareNumber>\n"
    retString << "<xAl:ThoroughfareName>" + @street +  " </xAl:ThoroughfareName>\n"
    retString << "</xAl:Thoroughfare>\n"

    if(@postalnumber != "")
      retString << "<xAL:PostalCode>\n"
			retString << "<xAL:PostalCodeNumber>" + @postalnumber + "</xAL:PostalCodeNumber>\n"
			retString << "</xAL:PostalCode>\n"
    end
    retString <<  "</xAl:Locality>\n"
    retString << "</xAl:Country>\n"
    retString << "</xAl:AddressDetails>\n"
    retString << "</core:xalAddress>\n"
    if(@points.length > 0)
      retString << "<core:MultiPoint>\n"
      retString << "<gml:MultiPoint>\n"
      @points.each { |p|
         retString << "<gml:pointMember>\n"
				 retString <<	 "<gml:Point>\n"
				 retString <<	 "<gml:pos srsDimension=\"3\">" +  p.x.to_f.to_s + " " + p.y.to_f.to_s + " " + p.z.to_f.to_s + "</gml:pos>\n"
			   retString <<	 "</gml:Point>\n"
					retString << "<//gml:pointMember>\n"
      }
       retString << "</gml:MultiPoint>\n"
      retString << "</core:MultiPoint>\n"
    end
    retString << "</core:Address>\n"
    return retString
  end

  def buildToSKP(parent, entity, dictname, counter)
     dictionary = entity.attribute_dictionary(dictname, true)
     dname = "Address" + counter.to_s
     dictionary[dname] = writeToCityGML
   end

   def buildFromSKP(entity, dictname)
     
   end
end
