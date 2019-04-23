# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_schema/geores_feature/gres_cityobject.rb'

class GRES_Installation < GRES_CityObject



  def initialize
    super()
      @boundaries = Hash.new()
      @implicitgeometries = Array.new()
  end

  def addBoundary b
    @boundaries[b.theinternalname] = b
  end

  def addImplicitGeometry i
    @implicitgeometries.push(i)
  end

   def buildToSKP(parent, entity, dictname, counter)
     super(parent, entity, dictname, counter)
     dictionary = entity.attribute_dictionary(dictname, true)
     @boundaries.each_value { |boundary|
       boundary.buildToSKP(parent + "." + @theinternalname, entity, boundary.theinternalname, counter)
       counter = counter +1
     }
     dictionary["parent"] = parent
   end

   def buildlod2multisurfacegeometry group, appearances, citygmlloader, parentnames, layer

    layer_creator = citygmlloader.layercreator
    groupToAdd = group.entities.add_group
     parents = Array.new()
       if(parentnames != nil)
         parents.concat(parentnames)
       end
       parents.push(@theinternalname)
    @boundaries.each_value { |boundary|
      boundaryLayer = layer_creator.getboundarylayerforname(boundary.type)
      boundary.buildlod2multisurfacegeometry(groupToAdd, appearances, citygmlloader, parents,boundaryLayer)
    }

    super(groupToAdd, appearances, citygmlloader, parents, layer)
   end



    def buildlod3multisurfacegeometry group, appearances, citygmlloader, parentnames, layer
      layer_creator = citygmlloader.layercreator
      groupToAdd = group.entities.add_group
       parents = Array.new()
       if(parentnames != nil)
         parents.concat(parentnames)
       end
       parents.push(@theinternalname)

      @boundaries.each_value { |boundary|
        boundaryLayer = layer_creator.getboundarylayerforname(boundary.type)
        boundary.buildlod3multisurfacegeometry(groupToAdd, appearances, citygmlloader, parents,boundaryLayer)
      }

      super(groupToAdd, appearances, citygmlloader, parents, layer)

   end


    def buildlod4multisurfacegeometry group, appearances, citygmlloader, parentnames, layer
       layer_creator = citygmlloader.layercreator
       groupToAdd = group.entities.add_group
        parents = Array.new()
       if(parentnames != nil)
         parents.concat(parentnames)
       end
       parents.push(@theinternalname)
      @boundaries.each_value { |boundary|
        boundaryLayer = layer_creator.getboundarylayerforname(boundary.type)
        boundary.buildlod4multisurfacegeometry(groupToAdd, appearances, citygmlloader, parents,boundaryLayer)
      }
 
      super(groupToAdd, appearances, citygmlloader, parents, layer)
   end

    def writeToCityGML isWFST, namespace

        if(isWFST == "true")
            return writeToCityGMLWFST(namespace)
        end

    
    retstring = ""
    lastString = ""
    if(@theinternalname.index("BuildingInstallation") != nil)
      retstring << "<" + namespace + "outerBuildingInstallation>\n"
      retstring << "<bldg:BuildingInstallation " + "gml:id=\"" + @gmlid + "\">\n"
      lastString << "</bldg:BuildingInstallation>\n"
      lastString << "</" + namespace + "outerBuildingInstallation>\n"
    elsif(@theinternalname.index("BridgeInstallation") != nil)
         retstring << "<" + namespace + "outerBridgeInstallation>\n"
         retstring << "<brid:BridgeInstallation " + "gml:id=\"" + @gmlid + "\">\n"
         lastString << "</brid:BridgeInstallation>\n"
         lastString << "</" + namespace + "outerBridgeInstallation>\n"
    elsif(@theinternalname.index("TunnelInstallation") != nil)
         retstring << "<" + namespace + "outerTunnelInstallation>\n"
         retstring << "<tun:TunnelInstallation " + "gml:id=\"" + @gmlid + "\">\n"
         lastString << "</tun:TunnelInstallation>\n"
         lastString << "</" + namespace + "outerTunnelInstallation>\n"
     elsif(@theinternalname.index("BridgeConstructionElement") != nil)
         retstring << "<" + namespace + "outerBridgeConstruction>\n"
         retstring << "<brid:BridgeConstructionElement " + "gml:id=\"" + @gmlid + "\">\n"
         lastString << "</brid:BridgeConstructionElement>\n"
         lastString << "</" + namespace + "outerBridgeConstruction>\n"
    else
      #not implemented!?
      return
    end

    @simpleCityObjectAttributes.each { |att|

      retstring << att.value
    }

      if(@lod2MultiSurface.length > 0)
        retstring  << "<" + namespace + "lod2Geometry>\n"
        retstring << "<gml:MultiSurface>\n"
       @lod2MultiSurface.each{ |geo|
       retstring << geo.writeToCityGML
      }
       retstring << "</gml:MultiSurface>\n"
       retstring  << "</"+ namespace + "lod2Geometry>\n"

     end
      if(@lod3MultiSurface.length > 0)
       retstring  << "<" + namespace + "lod3Geometry>\n"
       retstring << "<gml:MultiSurface>\n"
       @lod3MultiSurface.each{ |geo|
       retstring << geo.writeToCityGML
      }
       retstring << "</gml:MultiSurface>\n"
       retstring  << "</"+ namespace + "lod3Geometry>\n"

     end
      if(@lod4MultiSurface.length > 0)
       retstring  << "<" + namespace + "lod4Geometry>\n"
       retstring << "<gml:MultiSurface>\n"
       @lod4MultiSurface.each{ |geo|
       retstring << geo.writeToCityGML
      }
       retstring << "</gml:MultiSurface>\n"
       retstring  << "</"+ namespace + "lod4Geometry>\n"

     end


    bbstring = ""

     @boundaries.each_value { |boundary|
        bbstring << boundary.writeToCityGML(isWFST, namespace)
     }
     retstring << bbstring

     retstring << lastString
    return retstring
  end



    def writeToCityGMLWFST namespace
     retstring = ""
     lastString = ""
     retstring << "<wfs:Property>\n"

    if(@theinternalname.index("BuildingInstallation") != nil)
      retstring << "<wfs:Name>" + namespace + "outerBuildingInstallation</wfs:Name>\n"
      retstring << "<wfs:Value>\n"
      retstring << "<bldg:BuildingInstallation" + " gml:id=\"" + @gmlid + "\">\n"
      lastString << "</bldg:BuildingInstallation>\n"
      lastString << "</wfs:Value>\n"
      lastString << "</wfs:Property>\n"
    elsif(@theinternalname.index("BridgeInstallation") != nil)
      retstring << "<wfs:Name>" + namespace + "outerBridgeInstallation</wfs:Name>\n"
      retstring << "<wfs:Value>\n"
      retstring << "<brid:BridgeInstallation" + " gml:id=\"" + @gmlid + "\">\n"
      lastString << "</brid:BridgeInstallation>\n"
      lastString << "</wfs:Value>\n"
      lastString << "</wfs:Property>\n"
    elsif(@theinternalname.index("TunnelInstallation") != nil)
       retstring << "<wfs:Name>" + namespace + "outerTunnelInstallation</wfs:Name>\n"
      retstring << "<wfs:Value>\n"
      retstring << "<tun:TunnelInstallation" + " gml:id=\"" + @gmlid + "\">\n"
      lastString << "</tun:TunnelInstallation>\n"
      lastString << "</wfs:Value>\n"
      lastString << "</wfs:Property>\n"
     elsif(@theinternalname.index("BridgeConstructionElement") != nil)
      retstring << "<wfs:Name>" + namespace + "outerBridgeConstruction</wfs:Name>\n"
      retstring << "<wfs:Value>\n"
      retstring << "<brid:BridgeConstructionElement" + " gml:id=\"" + @gmlid + "\">\n"
      lastString << "</brid:BridgeConstructionElement>\n"
      lastString << "</wfs:Value>\n"
      lastString << "</wfs:Property>\n"
    end

    @simpleCityObjectAttributes.each { |att|

      retstring << att.value
    }

      if(@lod2MultiSurface.length > 0)
        retstring  << "<" + namespace + "lod2Geometry>\n"
        retstring << "<gml:MultiSurface>\n"
       @lod2MultiSurface.each{ |geo|
       retstring << geo.writeToCityGML
      }
       retstring << "</gml:MultiSurface>\n"
       retstring  << "</"+ namespace + "lod2Geometry>\n"

     end
      if(@lod3MultiSurface.length > 0)
       retstring  << "<" + namespace + "lod3Geometry>\n"
       retstring << "<gml:MultiSurface>\n"
       @lod3MultiSurface.each{ |geo|
       retstring << geo.writeToCityGML
      }
       retstring << "</gml:MultiSurface>\n"
       retstring  << "</"+ namespace + "lod3Geometry>\n"

     end
      if(@lod4MultiSurface.length > 0)
       retstring  << "<" + namespace + "lod4Geometry>\n"
       retstring << "<gml:MultiSurface>\n"
       @lod4MultiSurface.each{ |geo|
       retstring << geo.writeToCityGML
      }
       retstring << "</gml:MultiSurface>\n"
       retstring  << "</"+ namespace + "lod4Geometry>\n"

     end


    bbstring = ""

     @boundaries.each_value { |boundary|
       #muss false sein, da sonst wfs.Property geschrieben wird
        bbstring << boundary.writeToCityGML("false" ,namespace)
     }
     retstring << bbstring

     retstring << lastString
    return retstring
    end

attr_reader :boundaries

end
