# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_schema/geores_feature/gres_relief_feature.rb'
Sketchup::require 'sketchup.rb'
Sketchup::require 'geores_src/geores_debug/gres_cgmldebugger.rb'

class GRES_TINRelief < GRES_ReliefFeature
  def initialize
    super()
    @triangles = Array.new()
  end
  
  attr_reader :triangles

  def addTriangles(geometries)
    @triangles.concat(geometries)
  end

  def addTriangle(ent)
    @triangles.push(ent)
  end

  def buildgeometries(entities, appearances, citygmlloader, parentnames)
       parents = Array.new()
       GRES_CGMLDebugger.writedebugstring("TINRelief: buildgeometries \n")
       if(parentnames != nil)
         parents.concat(parentnames)
       end
       model = Sketchup.active_model
       parents.push(@theinternalname)
       layer_creator = citygmlloader.layercreator
       if(@triangles.length > 0)
         group = entities.add_group
         group.name = @theinternalname
         trianglecounter = 0
         groupToAdd = group.entities.add_group
         groupToAdd.name = @theinternalname + trianglecounter.to_s
         if(@triangles.length > 0)
             @triangles.each { |t|
               if(trianglecounter > 200)
                  groupToAdd = group.entities.add_group
                  groupToAdd.name = @theinternalname + trianglecounter.to_s
                  trianglecounter = 0
               end
               t.build(groupToAdd, appearances, citygmlloader, parents,@gmlid, "lod0",layer_creator.dtm, false, false)
               if(citygmlloader.isSimple == false)
                 if(t.gmlid != "")
                     model.set_attribute("tinids", t.gmlid,  t.gmlid)
                 end
               end
               trianglecounter = trianglecounter + 1
             }
         end
          transform = Geom::Transformation.scaling 39.370078740157477
          group.transformation = transform
       end
     end


   def writeToCityGML isWFST, namespace

    if(isWFST == "true")
      return writeToCityGMLWFST
    end
    costring = ""
    costring << "<core:cityObjectMember>\n"
        costring << "<dem:ReliefFeature gml:id=\""+ @gmlid + "\">\n"
        costring << "<dem:lod>3</dem:lod>\n"
        costring << "<dem:reliefComponent>\n"
        costring << "<dem:TINRelief>\n"
        costring << "<dem:lod>3</dem:lod>\n"
        costring << "<dem:tin>\n"
        costring << "<gml:TriangulatedSurface gml:id=\"" + @gmlid + "_triangulatedSurface" + "\">\n"
        costring << "<gml:trianglePatches>\n"
       @triangles.each { |ent|
          costring << ent.writeToCityGMLAsTriangle
        }
        costring << "</gml:trianglePatches>\n"
        costring << "</gml:TriangulatedSurface>\n"
        costring << "</dem:tin>\n"
        costring << "</dem:TINRelief >\n"
        costring << "</dem:reliefComponent>\n"
        costring << "</dem:ReliefFeature >\n"
        costring << "</core:cityObjectMember>\n"

     return costring

   end

  



   def writeToCityGMLWFST()
    retstring = ""
    if(@triangles.length == 0)
          return retstring
    end
    model = Sketchup.active_model
    attdict = model.attribute_dictionary("tinids")
    ids = Array.new()
    if(attdict != nil)
      ids = attdict.values
    end
    usedIDS = Array.new()
    @triangles.each { |surface|
      if(surface.gmlid != "")
            if(ids.include?(surface.gmlid))
               if(usedIDS.include?(surface.gmlid) == false)
                  retstring << writeupdate(surface)
                  usedIDS.push(surface.gmlid)
               end
            else
                 retstring << writeinsert(surface)
            end
      else
        retstring << writeinsert(surface)
      end

    }
    ids.each { |id|
      if(usedIDS.include?(id) == false)
         retstring <<  writedelete(id)
      end
    }
    return retstring
  end

  def writeinsert(ent)
    retstring = ""
    retstring << "<wfs:Insert>\n"
    retstring << "<dem:TINRelief>\n"
    retstring << "<dem:tin>\n"
    retstring << "<gml:TriangulatedSurface>\n"
    retstring << "<gml:trianglePatches>\n"
    retstring <<  ent.writeToCityGMLAsTriangle
    retstring << "</gml:trianglePatches>\n"
    retstring << "</gml:TriangulatedSurface>\n"
    retstring << "</dem:tin>\n"
    retstring << "</dem:TINRelief>\n"
    retstring << "</wfs:Insert>\n"
    return retstring
  end

   def writeupdate(ent)
            retstring = ""
            retstring << "<wfs:Update typeName=\"gml:Triangle\">\n"
            retstring << "<wfs:Property>\n"
            retstring << "<wfs:Name>gml:exterior/gml:LinearRing</wfs:Name>\n"
            retstring << "<wfs:Value>\n"
            retstring << ent.writeToCityGMLOnlyPosList
            retstring << "</wfs:Value>\n"
            retstring << "</wfs:Property>\n"
            retstring << "<ogc:Filter>\n"
            retstring << "<ogc:PropertyIsEqualTo>\n"
            retstring << "<ogc:PropertyName>gml:exterior/gml:LinearRing/gml:id</ogc:PropertyName>\n"
            retstring << "<ogc:Literal>" + ent.gmlid + "</ogc:Literal>\n"
            retstring << "</ogc:PropertyIsEqualTo>\n"
            retstring << "</ogc:Filter>\n"
            retstring << "</wfs:Update>\n"
       

    return retstring
  end

   def writedelete(id)
    retstring = ""
    retstring << "<wfs:Delete typeName=\"gml:Triangle\">\n"
    retstring << "<ogc:Filter>\n"
	  retstring << "<ogc:PropertyIsEqualTo>\n"

    retstring << "<ogc:PropertyName>gml:exterior/gml:LinearRing/gml:id</ogc:PropertyName>\n"
    retstring << "<ogc:Literal>" + id + "</ogc:Literal>\n"

    retstring << "</ogc:PropertyIsEqualTo>\n"
    retstring << "</ogc:Filter>\n"
    retstring << "</wfs:Delete>\n"
    return retstring
  end

  
end
