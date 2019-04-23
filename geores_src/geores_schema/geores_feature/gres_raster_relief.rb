# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_schema/geores_material/gres_georeferenced_texture.rb'
Sketchup::require 'geores_src/geores_schema/geores_feature/gres_relief_feature.rb'
Sketchup::require 'geores_src/geores_debug/gres_cgmldebugger.rb'
Sketchup::require 'sketchup.rb'

class GRES_RasterRelief < GRES_ReliefFeature
  def initialize
    super()
    @poslow = Array.new()
    @poshigh = Array.new()
    @posorigin = Array.new()
    @posOffset1 = Array.new()
    @posOffset2 = Array.new()
    @posQuantityList = Array.new()
    
  end
  attr_reader :poslow, :poshigh, :posorigin, :posOffset1, :posOffset2, :posQuantityList


  def addpointtolist(z)
    @posQuantityList.push(z)
  end

  def addposlow(x, y)
    @poslow.push(x)
    @poslow.push(y)
  end

  def addposhigh(x, y)
    @poshigh.push(x)
    @poshigh.push(y)
  end

 def addposorigin(x, y)
    @posorigin.push(x)
    @posorigin.push(y)
  end

  def addposoffset1(x, y)
    @posOffset1.push(x)
    @posOffset1.push(y)
  end

  def addposoffset2(x, y)
    @posOffset2.push(x)
    @posOffset2.push(y)
  end



  def buildgeometries(entities, appearances, citygmlloader, parentnames)
    offset_x = @posOffset1[0].to_f
    offset_y = @posOffset2[1].to_f
   #UI.messagebox "offset " + offset_x.to_s + "; " + offset_y.to_s , MB_OK
    origin_x = @posorigin[0].to_f
    origin_y = @posorigin[1].to_f
   #UI.messagebox "origin " + origin_x.to_s + "; " + origin_y.to_s , MB_OK
    low_x = @poslow[0].to_i
    low_y = @poslow[1].to_i
    high_x = @poshigh[0].to_i
    high_y = @poshigh[1].to_i
    layer_creator = citygmlloader.layercreator
    group = entities.add_group
    group.name = @theinternalname
    currentRow = 1;
    currentColumn = 1;
    counter = 0
    #UI.messagebox "quantity " + grid.posQuantityList.length.to_s , MB_OK
     while(counter < @posQuantityList.length-high_y) do
        if(counter == (((high_x-low_x)*currentRow))+ currentRow-1)
          currentColumn = 1
          currentRow = currentRow +1
          #UI.messagebox "counter " + counter.to_s , MB_OK
        else
          pts1 = Array.new()
          pts2 = Array.new()
          zLU = (@posQuantityList[counter].to_f)- citygmlloader.translZ.to_f
          zRU = (@posQuantityList[counter +1].to_f)- citygmlloader.translZ.to_f
          zLO = (@posQuantityList[counter+ high_x +1].to_f)- citygmlloader.translZ.to_f
          zRO = (@posQuantityList[counter+ high_x +2].to_f)- citygmlloader.translZ.to_f
          xmin = (origin_x + ((currentColumn-1)*offset_x)) - citygmlloader.translX.to_f
          xmax = (origin_x + ((currentColumn)*offset_x))- citygmlloader.translX.to_f
          ymin = (origin_y + ((currentRow-1)*offset_y))- citygmlloader.translY.to_f
          ymax = (origin_y + ((currentRow)*offset_y))- citygmlloader.translY.to_f
          pts1.push(Geom::Point3d.new xmin,ymin,zLU)
          pts1.push(Geom::Point3d.new xmax,ymin,zRU)
          pts1.push(Geom::Point3d.new xmin,ymax,zLO)
          pts2.push(Geom::Point3d.new xmax,ymin,zRU)
          pts2.push(Geom::Point3d.new xmax,ymax,zRO)
          pts2.push(Geom::Point3d.new xmin,ymax,zLO)
          GRES_CGMLDebugger.writedebugstring("erzeuge face aus Punkten: " + pts1.to_s + "\n")
          face = group.entities.add_face pts1
          face.layer= layer_creator.dtm
          GRES_CGMLDebugger.writedebugstring("erzeuge face aus Punkten: " + pts2.to_s + "\n")
          face2 = group.entities.add_face pts2
          face2.layer= layer_creator.dtm
          doapphandlingGeoRef(face, appearances, citygmlloader)
          doapphandlingGeoRef(face2, appearances, citygmlloader)


          currentColumn = currentColumn +1;
        end
        counter = counter +1
     end
       transform = Geom::Transformation.scaling 39.370078740157477
       group.transformation = transform
  end


  def doapphandlingGeoRef(face, appearances, citygmlloader)
    appearances.each { |app|
      if(app.instance_of?(GRES_GeoreferencedTexture) == true)
         if(app.includeFaceCoords(face, citygmlloader) == true)
           doapphandlinggeoref(face,app,citygmlloader)
         end
      end
    }
  end

    def doapphandlinggeoref(face, theApp,citygmlloader)

    #  puts "gehe durch alle georeferenced Textures"

            sumdxInMeter = theApp.material.texture.image_width.to_f * theApp.factorx.to_f
            sumdyInMeter = theApp.material.texture.image_height.to_f * (-theApp.factory.to_f)
           GRES_CGMLDebugger.writedebugstring("Surface doapphandlinggeoref mit sumdxInMeter=  " + sumdxInMeter.to_s + " sumdyInMeter= " + sumdyInMeter.to_s + "\n")
           outerloop = face.outer_loop
           vertices = outerloop.vertices
           newyrefpoint = theApp.yrefpoint.to_f - sumdyInMeter
           ptarray = Array.new
           dx = ((vertices[0].position.x) + citygmlloader.translX) - theApp.xrefpoint.to_f
          # puts dx.to_s
           dy = ((vertices[0].position.y) + citygmlloader.translY) -newyrefpoint
          # puts dy.to_s
           ptarray << vertices[0].position
           newx =dx.to_f/sumdxInMeter.to_f
          # puts newx.to_s
           newy = dy.to_f/sumdyInMeter.to_f
           #puts newy.to_s
           ptarray << Geom::Point3d.new(newx, newy)
          # puts "punkt dazu"
           dx = ((vertices[1].position.x) + citygmlloader.translX) - theApp.xrefpoint.to_f
           #puts dx.to_s
            dy = ((vertices[1].position.y) + citygmlloader.translY) -newyrefpoint
         #  puts dy.to_s
           ptarray << vertices[1].position
           newx =dx.to_f/sumdxInMeter.to_f
          # puts newx.to_s
           newy = dy.to_f/sumdyInMeter.to_f
         #  puts newy.to_s
           ptarray << Geom::Point3d.new(newx, newy)
          # puts "punkt dazu"
            dx = ((vertices[2].position.x) + citygmlloader.translX) - theApp.xrefpoint.to_f
           #puts dx.to_s
            dy = ((vertices[2].position.y) + citygmlloader.translY) -newyrefpoint
          # puts dy.to_s
           ptarray << vertices[2].position
           newx =dx.to_f/sumdxInMeter.to_f
          # puts newx.to_s
           newy = dy.to_f/sumdyInMeter.to_f
          # puts newy.to_s
           ptarray << Geom::Point3d.new(newx, newy)
           GRES_CGMLDebugger.writedebugstring("Surface doapphandlinggeoref mit ptarray  " + ptarray.to_s + "\n")
           face.position_material theApp.material, ptarray, true
           face.position_material theApp.material, ptarray, false
           return


  end

end
