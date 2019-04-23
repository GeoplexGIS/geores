# To change this template, choose Tools | Templates
# and open the template in the editor.

class GRES_Target
  def initialize u
    @coordlists = Array.new()
    @uri = u
  end

  attr_reader :uri, :coordlists

   def writeToCityGML
     retString = ""
     retString << "<app:target uri=\"#" + @uri + "\">\n"
     @coordlists.each { |list|
       retString << list.writeToCityGML
     }
     retString << "</app:target>\n"
   end

   def writeToCityGMLX3D
     retString = ""
     retString << "<app:target>"

       retString << "#" + @uri

     retString << "</app:target>\n"
   end

   def addcoordlist list
     @coordlists.push(list)
   end


   def seturi u
     @uri = u
   end
end
