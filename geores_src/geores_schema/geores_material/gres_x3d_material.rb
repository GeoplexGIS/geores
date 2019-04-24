# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'sketchup.rb'
Sketchup::require 'geores_src/geores_schema/geores_material/gres_abstract_appearance.rb'


class GRES_X3DMaterial < GRES_AbstractAppearance

   def initialize attrs
     super(attrs)
     @alpha = 1
  end

  attr_reader :color, :alpha

  def setColor (r,g,b)
    @color = Sketchup::Color.new r.to_f, g.to_f, b.to_f
    @name = "CGML_Material " + @color.to_s
  end

 def setColorNew(col)
    @color = col
    @name = "CGML_Material " + @color.to_s
  end

  def settransparancy(a)
    @alpha = a
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
     retString << "<app:X3DMaterial>\n"
    # if(@name != "")
      # retString << "<gml:name>" + @name + "</gml:name>\n"
     #end
     red = @color.red.to_f / 256.0
      green = @color.green.to_f / 256.0
      blue = @color.blue.to_f / 256.0
     retString << "<app:diffuseColor>" + red.to_s + " " + green.to_s + " " + blue.to_s + "</app:diffuseColor>\n"
     if(@alpha != -1)
        alphaWrite = 1 - @alpha
        retString << "<app:transparency>" + alphaWrite.to_s + "</app:transparency>\n"
     end
     @targets.each { |t|
       retString << t.writeToCityGMLX3D + "\n"

     }
     retString << "</app:X3DMaterial>\n"
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
         @material.color = @color
         @material.alpha = @alpha

    end
  
end
