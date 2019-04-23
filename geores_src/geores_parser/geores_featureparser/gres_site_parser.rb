# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_parser/cityobjectparser.rb'
Sketchup::require 'geores_src/geores_parser/geores_featureparser/gres_installation_parser.rb'
Sketchup::require 'geores_src/geores_parser/geores_featureparser/gres_boundary_parser.rb'
Sketchup::require 'geores_src/geores_schema/geores_attributes/simple_city_object_attribute.rb'
Sketchup::require 'geores_src/geores_debug/gres_cgmldebugger.rb'

class GRES_SiteParser < CityObjectParser





 def initialize(cityobject,factory)
    super(cityobject, factory)
      @currentSitePartParser = nil
      @isInSitePart = false

      @currentSiteGRES_InstallationParser = nil
      @isInSiteInstallation = false

      @currentSiteGRES_BoundaryParser = nil
      @isInSiteBoundary = false

      @nextisclassname = false
  end

   def tag_start name, attrs
     puts("Name to parse is " + name)
     GRES_CGMLDebugger.writedebugstring("GRES_SiteParser in tag_start mit " + name + "\n")
      if(@isInSitePart == true)
        if(@nextisclassname == true)
          @currentSitePartParser = @factory.getCityObjectParserForName(name);
          #if(@currentSitePartParser == nil)
           # @isInSitePart = false
           # @nextisclassname = false
          #  return false
         # end
          @nextisclassname = false
        end
        if(@currentSitePartParser != nil)
           @currentSitePartParser.tag_start(name, attrs)
        end
       
        return false
      end
       if(@isInSiteInstallation == true)
         if(@nextisclassname == true)
           GRES_CGMLDebugger.writedebugstring("Current name is" + name +" get Parser for name\n")
          @currentSiteGRES_InstallationParser = @factory.getCityObjectParserForName(name);
          #if(@currentSiteGRES_InstallationParser == nil)
          #  @isInSiteInstallation = false
           # @nextisclassname = false
          #  return false
          #end
          @nextisclassname = false
        end
        GRES_CGMLDebugger.writedebugstring("Try to open tag_start of GRES_InstallationParser \n")
         if(@currentSiteGRES_InstallationParser != nil)
              @currentSiteGRES_InstallationParser.tag_start(name, attrs)
         end
        return false
      end
       if(@isInSiteBoundary == true)
         if(@nextisclassname == true)
           puts "Name is " +name
          @currentSiteGRES_BoundaryParser = @factory.getCityObjectParserForName(name);
           #if(@currentSiteGRES_BoundaryParser == nil)
           # @isInSiteBoundary = false
            #@nextisclassname = false
            #puts "Set @isInSiteBoundary = false and @nextisclassname = false and return false"
            #return false
          #end
          @nextisclassname = false
        end
        if(@currentSiteGRES_BoundaryParser != nil)
          @currentSiteGRES_BoundaryParser.tag_start(name, attrs)
        end
        return false
      end
       puts "try to go in to cityobject tag_start"
       b = super(name,attrs)
       puts b.to_s
       if(b == false)
         puts "tag_start of cityobject returned false"
         return false
       end
      puts "tag_start of cityobject returned true"
      if(name.index("consistsOfBridgePart") != nil or name.index("consistsOfTunnelPart") != nil or name.index("consistsOfBuildingPart") != nil)
        @nextisclassname = true
        @isInSitePart = true
        return false
      end

      if(name.index("outerBridgeInstallation") != nil or name.index("outerBuildingInstallation") != nil or name.index("outerTunnelInstallation")!= nil)
       GRES_CGMLDebugger.writedebugstring("Found a Installation. Next is classname = true @isInSiteInstallation = true \n")
       @nextisclassname = true
        @isInSiteInstallation = true
        return false
      end

      if(name.index("boundedBy") != nil and name.index("gml:") == nil)
        puts "found a boundary"
         @nextisclassname = true
        @isInSiteBoundary = true
        return false
      end

       if(name.index("class") != nil or name.index("function") != nil or name.index("usage") != nil or
             name.index("yearOfConstruction") != nil or name.index("yearOfDestruction") != nil)
        @currentSimpleAttribute = SimpleCityObjectAttribute.new(name, attrs)
        @isInSimpleAttribute = true
        return false
      end
      
   
      return true
   end


    def text text
      GRES_CGMLDebugger.writedebugstring("GRES_SiteParser in text mit " + text + "\n")
      if(@isInSitePart == true and @currentSitePartParser != nil)
        @currentSitePartParser.text(text)
        return false
      end
      if(@isInSiteInstallation == true and @currentSiteGRES_InstallationParser != nil)
        @currentSiteGRES_InstallationParser.text(text)
        return false
      end
      if(@isInSiteBoundary == true and @currentSiteGRES_BoundaryParser != nil)
        @currentSiteGRES_BoundaryParser.text(text)
        return false
      end
    
      if(super(text) == false)
        return false
      end

      if(@isInSimpleAttribute == true and @currentSimpleAttribute != nil)
        @currentSimpleAttribute.addValue(text)
        return false
      end

      return true
    end

     def tag_end name

        if(name.index("consistsOfBridgePart") != nil or name.index("consistsOfTunnelPart") != nil or name.index("consistsOfBuildingPart") != nil)
              @cityObject.addPart(@currentSitePartParser.cityObject)
              @isInSitePart = false
              @currentSitePartParser = nil
              return false
        end
        if(@isInSitePart == true and @currentSitePartParser != nil)
                @currentSitePartParser.tag_end(name)
                return false
         end
         if(name.index("outerBridgeInstallation") != nil or name.index("outerBuildingInstallation") != nil or name.index("outerTunnelInstallation")!= nil)
              @cityObject.addInstallation(@currentSiteGRES_InstallationParser.cityObject)
              @isInSiteInstallation = false
              @currentSiteGRES_InstallationParser = nil
              return false
         end
           if(@isInSiteInstallation == true and @currentSiteGRES_InstallationParser != nil)
                @currentSiteGRES_InstallationParser.tag_end(name)
                return false
            end
           if(name.index("boundedBy") != nil and name.index("gml:") == nil)
             puts "fuege dem CityObject eine Boundary hinzu"
             if(@currentSiteGRES_BoundaryParser != nil and @currentSiteGRES_BoundaryParser.cityObject != nil)
                    @cityObject.addBoundary(@currentSiteGRES_BoundaryParser.cityObject)
             end
              @isInSiteBoundary = false
              @currentSiteGRES_BoundaryParser = nil
              return false
           end
          
           if(@isInSiteBoundary == true and @currentSiteGRES_BoundaryParser != nil)
                @currentSiteGRES_BoundaryParser.tag_end(name)
                return false
            end
        
             if(super(name) == false)
               "Gehe in Tag End von CityObject " + name
                return false
              end
             if(name.index("class") != nil or name.index("function") != nil or name.index("usage") != nil or
             name.index("yearOfConstruction") != nil or name.index("yearOfDestruction") != nil)
                @cityObject.addSimpleAttribute(@currentSimpleAttribute)
                @isInSimpleAttribute = false
                @currentSimpleAttribute = nil
               return false
           end
           return true
     end

end
