# To change this template, choose Tools | Templates
# and open the template in the editor.

class NameTester

  @@newbuilding = "BUILDING"
  @@newbpart = "BPART"
  @@newbuildingpart = "BUILDINGPART"
  @@newbuiinst = "BUIINST"
  @@newbuildinginst = "BUILDINGINSTALLATION"

  @@newbridge = "BRIDGE"
  @@newbridgepart = "BRIDGEPART"
  @@newbridgepart2 = "BPART"
  @@newbridgeinst = "BRIDGEINST"
  @@newbridgeinstallation = "BRIDGEINSTALLATION"
  @@newbridgeconstr = "BRIDGECONSTRUCTIONELEMENT"

  @@newtunnel = "TUNNEL"
  @@newtunnelpart = "TUNNELPART"
  @@newtunnelpart2 = "TPART"
  @@newtunnelinst = "TUNNELINST"
  @@newtunnelinstallation = "TUNNELINSTALLATION"


  @@newwall = "WALL"
  @@newroof = "ROOF"
  @@newground = "GROUND"
  @@newwindow = "WINDOW"
  @@newclosure = "CLOSURE"
  @@newceiling = "CEILING"
  @@newfloor = "FLOOR"
  @@newdoor = "DOOR"

  @@newsolitary = "SOLITARYVEGETATIONOBJECT"
  @@newsolveg = "SOLVEGOBJECT"
  @@newplantcover = "PLANTCOVER"

  @@newcityf = "CITYFURNITURE"

  @@newroad = "ROAD"
  @@newtrack = "TRACK"
  @@newsquare = "SQUARE"
  @@newrail = "RAIL"
  
  @@newtrafficarea = "TRAFFICAREA"

  @@newlanduse = "LANDUSE"

  @@newgenericcityobject = "GENERICCITYOBJECT"



  def initialize
    
  end



  def isbuilding (layername)
    puts "Teste ob " + @@newbuilding + " das in " + layername + "vorkommt"
      if(layername.index(@@newbuilding) != nil)
        puts "Test erfolgreich"
        return true
      end
      return false
  end


def isbuildingpart (layername)
  puts "Teste ob " + @@newbuildingpart + "oder das" + @@newbpart + " in " + layername + "vorkommt"
  if(layername.index(@@newbuildingpart) != nil or layername.index(@@newbpart) != nil)
     puts "Test erfolgreich"
    return true
  end
  return false
end

def isbuildinginst (layername)
  puts "Teste ob " + @@newbuiinst + "oder das" + @@newbuildinginst + " in " + layername + "vorkommt"
  if(layername.index(@@newbuiinst) != nil or layername.index(@@newbuildinginst) != nil)
    puts "Test erfolgreich"
    return true
  end
  return false
end

def isbridge (layername)
  if(layername.index(@@newbridge) != nil)
    return true
  end
  return false
end


def isbridgepart (layername)
  if(layername.index(@@newbridgepart) != nil or layername.index(@@newbridgepart2) != nil)
    return true
  end
  return false
end

def isbridgeinst (layername)
  if(layername.index(@@newbridgeinst) != nil or layername.index(@@newbridgeinstallation) != nil)
    return true
  end
  return false
end

def isconstr (layername)
  if(layername.index(@@newbridgeconstr) != nil)
    return true
  end
  return false
end

def istunnel (layername)
  if(layername.index(@@newtunnel) != nil)
    return true
  end
  return false
end


def istunnelpart (layername)
  if(layername.index(@@newtunnelpart) != nil or layername.index(@@newtunnelpart2) != nil)
    return true
  end
  return false
end

def istunnelinst (layername)
  if(layername.index(@@newtunnelinst) != nil or layername.index(@@newtunnelinstallation) != nil)
    return true
  end
  return false
end

 def isboundary (layername)
   if(layername.index(@@newwall) != nil or layername.index(@@newroof) != nil or layername.index(@@newground) != nil or
       layername.index(@@newclosure) != nil or layername.index(@@newceiling) != nil or layername.index(@@newfloor) != nil)
    return true
  end
  return false
 end

 def isopening (layername)
  if(layername.index(@@newdoor) != nil or layername.index(@@newwindow) != nil)
    return true
  end
  return false
end

  def isveggie (layername)
    if(layername.index(@@newsolitary) != nil or layername.index(@@newsolveg) != nil)
      return true
    end
    return false
  end

   def isgencityobject (layername)
    if(layername.index(@@newgenericcityobject) != nil)
      return true
    end
    return false
  end

  def isplantcover (layername)
    if(layername.index(@@newplantcover) != nil)
      return true
    end
    return false
  end

  def iscityf (layername)
    if(layername.index(@@newcityf))
      return true
    end
    return false
  end

  def istrafficarea(layername)
    if(layername.index(@@newtrafficarea))
      return true
    end
    return false
  end
  
  @@newtrafficarea

  def islanduse (layername)
    if(layername.index(@@newlanduse))
      return true
    end
    return false
  end

  def istrans (layername)
     if(layername.index(@@newroad) != nil or layername.index(@@newtrack) != nil or layername.index(@@newsquare) != nil or layername.index(@@newrail) != nil)
      return true
    end
    return false
  end

  def ismultiboundary(internalname)
     if(internalname == "WALLS" or internalname == "ROOFS" or internalname == "GROUNDS" or internalname == "CLOSURES" or internalname == "OUTERCEILINGS" or
         internalname == "OUTERFLOORS" or internalname == "WALLSURFACES" or internalname == "GROUNDSURFACES" or internalname == "ROOFSURFACES")
         return true
     end
    return false
 end


end
