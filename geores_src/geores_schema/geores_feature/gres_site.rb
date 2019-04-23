# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_schema/geores_feature/gres_cityobject.rb'
Sketchup::require 'sketchup.rb'
Sketchup::require 'geores_src/geores_debug/gres_cgmldebugger.rb'
Sketchup::require 'geores_src/geores_parser/layer_creator.rb'

class GRES_Site < GRES_CityObject

  

  def initialize
    super()
    @boundaries = Hash.new()
    @installations = Hash.new()
    @parts = Hash.new()
  end

  def addPart p
    @parts[p.theinternalname] = p
  end

  def addInstallation i
    @installations[i.theinternalname] = i
  end

  def addBoundary b
    @boundaries[b.theinternalname] = b
  end

  def buildToSKP(parent, entity, dictname, counter)
     GRES_CGMLDebugger.writedebugstring("in buildToSKP Site\n")
     super(parent, entity, dictname, counter)
     GRES_CGMLDebugger.writedebugstring("ended buildToSKP of Super Class\n")
     if(dictname == nil)
       GRES_CGMLDebugger.writedebugstring("Fehler dictname String ist nil \n")
     end
     GRES_CGMLDebugger.writedebugstring("Current dictionary name is " + dictname + "\n")
     dictionary = entity.attribute_dictionary(dictname, true)
     parentname = @theinternalname
     if(@theinternalname == nil)
       GRES_CGMLDebugger.writedebugstring("Fehler @internalname String ist nil\n")
     end
     GRES_CGMLDebugger.writedebugstring("parentname is " + parentname + "\n")
     if(parent == nil)
       GRES_CGMLDebugger.writedebugstring("Fehler parent String ist nil \n")
     end
     if(parent != "")
       GRES_CGMLDebugger.writedebugstring("Fuege parent " + parent + " dem Element " + @theinternalname + " hinzu\n")
       dictionary["parent"] = parent
       parentname = parent + "." + @theinternalname
     end
     @boundaries.each_value { |boundary|
       puts "try to build Boundary Surface"
       boundary.buildToSKP(parentname, entity, boundary.theinternalname, counter)
       counter = counter +1
     }
     @installations.each_value { |installation|
       installation.buildToSKP(parentname, entity, installation.theinternalname, counter)
       counter = counter +1
     }
     @parts.each_value { |part|
       part.buildToSKP(parentname, entity, part.theinternalname, counter)
       counter = counter +1
     }
     if(parent != "")
       dictionary["parent"] = parent
     end
     #@genericAttributes.each { |att|
    #   dname = "GenericCityObjectAttribute"+ counter.to_s
     #  att.buildToSKP(@name, entity, dname)
    #   counter = counter +1
     #}
    # @simpleCityObjectAttributes.each { |att|
     #  dname = "SimpleCityObjectAttribute"+ counter.to_s
     #  att.buildToSKP(@name, entity, dname)
    #   counter = counter +1
    # }

   end

    def buildFromSKP(entity, dictname)

   end

     def buildgeometries(entities, appearances, citygmlloader, parentnames)
       parents = Array.new()
       if(parentnames != nil)
         parents.concat(parentnames)
       end
       parents.push(@theinternalname)
       layer_creator = citygmlloader.layercreator
       if(@lod1Solid.length > 0)
         group = entities.add_group
         group.name = @theinternalname + ".lod1Solid"
         buildlod1solidgeometry(group, appearances, citygmlloader, parents, layer_creator.lod1layer)
         transform = Geom::Transformation.scaling 39.370078740157477
         group.transformation = transform
       end
       if(@lod1MultiSurface.length > 0)
         group = entities.add_group
         group.name = @theinternalname + ".@lod1MultiSurface"
         buildlod1multisurfacegeometry(group, appearances, citygmlloader, parents, layer_creator.lod1layer)
          transform = Geom::Transformation.scaling 39.370078740157477
         group.transformation = transform
       end

       @parts.each_value { |part|
          part.buildgeometries(entities, appearances, citygmlloader, parents)
       }


     end

     attr_reader :boundaries, :installations, :parts
end
