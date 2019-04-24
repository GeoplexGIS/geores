# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'sketchup.rb'
Sketchup::require 'geores_src/geores_debug/gres_cgmldebugger.rb'
Sketchup::require 'geores_src/geores_schema/geores_material/gres_georeferenced_texture.rb'
Sketchup::require 'geores_src/geores_schema/geores_material/gres_x3d_material.rb'
Sketchup::require 'geores_src/geores_schema/geores_material/gres_parameterized_texture.rb'

class GRES_Surface

 

  def initialize
    @xlink = ""
    @gmlid = ""
    @externalRing = nil
    @internalRings = Array.new()
    @parentgmlid = ""
    @loader = nil
  end

  attr_reader :gmlid, :xlink

  def setxlink x
    @xlink = x
  end

  def setgmlid g
    @gmlid = g
  end

  def setparentgmlid(pgmlid)
    @parentgmlid = pgmlid
  end

  def addExternalRing ring
    @externalRing = ring
  end

  def addInternalRing ring
    @internalRings.push(ring)
  end

  def writeToCityGML
     retString = ""
     
     if(@xlink != "")
       retString << "<gml:surfaceMember xlink:href=\"" + @xlink + "\"/>\n"
       return retString
     end
     if(@externalRing.pToExport.length < 3)
       return retString
     end
     indexRing = 0
     retString << "<gml:surfaceMember>\n"
     retString << "<gml:Polygon gml:id=\"" + @gmlid + "\">\n"
     retString << "<gml:exterior>\n"
     retString << @externalRing.writeToCityGML(nil)
     retString << "</gml:exterior>\n"
    
     @internalRings.each { |ring|
        retString << "<gml:interior>\n"
        retString << ring.writeToCityGML(indexRing)
        indexRing = indexRing +1
        retString << "</gml:interior>\n"
     }

    retString << "</gml:Polygon>\n"
    retString <<  "</gml:surfaceMember>\n"

     return retString
  end

def writeToCityGMLAsTriangle
   retstring = ""
    retstring << "<gml:Triangle>\n"
    retstring << "<gml:exterior>\n"
    if(@gmlid != nil and @gmlid != "")
       retstring << "<gml:LinearRing gml:id=\"" + @gmlid + "\">\n"
    else
      retstring << "<gml:LinearRing>\n"
    end
   
    retstring << "<gml:posList srsDimension=\"3\">"
    retstring << @externalRing.writeOnlyPointList
     retstring << "</gml:posList>\n"
     retstring << "</gml:LinearRing>\n"
     retstring << "</gml:exterior>\n"
    retstring << "</gml:Triangle>\n"
end

def writeToCityGMLOnlyPosList
  retstring = ""
   retstring << "<gml:LinearRing>\n"
  retstring << "<gml:posList srsDimension=\"3\">"
  retstring << @externalRing.writeOnlyPointList
  retstring << "</gml:posList>\n"
  retstring << "</gml:LinearRing>\n"
  return retstring
