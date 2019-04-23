# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_schema/geores_feature/gres_site.rb'
Sketchup::require 'sketchup.rb'

class GRES_Tunnel < GRES_Site
  def initialize
    super()
  end

   def buildgeometries(entities, appearances, citygmlloader, parentnames)
     super(entities, appearances, citygmlloader, parentnames)
      parents = Array.new()
       if(parentnames != nil)
         parents.concat(parentnames)
       end
       parents.push(@theinternalname)
     lod2SolidGroup = nil
     lod2MultiGroup = nil
     lod3SolidGroup = nil
     lod3MultiGroup = nil
     lod4SolidGroup = nil
     lod4MultiGroup = nil
      layer_creator = citygmlloader.layercreator
     if(@lod2Solid.length > 0)
          lod2SolidGroup = entities.add_group
          lod2SolidGroup.name = self.theinternalname + ".lod2Solid"
          buildlod2solidgeometry(lod2SolidGroup, appearances, citygmlloader, parents, layer_creator.lod2layer)
          transform = Geom::Transformation.scaling 39.370078740157477
          lod2SolidGroup.transformation = transform
     end
     if(@lod2MultiSurface.length > 0 or @boundaries.length > 0 or @installations.length > 0)
          lod2MultiGroup = entities.add_group
          lod2MultiGroup.name = self.theinternalname + ".lod2MultiSurface"
          buildlod2multisurfacegeometry(lod2MultiGroup, appearances, citygmlloader, parents, layer_creator.lod2layer)
          transform = Geom::Transformation.scaling 39.370078740157477
          lod2MultiGroup.transformation = transform
     end
     if(@lod3Solid.length > 0)
          lod3SolidGroup = entities.add_group
          lod3SolidGroup.name = self.theinternalname + ".lod3Solid"
          buildlod3solidgeometry(lod3SolidGroup, appearances, citygmlloader, parents, layer_creator.lod3layer)
          transform = Geom::Transformation.scaling 39.370078740157477
          lod3SolidGroup.transformation = transform
     end
     if(@lod3MultiSurface.length > 0 or @boundaries.length > 0 or @installations.length > 0)
          lod3MultiGroup = entities.add_group
          lod3MultiGroup.name = self.theinternalname + ".lod3MultiSurface"
          buildlod3multisurfacegeometry(lod3MultiGroup, appearances, citygmlloader, parents, layer_creator.lod3layer)
          transform = Geom::Transformation.scaling 39.370078740157477
          lod3MultiGroup.transformation = transform
     end
      if(@lod4Solid.length > 0)
          lod4SolidGroup = entities.add_group
          lod4SolidGroup.name = self.theinternalname + ".lod4Solid"
          buildlod4solidgeometry(lod4SolidGroup, appearances, citygmlloader, parents, layer_creator.lod4layer)
          transform = Geom::Transformation.scaling 39.370078740157477
          lod4SolidGroup.transformation = transform
     end
     if(@lod4MultiSurface.length > 0 or @boundaries.length > 0 or @installations.length > 0)
          lod4MultiGroup = entities.add_group
          lod4MultiGroup.name = self.theinternalname + ".lod4MultiSurface"
          buildlod4multisurfacegeometry(lod4MultiGroup, appearances, citygmlloader, parents, layer_creator.lod4layer)
          transform = Geom::Transformation.scaling 39.370078740157477
          lod4MultiGroup.transformation = transform
     end

    end


  def buildlod2multisurfacegeometry group, appearances, citygmlloader, parentnames, layer

    layer_creator = citygmlloader.layercreator
    @boundaries.each_value { |boundary|
      boundaryLayer = layer_creator.getboundarylayerforname(boundary.type)
      boundary.buildlod2multisurfacegeometry(group, appearances, citygmlloader, parentnames,boundaryLayer)
    }
     @installations.each_value { |installation|
            installation.buildlod2multisurfacegeometry(group, appearances, citygmlloader, parentnames, layer)
     }

    super(group, appearances, citygmlloader, parentnames, layer)
   end



    def buildlod3multisurfacegeometry group, appearances, citygmlloader, parentnames, layer
      layer_creator = citygmlloader.layercreator

      @boundaries.each_value { |boundary|
        boundaryLayer = layer_creator.getboundarylayerforname(boundary.type)
        boundary.buildlod3multisurfacegeometry(group, appearances, citygmlloader, parentnames,boundaryLayer)
      }
     @installations.each_value { |installation|
            installation.buildlod3multisurfacegeometry(group, appearances, citygmlloader, parentnames, layer)
     }

      super(group, appearances, citygmlloader, parentnames, layer)

   end


    def buildlod4multisurfacegeometry group, appearances, citygmlloader, parentnames, layer
       layer_creator = citygmlloader.layercreator
      @boundaries.each_value { |boundary|
        boundaryLayer = layer_creator.getboundarylayerforname(boundary.type)
        boundary.buildlod4multisurfacegeometry(group, appearances, citygmlloader, parentnames,boundaryLayer)
      }
     @installations.each_value { |installation|
            installation.buildlod4multisurfacegeometry(group, appearances, citygmlloader, parentnames,layer)
     }

      super(group, appearances, citygmlloader, parentnames, layer)
   end

     def writeToCityGML isWFST, namespace

    if(isWFST == "true")
      return writeToCityGMLWFST
    end
    retstring = ""

    if(@theinternalname.index("TunnelPart") != nil)
       retstring << "<tun:consistsOfTunnelPart>\n"
       retstring << "<tun:TunnelPart gml:id=\"" + @gmlid + "\">\n"
    else
       retstring << "<core:cityObjectMember>\n"
       retstring << "<tun:Tunnel gml:id=\"" + @gmlid + "\">\n"
    end
    @simpleCityObjectAttributes.each { |att|

      retstring << att.value
    }
     if(@lod1MultiSurface.length > 0)
        retstring  << "<tun:lod1MultiSurface>\n"
        retstring << "<gml:MultiSurface>\n"
       @lod1MultiSurface.each{ |geo|
       retstring << geo.writeToCityGML
      }
       retstring << "</gml:MultiSurface>\n"
       retstring  << "</tun:lod1MultiSurface>\n"

     end
      if(@lod2MultiSurface.length > 0)
        retstring  << "<tun:lod2MultiSurface>\n"
        retstring << "<gml:MultiSurface>\n"
       @lod2MultiSurface.each{ |geo|
       retstring << geo.writeToCityGML
      }
       retstring << "</gml:MultiSurface>\n"
       retstring  << "</tun:lod2MultiSurface>\n"

     end
      if(@lod3MultiSurface.length > 0)
        retstring  << "<tun:lod3MultiSurface>\n"
        retstring << "<gml:MultiSurface>\n"
       @lod3MultiSurface.each{ |geo|
       retstring << geo.writeToCityGML
      }
       retstring << "</gml:MultiSurface>\n"
       retstring  << "</tun:lod3MultiSurface>\n"

     end
      if(@lod4MultiSurface.length > 0)
        retstring  << "<tun:lod4MultiSurface>\n"
        retstring << "<gml:MultiSurface>\n"
       @lod4MultiSurface.each{ |geo|
       retstring << geo.writeToCityGML
      }
       retstring << "</gml:MultiSurface>\n"
       retstring  << "</tun:lod4MultiSurface>\n"

     end
     if(@lod1Solid.length > 0)
        retstring << "<tun:lod1Solid>\n"
        retstring << "<gml:Solid>\n"
        retstring << "<gml:exterior>\n"
        retstring << "<gml:CompositeSurface>\n"
       @lod1Solid.each{ |geo|
       retstring << geo.writeToCityGML
      }
        retstring << "</gml:CompositeSurface>\n"
       retstring << "</gml:exterior>\n"
       retstring << "</gml:Solid>\n"
       retstring << "</tun:lod1Solid>\n"

     end

     if(@lod2Solid.length > 0)
        retstring << "<tun:lod2Solid>\n"
        retstring << "<gml:Solid>\n"
        retstring << "<gml:exterior>\n"
        retstring << "<gml:CompositeSurface>\n"
       @lod2Solid.each{ |geo|
       retstring << geo.writeToCityGML
      }
        retstring << "</gml:CompositeSurface>\n"
       retstring << "</gml:exterior>\n"
       retstring << "</gml:Solid>\n"
       retstring << "</tun:lod2Solid>\n"

     end
      if(@lod3Solid.length > 0)
        retstring << "<tun:lod3Solid>\n"
        retstring << "<gml:Solid>\n"
        retstring << "<gml:exterior>\n"
        retstring << "<gml:CompositeSurface>\n"
       @lod3Solid.each{ |geo|
       retstring << geo.writeToCityGML
      }
        retstring << "</gml:CompositeSurface>\n"
       retstring << "</gml:exterior>\n"
       retstring << "</gml:Solid>\n"
       retstring << "</tun:lod3Solid>\n"

     end
      if(@lod4Solid.length > 0)
        retstring << "<tun:lod4Solid>\n"
        retstring << "<gml:Solid>\n"
        retstring << "<gml:exterior>\n"
        retstring << "<gml:CompositeSurface>\n"
       @lod4Solid.each{ |geo|
       retstring << geo.writeToCityGML
      }
        retstring << "</gml:CompositeSurface>\n"
       retstring << "</gml:exterior>\n"
       retstring << "</gml:Solid>\n"
       retstring << "</tun:lod4Solid>\n"

     end



    bpstring  = ""
    @parts.each_value {|bp|
      bpstring << bp.writeToCityGML(isWFST, "tun:")
    }
    bistring = ""
    @installations.each_value { |bi|
      bistring << bi.writeToCityGML(isWFST, "tun:")
    }
    bbstring = ""

     @boundaries.each_value { |boundary|
        bbstring << boundary.writeToCityGML(isWFST, "tun:")
     }
     retstring << bpstring
     retstring << bbstring
     retstring << bistring
     if(@theinternalname.index("TunnelPart") != nil)
       retstring << "</tun:TunnelPart>\n"
       retstring << "</tun:consistsOfTunnelPart>\n"
     else
       retstring << "</tun:Tunnel>\n"
       retstring << "</core:cityObjectMember>\n"
     end
    return retstring
  end

  def writeToCityGMLWFST()
    retstring = ""


    if(@theinternalname.index("TunnelPart") != nil)
       retstring << "<wfs:Update typeName=\"tun:TunnelPart\">\n"
    else
       retstring << "<wfs:Update typeName=\"tun:Tunnel\">\n"
    end
    @simpleCityObjectAttributes.each { |att|
       retstring << att.value

    }
     if(@lod1MultiSurface.length > 0)
       retstring << "<wfs:Property>\n"
       retstring << "<wfs:Name>tun:lod1MultiSurface</wfs:Name>\n"
       retstring << "<wfs:Value>\n"
       retstring << "<gml:MultiSurface>\n"
        @lod1MultiSurface.each{ |geo|
              retstring << geo.writeToCityGML
        }

        retstring << "</gml:MultiSurface>\n"
        retstring << "</wfs:Value>\n"
        retstring << "</wfs:Property>\n"

     end
      if(@lod2MultiSurface.length > 0)
       retstring << "<wfs:Property>\n"
       retstring << "<wfs:Name>tun:lod2MultiSurface</wfs:Name>\n"
       retstring << "<wfs:Value>\n"
       retstring << "<gml:MultiSurface>\n"
        @lod2MultiSurface.each{ |geo|
              retstring << geo.writeToCityGML
        }

        retstring << "</gml:MultiSurface>\n"
        retstring << "</wfs:Value>\n"
        retstring << "</wfs:Property>\n"

     end
      if(@lod3MultiSurface.length > 0)
       retstring << "<wfs:Property>\n"
       retstring << "<wfs:Name>tun:lod3MultiSurface</wfs:Name>\n"
       retstring << "<wfs:Value>\n"
       retstring << "<gml:MultiSurface>\n"
        @lod3MultiSurface.each{ |geo|
              retstring << geo.writeToCityGML
        }

        retstring << "</gml:MultiSurface>\n"
        retstring << "</wfs:Value>\n"
        retstring << "</wfs:Property>\n"

     end
      if(@lod4MultiSurface.length > 0)
        retstring << "<wfs:Property>\n"
       retstring << "<wfs:Name>tun:lod4MultiSurface</wfs:Name>\n"
       retstring << "<wfs:Value>\n"
       retstring << "<gml:MultiSurface>\n"
        @lod4MultiSurface.each{ |geo|
              retstring << geo.writeToCityGML
        }

        retstring << "</gml:MultiSurface>\n"
        retstring << "</wfs:Value>\n"
        retstring << "</wfs:Property>\n"

     end
     if(@lod1Solid.length > 0)
        retstring << "<wfs:Property>\n"
       retstring << "<wfs:Name>tun:lod1Solid</wfs:Name>\n"
       retstring << "<wfs:Value>\n"
       retstring << "<gml:Solid>\n"
        retstring << "<gml:exterior>\n"
        retstring << "<gml:CompositeSurface>\n"
        @lod1Solid.each{ |geo|
              retstring << geo.writeToCityGML
        }

       retstring << "</gml:CompositeSurface>\n"
       retstring << "</gml:exterior>\n"
       retstring << "</gml:Solid>\n"
        retstring << "</wfs:Value>\n"
        retstring << "</wfs:Property>\n"

     end

     if(@lod2Solid.length > 0)
        retstring << "<wfs:Property>\n"
       retstring << "<wfs:Name>tun:lod2Solid</wfs:Name>\n"
       retstring << "<wfs:Value>\n"
       retstring << "<gml:Solid>\n"
        retstring << "<gml:exterior>\n"
        retstring << "<gml:CompositeSurface>\n"
        @lod2Solid.each{ |geo|
              retstring << geo.writeToCityGML
        }

       retstring << "</gml:CompositeSurface>\n"
       retstring << "</gml:exterior>\n"
       retstring << "</gml:Solid>\n"
        retstring << "</wfs:Value>\n"
        retstring << "</wfs:Property>\n"

     end
      if(@lod3Solid.length > 0)
         retstring << "<wfs:Property>\n"
       retstring << "<wfs:Name>tun:lod3Solid</wfs:Name>\n"
       retstring << "<wfs:Value>\n"
       retstring << "<gml:Solid>\n"
        retstring << "<gml:exterior>\n"
        retstring << "<gml:CompositeSurface>\n"
        @lod3Solid.each{ |geo|
              retstring << geo.writeToCityGML
        }

       retstring << "</gml:CompositeSurface>\n"
       retstring << "</gml:exterior>\n"
       retstring << "</gml:Solid>\n"
        retstring << "</wfs:Value>\n"
        retstring << "</wfs:Property>\n"

     end
      if(@lod4Solid.length > 0)
       retstring << "<wfs:Property>\n"
       retstring << "<wfs:Name>tun:lod4Solid</wfs:Name>\n"
       retstring << "<wfs:Value>\n"
       retstring << "<gml:Solid>\n"
        retstring << "<gml:exterior>\n"
        retstring << "<gml:CompositeSurface>\n"
        @lod4Solid.each{ |geo|
              retstring << geo.writeToCityGML
        }

       retstring << "</gml:CompositeSurface>\n"
       retstring << "</gml:exterior>\n"
       retstring << "</gml:Solid>\n"
        retstring << "</wfs:Value>\n"
        retstring << "</wfs:Property>\n"

     end

    bpstring  = ""
    @parts.each_value {|bp|
      bpstring << bp.writeToCityGML("true", "tun:")
    }
    bistring = ""
    @installations.each_value { |bi|
      bistring << bi.writeToCityGML("true", "tun:")
    }
    bbstring = ""

     @boundaries.each_value { |boundary|
        bbstring << boundary.writeToCityGML("true","tun:")
     }

     retstring << bbstring
     retstring << bistring

       retstring << "<ogc:Filter>\n"
       retstring << "<ogc:Or>\n"
	     retstring << "<ogc:PropertyIsEqualTo>\n"

       retstring << "<ogc:PropertyName>gml:id</ogc:PropertyName>\n"
      retstring << "<ogc:Literal>" + @gmlid + "</ogc:Literal>\n"


       retstring << "</ogc:PropertyIsEqualTo>\n"
       retstring << "<ogc:PropertyIsEqualTo>\n"
       retstring << "<ogc:PropertyName>core:_GenericApplicationPropertyOfCityObject/gen:stringAttribute/gen:value</ogc:PropertyName>\n"
       retstring << "<ogc:Literal>" + @gmlid + "</ogc:Literal>\n"
       retstring << "</ogc:PropertyIsEqualTo>\n"
       retstring << "</ogc:Or>\n"
       retstring << "</ogc:Filter>\n"
       retstring << "</wfs:Update>\n"
       retstring << bpstring



        return retstring
  end
end
