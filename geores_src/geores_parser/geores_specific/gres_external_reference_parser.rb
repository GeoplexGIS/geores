# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_schema/geores_attributes/gres_external_reference.rb'
Sketchup::require 'geores_src/geores_debug/gres_cgmldebugger.rb'

class GRES_ExternalReferenceParser
  def initialize
    @externalReference = GRES_ExternalReference.new()
    @currenttag = ""
  end
  
   def tag_start name, attrs
    @currenttag = name
  end

   def text text
     if(@currenttag.index("informationSystem") != nil and text != "")
        GRES_CGMLDebugger.writedebugstring("found informationsystem " + text + "\n")
       @externalReference.setinformationsystem(text)
     end
      if(@currenttag.index("name") != nil and text != "")
        GRES_CGMLDebugger.writedebugstring("found name " + text + "\n")
        @externalReference.setexternalobjectname(text)
     end
     if(@currenttag.index("uri") != nil and text != "")
        GRES_CGMLDebugger.writedebugstring("found uri " + text + "\n")
        @externalReference.setexternalobjecturi(text)
     end
     
   end



  attr_reader :externalReference
end
