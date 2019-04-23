# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_schema/abstract_all.rb'

class GRES_ExternalReference < AbstractAll
  def initialize
    super()
    @informationSystem = ""
    @externalObjectName = ""
    @externalObjectUri = ""
  end
  
  def setinformationsystem s
    @informationSystem = s
  end
  
  def setexternalobjectname o
    @externalObjectName = o
  end

  def setexternalobjecturi u
    @externalObjectUri = u
  end

  attr_reader :informationSystem, :externalObjectName, :externalObjectUri

   def writeToCityGML
     retString = "<core:externalReference>\n"
     retString << "<core:informationSystem>" + @informationSystem + "</core:informationSystem>\n"
     retString << "<core:externalObject>\n"
     if(@externalObjectName != "")
        retString << "<core:name>" + @externalObjectName + "</core:name>\n"
     end
      if(@externalObjectUri != "")
        retString << "<core:uri>" + @externalObjectUri + "</core:uri>\n"
     end
     retString << "</core:externalObject>\n"
     retString << "</core:externalReference>\n"

     return retString
   end

   def buildToSKP(parent, entity, dictname, counter)
     dictionary = entity.attribute_dictionary(dictname, true)
     dname = "ExternalReference" + counter.to_s
     dictionary[dname] = writeToCityGML

   end

   def buildFromSKP(entity, dictname)

   end

     
end
