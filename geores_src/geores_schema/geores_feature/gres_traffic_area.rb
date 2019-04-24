# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_schema/geores_feature/gres_cityobject.rb'

class GRES_TrafficArea < GRES_CityObject


  def initialize
    super()
     @type = ""
  end

  def setTrafficType t
    @type = t
  end


  attr_reader :type

   def buildToSKP(parent, entity, dictname, counter)
     puts "in buildToSKP TrafficArea"
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
    lastString = ""
    if(@type.index("AuxiliaryTrafficArea") != nil)
      retstring << "<tran:auxiliaryTrafficArea>\n"
      retstring << "<tran:AuxiliaryTrafficArea" + " gml:id=\"" + @gmlid + "\">\n"
      lastString << "</tran:AuxiliaryTrafficArea>\n"
      lastString << "</tran:auxiliaryTrafficArea>\n"
    else
       retstring << "<tran:trafficArea>\n"
      retstring << "<tran:TrafficArea" + " gml:id=\"" + @gmlid + "\">\n"
      lastString << "</tran:TrafficArea>\n"
      lastString << "</tran:trafficArea>\n"
    end

    @simpleCityObjectAttributes.each { |att|

      retstring << att.value
    }


       if(@lod2MultiSurface.length > 0)
        retstring  << "<tran:lod2MultiSurface>\n"
        retstring << "<gml:MultiSurface>\n"
       @lod2MultiSurface.each{ |geo|
       retstring << geo.writeToCityGML
      }
       retstring << "</gml:MultiSurface>\n"
       retstring  << "</tran:lod2MultiSurface>\n"

     end
       if(@lod3MultiSurface.length > 0)
        retstring  << "<tran:lod3MultiSurface>\n"
        retstring << "<gml:MultiSurface>\n"
       @lod3MultiSurface.each{ |geo|
       retstring << geo.writeToCityGML
      }
       retstring << "</gml:MultiSurface>\n"
       retstring  << "</tran:lod3MultiSurface>\n"

     end
       if(@lod4MultiSurface.length > 0)
        retstring  << "<tran:lod4MultiSurface>\n"
        retstring << "<gml:MultiSurface>\n"
       @lod4MultiSurface.each{ |geo|
       retstring << geo.writeToCityGML
      }
       retstring << "</gml:MultiSurface>\n"
       retstring  << "</tran:lod4MultiSurface>\n"

     end

     retstring << lastString
    return retstring
  end
end
