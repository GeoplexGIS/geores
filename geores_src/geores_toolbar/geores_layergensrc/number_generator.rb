# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_toolbar/geores_layergensrc/name_tester.rb'


class NumberGenerator
  def initialize ()
    initnumbers()
    @nameTester = NameTester.new
    @buildingstring = ""
    @tunnelstring = ""
    @bridgestring = ""
    @genericstring = ""
    @solvegstring = ""
    @cfstring = ""
    @plantcoverstring = ""
  end
  
  attr_accessor :biggestSiteNumber , :biggestPartNumber, :biggestInstallationNumber, :biggestBoundaryNumber, :biggestOpeningNumber,
  :biggestConstructionNumber, :biggestVeggieNumber, :biggestFurnitureNumer, :biggestTransportationNumber, :biggestTrafficAreaNumber,
  :biggestLandUseNumber, :buildingstring, :tunnelstring, :bridgestring, :genericstring, :solvegstring, :cfstring, :plantcoverstring


  def initnumbers
     @biggestSiteNumber = 0
    @biggestPartNumber = 0
    @biggestInstallationNumber = 0
    @biggestBoundaryNumber = 0
    @biggestOpeningNumber = 0
    @biggestConstructionNumber = 0
    @biggestVeggieNumber = 0
    @biggestFurnitureNumer = 0
    @biggestTransportationNumber = 0
    @biggestLandUseNumber = 0
    @biggestTrafficAreaNumber = 0
  end

  def updatenumbers(model)
    @buildingstring = ""
    @tunnelstring = ""
    @bridgestring = ""
    @genericstring = ""
    @solvegstring = ""
    @cfstring = ""
    @plantcoverstring = ""
    initnumbers
    internalboundarystring = ""
     model.layers.each{|l|
        layername = l.name.upcase
        layername.each_line('.'){|substr|
              substr = substr.chomp('.')
              if(@nameTester.isbuildinginst(substr) or @nameTester.isbridgeinst(substr) or @nameTester.istunnelinst(substr))
                  @biggestInstallationNumber = @biggestInstallationNumber +1
              elsif(@nameTester.isbuildingpart(substr) or @nameTester.isbridgepart(substr) or @nameTester.istunnelpart(substr))
                  @biggestPartNumber = @biggestPartNumber +1
              elsif(@nameTester.isbuilding(substr))
                 
                  if(@buildingstring.index(substr) == nil)
                      @buildingstring = @buildingstring + "|" + substr
                      @biggestSiteNumber = @biggestSiteNumber +1
                  end
              elsif(@nameTester.isconstr(substr))
                  @biggestConstructionNumber = @biggestConstructionNumber +1
              elsif(@nameTester.isbridge(substr))

                  if(@bridgestring.index(substr) == nil)
                      @bridgestring = @bridgestring + "|" + substr
                      @biggestSiteNumber = @biggestSiteNumber +1
                  end
              elsif(@nameTester.istunnel(substr))
                  
                  if(@tunnelstring.index(substr) == nil)
                      @tunnelstring = @tunnelstring + "|" + substr
                      @biggestSiteNumber = @biggestSiteNumber +1
                  end
             elsif(@nameTester.isboundary(substr))
               if(internalboundarystring.index(substr) == nil)
                 @biggestBoundaryNumber = @biggestBoundaryNumber +1
                 internalboundarystring += "|" + substr
               end
                  
             elsif(@nameTester.isopening(substr))
                  @biggestOpeningNumber = @biggestOpeningNumber +1
            
             elsif(@nameTester.isveggie(substr))
               if(@solvegstring.index(substr) == nil)
                      @solvegstring = @solvegstring + "|" + substr
                      @biggestSiteNumber = @biggestSiteNumber +1
                  end
             elsif(@nameTester.isgencityobject(substr))
                  if(@genericstring.index(substr) == nil)
                      @genericstring = @genericstring + "|" + substr
                      @biggestSiteNumber = @biggestSiteNumber +1
                  end
             elsif(@nameTester.iscityf(substr))
                  if(@cfstring.index(substr) == nil)
                      @cfstring = @cfstring + "|" + substr
                       @biggestSiteNumber = @biggestSiteNumber +1
                  end
              elsif(@nameTester.isplantcover(substr))
                   if(@plantcoverstring.index(substr) == nil)
                        @plantcoverstring = @plantcoverstring + "|" + substr
                        @biggestSiteNumber = @biggestSiteNumber +1
                    end
             elsif(@nameTester.istrafficarea(substr))
                  @biggestTrafficAreaNumber = @biggestTrafficAreaNumber +1
             elsif(@nameTester.istrans(substr))
                  @biggestTransportationNumber = @biggestTransportationNumber +1
             elsif(@nameTester.islanduse(substr))
                  @biggestLandUseNumber = @biggestLandUseNumber +1
             end

        }  
      }
  end

end
