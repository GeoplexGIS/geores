# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_schema/geores_feature/gres_cityobject.rb'

class GRES_WaterBoundary < GRES_CityObject


  def initialize
    super()
     @type = ""
  end

  def setboundarytype t
    @type = t
  end


  attr_reader :type

   def buildToSKP(parent, entity, dictname, counter)
     puts "in buildToSKP Boundary"
     super(parent, entity, dictname, counter)
     dictionary = entity.attribute_dictionary(dictname, true)
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

    super(group, appearances, citygmlloader, parents, layer)

   end


    def buildlod4multisurfacegeometry group, appearances, citygmlloader, parentnames, layer
      parents = Array.new()
       if(parentnames != nil)
         parents.concat(parentnames)
       end
       parents.push(@theinternalname)


      super(group, appearances, citygmlloader, parents, layer)
   end

    def writeToCityGML isWFST, namespace
    retstring = ""
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
end
