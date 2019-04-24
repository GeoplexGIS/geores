# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_schema/geores_feature/gres_site.rb'
Sketchup::require 'sketchup.rb'

class GRES_Building < GRES_Site
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
    addstring = ""

    if(@theinternalname.index("BuildingPart") != nil)
       retstring << "<bldg:consistsOfBuildingPart>\n"
       retstring << "<bldg:BuildingPart gml:id=\"" + @gmlid + "\">\n"
    else
       retstring << "<core:cityObjectMember>\n"
       retstring << "<bldg:Building gml:id=\"" + @gmlid + "\">\n"
    end
    @simpleCityObjectAttributes.each { |att|
      puts "in Ausgabe der simplen Attribute"
      str = att.value
      if(att.value.index("xAl:") != nil)
        str = att.value.gsub("xAl:", "xAL:")
      end
      if(str.index("</gml:Point>\n<gml:pointMember>") != nil)
        str = str.gsub("</gml:Point>\n<gml:pointMember>", "</gml:Point>\n</gml:pointMember>")
        puts "Falschen String gefunden"
      end
      if(str.index("<//gml:pointMember>") != nil)
        str = str.gsub("<//gml:pointMember>", "</gml:pointMember>")
      end
      if(str.index("gen:Value") != nil)
         str = str.gsub("gen:Value", "gen:value")
      end
      if(str.index("core:MultiPoint") != nil)
         str = str.gsub("core:MultiPoint", "core:multiPoint")
      end

      if(str.index("<core:Address") != nil and str.index("<bldg:address") == nil)
        str = "<bldg:address>\n" + str + "</bldg:address>\n"

      end
      if(str.index("<bldg:address") != nil)
        addstring = str
      else
        retstring << str
      end
    }
     if(@lod1MultiSurface.length > 0)
        retstring  << "<bldg:lod1MultiSurface>\n"
        retstring << "<gml:MultiSurface>\n"
       @lod1MultiSurface.each{ |geo|
       retstring << geo.writeToCityGML
      }
       retstring << "</gml:MultiSurface>\n"
       retstring  << "</bldg:lod1MultiSurface>\n"

     end
      if(@lod2MultiSurface.length > 0)
        retstring  << "<bldg:lod2MultiSurface>\n"
        retstring << "<gml:MultiSurface>\n"
       @lod2MultiSurface.each{ |geo|
       retstring << geo.writeToCityGML
      }
       retstring << "</gml:MultiSurface>\n"
       retstring  << "</bldg:lod2MultiSurface>\n"

     end
      if(@lod3MultiSurface.length > 0)
        retstring  << "<bldg:lod3MultiSurface>\n"
        retstring << "<gml:MultiSurface>\n"
       @lod3MultiSurface.each{ |geo|
       retstring << geo.writeToCityGML
      }
       retstring << "</gml:MultiSurface>\n"
       retstring  << "</bldg:lod3MultiSurface>\n"

     end
      if(@lod4MultiSurface.length > 0)
        retstring  << "<bldg:lod4MultiSurface>\n"
        retstring << "<gml:MultiSurface>\n"
       @lod4MultiSurface.each{ |geo|
       retstring << geo.writeToCityGML
      }
       retstring << "</gml:MultiSurface>\n"
       retstring  << "</bldg:lod4MultiSurface>\n"

     end
     if(@lod1Solid.length > 0)
        retstring << "<bldg:lod1Solid>\n"
        retstring << "<gml:Solid>\n"
        retstring << "<gml:exterior>\n"
        retstring << "<gml:CompositeSurface>\n"
       @lod1Solid.each{ |geo|
       retstring << geo.writeToCityGML
      }
        retstring << "</gml:CompositeSurface>\n"
       retstring << "</gml:exterior>\n"
       retstring << "</gml:Solid>\n"
       retstring << "</bldg:lod1Solid>\n"

     end

     if(@lod2Solid.length > 0)
        retstring << "<bldg:lod2Solid>\n"
        retstring << "<gml:Solid>\n"
        retstring << "<gml:exterior>\n"
        retstring << "<gml:CompositeSurface>\n"
       @lod2Solid.each{ |geo|
       retstring << geo.writeToCityGML
      }
        retstring << "</gml:CompositeSurface>\n"
       retstring << "</gml:exterior>\n"
       retstring << "</gml:Solid>\n"
       retstring << "</bldg:lod2Solid>\n"

     end
      if(@lod3Solid.length > 0)
        retstring << "<bldg:lod3Solid>\n"
        retstring << "<gml:Solid>\n"
        retstring << "<gml:exterior>\n"
        retstring << "<gml:CompositeSurface>\n"
       @lod3Solid.each{ |geo|
       retstring << geo.writeToCityGML
      }
        retstring << "</gml:CompositeSurface>\n"
       retstring << "</gml:exterior>\n"
       retstring << "</gml:Solid>\n"
       retstring << "</bldg:lod3Solid>\n"

     end
      if(@lod4Solid.length > 0)
        retstring << "<bldg:lod4Solid>\n"
        retstring << "<gml:Solid>\n"
        retstring << "<gml:exterior>\n"
        retstring << "<gml:CompositeSurface>\n"
       @lod4Solid.each{ |geo|
       retstring << geo.writeToCityGML
      }
        retstring << "</gml:CompositeSurface>\n"
       retstring << "</gml:exterior>\n"
       retstring << "</gml:Solid>\n"
       retstring << "</bldg:lod4Solid>\n"

     end



    bpstring  = ""
    @parts.each_value {|bp|
      bpstring << bp.writeToCityGML(isWFST, "bldg:")
    }
    bistring = ""
    @installations.each_value { |bi|
      bistring << bi.writeToCityGML(isWFST, "bldg:")
    }
    bbstring = ""
  
     @boundaries.each_value { |boundary|
        bbstring << boundary.writeToCityGML(isWFST, "bldg:")
     }
     retstring << bpstring
     retstring << bbstring
     retstring << bistring
     retstring << addstring
     if(@theinternalname.index("BuildingPart") != nil)
       retstring << "</bldg:BuildingPart>\n"
       retstring << "</bldg:consistsOfBuildingPart>\n"
     else
       retstring << "</bldg:Building>\n"
       retstring << "</core:cityObjectMember>\n"
     end
    return retstring
  end

  def writeToCityGMLWFST()
    retstring = ""


    if(@theinternalname.index("BuildingPart") != nil)
       retstring << "<wfs:Update typeName=\"bldg:BuildingPart\">\n"
    else
       retstring << "<wfs:Update typeName=\"bldg:Building\">\n"
    end

    @simpleCityObjectAttributes.each { |att|
       retstring << att.value

    }
     if(@lod1MultiSurface.length > 0)
       retstring << "<wfs:Property>\n"
       retstring << "<wfs:Name>bldg:lod1MultiSurface</wfs:Name>\n"
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
       retstring << "<wfs:Name>bldg:lod2MultiSurface</wfs:Name>\n"
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
       retstring << "<wfs:Name>bldg:lod3MultiSurface</wfs:Name>\n"
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
       retstring << "<wfs:Name>bldg:lod4MultiSurface</wfs:Name>\n"
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
       retstring << "<wfs:Name>bldg:lod1Solid</wfs:Name>\n"
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
       retstring << "<wfs:Name>bldg:lod2Solid</wfs:Name>\n"
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
       retstring << "<wfs:Name>bldg:lod3Solid</wfs:Name>\n"
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
       retstring << "<wfs:Name>bldg:lod4Solid</wfs:Name>\n"
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
      bpstring << bp.writeToCityGML("true", "bldg:")
    }
    bistring = ""
    @installations.each_value { |bi|
      bistring << bi.writeToCityGML("true", "bldg:")
    }
    bbstring = ""

     @boundaries.each_value { |boundary|
        bbstring << boundary.writeToCityGML("true","bldg:")
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
