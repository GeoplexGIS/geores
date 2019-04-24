# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'sketchup.rb'
Sketchup::require 'geores_src/geores_schema/geores_material/gres_abstract_appearance.rb'
Sketchup::require 'geores_src/geores_schema/geores_material/gres_target.rb'


class GRES_ParameterizedTexture < GRES_AbstractAppearance

  def initialize attrs
    super(attrs)
    #speicherung der Texturkoordinaten und der Referenz zum polygon
    @attrs = attrs
  end
  
  def addimageURI (uri)
    @imageURI = uri
  end


  def writeToCityGML isWFST
    retString = ""
    if(isWFST == "true")
      retString << "<wfs:Update typeName=\"app:appearanceMember\">\n"
      retString << "<wfs:Property>\n"
      retString << "<wfs:Name>app:Appearance</wfs:Name>\n"
      retString << "<wfs:Value>"
    else
      retString << "<app:appearanceMember>\n"
    end

     retString << "<app:Appearance>\n"
     retString << "<app:theme>default</app:theme>"
     retString << "<app:surfaceDataMember>\n"
     retString << "<app:ParameterizedTexture>\n"
     #if(@name != "")
     #  retString << "<gml:name>" + @name + "</gml:name>\n"
     #end
    retString << "<app:imageURI>" + @imageURI + "</app:imageURI>\n"
     @targets.each { |t|
       retString << t.writeToCityGML

     }
     retString << "</app:ParameterizedTexture>\n"
     retString << "</app:surfaceDataMember>\n"
     retString << "</app:Appearance>\n"
     if(isWFST == "true")

      retString << "</wfs:Value>\n"
      retString << "</wfs:Property>\n"
      retString << "</wfs:Update>\n"
      else
        retString << "</app:appearanceMember>\n"
     end

     return retString
   end



    def createskpmaterial (filedir, model)
         materials = model.materials
         @material = materials.add
         texturepath = filedir + @imageURI
         @material.texture = texturepath
    end


  attr_reader :imageURI, :coordlists
end
