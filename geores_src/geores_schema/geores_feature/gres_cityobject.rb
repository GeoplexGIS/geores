# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_schema/abstract_all.rb'
Sketchup::require 'geores_src/geores_debug/gres_cgmldebugger.rb'

class GRES_CityObject < AbstractAll
  def initialize
    super()
    @addresses = Array.new()
    @externalReferences = Array.new()
    @genericAttributes = Array.new()
    @simpleCityObjectAttributes = Array.new()
    @gmlid = ""
    @lod1MultiSurface = Array.new()
    @lod2MultiSurface = Array.new()
    @lod3MultiSurface = Array.new()
    @lod4MultiSurface = Array.new()
    @lod1Solid = Array.new()
    @lod2Solid = Array.new()
    @lod3Solid = Array.new()
    @lod4Solid = Array.new()
    @theinternalname = ""
    @isImplicitReferenceObject = false
    @isImplicitObject = false
    @nameofCityObjectGroup = ""
  end

  def setisImplicitReferenceObject isrefobj
    @isImplicitReferenceObject = isrefobj
  end
  
  def setisImplicitObject isrefobj
    @isImplicitObject = isrefobj
  end

  def setnameOfCityObjectGroup name
    @nameofCityObjectGroup = name
  end

  def setgmlid id
    @gmlid = id
  end
  def setgmlid id
    @gmlid = id
  end

  def addAddress a
    @addresses.push(a)
  end

  def addExternalReference ref
    @externalReferences.push(ref)
  end

  def addSimpleAttribute a
    @simpleCityObjectAttributes.push(a)
  end

  def addGenericAttribute a
    @genericAttributes.push(a)
  end

  def addMultiSurface (geo, name)
    if(name.index("lod1") != nil)
      @lod1MultiSurface.push(geo)
    end
    if(name.index("lod2") != nil)
      @lod2MultiSurface.push(geo)
    end
    if(name.index("lod3") != nil)
      @lod3MultiSurface.push(geo)
    end
    if(name.index("lod4") != nil)
      @lod4MultiSurface.push(geo)
    end

  end

  def addSolid (geo, name)
    if(name.index("lod1") != nil)
      @lod1Solid.push(geo)
    end
    if(name.index("lod2") != nil)
      @lod2Solid.push(geo)
    end
    if(name.index("lod3") != nil)
      @lod3Solid.push(geo)
    end
    if(name.index("lod4") != nil)
      @lod4Solid.push(geo)
    end

  end

  def setname n
    @theinternalname = n
  end

  def writeToCityGML isWFST, namespace
  end

   def buildToSKP(parent, entity, dictname, counter)
     puts "in buildToSKP CityObject"
     dictionary = entity.attribute_dictionary(dictname, true)
     @addresses.each { |address|
       address.buildToSKP(@theinternalname, entity, dictname, counter)
       counter = counter +1
     }
     @externalReferences.each { |reference|
       reference.buildToSKP(@theinternalname, entity, dictname, counter)
       counter = counter +1
     }
     @genericAttributes.each { |att|
       att.buildToSKP(@theinternalname, entity, dictname, counter)
       counter = counter +1
     }
     @simpleCityObjectAttributes.each { |att|
       att.buildToSKP(@theinternalname, entity, dictname, counter)
       counter = counter +1
     }
     dictionary["gmlid"] = @gmlid
   end

   def buildFromSKP(entity, dictname)

   end

   def buildgeometries(entities, appearances, citygmlloader, parentnames)

   end
   

   def buildlod1solidgeometry group, appearances, citygmlloader, parentnames, layer
     
     if(@lod1Solid.length > 0)
         @lod1Solid.each { |solidgeometry|
           solidgeometry.build(group, appearances, citygmlloader, parentnames, "lod1",layer, false)
         }
     end
   end

    def buildlod1multisurfacegeometry group, appearances, citygmlloader, parentnames, layer
      GRES_CGMLDebugger.writedebugstring("In build LoD1 MultiSurface of CityObject\n")
     if(@lod1MultiSurface.length > 0)
         @lod1MultiSurface.each { |solidgeometry|
           solidgeometry.build(group, appearances, citygmlloader, parentnames, "lod1",layer, false)
         }

     end
   end

   def buildlod2solidgeometry group, appearances, citygmlloader, parentnames, layer

     if(@lod2Solid.length > 0)
         @lod2Solid.each { |solidgeometry|
           solidgeometry.build(group, appearances, citygmlloader, parentnames, "lod2",layer, false)
          
         }

     end
   end

    def buildlod2multisurfacegeometry group, appearances, citygmlloader, parentnames, layer
    GRES_CGMLDebugger.writedebugstring("In build LoD2 MultiSurface of CityObject\n")
     if(@lod2MultiSurface.length > 0)
         @lod2MultiSurface.each { |solidgeometry|
            solidgeometry.build(group, appearances, citygmlloader, parentnames,"lod2",layer, false)
          
         }
     end
   end

    def buildlod3solidgeometry group, appearances, citygmlloader, parentnames, layer

     if(@lod3Solid.length > 0)
         @lod3Solid.each { |solidgeometry|
            solidgeometry.build(group, appearances, citygmlloader, parentnames, "lod3", layer, false)
          
         }
     end
   end

    def buildlod3multisurfacegeometry group, appearances, citygmlloader, parentnames, layer
    GRES_CGMLDebugger.writedebugstring("In build LoD3 MultiSurface of CityObject\n")
     if(@lod3MultiSurface.length > 0)
         @lod3MultiSurface.each { |solidgeometry|
           solidgeometry.build(group, appearances, citygmlloader, parentnames, "lod3", layer, false)
          
         }
     end
   end

  def buildlod4solidgeometry group, appearances, citygmlloader, parentnames, layer

     if(@lod4Solid.length > 0)
         @lod4Solid.each { |solidgeometry|
           solidgeometry.build(group, appearances, citygmlloader, parentnames, "lod4", layer, false)
  
         }
     end

   end

    def buildlod4multisurfacegeometry group, appearances, citygmlloader, parentnames, layer

     if(@lod4MultiSurface.length > 0)
         @lod4MultiSurface.each { |solidgeometry|
            solidgeometry.build(group, appearances, citygmlloader, parentnames, "lod4", layer, false)
         }
     end


   end


  

  attr_reader :addresses, :externalReferences, :genericAttributes, :simpleCityObjectAttributes, :gmlid, :theinternalname, :lod1Solid , :lod1MultiSurface, :lod2Solid , :lod2MultiSurface, :lod3Solid , :lod3MultiSurface, :lod4Solid , :lod4MultiSurface, :isImplicitReferenceObject, :isImplicitObject
end