end

  def build group, appearances, citygmlloader, parentnames, parentgmlid, lod, layer, isimpl, issolid
    @loader = citygmlloader
    if(@xlink != "" )
       referencename = group.name
       GRES_CGMLDebugger.writedebugstring("Fuege eine Referenz hinzu: " + referencename + " " + @xlink + "\n")
       #puts "Fuege eine Referenz hinzu: " + referencename + " " + @xlink + "\n"
       if(citygmlloader.isSimple == false)
            citygmlloader.add_reference(lod, @xlink)
       end
       return
     end
     #puts "gmlid " + @gmlid
    # puts "xlink" + @xlink
    entitiesToUse = group.entities
    if(@internalRings.length > 0)#
      newgroup = entitiesToUse.add_group
      entitiesToUse = newgroup.entities
    end

     createextring(entitiesToUse, appearances, parentnames, parentgmlid, lod, layer, isimpl, issolid)
     createintring(entitiesToUse, isimpl)
  end


  def createextring (entities,appearances, parentnames, parentgmlid, lod, layer, isimpl, issolid)
    #jetzt zum ring Element und dort die gml:id abgreifen

    pts3d = Array.new()
    points2d = Array.new()
    points2dxz = Array.new()
    points2dzy = Array.new()
    ringgmlid = @externalRing.gmlid
    puts "RingGMLID " + ringgmlid
    @externalRing.points.each{ |p|
             puts p.to_s
             if(isimpl == true)
               x = p.x.to_f
               y = p.y.to_f
               z = p.z.to_f
             else
               x = p.x.to_f - @loader.translX.to_f
               y = p.y.to_f - @loader.translY.to_f
               z = p.z.to_f - @loader.translZ.to_f
             end
             
             po = Geom::Point3d.new x,y,0
             points2d.push(po)
             poxz = Geom::Point3d.new x,z,0
             points2dxz.push(poxz)
             pozy = Geom::Point3d.new z,y,0
             points2dzy.push(pozy)
             po3d = Geom::Point3d.new x,y,z
             pts3d.push(po3d)

    }
   begin

      if(pts3d[0] == pts3d[pts3d.length() - 1])
              pts3d.delete_at(pts3d.length() - 1)
              points2d.delete_at(points2d.length() - 1)
              points2dxz.delete_at(points2dxz.length() - 1)
              points2dzy.delete_at(points2dzy.length() - 1)
      end
      if(pts3d.length() < 3)
              GRES_CGMLDebugger.writedebugstring("Face mit weniger als 3 Punkten: surface.rb createextring()\n")
              return
       end
        n = calcnormal(pts3d)
        face = entities.add_face pts3d
        nNew = calcnormal2(face.outer_loop.vertices)
        if(n != nil)
          #nNew = face.normal.normalize!
          if((n[0] - nNew[0] >= 0.001 or n[0] - nNew[0] <= -0.001) or (n[1] - nNew[1] >= 0.001 or n[1] - nNew[1] <= -0.001) or (n[2] - nNew[2] >= 0.001 or n[2] - nNew[2] <= -0.001))
            face.reverse!
          end
        end
        if(@loader.isSimple == false)
            face.set_attribute("faceatts","id",@gmlid)
            face.set_attribute("faceatts","status","import")
            face.set_attribute("faceatts","lod", lod)
            if(issolid == true)
              face.set_attribute("faceatts",lod.to_s + "Solid", "true")
            end
             parentcounter = 0
            parentnames.each { |parent|
            face.set_attribute("faceatts","parent" + parentcounter.to_s, parent)
            parentcounter = parentcounter +1
        }
        end
       
        face.layer = layer
       
        @loader.add_face(face)

    rescue =>e
           #hier triangulation
           GRES_CGMLDebugger.writedebugstring("Triangulation von Face:" + @gmlid + " Fehlermeldung" + e.backtrace.to_s + "\n\n Punkte:" + pts3d.to_s + "\n\n")
            coordschanger = 0
            normalarea = getarea(points2d)
            xzarea = getarea(points2dxz)
            zyarea = getarea(points2dxz)
            if(normalarea < xzarea)
              if(xzarea > zyarea)
                coordschanger = 1
                points2d = points2dxz
              else
                coordschanger = 2
                points2d = points2dzy
              end
            elsif(normalarea < zyarea)
               if(xzarea > zyarea)
                coordschanger = 1
                points2d = points2dxz
              else
                coordschanger = 2
                points2d = points2dzy
              end
            end
              handlenonplanarface(points2d, pts3d, coordschanger, ringgmlid, entities, parentnames, appearances, parentgmlid, lod, layer, isimpl, issolid)

              return
            end
        begin
        #  tnow = Time.now.to_f
          if(@gmlid != "" or @parentgmlid != "" or parentgmlid != "")
             doapphandling(face,ringgmlid,appearances,parentgmlid)
          end
       #   tnow2 = Time.now.to_f
          #@logwriter << "Zeit für Zuweisen des Materials in Sketchup:     " +  (tnow2-tnow).to_s + "s\n"
        rescue => e
          GRES_CGMLDebugger.writedebugstring("Fehler in Appearance Handling von face:" + @gmlid + " Fehlermeldung" + e.backtrace.to_s + "\\nn")
         # @logwriter << "Fehler in app handling" + e.to_s + "\n"
         # @logwriter << "gmlid: " + gmlid + "\n"
        end

  end


 def handlenonplanarface(points2d, pts3d, coordschanger, ringgmlid, entities,parentnames, appearances, parentgmlid, lod, layer, isimpl, issolid)
     #okay nicht planar
     polyMesh = Geom::PolygonMesh.new
     newMesh = Geom::PolygonMesh.new
     #puts "mesh punkt hinzu"
     group = entities.add_group
     polyMesh.add_polygon points2d
     #polyMesh.add_polygon pts3d
     #puts polyMesh.count_polygons.to_s
     group.entities.fill_from_mesh polyMesh, false, 0
     groupcounter = 0
     group.entities.each{|ent|
       if(ent.typename == "Face")
            pmesh = ent.mesh 7
            pmesh.polygons.each do |poly2|
            groupcounter = groupcounter +1
             #puts "polygon: " + poly2.to_s
             ptarray = Array.new()
             indArray = Array.new()
             poly2.each do |i|
             #wegen ggf negativ vorkommenden Indizes
              i = (i*i)/i
               pos = pmesh.point_at i
               #puts "Positon" + pos.to_s
               indxinpt3d = 0
               pts3d.each { |p|
                # puts "schauen was das ist " + p.to_s
                 if(coordschanger == 0)
                    if(pos.x - p.x == 0  and pos.y - p.y == 0)
                        pos.z= p.z
                         ptarray << [pos.x, pos.y, pos.z]
                         indArray.push(indxinpt3d)
                         break
                   end
                 elsif(coordschanger == 1)
                   if(pos.x - p.x == 0  and pos.y - p.z == 0)
                         pos.z= p.y
                         ptarray << [pos.x, pos.z, pos.y]
                         indArray.push(indxinpt3d)
                         break
                   end
                 else
                   if(pos.x - p.z == 0  and pos.y - p.y == 0)
                         pos.z= p.x
                         ptarray << [pos.z, pos.y, pos.x]
                         indArray.push(indxinpt3d)
                         break
                   end
                 end
                 indxinpt3d = indxinpt3d + 1
               }
             end

             begin


             face = entities.add_face ptarray
              if(@loader.isSimple == false)
                 face.set_attribute("faceatts","id",@gmlid + groupcounter.to_s)
                   face.set_attribute("faceatts","status","import_triangulated")
                   face.set_attribute("faceatts","lod", lod)
                    if(issolid == true)
                        face.set_attribute("faceatts",lod.to_s + "Solid", "true")
                  end
                    parentcounter = 0
                    parentnames.each { |parent|
                        face.set_attribute("faceatts","parent" + parentcounter.to_s, parent)
                        parentcounter = parentcounter +1
                   }
              end
            
             face.layer = layer
           
             @loader.add_face(face)
             doapptriangulation(face, ringgmlid, appearances, indArray, parentgmlid)

             rescue => e
               GRES_CGMLDebugger.writedebugstring("Fehler beim Anlegen einer triangulierten Flaeche:" + @gmlid + " Fehlermeldung" + e.backtrace.to_s + "\n\n")
             end
            end
          end
        }
     entities.erase_entities group
  end

  def getarea(points2d)
    a = 0
    i = 0
		while(i < points2d.length)
      c1 = points2d[i];
			c2 = nil;
			if(i == points2d.length-1)
				c2 = points2d[0]
			else
				c2 = points2d[i+1]
      end
      a = a + ((c1.x-c2.x)*(c1.y+c2.y))
      i = i + 1
    end
    a = a/2
		return (a*a)/2
  end

  def getAreaEdge(p1,p2,p3)
    a = 0.0
		part1 = p1.x*(p2.y-p3.y)
		part2 = p2.x*(p3.y-p1.y)
		part3 = p3.x*(p1.y-p2.y)
		a = 0.5*(part1+part2+part3)
		return a.to_f
  end

   def doapptriangulation(face, ringgmlid, appearances, poly2,parentgmlid)

      theApp = nil
    appearances.each { |app|
      if(app.ids.include?(@gmlid))
        theApp = app
        if(theApp.instance_of?(GRES_ParameterizedTexture)  == true)
          break
        end
      elsif(app.ids.include?(parentgmlid) and theApp == nil)
        theApp = app
      end
    }

    if(theApp == nil)
      GRES_CGMLDebugger.writedebugstring("Keine Appearance gefunden fuer:" + @gmlid + "\n\n")
      return
    end
    if(theApp.instance_of?(GRES_X3DMaterial)  == true)
      face.material = theApp.material
      GRES_CGMLDebugger.writedebugstring("X3DMaterial " + theApp.name + "fuer Flaeche: " +@gmlid +"\n")
      return
    end
     if(theApp.instance_of?(GRES_ParameterizedTexture) == true)
       theTarget = nil
       GRES_CGMLDebugger.writedebugstring("ParameterizedTexture " + theApp.name + "fuer Flaeche: " +@gmlid +"\n")
       theApp.targets.each { |target|
         if(target.uri == @gmlid)
           theTarget = target
           break
         end
       }
       if(theTarget == nil)
         GRES_CGMLDebugger.writedebugstring("Kein Target gefunden fuer:" + @gmlid + "\n")
       end
       texcoordlist = nil
       theTarget.coordlists.each { |coordlist|
            if(coordlist.uri == ringgmlid)
              texcoordlist = coordlist.coords
            end

       }
       if(texcoordlist == nil)
         GRES_CGMLDebugger.writedebugstring("Kein TexCoordList gefunden fuer:" + ringgmlid + "\n")
         return
       end

      ptarray = Array.new
      outerloop = face.outer_loop
      vertices = outerloop.vertices
      ptarray[0] = vertices[0].position
      #puts  ptarray[0].to_s
      i = poly2[0]
      ptarray[1] = texcoordlist[i]
      #puts  ptarray[1].to_s
      ptarray[2] = vertices[1].position
      #puts  ptarray[2].to_s
      i = poly2[1]
      ptarray[3] = texcoordlist[i]
      #puts  ptarray[3].to_s
      ptarray[4] = vertices[2].position
      #puts  ptarray[4].to_s
      i = poly2[2]
      ptarray[5] = texcoordlist[i]
       GRES_CGMLDebugger.writedebugstring("Try to create Triangle with material " + ptarray.to_s +  "\n")
      face.position_material theApp.material, ptarray, true
      face.position_material theApp.material, ptarray, false
    end
  end


  def doapphandling(face, ringgmlid, appearances, parentgmlid)
   theApp = nil
    GRES_CGMLDebugger.writedebugstring("Surface: in  doapphandling mit Ring ID:" + ringgmlid.to_s +  " ParentGMLID: " + parentgmlid.to_s + " GMLID Surafce: " + @gmlid.to_s +  "\n")
    appearances.each { |app|
      if(app.ids.include?(@gmlid))
        theApp = app
        if(theApp.instance_of?(GRES_ParameterizedTexture) == true)
          break
        end
      elsif(app.ids.include?(parentgmlid) and theApp == nil)
        theApp = app
      elsif(@parentgmlid != "" and app.ids.include?(@parentgmlid))
        theApp = app
      end
    }

    if(theApp == nil)
      GRES_CGMLDebugger.writedebugstring("Keine Appearance gefunden fuer:" + @gmlid + "\n")
      return
    end
    if(theApp.instance_of?(GRES_X3DMaterial) == true)
      face.material = theApp.material
      GRES_CGMLDebugger.writedebugstring("X3DMaterial " + theApp.name + "fuer Flaeche: " +@gmlid +"\n")
      return
    end
    if(theApp.instance_of?(GRES_GeoreferencedTexture) == true)
      GRES_CGMLDebugger.writedebugstring("GeoreferencedTexture " + theApp.name + "fuer Flaeche: " +@gmlid +"\n")
      if(theApp.includeFaceCoords(face,@loader) == true)
          doapphandlinggeoref(face,theApp)
      end
    end

    if(theApp.instance_of?(GRES_ParameterizedTexture) == true)
       theTarget = nil
       GRES_CGMLDebugger.writedebugstring("ParameterizedTexture " + theApp.name + "fuer Flaeche: " +@gmlid +"\n")
       theApp.targets.each { |target|
         if(target.uri == @gmlid)
           theTarget = target
           break
         end
       }
       if(theTarget == nil)
          GRES_CGMLDebugger.writedebugstring("Kein Target gefunden fuer:" + @gmlid + "\n")
         return
       end
       texcoordlist = nil
       theTarget.coordlists.each { |coordlist|
            if(coordlist.uri == ringgmlid)
              texcoordlist = coordlist.coords
            end

       }
       if(texcoordlist == nil)
         GRES_CGMLDebugger.writedebugstring("Kein TexCoordList gefunden fuer:" + ringgmlid + "\n")
         return
       end
       texcoordlist.delete_at(texcoordlist.length() - 1)
      ptarray = Array.new
      outerloop = face.outer_loop
      vertices = outerloop.vertices
      if(vertices.length < 4)
       #only 2 point referencing
       ptarray[0] = vertices[0].position
       #puts  ptarray[0].to_s
       ptarray[1] = texcoordlist[0]
       #puts  ptarray[1].to_s
       ptarray[2] = vertices[1].position
       #puts  ptarray[2].to_s
       ptarray[3] = texcoordlist[1]
       #puts  ptarray[3].to_s
       ptarray[4] = vertices[2].position
       #puts  ptarray[4].to_s
       ptarray[5] = texcoordlist[2]
       #puts  ptarray[5].to_s
      elsif(vertices.length < 5)
        #only 2 point referencing
       ptarray[0] = vertices[0].position
       #puts  ptarray[0].to_s
       ptarray[1] = texcoordlist[0]
       #puts  ptarray[1].to_s
       ptarray[2] = vertices[1].position
       #puts  ptarray[2].to_s
       ptarray[3] = texcoordlist[1]
       #puts  ptarray[3].to_s
       ptarray[4] = vertices[2].position
       #puts  ptarray[4].to_s
       ptarray[5] = texcoordlist[2]
       ptarray[6] = vertices[3].position
       #puts  ptarray[4].to_s
       ptarray[7] = texcoordlist[3]
      else
       #puts "machs mit 8"
     ro_x = -1
     ro_y = -1
     lu_x = -1
     lu_y = -1

      for i in 0..(texcoordlist.length() - 1)
          ro_x = texcoordlist[i].x if(ro_x == -1 or texcoordlist[i].x > ro_x)
          ro_y = texcoordlist[i].y if(ro_y == -1 or texcoordlist[i].y > ro_y)
          lu_x = texcoordlist[i].x if(lu_x == -1 or texcoordlist[i].x < lu_x)
          lu_y = texcoordlist[i].y if(lu_y == -1 or texcoordlist[i].y < lu_y)
        end
        ru_x = ro_x
        ru_y = lu_y
        lo_x = lu_x
        lo_y = ro_y
        abs_ro = []
        abs_ru = []
        abs_lu = []
        abs_lo = []
        for i1 in 0..(texcoordlist.length() - 1)
          abs_ro << [(ro_x - texcoordlist[i1][0]) * (ro_x - texcoordlist[i1][0]) + (ro_y - texcoordlist[i1][1]) * (ro_y - texcoordlist[i1][1]), i1]
          abs_ru << [(ru_x - texcoordlist[i1][0]) * (ru_x - texcoordlist[i1][0]) + (ru_y - texcoordlist[i1][1]) * (ru_y - texcoordlist[i1][1]), i1]
          abs_lu << [(texcoordlist[i1][0] - lu_x) * (texcoordlist[i1][0] - lu_x) + (texcoordlist[i1][1] - lu_y) * (texcoordlist[i1][1] - lu_y), i1]
          abs_lo << [(texcoordlist[i1][0] - lo_x) * (texcoordlist[i1][0] - lo_x) + (texcoordlist[i1][1] - lo_y) * (texcoordlist[i1][1] - lo_y), i1]
        end

         abs_ro.sort!
         abs_lo.sort!
         abs_ru.sort!
         abs_lu.sort!

        pos_ru = abs_ru[0][1]
        pos_lu = abs_lu[0][1]
        pos_ro = abs_ro[0][1]
        pos_lo = abs_lo[0][1]

        origin = [0, 0, 0]
        if(pos_lu != pos_ru and pos_lu != pos_ro and pos_lu != pos_lo)
          ptarray << Geom::Point3d.new(vertices[pos_lu].position.x - origin[0], vertices[pos_lu].position.y - origin[1], vertices[pos_lu].position.z - origin[2])
         ptarray << Geom::Point3d.new(texcoordlist[pos_lu][0], texcoordlist[pos_lu][1])
        end
        if(pos_ru != pos_ro and pos_ru != pos_lo)
           ptarray << Geom::Point3d.new(vertices[pos_ru].position.x - origin[0], vertices[pos_ru].position.y - origin[1], vertices[pos_ru].position.z - origin[2])
          ptarray << Geom::Point3d.new(texcoordlist[pos_ru][0], texcoordlist[pos_ru][1])
        end
        if(pos_ro != pos_lo)
           ptarray << Geom::Point3d.new(vertices[pos_ro].position.x - origin[0], vertices[pos_ro].position.y - origin[1], vertices[pos_ro].position.z - origin[2])
          ptarray << Geom::Point3d.new(texcoordlist[pos_ro][0], texcoordlist[pos_ro][1])
        end

        ptarray << Geom::Point3d.new(vertices[pos_lo].position.x - origin[0], vertices[pos_lo].position.y - origin[1], vertices[pos_lo].position.z - origin[2])
        ptarray << Geom::Point3d.new(texcoordlist[pos_lo][0], texcoordlist[pos_lo][1])



      end
      begin
      face.position_material theApp.material, ptarray, true
      face.position_material theApp.material, ptarray, false
     rescue => e
       GRES_CGMLDebugger.writedebugstring("Fehler beim Zuweisen von Texturkoordinaten:" + ringgmlid + " Fehlermeldung:"  + e.backtrace.to_s + "\n")
      end
      
    end

   
  end

   def createintring (entities, isimpl)
    #jetzt zum ring Element und dort die gml:id abgreifen

    @internalRings.each { |ring|
        pts = ring.points
        pts3d = Array.new()
        pts.each { |p|
              if(isimpl == true)
               x = p.x.to_f
               y = p.y.to_f
               z = p.z.to_f
             else
               x = p.x.to_f - @loader.translX.to_f
               y = p.y.to_f - @loader.translY.to_f
               z = p.z.to_f - @loader.translZ.to_f
             end
             po3d = Geom::Point3d.new x,y,z
             pts3d.push(po3d)
        }
         begin
            if(pts3d[0] == pts3d[pts3d.length()-1])
               pts3d.delete_at(pts3d.length() - 1)
            end
            int = entities.add_face pts3d
            int.erase!
        rescue =>e
             GRES_CGMLDebugger.writedebugstring("Fehler beim Erstellen einer Insel:" + @gmlid + " Fehlermeldung:"  + e.backtrace.to_s + "\n")
        end


        }
  end

   def calcnormal (pts3d)
    if(pts3d.length < 3)
      return nil
    end
    edgecounter = 0
    konkavedgecounter = 0
    i = 1
    while(i < pts3d.length - 1)
      base = pts3d[i-1]
      p1 = pts3d[i]
      p2 = pts3d[i+1]
      u = Geom::Vector3d.new(p1.x - base.x, p1.y - base.y,p1.z - base.z)
      v = Geom::Vector3d.new(p2.x - p1.x, p2.y - p1.y,p2.z - p1.z)
      if(u.parallel? v or u.samedirection? v)
         i = i + 1
        next
      else
        edgecounter = edgecounter + 1
        if(getAreaEdge(base,p1,p2) >= 0)
          nNormal = u.cross v
          nNormal = nNormal.normalize!
        else
          konkavedgecounter = konkavedgecounter + 1
          nKonkav = u.cross v
          nKonkav = nKonkav.normalize!
        end
      end
       i = i + 1
    end
    if(konkavedgecounter > edgecounter/2)
      return nKonkav
    else
      return nNormal
    end
  end

    def calcnormal2 (pts3d)
    if(pts3d.length < 3)
      return nil
    end
    i = 1
    edgecounter = 0
    konkavedgecounter = 0
    while(i < pts3d.length - 1)
      base = pts3d[i-1].position
      p1 = pts3d[i].position
      p2 = pts3d[i+1].position
      u = Geom::Vector3d.new(p1.x - base.x, p1.y - base.y,p1.z - base.z)
      v = Geom::Vector3d.new(p2.x - p1.x, p2.y - p1.y,p2.z - p1.z)
      if(u.parallel? v or u.samedirection? v)
         i = i + 1
        next
      else
        edgecounter = edgecounter + 1
        if(getAreaEdge(base,p1,p2) >= 0)
          nNormal = u.cross v
          nNormal = nNormal.normalize!
        else
          konkavedgecounter = konkavedgecounter + 1
          nKonkav = u.cross v
          nKonkav = nKonkav.normalize!
        end
      end
       i = i + 1
    end
     if(konkavedgecounter > edgecounter/2)
      return nKonkav
    else
      return nNormal
    end
  end

 def doapphandlinggeoref(face, theApp)

    #  puts "gehe durch alle georeferenced Textures"

            sumdxInMeter = theApp.material.texture.image_width.to_f * theApp.factorx.to_f
            sumdyInMeter = theApp.material.texture.image_height.to_f * (-theApp.factory.to_f)
           GRES_CGMLDebugger.writedebugstring("Surface doapphandlinggeoref mit sumdxInMeter=  " + sumdxInMeter.to_s + " sumdyInMeter= " + sumdyInMeter.to_s + "\n")
           outerloop = face.outer_loop
           vertices = outerloop.vertices
           newyrefpoint = theApp.yrefpoint.to_f - sumdyInMeter
           ptarray = Array.new
           dx = ((vertices[0].position.x) + @loader.translX) - theApp.xrefpoint.to_f
          # puts dx.to_s
           dy = ((vertices[0].position.y) + @loader.translY) -newyrefpoint
          # puts dy.to_s
           ptarray << vertices[0].position
           newx =dx.to_f/sumdxInMeter.to_f
          # puts newx.to_s
           newy = dy.to_f/sumdyInMeter.to_f
           #puts newy.to_s
           ptarray << Geom::Point3d.new(newx, newy)
          # puts "punkt dazu"
           dx = ((vertices[1].position.x) + @loader.translX) - theApp.xrefpoint.to_f
           #puts dx.to_s
            dy = ((vertices[1].position.y) + @loader.translY) -newyrefpoint
         #  puts dy.to_s
           ptarray << vertices[1].position
           newx =dx.to_f/sumdxInMeter.to_f
          # puts newx.to_s
           newy = dy.to_f/sumdyInMeter.to_f
         #  puts newy.to_s
           ptarray << Geom::Point3d.new(newx, newy)
          # puts "punkt dazu"
            dx = ((vertices[2].position.x) + @loader.translX) - theApp.xrefpoint.to_f
           #puts dx.to_s
            dy = ((vertices[2].position.y) + @loader.translY) -newyrefpoint
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
