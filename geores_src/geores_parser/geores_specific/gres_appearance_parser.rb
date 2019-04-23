# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'sketchup.rb'
Sketchup::require 'geores_src/geores_schema/geores_material/gres_georeferenced_texture.rb'
Sketchup::require 'geores_src/geores_schema/geores_material/gres_parameterized_texture.rb'
Sketchup::require 'geores_src/geores_schema/geores_material/gres_x3d_material.rb'
Sketchup::require 'geores_src/geores_schema/geores_material/gres_texcoordlist.rb'
Sketchup::require 'geores_src/geores_schema/geores_material/gres_target.rb'
Sketchup::require 'geores_src/geores_debug/gres_cgmldebugger.rb'

class GRES_AppearanceParser
  

  def initialize
    @appearance = nil
    @currenTarget = nil
    @currenttagname = ""
  end


  def tag_start name, attrs
    @currenttagname = name.strip
    if(name.index("X3DMaterial") != nil)
       GRES_CGMLDebugger.writedebugstring("found X3DMaterial - init Material Object \n")
      @appearance = GRES_X3DMaterial.new(attrs)
      return
    elsif(name.index("ParameterizedTexture") != nil)
       GRES_CGMLDebugger.writedebugstring("found ParameterizedTexture - init Material Object \n")
      @appearance = GRES_ParameterizedTexture.new(attrs)
      return
    elsif(name.index("GeoreferencedTexture") != nil)
      GRES_CGMLDebugger.writedebugstring("found GeoreferencedTexture - init Material Object \n")
      @appearance = GRES_GeoreferencedTexture.new(attrs)
      return
    end

   if(@currenttagname == "app:target")

        uri = getattrvalue("uri", attrs)

        if(uri != "")
          if(uri.index("#") != nil)
            uri = uri.sub("#","")
          end
          @currenTarget = GRES_Target.new(uri)
          GRES_CGMLDebugger.writedebugstring("found target - with uri:" + uri + "create a new currentTarget Object \n")
        else
          GRES_CGMLDebugger.writedebugstring("found target - with  no uri: create a new currentTarget Object \n")
          @currenTarget = GRES_Target.new("default")
        end

        return
     end

    if(@currenttagname == "app:textureCoordinates" or name == "textureCoordinates")
        uri = getattrvalue("ring", attrs)
        if(uri != "")
          if(uri.index("#") != nil)
            uri = uri.sub("#","")
          end
          @texcoords_uri = uri
          GRES_CGMLDebugger.writedebugstring("found textureCoordinates - with uri:" + @texcoords_uri + "set the @uri string \n")
        end
        return
     end

  end

  def text text
     if(@currenttagname  == "app:imageURI" or @currenttagname  == "imageURI" and text != "")
         filename = text
         filename = filename.gsub('\\' , '/')
         if(filename.index("/") != 0)
           filename = "/" + filename
         end
         GRES_CGMLDebugger.writedebugstring("found a image uri for the material in text method: " + filename + "set the image uri string \n")
         @appearance.addimageURI(filename)
         return
     end
     if(@currenttagname == "app:textureCoordinates" or @currenttagname == "textureCoordinates" and text != "")
          coordlist = parsecoordlist(text)
          GRES_CGMLDebugger.writedebugstring("found a coordList in text method \n")
          if(@currenTarget != nil)
            coordlist.seturi(@texcoords_uri)
            @currenTarget.addcoordlist(coordlist)
            GRES_CGMLDebugger.writedebugstring("add coordlist" + coordlist.to_s + " with uri:" + @texcoords_uri + " to the target \n")
          end
          return
     end
      if(@currenttagname == "diffuseColor" or @currenttagname == "app:diffuseColor" and text != "")
          rgb = text.split(" ")
          puts "Color Red:" + rgb[0].to_s + " Green:" + rgb[1].to_s + " Blue:" + rgb[2].to_s
          @appearance.setColor(rgb[0].to_s, rgb[1].to_s, rgb[2].to_s)
          GRES_CGMLDebugger.writedebugstring("found a color in text method  Red:" + rgb[0].to_s + " Green:" + rgb[1].to_s + "Blue: " + rgb[2].to_s +  "\n")
      end
       if(@currenttagname == "app:target" or @currenttagname == "target")
          if(text != "")
              if(text.index("#") != nil)
                  text = text.sub("#","")
              end
           @currenTarget.seturi(text)
           GRES_CGMLDebugger.writedebugstring("found target text :" + text + " current target != nil\n")
         end
       end
       if(@currenttagname == "app:transparency" or @currenttagname == "transparency" and text != "")
            GRES_CGMLDebugger.writedebugstring("found transparency text :" + text + "set transparency for Appearance\n")
            @appearance.settransparancy(1.0 - text.to_f)
       end
       if(@currenttagname == "app:orientation" or @currenttagname == "orientation" and text != "")
          orient = text.split(" ")
          facX = orient[0].to_f
          facY = orient[3].to_f
          @appearance.setfacx(facX)
          @appearance.setfacy(facY)
          GRES_CGMLDebugger.writedebugstring("found orientation in text :" + facX.to_s  + " add to Appearance\n")
       end
      if(@currenttagname == "gml:pos" and text != "")
         coords = text.split(" ")
         x = coords[0].to_f
         y = coords[1].to_f
         @appearance.setxrefpoint(x)
         @appearance.setyrefpoint(y)
         GRES_CGMLDebugger.writedebugstring("found reference Point in text :" + x.to_s + " " + y.to_s  + "\n")
      end
      if(@currenttagname == "app:preferWorldFile" and text != "")
         if(text.to_s == "true")
           @appearance.setpreferworldfile(true)
         else
           @appearance.setpreferworldfile(false)
         end
         GRES_CGMLDebugger.writedebugstring("found app:preferWorldFile in text :" + text.to_s  + "\n")
      end

  end

  def tag_end name
    name = name.strip
       if(name == "app:target" or name == "target")
           @appearance.addtarget(@currenTarget)
           GRES_CGMLDebugger.writedebugstring("found target tag_end :current target != nil add to Appearance \n")
           @currenTarget = nil
       end
  end



  def getattrvalue(name, array)
   array.each{|arr|
     if(arr[0] == name)
       return arr[1]
     end
   }
   return ""
 end

   def parsecoordlist(text)
    #puts "bin in parse texcoordlist"
    tclist = GRES_TexCoordList.new
    coordliststring = text
       #puts coordliststring
       coords = coordliststring.split(" ")
       i = 0
       while i < coords.length-1
        x = coords[i].to_f
        y = coords[i+1].to_f
        po = Geom::Point3d.new x,y,0
        tclist.addcord(po)
        #puts po.to_s
        i = i + 2
      end
    return tclist
  end

  attr_reader :appearance;
end
