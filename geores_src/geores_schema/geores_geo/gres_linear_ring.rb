# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_schema/geores_geo/gres_point.rb'

class GRES_LinearRing
  
  def initialize
    @gmlid = ""
  @points = Array.new()
  @pToExport = Array.new()
  end

  def setgmlid g
    @gmlid = g
  end

  def addPoint p
    @points.push(p)
  end

  def addPointToExport x,y,z
    @pToExport.push(GRES_Point.new(x,y,z))
  end

  def writeToCityGML

     retString = "<gml:LinearRing gml:id=\"" + @gmlid + "\">\n"
     retString << "<gml:posList srsDimension=\"3\">"
     counter = 0
     lastString = ""
     @pToExport.each { |p|
       if(counter == 0)
         lastString << " " + p.x.to_s + " " + p.y.to_s + " " + p.z.to_s
       end
       retString << " " + p.x.to_s + " " + p.y.to_s + " " + p.z.to_s
       counter = counter + 1
     }
     retString << lastString
    retString <<  "</gml:posList>\n"
    retString << "</gml:LinearRing>\n"

     return retString
  end

  def writeOnlyPointList
    retString = ""
     counter = 0
     lastString = ""
    @pToExport.each { |p|
      if(counter == 0)
         lastString << " " + p.x.to_s + " " + p.y.to_s + " " + p.z.to_s
       end
       retString << " " + p.x.to_s + " " + p.y.to_s + " " + p.z.to_s
       counter = counter + 1
     }
     retString << lastString
    return retString
  end

  attr_reader :points, :gmlid, :pToExport
end
