# To change this template, choose Tools | Templates
# and open the template in the editor.

class GRES_TexCoordList
  def initialize
    @coords = Array.new()
    @uri = ""
  end

  def addcord (c)
    @coords.push(c)
  end

  def seturi u
    @uri = u
  end

  attr_reader :coords, :uri

   def writeToCityGML
     retString = ""
     retString << "<app:TexCoordList>\n"
     retString << "<app:textureCoordinates ring=\"#" +  @uri +"\">"
     counter = 0
     lastString = ""
     @coords.each { |c|
       if(counter == 0)
         lastString = " " + c.x.to_f.to_s + " " +c.y.to_f.to_s
       end
       retString << " " + c.x.to_f.to_s + " " +c.y.to_f.to_s
       counter = counter +1
     }
     retString << lastString
     retString << "</app:textureCoordinates>\n"
     retString << "</app:TexCoordList>\n"

     return retString
   end

end
