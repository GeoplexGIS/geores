# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_schema/geores_feature/gres_cityobject.rb'
Sketchup::require 'geores_src/geores_debug/gres_cgmldebugger.rb'

class GRES_GenericCityObject < GRES_CityObject
 def initialize
    super()
    @implicitgeometriesLod1 = Array.new()
    @implicitgeometriesLod2 = Array.new()
    @implicitgeometriesLod3 = Array.new()
    @implicitgeometriesLod4 = Array.new()
  end

  attr_reader :implicitgeometriesLod1, :implicitgeometriesLod2, :implicitgeometriesLod3,  :implicitgeometriesLod4


   def buildgeometries(entities, appearances, citygmlloader, parentnames)
      parents = Array.new()
       if(parentnames != nil)
         parents.concat(parentnames)
       end
       parents.push(@theinternalname)

       #begin
       if(@isImplicitReferenceObject == true)
        GRES_CGMLDebugger.writedebugstring("Erzeuge implizite Geometrien als Refernz fuer" + @theinternalname +"\n")
        buildImplicitGeometryLoD1(entities, appearances, citygmlloader, parents, true)
        buildImplicitGeometryLoD2(entities, appearances, citygmlloader, parents, true)
        buildImplicitGeometryLoD3(entities, appearances, citygmlloader, parents, true)
        buildImplicitGeometryLoD4(entities, appearances, citygmlloader, parents, true)
       return
       end
        if(@isImplicitObject == true)
          GRES_CGMLDebugger.writedebugstring("Erzeuge implizite Geometrien als Kopie fuer" + @theinternalname +"\n")
          buildImplicitGeometryLoD1(entities, appearances, citygmlloader, parents, false)
          buildImplicitGeometryLoD2(entities, appearances, citygmlloader, parents, false)
          buildImplicitGeometryLoD3(entities, appearances, citygmlloader, parents, false)
          buildImplicitGeometryLoD4(entities, appearances, citygmlloader, parents, false)
        return
       end
       #rescue => err
        # GRES_CGMLDebugger.writedebugstring("Fehler:" + err.backtrace.to_s + "\n")
      # end

       layer_creator = citygmlloader.layercreator

       if(@lod1MultiSurface.length > 0)
         group = entities.add_group
         group.name = @theinternalname + ".@lod1Geometry"
         GRES_CGMLDebugger.writedebugstring("Call buildlod1multisurfacegeometry \n")
         buildlod1multisurfacegeometry(group, appearances, citygmlloader, parents, layer_creator.lod1layer)
         transform = Geom::Transformation.scaling 39.370078740157477
         group.transformation = transform
       end
       if(@lod2MultiSurface.length > 0)
         group = entities.add_group
         group.name = @theinternalname + ".@lod2Geometry"
         GRES_CGMLDebugger.writedebugstring("Call buildlod2multisurfacegeometry \n")
         buildlod2multisurfacegeometry(group, appearances, citygmlloader, parents, layer_creator.lod2layer)
         transform = Geom::Transformation.scaling 39.370078740157477
         group.transformation = transform
       end
       if(@lod3MultiSurface.length > 0)
         group = entities.add_group
         group.name = @theinternalname + ".@lod3Geometry"
         GRES_CGMLDebugger.writedebugstring("Call buildlod3multisurfacegeometry \n")
         buildlod3multisurfacegeometry(group, appearances, citygmlloader, parents, layer_creator.lod3layer)
         transform = Geom::Transformation.scaling 39.370078740157477
         group.transformation = transform
       end
       if(@lod4MultiSurface.length > 0)
         group = entities.add_group
         group.name = @theinternalname + ".@lod4Geometry"
         GRES_CGMLDebugger.writedebugstring("Call buildlod4multisurfacegeometry \n")
         buildlod4multisurfacegeometry(group, appearances, citygmlloader, parents, layer_creator.lod4layer)
         transform = Geom::Transformation.scaling 39.370078740157477
         group.transformation = transform
       end

   end

    def buildToSKP(parent, entity, dictname, counter)
     super(parent, entity, dictname, counter)
     dictionary = entity.attribute_dictionary(dictname, true)
     if(@isImplicitReferenceObject == true)
       dictionary["isImplicitReference"] = "true"
     end
     dictionary["gmlid"] = @gmlid
   end

   def addImplicitGeometry (geo, name)
    if(name.index("lod1") != nil)
      @implicitgeometriesLod1.push(geo)
    end
    if(name.index("lod2") != nil)
      @implicitgeometriesLod2.push(geo)
    end
    if(name.index("lod3") != nil)
      @implicitgeometriesLod3.push(geo)
    end
    if(name.index("lod4") != nil)
      @implicitgeometriesLod4.push(geo)
    end

  end


       def buildImplicitGeometryLoD1(entities, appearances, citygmlloader, parents, isrefobject)
     layer_creator = citygmlloader.layercreator
     if(isrefobject == true)
       @implicitgeometriesLod1.each { |implGeom|
         implgroup = entities.add_group
         implgroup.name= @theinternalname +"@implicitReferenceLoD1"
         GRES_CGMLDebugger.writedebugstring("GenericCityObject: Erzeuge neues implizites Referenzobjekt mit Namen " + implgroup.name + " und id: " + implGeom.gmlid + "\n")
         if(implGeom == nil or implGeom.geometries == nil)
           GRES_CGMLDebugger.writedebugstring("GenericCityObject: Fehler:  implizite Geometrie oder beinhaltete Geometrien null \n")
         end
         implGeom.geometries.each { |geo|
           geo.build(implgroup, appearances, citygmlloader, parents, implGeom.gmlid, "lod1", layer_creator.generics, true, false)
         }
         GRES_CGMLDebugger.writedebugstring("GenericCityObject: Geometrien fuer implizites Objekt erstellt.\n")
         comp_inst = implgroup.to_component
          comp_instdict = comp_inst.attribute_dictionary("groupatts", true)
         comp_instdict["isReference"] = "true"
         comp_instdict["referencename"] = @theinternalname
         comp_instdict["lod"] = "lod1"
         comp_instdict["internalname"] = @theinternalname
         implGeom.setcompinstance(comp_inst)
         newgroup = entities.add_instance(comp_inst.definition, comp_inst.transformation)
         newgroupdict = newgroup.attribute_dictionary("groupatts", true)
         newgroupdict["isReference"] = "true"
         newgroupdict["referencename"] = @theinternalname
          newgroupdict["lod"] = "lod1"
         newgroupdict["internalname"] = @theinternalname
          newgroup.name= @theinternalname +"@implicitReferenceLoD1"
         GRES_CGMLDebugger.writedebugstring("GenericCityObject: 4x4 Transformation des Objektes " + implGeom.trafo.to_a.to_s + "\n")
          GRES_CGMLDebugger.writedebugstring("GenericCityObject: Punkt Transformation des Objektes " + implGeom.trafopoint.to_a.to_s + "\n")
          newgroup.transform! implGeom.trafo
          po = implGeom.trafopoint
          po.x = po.x - citygmlloader.translX
          po.y = po.y - citygmlloader.translY
          po.z = po.z - citygmlloader.translZ
          trafopoint = Geom::Transformation.new po
          newgroup.transform! trafopoint
          transform = Geom::Transformation.scaling 39.370078740157477
          newgroup.transform! transform
          newgroup.layer = layer_creator.generics
          newgroup.make_unique
          citygmlloader.add_group_to_erase comp_inst
       }



     else
       implrefobjects = citygmlloader.parsedImplicitRefObjects
       thecompInst = nil
       if(implrefobjects == nil)
         GRES_CGMLDebugger.writedebugstring("GenericCityObject: Implizite Referenzobjekte sind nil \n")
       end
       GRES_CGMLDebugger.writedebugstring("GenericCityObject: Erzeuge neue implizite Geometrie als Kopie fuer Objekt mit Namen " + @theinternalname + "\n")

        @implicitgeometriesLod1.each { |implGeom|
           GRES_CGMLDebugger.writedebugstring("GenericCityObject: Suche Referenzobjekt fuer" + implGeom.xlink +  "\n")
              implrefobjects.each { |implref|
                implref.implicitgeometriesLod1.each{|implrefImplGeom|
                  if(implrefImplGeom.gmlid == implGeom.xlink)
                   GRES_CGMLDebugger.writedebugstring("GenericCityObject: Referenzkomponente gefunden :" + implGeom.xlink +  "\n")
                   thecompInst = implrefImplGeom.compInst
                end
                }

              }
         if(thecompInst != nil)
           GRES_CGMLDebugger.writedebugstring("GenericCityObject: ComponentInstance gefunden! Erzeuge neue Instanz\n")
           newgroup = entities.add_instance(thecompInst.definition, thecompInst.transformation)
           newgroup.name= @theinternalname +"@implicitReferenceLoD1"
            GRES_CGMLDebugger.writedebugstring("SolitaryVegetationObject: 4x4 Transformation des Objektes " + implGeom.trafo.to_a.to_s + "\n")
           GRES_CGMLDebugger.writedebugstring("SolitaryVegetationObject: Punkt Transformation des Objektes " + implGeom.trafopoint.to_a.to_s + "\n")
           newgroup.transform! implGeom.trafo
                   po = implGeom.trafopoint
          po.x = po.x - citygmlloader.translX
          po.y = po.y - citygmlloader.translY
          po.z = po.z - citygmlloader.translZ
          trafopoint = Geom::Transformation.new po
          newgroup.transform! trafopoint
            transform = Geom::Transformation.scaling 39.370078740157477
            newgroup.transform! transform
            newgroup.layer = layer_creator.generics
             newgroup.make_unique
            newgroupdict = newgroup.attribute_dictionary("groupatts", true)
           newgroupdict["isReference"] = "false"
           newgroupdict["referencename"] = thecompInst.get_attribute("groupatts", "referencename")
            newgroupdict["lod"] = "lod1"
           newgroupdict["internalname"] = @theinternalname
         end
         }


     end

   end

    def buildImplicitGeometryLoD2(entities, appearances, citygmlloader, parents, isrefobject)
     layer_creator = citygmlloader.layercreator
     if(isrefobject == true)
       @implicitgeometriesLod2.each { |implGeom|
         implgroup = entities.add_group
         implgroup.name= @theinternalname +"@implicitReferenceLoD2"
         GRES_CGMLDebugger.writedebugstring("GenericCityObject: Erzeuge neues implizites Referenzobjekt mit Namen " + implgroup.name + " und id: " + implGeom.gmlid + "\n")
         if(implGeom == nil or implGeom.geometries == nil)
           GRES_CGMLDebugger.writedebugstring("GenericCityObject: Fehler:  implizite Geometrie oder beinhaltete Geometrien null \n")
         end
         implGeom.geometries.each { |geo|
           geo.build(implgroup, appearances, citygmlloader, parents, implGeom.gmlid, "lod2", layer_creator.generics, true, false)
         }
         GRES_CGMLDebugger.writedebugstring("GenericCityObject: Geometrien fuer implizites Objekt erstellt.\n")
          comp_inst = implgroup.to_component
          comp_instdict = comp_inst.attribute_dictionary("groupatts", true)
         comp_instdict["isReference"] = "true"
         comp_instdict["referencename"] = @theinternalname
         comp_instdict["lod"] = "lod2"
         comp_instdict["internalname"] = @theinternalname
         implGeom.setcompinstance(comp_inst)
         newgroup = entities.add_instance(comp_inst.definition, comp_inst.transformation)
           newgroupdict = newgroup.attribute_dictionary("groupatts", true)
         newgroupdict["isReference"] = "true"
         newgroupdict["referencename"] = @theinternalname
         newgroupdict["lod"] = "lod2"
         newgroupdict["internalname"] = @theinternalname
          newgroup.name= @theinternalname +"implicitReferenceLoD2"
         GRES_CGMLDebugger.writedebugstring("GenericCityObject: 4x4 Transformation des Objektes " + implGeom.trafo.to_a.to_s + "\n")
          GRES_CGMLDebugger.writedebugstring("GenericCityObject: Punkt Transformation des Objektes " + implGeom.trafopoint.to_a.to_s + "\n")
          newgroup.transform! implGeom.trafo
          po = implGeom.trafopoint
          po.x = po.x - citygmlloader.translX
          po.y = po.y - citygmlloader.translY
          po.z = po.z - citygmlloader.translZ
          trafopoint = Geom::Transformation.new po
          newgroup.transform! trafopoint
          transform = Geom::Transformation.scaling 39.370078740157477
          newgroup.transform! transform
          newgroup.layer = layer_creator.generics
          newgroup.make_unique
          citygmlloader.add_group_to_erase comp_inst
       }



     else
       implrefobjects = citygmlloader.parsedImplicitRefObjects
       thecompInst = nil
       if(implrefobjects == nil)
         GRES_CGMLDebugger.writedebugstring("GenericCityObject: Implizite Referenzobjekte sind nil \n")
       end
       GRES_CGMLDebugger.writedebugstring("GenericCityObject: Erzeuge neue implizite Geometrie als Kopie fuer Objekt mit Namen " + @theinternalname + "\n")

        @implicitgeometriesLod2.each { |implGeom|
           GRES_CGMLDebugger.writedebugstring("GenericCityObject: Suche Referenzobjekt fuer" + implGeom.xlink +  "\n")
              implrefobjects.each { |implref|
                implref.implicitgeometriesLod2.each{|implrefImplGeom|
                  if(implrefImplGeom.gmlid == implGeom.xlink)
                   GRES_CGMLDebugger.writedebugstring("GenericCityObject: Referenzkomponente gefunden :" + implGeom.xlink +  "\n")
                   thecompInst = implrefImplGeom.compInst
                end
                }

              }
         if(thecompInst != nil)
           GRES_CGMLDebugger.writedebugstring("GenericCityObject: ComponentInstance gefunden! Erzeuge neue Instanz\n")
           newgroup = entities.add_instance(thecompInst.definition, thecompInst.transformation)
           newgroup.name= @theinternalname +"@implicitReferenceLoD1"
            GRES_CGMLDebugger.writedebugstring("GenericCityObject: 4x4 Transformation des Objektes " + implGeom.trafo.to_a.to_s + "\n")
           GRES_CGMLDebugger.writedebugstring("GenericCityObject: Punkt Transformation des Objektes " + implGeom.trafopoint.to_a.to_s + "\n")
           newgroup.transform! implGeom.trafo
           po = implGeom.trafopoint
          po.x = po.x - citygmlloader.translX
          po.y = po.y - citygmlloader.translY
          po.z = po.z - citygmlloader.translZ
          trafopoint = Geom::Transformation.new po
          newgroup.transform! trafopoint
            transform = Geom::Transformation.scaling 39.370078740157477
            newgroup.transform! transform
            newgroup.layer = layer_creator.generics
             newgroup.make_unique
            newgroupdict = newgroup.attribute_dictionary("groupatts", true)
           newgroupdict["isReference"] = "false"
           newgroupdict["referencename"] = thecompInst.get_attribute("groupatts", "referencename")
           newgroupdict["lod"] = "lod2"
           newgroupdict["internalname"] = @theinternalname
         end
         }


     end

   end

    def buildImplicitGeometryLoD3(entities, appearances, citygmlloader, parents, isrefobject)
     layer_creator = citygmlloader.layercreator
     if(isrefobject == true)
       @implicitgeometriesLod3.each { |implGeom|
         implgroup = entities.add_group
         implgroup.name= @theinternalname +"@implicitReferenceLoD3"
         GRES_CGMLDebugger.writedebugstring("GenericCityObject: Erzeuge neues implizites Referenzobjekt mit Namen " + implgroup.name + " und id: " + implGeom.gmlid + "\n")
         if(implGeom == nil or implGeom.geometries == nil)
           GRES_CGMLDebugger.writedebugstring("GenericCityObject: Fehler:  implizite Geometrie oder beinhaltete Geometrien null \n")
         end
         implGeom.geometries.each { |geo|
           geo.build(implgroup, appearances, citygmlloader, parents, implGeom.gmlid, "lod3", layer_creator.generics, true, false)
         }
         GRES_CGMLDebugger.writedebugstring("GenericCityObject: Geometrien fuer implizites Objekt erstellt.\n")
        comp_inst = implgroup.to_component
         comp_instdict = comp_inst.attribute_dictionary("groupatts", true)
         comp_instdict["isReference"] = "true"
         comp_instdict["referencename"] = @theinternalname
         comp_instdict["lod"] = "lod3"
         comp_instdict["internalname"] = @theinternalname
         implGeom.setcompinstance(comp_inst)
         newgroup = entities.add_instance(comp_inst.definition, comp_inst.transformation)
          newgroupdict = newgroup.attribute_dictionary("groupatts", true)
         newgroupdict["isReference"] = "true"
         newgroupdict["referencename"] = @theinternalname
         newgroupdict["lod"] = "lod3"
         newgroupdict["internalname"] = @theinternalname
          newgroup.name= @theinternalname +"implicitReferenceLoD3"
         GRES_CGMLDebugger.writedebugstring("GenericCityObject: 4x4 Transformation des Objektes " + implGeom.trafo.to_a.to_s + "\n")
          GRES_CGMLDebugger.writedebugstring("GenericCityObject: Punkt Transformation des Objektes " + implGeom.trafopoint.to_a.to_s + "\n")
          newgroup.transform! implGeom.trafo
          po = implGeom.trafopoint
          po.x = po.x - citygmlloader.translX
          po.y = po.y - citygmlloader.translY
          po.z = po.z - citygmlloader.translZ
          trafopoint = Geom::Transformation.new po
          newgroup.transform! trafopoint
          transform = Geom::Transformation.scaling 39.370078740157477
          newgroup.transform! transform
          newgroup.layer = layer_creator.generics
          newgroup.make_unique
          citygmlloader.add_group_to_erase comp_inst
       }



     else
       implrefobjects = citygmlloader.parsedImplicitRefObjects
       thecompInst = nil
       if(implrefobjects == nil)
         GRES_CGMLDebugger.writedebugstring("GenericCityObject: Implizite Referenzobjekte sind nil \n")
       end
       GRES_CGMLDebugger.writedebugstring("GenericCityObject: Erzeuge neue implizite Geometrie als Kopie fuer Objekt mit Namen " + @theinternalname + "\n")

        @implicitgeometriesLod3.each { |implGeom|
           GRES_CGMLDebugger.writedebugstring("GenericCityObject: Suche Referenzobjekt fuer" + implGeom.xlink +  "\n")
              implrefobjects.each { |implref|
                implref.implicitgeometriesLod3.each{|implrefImplGeom|
                  if(implrefImplGeom.gmlid == implGeom.xlink)
                   GRES_CGMLDebugger.writedebugstring("GenericCityObject: Referenzkomponente gefunden :" + implGeom.xlink +  "\n")
                   thecompInst = implrefImplGeom.compInst
                end
                }

              }
         if(thecompInst != nil)
           GRES_CGMLDebugger.writedebugstring("GenericCityObject: ComponentInstance gefunden! Erzeuge neue Instanz\n")
           newgroup = entities.add_instance(thecompInst.definition, thecompInst.transformation)
           newgroup.name= @theinternalname +"implicitReferenceLoD3"
            GRES_CGMLDebugger.writedebugstring("GenericCityObject: 4x4 Transformation des Objektes " + implGeom.trafo.to_a.to_s + "\n")
           GRES_CGMLDebugger.writedebugstring("GenericCityObject: Punkt Transformation des Objektes " + implGeom.trafopoint.to_a.to_s + "\n")
           newgroup.transform! implGeom.trafo
           po = implGeom.trafopoint
          po.x = po.x - citygmlloader.translX
          po.y = po.y - citygmlloader.translY
          po.z = po.z - citygmlloader.translZ
          trafopoint = Geom::Transformation.new po
          newgroup.transform! trafopoint
            transform = Geom::Transformation.scaling 39.370078740157477
            newgroup.transform! transform
            newgroup.layer = layer_creator.generics
             newgroup.make_unique
                   newgroupdict = newgroup.attribute_dictionary("groupatts", true)
           newgroupdict["isReference"] = "false"
           newgroupdict["referencename"] = thecompInst.get_attribute("groupatts", "referencename")
           newgroupdict["lod"] = "lod3"
           newgroupdict["internalname"] = @theinternalname
         end
         }


     end

   end

    def buildImplicitGeometryLoD4(entities, appearances, citygmlloader, parents, isrefobject)
     layer_creator = citygmlloader.layercreator
     if(isrefobject == true)
       @implicitgeometriesLod4.each { |implGeom|
         implgroup = entities.add_group
         implgroup.name= @theinternalname +"@implicitReferenceLoD1"
         GRES_CGMLDebugger.writedebugstring("GenericCityObject: Erzeuge neues implizites Referenzobjekt mit Namen " + implgroup.name + " und id: " + implGeom.gmlid + "\n")
         if(implGeom == nil or implGeom.geometries == nil)
           GRES_CGMLDebugger.writedebugstring("GenericCityObject: Fehler:  implizite Geometrie oder beinhaltete Geometrien null \n")
         end
         implGeom.geometries.each { |geo|
           geo.build(implgroup, appearances, citygmlloader, parents, implGeom.gmlid, "lod1", layer_creator.generics, true, false)
         }
         GRES_CGMLDebugger.writedebugstring("GenericCityObject: Geometrien fuer implizites Objekt erstellt.\n")
           comp_instdict = comp_inst.attribute_dictionary("groupatts", true)
         comp_instdict["isReference"] = "true"
         comp_instdict["referencename"] = @theinternalname
         comp_instdict["lod"] = "lod4"
         comp_instdict["internalname"] = @theinternalname
         implGeom.setcompinstance(comp_inst)
         newgroup = entities.add_instance(comp_inst.definition, comp_inst.transformation)
          newgroupdict = newgroup.attribute_dictionary("groupatts", true)
         newgroupdict["isReference"] = "true"
         newgroupdict["referencename"] = @theinternalname
         newgroupdict["lod"] = "lod4"
         newgroupdict["internalname"] = @theinternalname
          newgroup.name= @theinternalname +"@implicitReferenceLoD1"
         GRES_CGMLDebugger.writedebugstring("GenericCityObject: 4x4 Transformation des Objektes " + implGeom.trafo.to_a.to_s + "\n")
          GRES_CGMLDebugger.writedebugstring("GenericCityObject: Punkt Transformation des Objektes " + implGeom.trafopoint.to_a.to_s + "\n")
          newgroup.transform! implGeom.trafo
          po = implGeom.trafopoint
          po.x = po.x - citygmlloader.translX
          po.y = po.y - citygmlloader.translY
          po.z = po.z - citygmlloader.translZ
          trafopoint = Geom::Transformation.new po
          newgroup.transform! trafopoint
          transform = Geom::Transformation.scaling 39.370078740157477
          newgroup.transform! transform
          newgroup.layer = layer_creator.generics
          newgroup.make_unique
          citygmlloader.add_group_to_erase comp_inst
       }



     else
       implrefobjects = citygmlloader.parsedImplicitRefObjects
       thecompInst = nil
       if(implrefobjects == nil)
         GRES_CGMLDebugger.writedebugstring("GenericCityObject::Fehler: Implizite Referenzobjekte sind nil \n")
       end
       GRES_CGMLDebugger.writedebugstring("GenericCityObject: Erzeuge neue implizite Geometrie als Kopie fuer Objekt mit Namen " + @theinternalname + "\n")

        @implicitgeometriesLod4.each { |implGeom|
           GRES_CGMLDebugger.writedebugstring("GenericCityObject: Suche Referenzobjekt fuer" + implGeom.xlink +  "\n")
              implrefobjects.each { |implref|
                implref.implicitgeometriesLod1.each{|implrefImplGeom|
                  if(implrefImplGeom.gmlid == implGeom.xlink)
                   GRES_CGMLDebugger.writedebugstring("GenericCityObject: Referenzkomponente gefunden :" + implGeom.xlink +  "\n")
                   thecompInst = implrefImplGeom.compInst
                end
                }

              }
         if(thecompInst != nil)
           GRES_CGMLDebugger.writedebugstring("GenericCityObject: ComponentInstance gefunden! Erzeuge neue Instanz\n")
           newgroup = entities.add_instance(thecompInst.definition, thecompInst.transformation)
           newgroup.name= @theinternalname +"@implicitReferenceLoD1"
            GRES_CGMLDebugger.writedebugstring("GenericCityObject: 4x4 Transformation des Objektes " + implGeom.trafo.to_a.to_s + "\n")
           GRES_CGMLDebugger.writedebugstring("GenericCityObject: Punkt Transformation des Objektes " + implGeom.trafopoint.to_a.to_s + "\n")
           newgroup.transform! implGeom.trafo
           po = implGeom.trafopoint
          po.x = po.x - citygmlloader.translX
          po.y = po.y - citygmlloader.translY
          po.z = po.z - citygmlloader.translZ
          trafopoint = Geom::Transformation.new po
          newgroup.transform! trafopoint
            transform = Geom::Transformation.scaling 39.370078740157477
            newgroup.transform! transform
            newgroup.layer = layer_creator.generics
             newgroup.make_unique
              newgroupdict["isReference"] = "false"
           newgroupdict["referencename"] = thecompInst.get_attribute("groupatts", "referencename")
           newgroupdict["lod"] = "lod4"
           newgroupdict["internalname"] = @theinternalname
         end
         }


     end

   end

 def writeToCityGML isWFST, namespace

    retstring = ""


   retstring << "<core:cityObjectMember>\n"
   retstring << "<gen:GenericCityObject gml:id=\"" + @gmlid + "\">\n"

    @simpleCityObjectAttributes.each { |att|

      retstring << att.value
    }
     if(@lod1MultiSurface.length > 0)
        retstring  << "<gen:lod1Geometry>\n"
        retstring << "<gml:MultiSurface>\n"
       @lod1MultiSurface.each{ |geo|
       retstring << geo.writeToCityGML
      }
       retstring << "</gml:MultiSurface>\n"
       retstring  << "</gen:lod1Geometry>\n"

     end
      if(@lod2MultiSurface.length > 0)
        retstring  << "<gen:lod2Geometry>\n"
        retstring << "<gml:MultiSurface>\n"
       @lod2MultiSurface.each{ |geo|
       retstring << geo.writeToCityGML
      }
       retstring << "</gml:MultiSurface>\n"
       retstring  << "</gen:lod2Geometry>\n"

     end
      if(@lod3MultiSurface.length > 0)
        retstring  << "<gen:lod3Geometry>\n"
        retstring << "<gml:MultiSurface>\n"
       @lod3MultiSurface.each{ |geo|
       retstring << geo.writeToCityGML
      }
       retstring << "</gml:MultiSurface>\n"
       retstring  << "</gen:lod3Geometry>\n"

     end
      if(@lod4MultiSurface.length > 0)
        retstring  << "<gen:lod4Geometry>\n"
        retstring << "<gml:MultiSurface>\n"
       @lod4MultiSurface.each{ |geo|
       retstring << geo.writeToCityGML
      }
       retstring << "</gml:MultiSurface>\n"
       retstring  << "</gen:lod4Geometry>\n"

     end

      if(@implicitgeometriesLod1.length  > 0)
         retstring  << "<gen:lod1ImplicitRepresentation>\n"
         @implicitgeometriesLod1.each { |implGeom|
            retstring << implGeom.writeToCityGML
         }
        retstring  << "</gen:lod1ImplicitRepresentation>\n"
      end
        if(@implicitgeometriesLod2.length  > 0)
         retstring  << "<gen:lod2ImplicitRepresentation>\n"
         @implicitgeometriesLod2.each { |implGeom|
            retstring << implGeom.writeToCityGML
         }
        retstring  << "</gen:lod2ImplicitRepresentation>\n"
      end
        if(@implicitgeometriesLod3.length  > 0)
         retstring  << "<gen:lod3ImplicitRepresentation>\n"
         @implicitgeometriesLod3.each { |implGeom|
            retstring << implGeom.writeToCityGML
         }
        retstring  << "</gen:lod3ImplicitRepresentation>\n"
      end
        if(@implicitgeometriesLod4.length  > 0)
         retstring  << "<gen:lod4ImplicitRepresentation>\n"
         @implicitgeometriesLod4.each { |implGeom|
            retstring << implGeom.writeToCityGML
         }
        retstring  << "</gen:lod4ImplicitRepresentation>\n"
      end


       retstring << "</gen:GenericCityObject>\n"
       retstring << "</core:cityObjectMember>\n"

    return retstring
  end
end
