# To change this template, choose Tools | Templates
# and open the template in the editor.

class GRES_GeometryCollection

  
 

  attr_reader :geometries, :gmlid

  def initialize
    @gmlid = ""
    @geometries = Array.new()
  end

 def setgmlid g
    @gmlid = g
  end

 def addGeometries geos
   @geometries.concat(geos)
 end


  def writeToCityGML

  end


end
