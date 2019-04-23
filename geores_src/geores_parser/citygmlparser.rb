# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'sketchup.rb'
Sketchup::require 'geores_src/geores_import/geores_rexml/streamlistener.rb'
Sketchup::require 'geores_src/geores_parser/cityobjectparserfactory.rb'
Sketchup::require 'geores_src/geores_parser/geores_specific/gres_appearance_parser.rb'
Sketchup::require 'geores_src/geores_debug/gres_cgmldebugger.rb'
Sketchup::require 'geores_src/geores_gui/time.rb'



class CityGMLParser
  include REXML::StreamListener


  


  def initialize counter
    GRES_CGMLDebugger.writedebugstring("++++BEGIN CityGML parsing+++++ \n")
    super()
     GRES_CGMLDebugger.writedebugstring("CityGMLParser: initialize Super Class StreamListener \n")
    @parserFactory = CityObjectParserFactory.new(counter)
    @parsedCityObjects = Array.new()
    @parsedImplicitObjects = Array.new()
    @parsedImplicitRefObjects = Array.new()
    @parsedAppearances = Array.new()
     GRES_CGMLDebugger.writedebugstring("GRES_CityGMLParser: initialized Parser Factory \n")
     @isInSubhandler = false  #hier wird gespeichert ob der Inhalt der folgenden Tags an eine Subroutine weitergereicht wird
     @nextIsClassName = false #hier wird gespeichert, dass als nächster Tag der Klassenname des CityObjektes kommt
     @currentObjectParser = nil
     @isInAppSubHandler = false
     @currentAppearanceParser = nil
     @translX = 0
     @translY = 0
     @translZ = 0
     @currenttag = ""

     @appcounter = 1
     @objcounter = 1
   end

   attr_reader :parsedCityObjects, :parsedAppearances, :translX, :translY, :translZ, :parsedImplicitObjects, :parsedImplicitRefObjects
  
  #wird aufgerufen wenn ein neuer Tag beginnt, also z.B. <bldg:Building gml:id="DEBW000343434">
  def tag_start name, attrs
    @currenttag = name.strip
    
    GRES_CGMLDebugger.writedebugstring("GRES_CityGMLParser: tag_start of CityGMLParser current tag ist " + @currenttag + "\n")
    
    if(@isInSubhandler == true)
      if(@nextIsClassName == true)
        @currentObjectParser = @parserFactory.getCityObjectParserForName(@currenttag);
        if(@currentObjectParser.instance_of?(GRES_CityObjectGroupParser) == true)
          @currentObjectParser.setloader(self)
        end
        GRES_CGMLDebugger.writedebugstring("GRES_CityGMLParser: get ObjectParser for " + name + "\n")
        @nextIsClassName = false;
      end
       @currentObjectParser.tag_start(@currenttag, attrs)
       return;
    end
     if(@isInAppSubHandler == true)
       @currentAppearanceParser.tag_start(@currenttag, attrs)
       return;
    end
    
    if(name.index("cityObjectMember") != nil)
        @isInSubhandler = true;
        @nextIsClassName = true;
        @timeStartCO = Time.now.to_s

        return;
    elsif(name.index("app:surfaceDataMember") != nil)
        @isInAppSubHandler = true;
         GRES_CGMLDebugger.writedebugstring("GRES_CityGMLParser: found appearance init AppearanceParser and set @isInAppSubHandler = true \n")
        @currentAppearanceParser = GRES_AppearanceParser.new();

        return;
    end

    
  end
  
  #wird aufgerufen wenn nach einem Tag Text kommt, also z.B <bldg:yearOfConstruction> 1978 </bldg:yearOfConstruction> 
  #text beinhaltet in diesem Fall: 1978
  def text text
    
      text = text.strip
      GRES_CGMLDebugger.writedebugstring("GRES_CityGMLParser: text  of CityGMLParser current tag ist " + @currenttag + "and text is _" + text + "_\n")
     if(text == "")
       return
     end
     if((@currenttag == "gml:pos" or @currenttag == "gml:posList") and @translX == 0)
        coords = text.split(" ")
        @translX = coords[0].to_f
        @translY = coords[1].to_f
        @translZ = coords[2].to_f
        GRES_CGMLDebugger.writedebugstring("GRES_CityGMLParser: found Position, init Translation " + @translX.to_s + " " + @translY.to_s + " " + @translZ.to_s + "\n")

    end
    if(@isInSubhandler == true and @currentObjectParser != nil)
       @currentObjectParser.text(text)
       return
    end
     if(@isInAppSubHandler == true and @currentAppearanceParser != nil)
       @currentAppearanceParser.text(text)
       return
    end


  end
  
  #wird aufgerufen wenn ein Tag geschlossen wird, also z.B. </bldg:Building>
  def tag_end name
    
     name = name.strip
     GRES_CGMLDebugger.writedebugstring("GRES_CityGMLParser: tag_end of CityGMLParser current tag is " + name + "\n")
     if(name.index("cityObjectMember") != nil)
       
       @objcounter = @objcounter +1
       GRES_CGMLDebugger.writedebugstring("GRES_CityGMLParser: found cityobjectMember closing tag. @isInSubhandler = false \n")
        @isInSubhandler = false;
        co = @currentObjectParser.cityObject
        if(co == nil)
          GRES_CGMLDebugger.writedebugstring("GRES_CityGMLParser: Fehler: retuniertes objekt des @currentObjectParser ist nil \n")
        end
        if(@parsedCityObjects == nil)
          GRES_CGMLDebugger.writedebugstring("GRES_CityGMLParser: Fehler: @parsedCityObjects ist nil. Array nicht initialisiert \n")
        end
        if(co.isImplicitObject == true)
          @parsedImplicitObjects.push(co)
          GRES_CGMLDebugger.writedebugstring("GRES_CityGMLParser: Fuege CityObject " + co.theinternalname + "dem Array @parsedImplicitObjects hinzu \n")
        elsif(co.isImplicitReferenceObject == true)
          @parsedImplicitRefObjects.push(co)
          GRES_CGMLDebugger.writedebugstring("GRES_CityGMLParser: Fuege CityObject " + co.theinternalname + "dem Array @parsedImplicitRefObjects hinzu \n")
        else
          @parsedCityObjects.push(co)
          GRES_CGMLDebugger.writedebugstring("GRES_CityGMLParser: Fuege CityObject " + co.theinternalname + "dem Array @parsedCityObjects hinzu \n")
        end
        
        
        apps = @currentObjectParser.parsedAppearances
        GRES_CGMLDebugger.writedebugstring("GRES_CityGMLParser:Hole interne Appearances \n")
        if(apps != nil and apps.length > 0)
          GRES_CGMLDebugger.writedebugstring("GRES_CityGMLParser:" + apps.length.to_s + "Interne Appearances vorhanden. Dem Array @parsedAppearances hinzufuegen\n")
          apps.each { |app|
              if(appDoesNotExist(app) == true)
                GRES_CGMLDebugger.writedebugstring("GRES_CityGMLParser: Fuege Appearance " + app.name + "mit IDS " + app.ids.to_s + "hinzu\n")
               @parsedAppearances.push(app)
              end
              
          }
        end
        @timeStartEnd = Time.now.to_s
        #UI.messagebox("Startzeit CO Parsing " + @timeStartCO + " Endzeit CO Parsing " + @timeStartEnd)
        @currentObjectParser = nil
        return
     elsif(name.index("app:surfaceDataMember") != nil and @isInSubhandler == false)
        @isInAppSubHandler = false;

       @appcounter = @appcounter +1
       app = @currentAppearanceParser.appearance
       if(appDoesNotExist(app) == true)
            GRES_CGMLDebugger.writedebugstring("GRES_CityGMLParser: Fuege Appearance " + app.name + "mit IDS " + app.ids.to_s + "hinzu\n")
            @parsedAppearances.push(app)
      end
         GRES_CGMLDebugger.writedebugstring("GRES_CityGMLParser: Fuege Appearance " + @currentAppearanceParser.appearance.name + "dem Array @parsedAppearances hinzu \n")
        @currentAppearanceParser = nil
        return
    end
      if(@isInSubhandler == true and @currentObjectParser != nil)
       @currentObjectParser.tag_end(name)
       return;
    end
     if(@isInAppSubHandler == true and @currentAppearanceParser != nil)
       @currentAppearanceParser.tag_end(name)
       return;
    end

  end

  def getcounter
    @parserFactory.counter
  end

  def addImplicitObject obj
    @parsedImplicitObjects.push(obj)
  end

  def addImplicitReferenceObject obj
    @parsedImplicitRefObjects.push(obj)
  end

  def addObject obj
    @parsedCityObjects.push(obj)
  end

  def addAppearances apps
    @parsedAppearances.concat(apps)
  end

  def appDoesNotExist(app)
     retType = true
     if(app.instance_of?(GRES_ParameterizedTexture) == true)
         imageuri = app.imageURI
         @parsedAppearances.each { |parsed_app|
           if(parsed_app.instance_of?(GRES_ParameterizedTexture) == true)
             if(parsed_app.imageURI == imageuri)
               retType = false
               app.targets.each { |t|
                 parsed_app.addtarget(t);
               }
               break
             end
           end
         }
       end
      return retType
  end
end
