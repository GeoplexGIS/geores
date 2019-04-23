# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_schema/geores_feature/gres_site.rb'
Sketchup::require 'sketchup.rb'

class GRES_Bridge < GRES_Site
  

  def initialize
    super()
    @bridgeConstructions = Hash.new()
  end

  def addBridgeConstruction b
    @bridgeConstructions[b.theinternalname] = b
  end

  def buildToSKP(parent, entity, dictname, counter)
     super(parent, entity, dictname, counter)
     dictionary = entity.attribute_dictionary(dictname, true)
     parentname = @theinternalname
     if(parent != "")
       parentname = parent + "." + @theinternalname
     end
     @bridgeConstructions.each_value { |bridgeConst|
       bridgeConst.buildToSKP(parentname, entity, bridgeConst.theinternalname, counter)
       counter = counter +1
     }
   end

    def buildFromSKP(entity, dictname)

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
     if(@lod2MultiSurface.length > 0 or @boundaries.length > 0 or @installations.length > 0 or @bridgeConstructions.length > 0)
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
     if(@lod3MultiSurface.length > 0 or @boundaries.length > 0 or @installations.length > 0 or @bridgeConstructions.length > 0)
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
     if(@lod4MultiSurface.length > 0 or @boundaries.length > 0 or @installations.length > 0 or @bridgeConstructions.length > 0)
          lod4MultiGroup = entities.add_group
          lod4MultiGroup.name = self.theinternalname + ".lod4MultiSurface"
          buildlod4multisurfacegeometry(lod4MultiGroup, appearances, citygmlloader, parents , layer_creator.lod4layer)
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
      @bridgeConstructions.each_value { |constr|
          constr.buildlod2multisurfacegeometry(group, appearances, citygmlloader, parentnames, layer)
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
     @bridgeConstructions.each_value { |constr|
          constr.buildlod3multisurfacegeometry(group, appearances, citygmlloader, parentnames, layer)
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
      @bridgeConstructions.each_value { |constr|
          constr.buildlod4multisurfacegeometry(group, appearances, citygmlloader, parentnames,layer)
       }
      super(group, appearances, citygmlloader, parentnames, layer)
   end

    def writeToCityGML isWFST, namespace

    if(isWFST == "true")
      return writeToCityGMLWFST
    end
    retstring = ""

    if(@theinternalname.index("BridgePart") != nil)
       retstring << "<brid:consistsOfBridgePart>\n"
       retstring << "<brid:BridgePart gml:id=\"" + @gmlid + "\">\n"
    else
       retstring << "<core:cityObjectMember>\n"
       retstring << "<brid:Bridge gml:id=\"" + @gmlid + "\">\n"
    end
    @simpleCityObjectAttributes.each { |att|

      retstring << att.value
    }
     if(@lod1MultiSurface.length > 0)
        retstring  << "<brid:lod1MultiSurface>\n"
        retstring << "<gml:MultiSurface>\n"
       @lod1MultiSurface.each{ |geo|
       retstring << geo.writeToCityGML
      }
       retstring << "</gml:MultiSurface>\n"
       retstring  << "</brid:lod1MultiSurface>\n"

     end
      if(@lod2MultiSurface.length > 0)
        retstring  << "<brid:lod2MultiSurface>\n"
        retstring << "<gml:MultiSurface>\n"
       @lod2MultiSurface.each{ |geo|
       retstring << geo.writeToCityGML
      }
       retstring << "</gml:MultiSurface>\n"
       retstring  << "</brid:lod2MultiSurface>\n"

     end
      if(@lod3MultiSurface.length > 0)
        retstring  << "<brid:lod3MultiSurface>\n"
        retstring << "<gml:MultiSurface>\n"
       @lod3MultiSurface.each{ |geo|
       retstring << geo.writeToCityGML
      }
       retstring << "</gml:MultiSurface>\n"
       retstring  << "</brid:lod3MultiSurface>\n"

     end
      if(@lod4MultiSurface.length > 0)
        retstring  << "<brid:lod4MultiSurface>\n"
        retstring << "<gml:MultiSurface>\n"
       @lod4MultiSurface.each{ |geo|
       retstring << geo.writeToCityGML
      }
       retstring << "</gml:MultiSurface>\n"
       retstring  << "</brid:lod4MultiSurface>\n"

     end
     if(@lod1Solid.length > 0)
        retstring << "<brid:lod1Solid>\n"
        retstring << "<gml:Solid>\n"
        retstring << "<gml:exterior>\n"
        retstring << "<gml:CompositeSurface>\n"
       @lod1Solid.each{ |geo|
       retstring << geo.writeToCityGML
      }
        retstring << "</gml:CompositeSurface>\n"
       retstring << "</gml:exterior>\n"
       retstring << "</gml:Solid>\n"
       retstring << "</brid:lod1Solid>\n"

     end

     if(@lod2Solid.length > 0)
        retstring << "<brid:lod2Solid>\n"
        retstring << "<gml:Solid>\n"
        retstring << "<gml:exterior>\n"
        retstring << "<gml:CompositeSurface>\n"
       @lod2Solid.each{ |geo|
       retstring << geo.writeToCityGML
      }
        retstring << "</gml:CompositeSurface>\n"
       retstring << "</gml:exterior>\n"
       retstring << "</gml:Solid>\n"
       retstring << "</brid:lod2Solid>\n"

     end
      if(@lod3Solid.length > 0)
        retstring << "<brid:lod3Solid>\n"
        retstring << "<gml:Solid>\n"
        retstring << "<gml:exterior>\n"
        retstring << "<gml:CompositeSurface>\n"
       @lod3Solid.each{ |geo|
       retstring << geo.writeToCityGML
      }
        retstring << "</gml:CompositeSurface>\n"
       retstring << "</gml:exterior>\n"
       retstring << "</gml:Solid>\n"
       retstring << "</brid:lod3Solid>\n"

     end
      if(@lod4Solid.length > 0)
        retstring << "<brid:lod4Solid>\n"
        retstring << "<gml:Solid>\n"
        retstring << "<gml:exterior>\n"
        retstring << "<gml:CompositeSurface>\n"
       @lod4Solid.each{ |geo|
       retstring << geo.writeToCityGML
      }
        retstring << "</gml:CompositeSurface>\n"
       retstring << "</gml:exterior>\n"
       retstring << "</gml:Solid>\n"
       retstring << "</brid:lod4Solid>\n"

     end



    bpstring  = ""
    @parts.each_value {|bp|
      bpstring << bp.writeToCityGML(isWFST, "brid:")
    }
    bistring = ""
    @installations.each_value { |bi|
      bistring << bi.writeToCityGML(isWFST, "brid:")
    }
    @bridgeConstructions.each_value { |bi|
      bistring << bi.writeToCityGML(isWFST, "brid:")
    }
    bbstring = ""

     @boundaries.each_value { |boundary|
        bbstring << boundary.writeToCityGML(isWFST, "brid:")
     }
     retstring << bpstring
     retstring << bbstring
     retstring << bistring
     if(@theinternalname.index("BridgePart") != nil)
       retstring << "</brid:BridgePart>\n"
       retstring << "</brid:consistsOfBridgePart>\n"
     else
       retstring << "</brid:Bridge>\n"
       retstring << "</core:cityObjectMember>\n"
     end
    return retstring
  end

  def writeToCityGMLWFST()
    retstring = ""


    if(@theinternalname.index("BridgePart") != nil)
       retstring << "<wfs:Update typeName=\"brid:BridgePart\">\n"
    else
       retstring << "<wfs:Update typeName=\"brid:Bridge\">\n"
    end
    @simpleCityObjectAttributes.each { |att|
       retstring << att.value

    }
     if(@lod1MultiSurface.length > 0)
       retstring << "<wfs:Property>\n"
       retstring << "<wfs:Name>brid:lod1MultiSurface</wfs:Name>\n"
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
       retstring << "<wfs:Name>brid:lod2MultiSurface</wfs:Name>\n"
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
       retstring << "<wfs:Name>brid:lod3MultiSurface</wfs:Name>\n"
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
       retstring << "<wfs:Name>brid:lod4MultiSurface</wfs:Name>\n"
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
       retstring << "<wfs:Name>brid:lod1Solid</wfs:Name>\n"
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
       retstring << "<wfs:Name>brid:lod2Solid</wfs:Name>\n"
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
       retstring << "<wfs:Name>brid:lod3Solid</wfs:Name>\n"
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
       retstring << "<wfs:Name>brid:lod4Solid</wfs:Name>\n"
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
      bpstring << bp.writeToCityGML("true", "brid:")
    }
    bistring = ""
    @installations.each_value { |bi|
      bistring << bi.writeToCityGML("true", "brid:")
    }
    @bridgeConstructions.each_value { |bi|
      bistring << bi.writeToCityGML("true", "brid:")
    }
    bbstring = ""

     @boundaries.each_value { |boundary|
        bbstring << boundary.writeToCityGML("true","brid:")
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

    attr_reader :bridgeConstructions

end
