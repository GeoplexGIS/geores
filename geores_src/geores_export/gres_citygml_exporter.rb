# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'sketchup.rb'
Sketchup::require 'geores_src/geores_parser/cityobjectparserfactory.rb'
Sketchup::require 'geores_src/geores_schema/geores_geo/gres_linear_ring.rb'
Sketchup::require 'geores_src/geores_schema/geores_geo/gres_surface.rb'
Sketchup::require 'geores_src/geores_schema/geores_geo/gres_implicitgeometry.rb'
Sketchup::require 'geores_src/geores_debug/gres_cgmldebugger.rb'
Sketchup::require 'geores_src/geores_schema/geores_attributes/simple_city_object_attribute.rb'
Sketchup::require 'geores_src/geores_schema/geores_material/gres_georeferenced_texture.rb'
Sketchup::require 'geores_src/geores_schema/geores_material/gres_parameterized_texture.rb'
Sketchup::require 'geores_src/geores_schema/geores_material/gres_x3d_material.rb'
Sketchup::require 'geores_src/geores_schema/geores_material/gres_texcoordlist.rb'
Sketchup::require 'geores_src/geores_schema/geores_material/gres_target.rb'

class GRESCityGMLExporter
  def initialize filestring,dx,dy,dz,lod,cgml,iswfst,classesToExport, texfolder
    @model = Sketchup.active_model
    @cityobjects = Hash.new()
    @materials = Hash.new()
    @counter = 0
    @translx = dx.to_f
    @transly = dy.to_f
    @translz = dz.to_f
    @isWFST = iswfst
    @citygmlVersion = cgml
    @textureFolder = texfolder
    @lodsToExport = lod
    @classesToExport = classesToExport
    @objFactory = CityObjectParserFactory.new(@counter)
    @skpfactor = 0.0254
    @texturewriter = Sketchup.create_texture_writer
    @filename = ""
    puts filestring
    if(filestring.index('/') != nil)
       @filedir = filestring[0,filestring.rindex('/')]
       puts @filedir
       @filename = filestring[filestring.rindex('/')+1,filestring.length]
       puts @filename
    end
    filen = @filename.split(".");
    @filenamewithoutxml = filen[0];
  end


  def writetoCityGML
    begin
      if(@textureFolder != "")
        Dir.mkdir(@filedir+ "/" + @textureFolder)unless File.exists?(@filedir+ "/" + @textureFolder)
      end
      
     GRES_CGMLDebugger.init
    @writer = File.open(@filedir+"/"+ @filename, "w")
    rescue =>e
       UI.messagebox "Please insert a valid file path.", MB_OK
      return
    end
    entities = @model.active_entities
    entities.each {|entity|
             if(entity.class == Sketchup::Face)
                if(entity.material != nil and entity.material.texture != nil)
                  @texturewriter.load(entity, true)
                end
              elsif(entity.class == Sketchup::Group)
                loadtextures(entity.entities, @texturewriter)
              elsif(entity.class == Sketchup::ComponentInstance)
                loadtextures(entity.definition.entities, @texturewriter)
              end
    }
    if(@textureFolder != "")
          @texturewriter.write_all(@filedir+ "/" + @textureFolder, false)
     else
       @texturewriter.write_all(@filedir, false)
     end

    
   
    GRES_CGMLDebugger.writedebugstring("GRESCityGMLExporter : Translation is : " + @translx.to_s + " " + @transly.to_s + " " + @translz.to_s + "\n")

    writeheader()
    #Vorabbehandlung der Impliziten Geometrien
    usedEntities = Hash.new()
    implicitRefObjects = Hash.new()
    implicitObjects = Hash.new()
    entities.each { |ent|
    if(ent.class == Sketchup::Group or ent.class == Sketchup::ComponentInstance)
      groupdict = ent.attribute_dictionary "groupatts"
      if(groupdict != nil)
        internalname = groupdict["internalname"]
        referenceName = groupdict["referencename"]
        if(internalname != nil)
          isReference = groupdict["isReference"]
          lod = groupdict["lod"]
          if(isExportClass(internalname) == false or lod == nil or @lodsToExport.index(lod) == nil)
            GRES_CGMLDebugger.writedebugstring("GRESCityGMLExporter : " + internalname + "oder" + lod + "nicht in Exportmenge - gehe weiter\n")
            next
          end
          parentObject = nil
          if(isReference == "true")
            parentObject = implicitRefObjects[internalname]
            if(parentObject == nil)
              parentObject = @objFactory.getCityObjectForName(internalname)
               implicitRefObjects[internalname] = parentObject
               GRES_CGMLDebugger.writedebugstring("GRESCityGMLExporter : Neues Link Objekt mit Namen + " + internalname + "angelegt\n")
            end
              fillImplicitGeometry(parentObject, lod, ent)
            
          else
            parentObject = implicitObjects[internalname]
            if(parentObject == nil)
              parentObject = @objFactory.getCityObjectForName(internalname)
              implicitObjects[internalname] = parentObject
            end
             fillImplicitGeometryXLink(parentObject, lod, referenceName, ent)
          end
          usedEntities[ent.entityID] = ent
        end
      end
    end
    }

    implicitObjects.each_value { |value|
        refobject = nil
        xlinkLoD1 = ""
        xlinkLoD2 = ""
        xlinkLoD3 = ""
        xlinkLoD4 = ""
        implLoD1 = nil
        implLoD2 = nil
        implLoD3 = nil
        implLoD4 = nil
        value.implicitgeometriesLod1.each { |impl|
          refobject = implicitRefObjects[impl.parent]
          if(refobject != nil)
            refobject.implicitgeometriesLod1.each { |ref_imp|
              xlinkLoD1 = ref_imp.gmlid
            }
            impl.setxlink(xlinkLoD1)
            implLoD1 = impl
            refobject.implicitgeometriesLod2.each { |ref_imp|
              xlinkLoD2 = ref_imp.gmlid
            }
            if(value.implicitgeometriesLod2.length == 0 and xlinkLoD2 != "")
              implLoD2 = GRES_ImplicitGeometry.new
              implLoD2.settransformation(implLoD1.trafo)
              implLoD2.settransformationpoint(implLoD1.trafopoint)
              implLoD2.setxlink(xlinkLoD2)
              value.addImplicitGeometry(implLoD2, "lod2")
            elsif(xlinkLoD2 != "")
               value.implicitgeometriesLod2.each { |impl|
                 impl.setxlink(xlinkLoD2)
               }
            end
            refobject.implicitgeometriesLod3.each { |ref_imp|
              xlinkLoD3 = ref_imp.gmlid
            }
            if(value.implicitgeometriesLod3.length == 0 and xlinkLoD3 != "")
              implLoD3 = GRES_ImplicitGeometry.new
              implLoD3.settransformation(implLoD1.trafo)
              implLoD3.settransformationpoint(implLoD1.trafopoint)
              implLoD3.setxlink(xlinkLoD3)
              value.addImplicitGeometry(implLoD3, "lod3")
            elsif(xlinkLoD3 != "")
               value.implicitgeometriesLod3.each { |impl|
                 impl.setxlink(xlinkLoD3)
               }
            end
            refobject.implicitgeometriesLod4.each { |ref_imp|
              xlinkLoD4 = ref_imp.gmlid
            }
            if(value.implicitgeometriesLod4.length == 0 and xlinkLoD4 != "")
              implLoD4 = GRES_ImplicitGeometry.new
              implLoD4.settransformation(implLoD1.trafo)
              implLoD4.settransformationpoint(implLoD1.trafopoint)
              implLoD4.setxlink(xlinkLoD4)
              value.addImplicitGeometry(implLoD4, "lod4")
            elsif(xlinkLoD4 != "")
               value.implicitgeometriesLod4.each { |impl|
                 impl.setxlink(xlinkLoD4)
               }
            end

          end
        }
        #LOD2 ist vorhanden
         value.implicitgeometriesLod2.each { |impl|
          refobject = implicitRefObjects[impl.parent]
          if(refobject != nil)
            refobject.implicitgeometriesLod2.each { |ref_imp|
              xlinkLoD2 = ref_imp.gmlid
            }
            impl.setxlink(xlinkLoD2)
            implLoD2 = impl
            refobject.implicitgeometriesLod1.each { |ref_imp|
              xlinkLoD1 = ref_imp.gmlid
            }
            if(value.implicitgeometriesLod1.length == 0 and xlinkLoD1 != "")
              implLoD1 = GRES_ImplicitGeometry.new
              implLoD1.settransformation(implLoD2.trafo)
              implLoD1.settransformationpoint(implLoD2.trafopoint)
              implLoD1.setxlink(xlinkLoD1)
              value.addImplicitGeometry(implLoD1, "lod1")
            elsif(xlinkLoD1 != "")
               value.implicitgeometriesLod1.each { |impl|
                 impl.setxlink(xlinkLoD1)
               }
            end
            refobject.implicitgeometriesLod3.each { |ref_imp|
              xlinkLoD3 = ref_imp.gmlid
            }
            if(value.implicitgeometriesLod3.length == 0 and xlinkLoD3 != "")
              implLoD3 = GRES_ImplicitGeometry.new
              implLoD3.settransformation(implLoD2.trafo)
              implLoD3.settransformationpoint(implLoD2.trafopoint)
              implLoD3.setxlink(xlinkLoD3)
              value.addImplicitGeometry(implLoD3, "lod3")
            elsif(xlinkLoD3 != "")
               value.implicitgeometriesLod3.each { |impl|
                 impl.setxlink(xlinkLoD3)
               }
            end
            refobject.implicitgeometriesLod4.each { |ref_imp|
              xlinkLoD4 = ref_imp.gmlid
            }
            if(value.implicitgeometriesLod4.length == 0 and xlinkLoD4 != "")
              implLoD4 = GRES_ImplicitGeometry.new
              implLoD4.settransformation(implLoD2.trafo)
              implLoD4.settransformationpoint(implLoD2.trafopoint)
              implLoD4.setxlink(xlinkLoD4)
              value.addImplicitGeometry(implLoD4, "lod4")
            elsif(xlinkLoD4 != "")
               value.implicitgeometriesLod4.each { |impl|
                 impl.setxlink(xlinkLoD4)
               }
            end

          end
        }
        #LOD3 ist vorhanden
         value.implicitgeometriesLod3.each { |impl|
          refobject = implicitRefObjects[impl.parent]
          if(refobject != nil)
            refobject.implicitgeometriesLod3.each { |ref_imp|
              xlinkLoD3 = ref_imp.gmlid
            }
            impl.setxlink(xlinkLoD3)
            implLoD3 = impl
            refobject.implicitgeometriesLod2.each { |ref_imp|
              xlinkLoD2 = ref_imp.gmlid
            }
            if(value.implicitgeometriesLod2.length == 0 and xlinkLoD2 != "")
              implLoD2 = GRES_ImplicitGeometry.new
              implLoD2.settransformation(implLoD3.trafo)
              implLoD2.settransformationpoint(implLoD3.trafopoint)
              implLoD2.setxlink(xlinkLoD2)
              value.addImplicitGeometry(implLoD2, "lod2")
            elsif(xlinkLoD2 != "")
               value.implicitgeometriesLod2.each { |impl|
                 impl.setxlink(xlinkLoD2)
               }
            end
            refobject.implicitgeometriesLod1.each { |ref_imp|
              xlinkLoD1 = ref_imp.gmlid
            }
            if(value.implicitgeometriesLod1.length == 0 and xlinkLoD1 != "")
              implLoD1 = GRES_ImplicitGeometry.new
              implLoD1.settransformation(implLoD3.trafo)
              implLoD1.settransformationpoint(implLoD3.trafopoint)
              implLoD1.setxlink(xlinkLoD1)
              value.addImplicitGeometry(implLoD1, "lod1")
            elsif(xlinkLoD1 != "")
               value.implicitgeometriesLod1.each { |impl|
                 impl.setxlink(xlinkLoD1)
               }
            end
            refobject.implicitgeometriesLod4.each { |ref_imp|
              xlinkLoD4 = ref_imp.gmlid
            }
            if(value.implicitgeometriesLod4.length == 0 and xlinkLoD4 != "")
              implLoD4 = GRES_ImplicitGeometry.new
              implLoD4.settransformation(implLoD3.trafo)
              implLoD4.settransformationpoint(implLoD3.trafopoint)
              implLoD4.setxlink(xlinkLoD4)
              value.addImplicitGeometry(implLoD4, "lod4")
            elsif(xlinkLoD4 != "")
               value.implicitgeometriesLod4.each { |impl|
                 impl.setxlink(xlinkLoD4)
               }
            end

          end
        }
        #LoD4 ist vorhanden
        value.implicitgeometriesLod4.each { |impl|
          refobject = implicitRefObjects[impl.parent]
          if(refobject != nil)
            refobject.implicitgeometriesLod4.each { |ref_imp|
              xlinkLoD4 = ref_imp.gmlid
            }
            impl.setxlink(xlinkLoD4)
            implLoD4 = impl
            refobject.implicitgeometriesLod2.each { |ref_imp|
              xlinkLoD2 = ref_imp.gmlid
            }
            if(value.implicitgeometriesLod2.length == 0 and xlinkLoD2 != "")
              implLoD2 = GRES_ImplicitGeometry.new
              implLoD2.settransformation(implLoD4.trafo)
              implLoD2.settransformationpoint(implLoD4.trafopoint)
              implLoD2.setxlink(xlinkLoD2)
              value.addImplicitGeometry(implLoD2, "lod2")
            elsif(xlinkLoD2 != "")
               value.implicitgeometriesLod2.each { |impl|
                 impl.setxlink(xlinkLoD2)
               }
            end
            refobject.implicitgeometriesLod3.each { |ref_imp|
              xlinkLoD3 = ref_imp.gmlid
            }
            if(value.implicitgeometriesLod3.length == 0 and xlinkLoD3 != "")
              implLoD3 = GRES_ImplicitGeometry.new
              implLoD3.settransformation(implLoD1.trafo)
              implLoD3.settransformationpoint(implLoD1.trafopoint)
              implLoD3.setxlink(xlinkLoD3)
              value.addImplicitGeometry(implLoD3, "lod3")
            elsif(xlinkLoD3 != "")
               value.implicitgeometriesLod3.each { |impl|
                 impl.setxlink(xlinkLoD3)
               }
            end
            refobject.implicitgeometriesLod1.each { |ref_imp|
              xlinkLoD1 = ref_imp.gmlid
            }
            if(value.implicitgeometriesLod1.length == 0 and xlinkLoD1 != "")
              implLoD1 = GRES_ImplicitGeometry.new
              implLoD1.settransformation(implLoD4.trafo)
              implLoD1.settransformationpoint(implLoD4.trafopoint)
              implLoD1.setxlink(xlinkLoD1)
              value.addImplicitGeometry(implLoD1, "lod1")
            elsif(xlinkLoD1 != "")
               value.implicitgeometriesLod1.each { |impl|
                 impl.setxlink(xlinkLoD1)
               }
            end
            
          end
        }

    }

    entities.each{ |ent|
      if(usedEntities[ent.entityID] != nil)
        next
      end
      if(ent.class == Sketchup::Face)
        fillCityObjectsWithFace(ent, nil)
      elsif(ent.class == Sketchup::Group)
        fillCityObjectsWithGroup(ent.entities, ent.transformation)
      elsif(ent.class == Sketchup::ComponentInstance)
        fillCityObjectsWithGroup(ent.definition.entities, ent.transformation)
      end
    }
    @materials.each_value { |value|
      @writer << value.writeToCityGML(@isWFST)
    }
    @cityobjects.each_value { |value|
      @writer << value.writeToCityGML(@isWFST, "")

    }
    implicitRefObjects.each_value { |value|
          @writer << value.writeToCityGML(@isWFST, "")
    }
     implicitObjects.each_value { |value|
          @writer << value.writeToCityGML(@isWFST, "")
    }


      if(@isWFST == "true")
       @writer << "</wfs:Transaction>\n"
     else
       @writer << "</core:CityModel>\n"
     end
    # puts "Anzahl Texturen " + @texturewriter.length.to_s

     @writer.close()
     UI.messagebox("Exported succesfully to " + @filedir+"/"+ @filename + "\n" , MB_MULTILINE)

  end

  ####


  ##Nur eine Fläche mit der Textur erhält diese momentan....

  ###

  def loadtextures(ent, tw)
      ent.each do |e|
        if(e.class ==Sketchup::Group)
         loadtextures(e.entities, tw)
        elsif(e.class == Sketchup::ComponentInstance)
         loadtextures(e.definition.entities, tw)
        elsif(e.class == Sketchup::Face)
         if(e.material != nil and e.material.texture != nil)
            tw.load(e, true)
          end
        end
      end
    end



  def fillImplicitGeometryXLink(parentObject, lod, referenceName, entity)
    implGeom = GRES_ImplicitGeometry.new()
    trafo = entity.transformation
    array = trafo.to_a
    x = (array.at(12).to_f*@skpfactor)
    y = (array.at(13).to_f*@skpfactor)
    z = (array.at(14).to_f*@skpfactor)
    x = x +@translx
    y = y +@transly
    z = z +@translz
    point = Geom::Point3d.new(x,y,z)
    implGeom.settransformationpoint(point)

    array[12] = 0.0
    array[13] = 0.0
    array[14] = 0.0
    implGeom.settransformation(Geom::Transformation.new(array))
    implGeom.setparent(referenceName)
    parentObject.addImplicitGeometry(implGeom, lod)
  end

  def fillImplicitGeometry(parentObject, lod, entity)

    implGeom = GRES_ImplicitGeometry.new()
    GRES_CGMLDebugger.writedebugstring("GRESCityGMLExporter : In fillImplicitGeometry \n")
    gmlid = "MultiGMLID " + "_" + rand(2000).to_s + "_" + rand(900000).to_s+"_" + rand(432222).to_s + "_" + rand(1000).to_s
    implGeom.setid(gmlid)
    trafo = entity.transformation
    array = trafo.to_a
    x = (array.at(12).to_f*@skpfactor)
    y = (array.at(13).to_f*@skpfactor)
    z = (array.at(14).to_f*@skpfactor)
    x = x +@translx
    y = y +@transly
    z = z +@translz
    point = Geom::Point3d.new(x,y,z)
    implGeom.settransformationpoint(point)
    array[12] = 0.0
    array[13] = 0.0
    array[14] = 0.0
    implGeom.settransformation(Geom::Transformation.new(array))
    if(entity.class == Sketchup::Group)
      entity.entities.each{ |ent|
        if(ent.class == Sketchup::Face)
          addFaceToImplGeom(implGeom, ent, nil)
        elsif(ent.class == Sketchup::Group)
          handleImplicitGroup(implGeom, ent.entities, ent.transformation)
        elsif(ent.class == Sketchup::ComponentInstance)
          handleImplicitGroup(implGeom,ent.definition.entities, ent.transformation)
        end
      }
    elsif(entity.class == Sketchup::ComponentInstance)
      entity.definition.entities.each{ |ent|
        if(ent.class == Sketchup::Face)
          addFaceToImplGeom(implGeom, ent, nil)
         elsif(ent.class == Sketchup::Group)
          handleImplicitGroup(implGeom, ent.entities, ent.transformation)
        elsif(ent.class == Sketchup::ComponentInstance)
          handleImplicitGroup(implGeom,ent.definition.entities, ent.transformation)
        end
      }
    end
    parentObject.addImplicitGeometry(implGeom, lod)
  end

  def handleImplicitGroup(implGeom, entities, trafo)
     entities.each{ |ent|
      if(ent.class == Sketchup::Face)
        addFaceToImplGeom(implGeom, ent, trafo)
      elsif(ent.class == Sketchup::Group)
        handleImplicitGroup(implGeom, ent.entities,trafo * ent.transformation)
      elsif(ent.class == Sketchup::ComponentInstance)
        handleImplicitGroup(implGeom, ent.definition.entities,trafo * ent.transformation)
      end
    }
  end


  def addFaceToImplGeom(implGeom, ent, trafo)
   faceatts = ent.attribute_dictionary("faceatts", true)
  GRES_CGMLDebugger.writedebugstring("GRESCityGMLExporter : In addFaceToImplGeom \n")
    surface = GRES_Surface.new()
    gmlid = faceatts["id"]
    if(gmlid == nil)
      GRES_CGMLDebugger.writedebugstring("GRESCityGMLExporter GML:ID Attribut ist nil \n")
      gmlid = "PolyGMLID" + "_" + rand(2000).to_s + "_" + rand(900000).to_s+"_" + rand(432222).to_s + "_" + rand(1000).to_s
      faceatts["id"] = gmlid
    end
    surface.setgmlid(gmlid)
    ent.loops.each { |loop|
      counter = 0
      linRing = GRES_LinearRing.new()
      loop.vertices.each { |v|
         position = v.position
         tpos = nil
         if(trafo != nil)
           tpos = trafo * position
         else
           tpos = position
         end

         xf = ((tpos.x.to_f)*@skpfactor)
         yf = ((tpos.y.to_f)*@skpfactor)
         zf = ((tpos.z.to_f)*@skpfactor)
         GRES_CGMLDebugger.writedebugstring("GRESCityGMLExporter Erzeuge Punkt mit Koordinaten " + xf.to_s + " " + yf.to_s + " " + zf.to_s + "  \n")

         linRing.addPointToExport(xf,yf,zf)
      }
      if(gmlid != nil)
          linRing.setgmlid(surface.gmlid + "_" + counter.to_s)
      end
      if(loop.outer?)
        surface.addExternalRing(linRing)
      else
        surface.addInternalRing(linRing)
      end
      counter = counter + 1
    }
    implGeom.addGeometry(surface)
    mat = ent.material
    if(mat != nil)
      handleMaterial(mat, ent, faceatts)
    end

  end


