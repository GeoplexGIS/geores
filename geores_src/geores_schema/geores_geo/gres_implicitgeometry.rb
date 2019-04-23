# To change this template, choose Tools | Templates
# and open the template in the editor.

class GRES_ImplicitGeometry
  

  def initialize
    @geometries = Array.new()
    @isreferenceobject = true
    @xlink = ""
    @parent = ""
    @compInst = nil
    @gmlid = ""
  end

  def setxlink xlink
    @xlink = xlink
    @isreferenceobject = false
  end

  def settransformation trafo
    @trafo = trafo
  end

  def settransformationpoint point
    @trafopoint = point
  end

  def addGeometries g
    @geometries.concat(g)
  end

  def setcompinstance inst
    @compInst = inst
  end

  def setid id
    @gmlid = id
  end

  def setparent p
    @parent = p
  end

  def addGeometry g
    @geometries.push(g)
  end

  def writeToCityGML
    retstring = ""
    retstring << "<core:ImplicitGeometry>\n"

    array = @trafo.to_a
    retstring << "<core:transformationMatrix>\n"
    retstring << array[0].to_s + " " + array[4].to_s + " " + array[8].to_s + " " + array[12].to_s + "\n"
    retstring << array[1].to_s + " " + array[5].to_s + " " + array[9].to_s + " " + array[13].to_s + "\n"
    retstring << array[2].to_s + " " + array[6].to_s + " " + array[10].to_s + " " + array[14].to_s + "\n"
    retstring << array[3].to_s + " " + array[7].to_s + " " + array[11].to_s + " " + array[15].to_s + "\n"
    retstring << "</core:transformationMatrix>\n"


  if(@isreferenceobject)
    retstring << "<core:relativeGMLGeometry>\n"
    retstring << "<gml:MultiSurface gml:id=\"" + @gmlid + "\">\n"
    @geometries.each { |surf|
    
        retstring << surf.writeToCityGML
    }
     retstring << "</gml:MultiSurface>\n"
    retstring << "</core:relativeGMLGeometry>\n"


  else
    retstring << "<core:relativeGMLGeometry xlink:href=\"#" + @xlink + "\"/>\n"
  end
  retstring << "<core:referencePoint>\n"
  retstring << "<gml:Point>"
  retstring << "<gml:pos srsDimension=\"3\">" + @trafopoint.x.to_f.to_s + " " + @trafopoint.y.to_f.to_s + " " + @trafopoint.z.to_f.to_s

  retstring << "</gml:pos>\n"
  retstring << "</gml:Point>"
  retstring << "</core:referencePoint>\n"
   retstring << "</core:ImplicitGeometry>\n"
   return retstring

  end

  attr_reader :xlink, :trafo, :trafopoint, :geometries, :isreferenceobject, :compInst, :gmlid, :parent
end
