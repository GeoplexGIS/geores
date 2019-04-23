# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'sketchup.rb'
Sketchup::require 'geores_src/geores_parser/citygmlparser.rb'
Sketchup::require 'geores_src/geores_debug/gres_cgmldebugger.rb'
Sketchup::require 'geores_src/geores_import/geores_rexml/document.rb'
Sketchup::require 'geores_src/geores_parser/layer_creator.rb'
Sketchup::require 'geores_src/geores_gui/gres_progress.rb'
Sketchup::require 'geores_src/geores_gui/time.rb'

include REXML  # so that we don't have to prefix everything with REXML::...

class CityGMLLoader
  def initialize
    puts "in constructor CityGMLLoader"
    @translX = 0
    @translY = 0
    @translZ = 0
    @currentcounter = 0
    @filedir = ""
    @parsedReferences = Hash.new()
    @parsedImplicitRefObjects = Array.new()
    @parsedImplicitObjs = Array.new()
    @layercreator = LayerCreator.new()
    @createdFaces = Array.new()
    @groups_to_erase = Array.new()

  end

  attr_reader :currentcounter, :translX, :translY , :translZ, :layercreator, :parsedImplicitRefObjects, :isSimple




  def load(file_path, keep_transl, translheight, isSimple)
      GRES_CGMLDebugger.init()
      puts "filepath is " + file_path
     file = File.new( file_path )
     filestring = file_path.gsub('\\' , '/')
     if(filestring.index('/') != nil)
       @filedir = filestring[0,filestring.rindex('/')]
    end
    if(isSimple == "Ja")
      @isSimple = true
    else
      @isSimple = false
    end
    
    GRES_CGMLDebugger.writedebugstring("GRES_CityGMLLoader: filedir is " + @filedir +"\n")
    @model = Sketchup.active_model
    @currentcounter = @model.get_attribute("baseinfos" , "currentcityobjectcount", 0)
    @keep_transl = keep_transl
    @transl_height = translheight
    @tStart = Time.now.to_s
    begin
      parser = CityGMLParser.new(@currentcounter.to_i)
     
      REXML::Document.parse_stream(file, parser)
      if(@keep_transl == "Ja")
            
            dxs = @model.get_attribute "translation", "dx", "0.0"
            dys = @model.get_attribute "translation", "dy", "0.0"
            dzs = @model.get_attribute "translation", "dz", "0.0"
            @translX = dxs.to_f
            @translY = dys.to_f
            @translZ = dzs.to_f
      else
        if(@transl_height == "Ja")
            @translX = parser.translX
            @translY = parser.translY
            @translZ = parser.translZ
        else
            @translX = parser.translX
            @translY = parser.translY
            @translZ = 0
        end
      end
      GRES_CGMLDebugger.writedebugstring("GRES_CityGMLLoader: Verschiebung: " + @translX.to_s + " " + @translY.to_s + " " + @translZ.to_s + "\n")
      GRES_CGMLDebugger.writedebugstring("++++END of PARSING +++++\n")
    rescue => e
      UI.messagebox "GRES_CityGMLLoader: Unerwarteter Fehler beim Lesen:" + e.backtrace.to_s , MB_OK
      GRES_CGMLDebugger.writedebugstring("GRES_CityGMLLoader: Fehler CityGMLLoader " + e.backtrace.to_s + "\n")
      GRES_CGMLDebugger.close()
      return
    end
     @tEndParsing = Time.now.to_s
      #UI.messagebox("Ende der CityGML Interpretation " + @tEndParsing.to_s )

     @currentcounter = parser.getcounter
      GRES_CGMLDebugger.writedebugstring("GRES_CityGMLLoader: Object Counter after parsing is " + @currentcounter.to_s + "\n")
     @model.set_attribute "translation", "dx", @translX
     @model.set_attribute "translation", "dy", @translY
     @model.set_attribute "translation", "dz", @translZ
     cityobjects = parser.parsedCityObjects
     @bp = GRES_Progress.new(cityobjects.length,"Import CityGML Objects")
     @parsedImplicitRefObjects = parser.parsedImplicitRefObjects
     @parsedImplicitObjs = parser.parsedImplicitObjects

     appearances = parser.parsedAppearances
     GRES_CGMLDebugger.writedebugstring("GRES_CityGMLLoader: Anzahl Appearances " + appearances.length.to_s + "\n")
     handleParsedObjects(cityobjects, appearances)
     @tFinished = Time.now.to_s
     @model.set_attribute "baseinfos" , "currentcityobjectcount", @currentcounter
      UI.messagebox("Imported erfolgreich \n" +
         "Startzeit " + @tStart.to_s + "\n" +
         "Ende der CityGML Interpretation " + @tEndParsing.to_s + "\n" +
         "Ende der Erzeugung aller Materialien " + @tFinishedAppearances.to_s + "\n" +
         "Ende der Erzeugung aller Metadaten " +@tFinishedMetadata.to_s + "\n"+
         "Ende des Anlegens aller Sketchup Geometrien " +@tFinishedGeometryCreation.to_s + "\n"+
         "Ende des Einlesevorgangs insgesamt: " + @tFinished.to_s + "\n", MB_MULTILINE)
  end

  def handleParsedObjects cityobjects, appearances
    GRES_CGMLDebugger.writedebugstring("++++BEGINNE Sketchup Objekte zu erzeugen +++++\n")
    appcounter = 1
    messagecounter = 1
    appearances.each { |app|
      app.createskpmaterial(@filedir, @model)

       GRES_CGMLDebugger.writedebugstring("Appearance Name = " + app.name + "Appearance IDs: " + app.ids.to_s + "\n")
       #if(appcounter > 100)
         #@tFinishedAppearances = Time.now.to_s
        # c = appcounter*messagecounter
         #UI.messagebox("App created " + c.to_s + " in " + @tFinishedAppearances.to_s)
        # appcounter = 0
         #messagecounter = messagecounter +1;
      # end
     
      appcounter = appcounter +1
    }
    @tFinishedAppearances = Time.now.to_s
    #UI.messagebox("Ende der Erzeugung aller Materialien " + @tFinishedAppearances.to_s )
    objcounter = 1
    if(@isSimple == false)
          cityobjects.each { |co|
            GRES_CGMLDebugger.writedebugstring("GRES_CityGMLLoader: call buildToSKP for " + co.theinternalname + "\n")

            co.buildToSKP("", @model, co.theinternalname, @currentcounter)
            parents = Array.new()
             GRES_CGMLDebugger.writedebugstring("GRES_CityGMLLoader: call buildgeometries for " + co.theinternalname + "\n")


          }
    end
    
     @tFinishedMetadata = Time.now.to_s
      #UI.messagebox("Ende der Erzeugung aller Metadaten " + @tFinishedMetadata.to_s )
     cityobjects.each { |co|
        parents = Array.new()
          co.buildgeometries(@model.active_entities, appearances, self, parents)
            if(@isSimple == false)
               entities = @model.active_entities
                      @parsedReferences.each_key { |key|
                        #puts "Key ist gleich " + key.to_s
                        entities.each { |ent|
                         if(ent.class == Sketchup::Face)
                           checkFaceReference(ent, key)
                         elsif(ent.class == Sketchup::Group)
                           checkGroupReference(ent, key)
                         end
                        }
                      }
            end

            @bp.update(objcounter)
        objcounter = objcounter +1
          @parsedReferences.clear
     }
     @tFinishedGeometryCreation = Time.now.to_s
    # UI.messagebox("Ende der Erzeugung aller Geometrien " + @tFinishedGeometryCreation.to_s )
    @parsedImplicitRefObjects.each { |co|
        GRES_CGMLDebugger.writedebugstring("GRES_CityGMLLoader: call buildToSKP for " + co.theinternalname + " as implict reference Object\n")
        co.buildToSKP("", @model, co.theinternalname, @currentcounter)
        parents = Array.new()
        GRES_CGMLDebugger.writedebugstring("GRES_CityGMLLoader: call buildgeometries for " + co.theinternalname + "as implict reference Object\n")
        co.buildgeometries(@model.active_entities, appearances, self, parents)
    }
    @parsedImplicitObjs.each { |co|
        GRES_CGMLDebugger.writedebugstring("GRES_CityGMLLoader: call buildToSKP for " + co.theinternalname + " as implict Object\n")
        co.buildToSKP("", @model, co.theinternalname, @currentcounter)
        parents = Array.new()
        GRES_CGMLDebugger.writedebugstring("GRES_CityGMLLoader: call buildgeometries for " + co.theinternalname + "as implict Object\n")
        co.buildgeometries(@model.active_entities, appearances, self, parents)
    }
    
    @groups_to_erase.each { |group|
      entities = @model.active_entities
      entities.erase_entities group
    }

     
     GRES_CGMLDebugger.writedebugstring("++++ENDE der Erzeugung aller Sketchup Objekte +++++\n")
    GRES_CGMLDebugger.close()
  end

  def checkFaceReference(ent, key)
    faceatts = ent.attribute_dictionary("faceatts", false)
    if(faceatts != nil)
      id = faceatts["id"]
      if(id == nil or key == nil)
        return
      end
      puts "ID ist " + id + "Key ist " + key
      if(id == key)
        lod = @parsedReferences[key]
        puts "found reference"
        faceatts[lod.to_s + "Solid"] = "true"
      end
    end
  end
  
  def checkGroupReference(ent, key)
    ent.entities.each { |group_ent| 
        if(group_ent.class == Sketchup::Face)
               checkFaceReference(group_ent, key)
         elsif(group_ent.class == Sketchup::Group)
               checkGroupReference(group_ent, key)
      end
      
    }
  end



  def add_reference lod, xlink
    @parsedReferences[xlink] = lod
  end

  def add_face(face)
    @createdFaces.push(face)
  end

  def settranslation(x,y,z)
    @translX = x
    @translY = y
    @translZ = z
  end

  def add_group_to_erase group
    @groups_to_erase.push group
  end
end
