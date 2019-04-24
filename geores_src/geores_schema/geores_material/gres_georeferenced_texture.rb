# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'sketchup.rb'
Sketchup::require 'geores_src/geores_schema/geores_material/gres_abstract_appearance.rb'
Sketchup::require 'geores_src/geores_debug/gres_cgmldebugger.rb'

class GRES_GeoreferencedTexture < GRES_AbstractAppearance

   def initialize attrs
     super(attrs)

    @xrefpoint = 0
    @yrefpoint = 0
    @factorx = 0
    @factory = 0
    @useworldfile = false
  end

   attr_reader :imageURI, :xrefpoint, :yrefpoint, :factorx, :factory

  def addimageURI (uri)
    @imageURI = uri
  end
 

  def setxrefpoint(xrefp)
    @xrefpoint = xrefp
  end

  def setyrefpoint(yrefp)
    @yrefpoint = yrefp
  end
  def setfacx(facx)
    @factorx = facx
  end
  def setfacy(facy)
    @factory = facy
  end
  def setpreferworldfile prefer
    @useworldfile = prefer
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
     retString << "<app:GeoreferencedTexture>\n"
     if(@name != "")
       retString << "<gml:name>" + @name + "</gml:name>\n"
     end
    retString << "<app:imageURI>" + @imageURI + "</app:imageURI>\n"
     if(@xrefpoint != 0 and @yrefpoint != 0)
        retString << "<app:referencePoint>\n"
        retString << "<gml:Point>\n"
         retString << "<gml:pos>" + @xrefpoint.to_s + " " + @yrefpoint.to_s + "</gml:pos>\n"
        retString << "</gml:Point>\n"
        retString << "</app:referencePoint>\n"
    end
    if(@factorx != 0 and @factory)
      retString << "<app:orientation>"+ @factorx + " 0 0 " +  @factory + "</app:orientation>\n"
    end
    retString << "<app:preferWorldFile>" + @useworldfile.to_s + "</app:preferWorldFile>\n"
    @targets.each { |t|
       retString << "<app:target>" + t + "</app:target>\n"

     }

     retString << "</app:GeoreferencedTexture>\n"
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
         if(@useworldfile == true)
           loadWorldFile(filedir)
         end
         GRES_CGMLDebugger.writedebugstring("GeoreferencedTexture: @xrefpoint= " + @xrefpoint.to_s + ", @yrefpoint=" + @yrefpoint.to_s + " ,@factorx=" + @factorx.to_s + " ,@factory" + @factory.to_s + "\n")
    end

   def loadWorldFile filedir
     worldFileUri = @imageURI.upcase
     if(worldFileUri.end_with?(".JPG") == true)
       worldFileUri = worldFileUri.gsub(".JPG", ".JGW")
     end
      if(worldFileUri.end_with?(".JPEG") == true)
       worldFileUri = worldFileUri.gsub(".JPEG", ".JGW")
     end
     if(worldFileUri.end_with?(".PNG") == true)
       worldFileUri = worldFileUri.gsub(".PNG", ".PGW")
     end
     if(worldFileUri.end_with?(".TIF") == true)
       worldFileUri = worldFileUri.gsub(".TIF", ".TFW")
     end
      if(worldFileUri.end_with?(".TIFF") == true)
       worldFileUri = worldFileUri.gsub(".TIFF", ".TFW")
     end

    begin
    file = File.new(filedir+worldFileUri, "r")
    counter = 0
    while (line = file.gets)
        if(counter == 0)
          @factorx = line.to_f
        end
        if(counter == 3)
          @factory = line.to_f
        end
        if(counter == 4)
          @xrefpoint = line.to_f
        end
        if(counter == 5)
          @yrefpoint = line.to_f
        end
        counter = counter + 1
    end
    file.close
      rescue => err
      GRES_CGMLDebugger.writedebugstring("Fehler beim Laden eines Worldfiles " + err.to_s + "\n")
    end
   end

   def includeFaceCoords(face, citygmlloader)

     if(@material.texture == nil)
       return false
     end

      sumdxInMeter = @material.texture.image_width.to_f * @factorx.to_f
      sumdyInMeter = @material.texture.image_height.to_f * (-@factory.to_f)

      minx = @xrefpoint
      maxx = @xrefpoint + sumdxInMeter
      miny = @yrefpoint - sumdyInMeter
      maxy = @yrefpoint



     face.outer_loop.vertices.each { |vertex|
        checkPointX = vertex.position.x + citygmlloader.translX
        checkPointY = vertex.position.y + citygmlloader.translY
         if(checkPointX > minx and checkPointX < maxx and checkPointY > miny and checkPointY < maxy)
            return true
        end
     }

    

      return false

   end


end
