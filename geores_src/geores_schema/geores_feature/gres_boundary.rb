# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_schema/geores_feature/gres_cityobject.rb'

class GRES_Boundary < GRES_CityObject
 

  def initialize
    super()
     @type = ""
     @openings = Hash.new()
  end

  def setboundarytype t
    @type = t
  end

  def addOpening o
    @openings[o.theinternalname] = o
  end

  attr_reader :type
  
   def buildToSKP(parent, entity, dictname, counter)
     puts "in buildToSKP Boundary"
     super(parent, entity, dictname, counter)
     dictionary = entity.attribute_dictionary(dictname, true)
     @openings.each_value{ |opening|
       dname = "Opening" + counter.to_s
       opening.buildToSKP(parent + "." + @theinternalname, entity, opening.theinternalname, counter)
       counter = counter +1
     }
     dictionary["type"] = @type
     dictionary["parent"] = parent

   end

   def buildFromSKP(entity, dictname)

   end
   
    def buildlod2multisurfacegeometry group, appearances, citygmlloader, parentnames, layer
      parents = Array.new()
       if(parentnames != nil)
         parents.concat(parentnames)
       end
       parents.push(@theinternalname)
      super(group, appearances, citygmlloader, parents, layer)


   end



    def buildlod3multisurfacegeometry group, appearances, citygmlloader, parentnames, layer

      parents = Array.new()
       if(parentnames != nil)
         parents.concat(parentnames)
       end
       parents.push(@theinternalname)
      
     @openings.each_value { |opening|
        op1 = group.entities.add_group
        op1.name = opening.theinternalname + "@lod3MultiSurface"
       opening_layer = citygmlloader.layercreator.windows
       if(opening.type.index("Door") != nil)
         opening_layer = citygmlloader.layercreator.doors
       end

       opening.buildlod3multisurfacegeometry(op1, appearances, citygmlloader, parents, opening_layer)
     }
    super(group, appearances, citygmlloader, parents, layer)

   end


    def buildlod4multisurfacegeometry group, appearances, citygmlloader, parentnames, layer
      parents = Array.new()
       if(parentnames != nil)
         parents.concat(parentnames)
       end
       parents.push(@theinternalname)
      
     @openings.each_value { |opening|
            op1 = group.entities.add_group
            op1.name = opening.theinternalname + "@lod4MultiSurface"
            opening_layer = citygmlloader.layercreator.windows
           if(opening.type.index("Door") != nil)
             opening_layer = citygmlloader.layercreator.doors
           end
            opening.buildlod4multisurfacegeometry(op1, appearances, citygmlloader, parents,opening_layer)
     }
      super(group, appearances, citygmlloader, parents, layer)
   end

    def writeToCityGML isWFST, namespace
    retstring = ""
    if(isWFST == "true")
      return writeToCityGMLWFST(namespace)
    end

    retstring << "<" + namespace + "boundedBy>\n"
    retstring << "<" + namespace + getBoundaryNameForInternalName() + " gml:id=\"" + @gmlid + "\">\n"

    @simpleCityObjectAttributes.each { |att|

      retstring << att.value
    }

      if(@lod2MultiSurface.length > 0)
        retstring  << "<" + namespace + "lod2MultiSurface>\n"
        retstring << "<gml:MultiSurface>\n"
       @lod2MultiSurface.each{ |geo|
       retstring << geo.writeToCityGML
      }
       retstring << "</gml:MultiSurface>\n"
       retstring  << "</" + namespace + "lod2MultiSurface>\n"

     end
      if(@lod3MultiSurface.length > 0)
        retstring  << "<" + namespace + "lod3MultiSurface>\n"
        retstring << "<gml:MultiSurface>\n"
       @lod3MultiSurface.each{ |geo|
       retstring << geo.writeToCityGML
      }
       retstring << "</gml:MultiSurface>\n"
       retstring  << "</" + namespace + "lod3MultiSurface>\n"

     end
      if(@lod4MultiSurface.length > 0)
        retstring  << "<" + namespace + "lod4MultiSurface>\n"
        retstring << "<gml:MultiSurface>\n"
       @lod4MultiSurface.each{ |geo|
       retstring << geo.writeToCityGML
      }
       retstring << "</gml:MultiSurface>\n"
       retstring  << "</" + namespace + "lod2MultiSurface>\n"

     end



    bpstring  = ""
    @openings.each_value {|bp|
      bpstring << bp.writeToCityGML(isWFST, namespace)
    }


     retstring << bpstring


      retstring << "</"+ namespace + getBoundaryNameForInternalName() +  ">\n"
      retstring << "</" + namespace + "boundedBy>\n"

    return retstring
  end

     def writeToCityGMLWFST namespace
    retstring = ""

      retstring << "<wfs:Property>\n"
      retstring << "<wfs:Name>" + namespace + "boundedBy</wfs:Name>\n"
      retstring << "<wfs:Value>\n"

    
    retstring << "<" + namespace + getBoundaryNameForInternalName() + " gml:id=\"" + @gmlid + "\">\n"

    @simpleCityObjectAttributes.each { |att|

      retstring << att.value
    }

      if(@lod2MultiSurface.length > 0)
        retstring  << "<" + namespace + "lod2MultiSurface>\n"
        retstring << "<gml:MultiSurface>\n"
       @lod2MultiSurface.each{ |geo|
       retstring << geo.writeToCityGML
      }
       retstring << "</gml:MultiSurface>\n"
       retstring  << "</" + namespace + "lod2MultiSurface>\n"

     end
      if(@lod3MultiSurface.length > 0)
        retstring  << "<" + namespace + "lod3MultiSurface>\n"
        retstring << "<gml:MultiSurface>\n"
       @lod3MultiSurface.each{ |geo|
       retstring << geo.writeToCityGML
      }
       retstring << "</gml:MultiSurface>\n"
       retstring  << "</" + namespace + "lod3MultiSurface>\n"

     end
      if(@lod4MultiSurface.length > 0)
        retstring  << "<" + namespace + "lod4MultiSurface>\n"
        retstring << "<gml:MultiSurface>\n"
       @lod4MultiSurface.each{ |geo|
       retstring << geo.writeToCityGML
      }
       retstring << "</gml:MultiSurface>\n"
       retstring  << "</" + namespace + "lod2MultiSurface>\n"

     end



    bpstring  = ""
    @openings.each_value {|bp|
      bpstring << bp.writeToCityGML("true", namespace)
    }


     retstring << bpstring


      retstring << "</"+ namespace + getBoundaryNameForInternalName() +  ">\n"
      retstring << "</wfs:Value>\n"
      retstring << "</wfs:Property>\n"

    return retstring
  end


     def getBoundaryNameForInternalName()
       if(@theinternalname.index("WaterSurface") != nil)
         return "WaterSurface"
       end
       if(@theinternalname.index("WaterGroundSurface") != nil)
         return "WaterGroundSurface"
       end
       if(@theinternalname.index("OuterCeilingSurface") != nil)
         return "OuterCeilingSurface"
       end
       if(@theinternalname.index("OuterFloorSurface") != nil)
         return "OuterFloorSurface"
       end
       if(@theinternalname.index("GroundSurface") != nil)
         return "GroundSurface"
       end
       if(@theinternalname.index("RoofSurface") != nil)
         return "RoofSurface"
       end
       if(@theinternalname.index("InteriorWallSurface") != nil)
         return "InteriorWallSurface"
       end
       if(@theinternalname.index("WallSurface") != nil)
         return "WallSurface"
       end
       if(@theinternalname.index("ClosureSurface") != nil)
         return "ClosureSurface"
       end
       if(@theinternalname.index("FloorSurface") != nil)
         return "FloorSurface"
       end
       if(@theinternalname.index("CeilingSurface") != nil)
         return "CeilingSurface"
       end
       return "WallSurface"
     end



    attr_reader :openings

end
