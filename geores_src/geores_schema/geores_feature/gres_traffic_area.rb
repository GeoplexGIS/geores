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
end
