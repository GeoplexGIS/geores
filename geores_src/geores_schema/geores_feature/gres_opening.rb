# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_schema/geores_feature/gres_cityobject.rb'

class GRES_Opening < GRES_CityObject
 
  def initialize
    super()
     @implicitgeometries = Array.new()
      @type = ""
  end

  attr_reader :type

   def addImplicitGeometry i
    @implicitgeometries.push(i)
  end

   def setopeningtype t
     @type
   end

    def buildToSKP(parent, entity, dictname, counter)

     super(parent, entity, dictname, counter)
     dictionary = entity.attribute_dictionary(dictname, true)
     dictionary["type"] = @type
     dictionary["parent"] = parent
   end

   def buildFromSKP(entity, dictname)

   end

   def writeToCityGML isWFST, namespace
     retstring = ""
     retstring << "<" + namespace + "opening>\n"
     retstring << "<" + namespace + getObjectTypeForInternalName() + " gml:id=\"" + @gmlid + "\">\n"
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

     retstring << "</" + namespace + getObjectTypeForInternalName() + ">\n"
     retstring << "</" + namespace + "opening>\n"

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

    def getObjectTypeForInternalName()
      if(@theinternalname.index("Door") != nil)
        return "Door"
      end
      return "Window"
    end

  
end