def writeheader()

    if(@citygmlVersion == "2")
         if(@isWFST == "true")
            @writer <<  "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n"
            @writer << "<!--CityGML WFS-T Dataset produced with CityGML Export Plugin for Sketchup by GEORES -->\n"
            @writer << "<!--http://www.geores.de -->\n"
                      @writer << "<wfs:Transaction version=\"1.1.0\" service=\"WFS\" xmlns:ogc=\"http://www.opengis.net/ogc\" xmlns:wfs=\"http://www.opengis.net/wfs\" xmlns=\"http://www.opengis.net/citygml/2.0\" xmlns:xAL=\"urn:oasis:names:tc:ciq:xsdschema:xAL:2.0\"
              xmlns:app=\"http://www.opengis.net/citygml/appearance/2.0\"
              xmlns:wtr=\"http://www.opengis.net/citygml/waterbody/2.0\"
              xmlns:gen=\"http://www.opengis.net/citygml/generics/2.0\"
              xmlns:xlink=\"http://www.w3.org/1999/xlink\"
              xmlns:luse=\"http://www.opengis.net/citygml/landuse/2.0\"
              xmlns:tran=\"http://www.opengis.net/citygml/transportation/2.0\"
              xmlns:frn=\"http://www.opengis.net/citygml/cityfurniture/2.0\"
              xmlns:veg=\"http://www.opengis.net/citygml/vegetation/2.0\"
              xmlns:tun=\"http://www.opengis.net/citygml/tunnel/2.0\"
              xmlns:tex=\"http://www.opengis.net/citygml/textures/2.0\"
              xmlns:brid=\"http://www.opengis.net/citygml/bridge/2.0\" xmlns:gml=\"http://www.opengis.net/gml\"
              xmlns:core=\"http://www.opengis.net/citygml/base/2.0\"
              xmlns:dem=\"http://www.opengis.net/citygml/relief/2.0\"
              xmlns:bldg=\"http://www.opengis.net/citygml/building/2.0\">\n"
         else
                 @writer <<  "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n"
                @writer << "<!--CityGML Dataset produced with CityGML Export Plugin for Sketchup by GEORES -->\n"
                @writer << "<!--http://www.geores.de -->\n"
                @writer << "<core:CityModel xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
                xsi:schemaLocation=\"http://www.opengis.net/citygml/2.0 ./CityGML_2.0/CityGML.xsd\"
                xmlns=\"http://www.opengis.net/citygml/2.0\" xmlns:xAL=\"urn:oasis:names:tc:ciq:xsdschema:xAL:2.0\"
                xmlns:app=\"http://www.opengis.net/citygml/appearance/2.0\"
                xmlns:wtr=\"http://www.opengis.net/citygml/waterbody/2.0\"
                xmlns:gen=\"http://www.opengis.net/citygml/generics/2.0\"
                xmlns:xlink=\"http://www.w3.org/1999/xlink\"
                xmlns:luse=\"http://www.opengis.net/citygml/landuse/2.0\"
                xmlns:tran=\"http://www.opengis.net/citygml/transportation/2.0\"
                xmlns:frn=\"http://www.opengis.net/citygml/cityfurniture/2.0\"
                xmlns:veg=\"http://www.opengis.net/citygml/vegetation/2.0\"
                xmlns:tun=\"http://www.opengis.net/citygml/tunnel/2.0\"
                xmlns:tex=\"http://www.opengis.net/citygml/textures/2.0\"
                xmlns:brid=\"http://www.opengis.net/citygml/bridge/2.0\" xmlns:gml=\"http://www.opengis.net/gml\"
                xmlns:core=\"http://www.opengis.net/citygml/2.0\"
                xmlns:dem=\"http://www.opengis.net/citygml/relief/2.0\"
                xmlns:bldg=\"http://www.opengis.net/citygml/building/2.0\">\n"
         end
    else
      if(@isWFST == "true")
          @writer <<  "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n"
          @writer << "<!--CityGML WFS-T Dataset produced with CityGML Export Plugin for Sketchup by GEORES -->\n"
          @writer << "<!--http://www.geores.de -->\n"
          @writer << "<wfs:Transaction version=\"1.1.0\" service=\"WFS\" xmlns:ogc=\"http://www.opengis.net/ogc\" xmlns:wfs=\"http://www.opengis.net/wfs\" xmlns=\"http://www.opengis.net/citygml/profiles/base/1.0\" xmlns:core=\"http://www.opengis.net/citygml/1.0\" xmlns:bldg=\"http://www.opengis.net/citygml/building/1.0\" xmlns:grp=\"http://www.opengis.net/citygml/cityobjectgroup/1.0\"
      xmlns:app=\"http://www.opengis.net/citygml/appearance/1.0\" xmlns:gml=\"http://www.opengis.net/gml\" xmlns:xAL=\"urn:oasis:names:tc:ciq:xsdschema:xAL:2.0\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"  xmlns:gen=\"http://www.opengis.net/citygml/generics/1.0\"
      xsi:schemaLocation=\"http://www.opengis.net/citygml/1.0 http://schemas.opengis.net/citygml/1.0/cityGMLBase.xsd  http://www.opengis.net/citygml/appearance/1.0 http://schemas.opengis.net/citygml/appearance/1.0/appearance.xsd http://www.opengis.net/citygml/building/1.0 http://schemas.opengis.net/citygml/building/1.0/building.xsd
     http://www.opengis.net/citygml/generics/1.0 http://schemas.opengis.net/citygml/generics/1.0/generics.xsd http://www.opengis.net/wfs http://schemas.opengis.net/wfs/1.1.0/wfs.xsd\">\n"
    else
          @writer <<  "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n"
          @writer << "<!--CityGML Dataset produced with CityGML Export Plugin for Sketchup by GEORES -->\n"
          @writer << "<!--http://www.geores.de -->\n"
          @writer << "<core:CityModel xmlns=\"http://www.opengis.net/citygml/1.0\" xmlns:core=\"http://www.opengis.net/citygml/1.0\" xmlns:bldg=\"http://www.opengis.net/citygml/building/1.0\" xmlns:grp=\"http://www.opengis.net/citygml/cityobjectgroup/1.0\"
      xmlns:app=\"http://www.opengis.net/citygml/appearance/1.0\" xmlns:gml=\"http://www.opengis.net/gml\" xmlns:xAL=\"urn:oasis:names:tc:ciq:xsdschema:xAL:2.0\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:gen=\"http://www.opengis.net/citygml/generics/1.0\"
      xsi:schemaLocation=\"http://www.opengis.net/citygml/1.0 http://schemas.opengis.net/citygml/1.0/cityGMLBase.xsd  http://www.opengis.net/citygml/appearance/1.0 http://schemas.opengis.net/citygml/appearance/1.0/appearance.xsd http://www.opengis.net/citygml/building/1.0 http://schemas.opengis.net/citygml/building/1.0/building.xsd http://www.opengis.net/citygml/generics/1.0 http://schemas.opengis.net/citygml/generics/1.0/generics.xsd\">\n"
    end
    end
    
  end
  
  def fillCityObjectsWithGroup entities, trafo
    entities.each{ |ent|
      if(ent.class == Sketchup::Face)
        fillCityObjectsWithFace(ent, trafo)
      elsif(ent.class == Sketchup::Group)
        fillCityObjectsWithGroup(ent.entities,trafo * ent.transformation)
      elsif(ent.class == Sketchup::ComponentInstance)
        fillCityObjectsWithGroup(ent.definition.entities,trafo * ent.transformation)
      end
    }
  end




  def fillCityObjectsWithFace face, trafo
    faceatts = face.attribute_dictionary("faceatts", true)
    parent0 = faceatts["parent0"]
    lod = faceatts["lod"]
    if(parent0 == nil or lod == nil)
      return
    end

    if(@lodsToExport.index(lod) == nil)
      puts "lod " + lod.to_s + " nicht in " +  @lodsToExport.to_s + " vorhanden"
    end
    if(isExportClass(parent0) == false)
      puts "Klasse " + parent0 + " ist keine Export Klasse "
    end

    if(isExportClass(parent0) == false or lod == nil or @lodsToExport.index(lod) == nil)
      puts "returniere weil -> kein Export"
      return
    end
    
    parentObject = nil
    if(parent0 != nil)
      GRES_CGMLDebugger.writedebugstring("GRESCityGMLExporter : Parent 0 ist : " + parent0 + "\n")
      parentObject = @cityobjects[parent0]
      if(parentObject == nil)
        parentObject = @objFactory.getCityObjectForName(parent0)
         parentObject.setname(parent0)
        fillattributes(parentObject)
       
        @cityobjects[parent0] = parentObject
      end
    end
    count = 1
    currentParent = parentObject
    while(count < 8)
      parentI = faceatts["parent" + count.to_s]
      if(parentI != nil)
        GRES_CGMLDebugger.writedebugstring("GRESCityGMLExporter : Parent I ist : " + parentI + "\n")
        parentIObject = nil
        #@objFactory.getCityObjectForName(parentI)
        if(isBoundary(parentI) == true)
          parentIObject = currentParent.boundaries[parentI]
          if(parentIObject == nil)
            parentIObject = @objFactory.getCityObjectForName(parentI)
              parentIObject.setname(parentI)
            fillattributes(parentIObject)
            currentParent.addBoundary(parentIObject)
          end
          currentParent = parentIObject
        elsif(isPart(parentI) == true)
           parentIObject = currentParent.parts[parentI]
          if(parentIObject == nil)
            parentIObject = @objFactory.getCityObjectForName(parentI)
            parentIObject.setname(parentI)
            fillattributes(parentIObject)
            currentParent.addPart(parentIObject)
          end
          currentParent = parentIObject
          parentObject = currentParent
        elsif(isInst(parentI) == true)
          parentIObject = currentParent.installations[parentI]
          if(parentIObject == nil)
            parentIObject = @objFactory.getCityObjectForName(parentI)
            parentIObject.setname(parentI)
            fillattributes(parentIObject)
            currentParent.addInstallation(parentIObject)
          end
          currentParent = parentIObject
        elsif(isConstr(parentI) == true)
           parentIObject = currentParent.bridgeConstructions[parentI]
          if(parentIObject == nil)
            parentIObject = @objFactory.getCityObjectForName(parentI)
            parentIObject.setname(parentI)
            fillattributes(parentIObject)
            currentParent.addBridgeConstruction(parentIObject)
          end
          currentParent = parentIObject
        elsif(isTrafficArea(parentI) == true)
           parentIObject = currentParent.trafficAreas[parentI]
          if(parentIObject == nil)
            parentIObject = @objFactory.getCityObjectForName(parentI)
            parentIObject.setname(parentI)
            fillattributes(parentIObject)
            currentParent.addTrafficArea(parentIObject)
          end
          currentParent = parentIObject

        elsif(isOpening(parentI) == true)
           parentIObject = currentParent.openings[parentI]
          if(parentIObject == nil)
            parentIObject = @objFactory.getCityObjectForName(parentI)
            parentIObject.setname(parentI)
            fillattributes(parentIObject)
            currentParent.addOpening(parentIObject)
          end
          currentParent = parentIObject
        end
      end
      count = count + 1
    end
    addfacetoObj(face,currentParent,parentObject, trafo)
    mat = face.material

    if(mat != nil and currentParent.theinternalname.index("TIN") == nil)
      handleMaterial(mat, face, faceatts)

    end
  end

  def handleMaterial(mat, face, faceatts)
       
       id = faceatts["id"]
       if(id == nil)
         return
       end
      cgml_mat = @materials[mat.name]
      if(cgml_mat == nil and mat.texture != nil)
          index = @texturewriter.load(face,true)
          texturename  = @texturewriter.filename(index).to_s
          cgml_mat = @materials[texturename]
      end
      if(cgml_mat != nil)
        if(mat.texture != nil)
          index = @texturewriter.load(face,true)
          extractUVCoords(face, cgml_mat, id)
        else
          cgml_mat.addtarget(GRES_Target.new(id))
        end
      else
        if(mat.texture != nil)
          cgml_mat = GRES_ParameterizedTexture.new(nil)
          index = @texturewriter.load(face,true)
          texturename  = @texturewriter.filename(index).to_s
          newid_texturename = texturename
          #texturename = mat.texture.filename
          texturename = texturename.gsub('\\' , '/')
          if(texturename.index('/') != nil)
            texturename = texturename[texturename.rindex('/')+1,texturename.length]
          end
          if(@textureFolder != nil and @textureFolder != "")
              texturename = "/" + @textureFolder + "/" + texturename
          end
          # @texturewriter.write(face, true, @filedir+ "/" + texturename)
          cgml_mat.addimageURI(texturename)
          extractUVCoords(face, cgml_mat, id)
          @materials[newid_texturename] = cgml_mat
        else
          cgml_mat = GRES_X3DMaterial.new(nil)
          cgml_mat.setColorNew(mat.color)
          cgml_mat.settransparancy(mat.alpha)
          cgml_mat.addtarget(GRES_Target.new(id))
          @materials[mat.name] = cgml_mat
        end
      end
  end

  def isExportClass classNameToCheck
    if(classNameToCheck == nil)
      return false
    end
    isExport = false
    @classesToExport.each { |name|
        if(classNameToCheck.index(name) != nil)
          isExport = true
        end
    }
    return isExport

  end

  def extractUVCoords face, material, id
    uvhelper = face.get_UVHelper(true,false,@texturewriter)
       t = GRES_Target.new(id)
       loopcounter = 0
       face.loops.each{ |loop|

         if(loop.outer?)
           texList = GRES_TexCoordList.new()
           texList.seturi(id + "_" + loopcounter.to_s)
            loop.vertices.each{ |v|
              uvq = uvhelper.get_front_UVQ(v.position)
              po = Geom::Point3d.new(round_to(uvq.x,4).to_f,round_to(uvq.y,4).to_f,0)
              texList.addcord(po)
              
            }
            t.addcoordlist(texList)
         end
         loopcounter = loopcounter + 1
       }
       material.addtarget(t)
  end

     def round_to(number, fac)
          return (number * 10**fac).round.to_f/10**fac
    end


  def addfacetoObj(face, currentParent, parentObject, trafo)
    faceatts = face.attribute_dictionary("faceatts", false)
    if(faceatts == nil)
      GRES_CGMLDebugger.writedebugstring("GRESCityGMLExporter Kein Attribut Dictionary für Face \n")
      return
    end
    surface = GRES_Surface.new()
    gmlid = faceatts["id"]
    if(currentParent.theinternalname.index("TIN") == nil)
      GRES_CGMLDebugger.writedebugstring("GRESCityGMLExporter GML:ID Attribut ist nil \n")
      gmlid = "PolyGMLID" + "_" + rand(180000).to_s + "_" + rand(900000).to_s+"_" + rand(432222).to_s + "_" + rand(10000).to_s
      faceatts["id"] = gmlid
    end
    surface.setgmlid(gmlid)
    face.loops.each { |loop|
      counter = 0
      linRing = GRES_LinearRing.new()
      loop.vertices.each { |v|
         position = v.position
         tpos = nil
         if(trafo != nil)
           tpos = trafo * position
         else
           tpos = position
         end

         xf = ((tpos.x.to_f*@skpfactor)+@translx)
         yf = ((tpos.y.to_f*@skpfactor)+@transly)
         zf = ((tpos.z.to_f*@skpfactor)+@translz)
         GRES_CGMLDebugger.writedebugstring("GRESCityGMLExporter Erzeuge Punkt mit Koordinaten " + xf.to_s + " " + yf.to_s + " " + zf.to_s + "  \n")
        
         linRing.addPointToExport(xf,yf,zf)
      }
      if(gmlid != nil)
          linRing.setgmlid(surface.gmlid + "_" + counter.to_s)
      end
      if(loop.outer?)
        surface.addExternalRing(linRing)
      else
        surface.addInternalRing(linRing)
      end
      counter = counter + 1
    }

    lod = faceatts["lod"]
    if(lod == nil)
      GRES_CGMLDebugger.writedebugstring("GRESCityGMLExporter Kein LOD für Face \n")
      return
    end
    solid = faceatts[lod + "Solid"]
    if(currentParent.theinternalname.index("TIN") != nil)
      currentParent.addTriangle(surface)
    end
    if(solid != nil and currentParent.theinternalname == parentObject.theinternalname)
      currentParent.addSolid(surface, lod)
      GRES_CGMLDebugger.writedebugstring("GRESCityGMLExporter Fuege Face dem Objekt  " + currentParent.theinternalname + " in " + lod.to_s + "Solid hinzu  \n")
    elsif(solid != nil)
      currentParent.addMultiSurface(surface, lod)
      GRES_CGMLDebugger.writedebugstring("GRESCityGMLExporter Fuege Face dem Objekt  " + currentParent.theinternalname + " in " + lod.to_s + "MultiSurface hinzu  \n")
      solidSurface = GRES_Surface.new()
      solidSurface.setxlink(surface.gmlid)
      parentObject.addSolid(solidSurface, lod)
      GRES_CGMLDebugger.writedebugstring("GRESCityGMLExporter Fuege Face dem Objekt  " + parentObject.theinternalname + " in " + lod.to_s + "Solid als xlink hinzu  \n")
    else
      currentParent.addMultiSurface(surface, lod)
      GRES_CGMLDebugger.writedebugstring("GRESCityGMLExporter Fuege Face dem Objekt  " + currentParent.theinternalname + " in " + lod.to_s + "MultiSurface hinzu  \n")
    end
  end



  def isBoundary name

   if(name.index("WallSurface") != nil or name.index("RoofSurface") != nil or name.index("ClosureSurface") != nil or name.index("GroundSurface") != nil or
        name.index("CeilingSurface") != nil or name.index("FloorSurface") != nil or name.index("WaterSurface") != nil)
      return true
    end
    return false
  end
  
  def isInst name

   if(name.index("BuildingInstallation") != nil or name.index("TunnelInstallation") != nil or name.index("BridgeInstallation") != nil )
      return true
    end
    return false
  end
  
  def isPart name

   if(name.index("BuildingPart") != nil or name.index("BridgePart") != nil or name.index("TunnelPart") != nil )
      return true
    end
    return false
  end

 def isConstr name

   if(name.index("BridgeConstructionElement") != nil )
      return true
    end
    return false
  end

 def isOpening name

   if(name.index("Window") != nil or name.index("Door") != nil )
      return true
    end
    return false
  end

  def isTrafficArea name

   if(name.index("TrafficArea") != nil )
      return true
    end
    return false
  end


 def fillattributes obj

   objdict = @model.attribute_dictionary(obj.theinternalname, false)
   GRES_CGMLDebugger.writedebugstring("GRESCityGMLExporter : Hole att dict fuer: " + obj.theinternalname + "\n")
   if(objdict == nil)
     GRES_CGMLDebugger.writedebugstring("GRESCityGMLExporter : att dict existiert nicht fuer: " + obj.theinternalname + "\n")
     return
   end
   objdict.each_pair { |key, value|
     puts "Key is " + key + " Value is " + value
     if(key == "gmlid")
       obj.setgmlid(value)
     elsif(key == "parent" or key == "type")
       next
     else
       att = SimpleCityObjectAttribute.new(key, value)
       att.addValue(value)
       obj.addSimpleAttribute(att)
     end
   }
   
 end


end


