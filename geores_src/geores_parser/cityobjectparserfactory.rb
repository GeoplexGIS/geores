# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_parser/cityobjectparser.rb'
Sketchup::require 'geores_src/geores_parser/geores_featureparser/gres_building_parser.rb'
Sketchup::require 'geores_src/geores_schema/geores_feature/gres_building.rb'
Sketchup::require 'geores_src/geores_parser/geores_featureparser/gres_bridge_parser.rb'
Sketchup::require 'geores_src/geores_schema/geores_feature/gres_bridge.rb'
Sketchup::require 'geores_src/geores_parser/geores_featureparser/gres_tunnel_parser.rb'
Sketchup::require 'geores_src/geores_schema/geores_feature/gres_tunnel.rb'
Sketchup::require 'geores_src/geores_parser/geores_featureparser/gres_boundary_parser.rb'
Sketchup::require 'geores_src/geores_schema/geores_feature/gres_boundary.rb'
Sketchup::require 'geores_src/geores_parser/geores_featureparser/gres_installation_parser.rb'
Sketchup::require 'geores_src/geores_schema/geores_feature/gres_installation.rb'
Sketchup::require 'geores_src/geores_parser/geores_featureparser/gres_opening_parser.rb'
Sketchup::require 'geores_src/geores_schema/geores_feature/gres_opening.rb'
Sketchup::require 'geores_src/geores_parser/geores_featureparser/gres_relief_feature_parser.rb'
Sketchup::require 'geores_src/geores_schema/geores_feature/gres_relief_feature.rb'
Sketchup::require 'geores_src/geores_parser/geores_featureparser/gres_cityfurniture_parser.rb'
Sketchup::require 'geores_src/geores_schema/geores_feature/gres_cityfurniture.rb'
Sketchup::require 'geores_src/geores_parser/geores_featureparser/gres_sol_veg_parser.rb'
Sketchup::require 'geores_src/geores_schema/geores_feature/gres_solitary_vegetation_object.rb'
Sketchup::require 'geores_src/geores_parser/geores_featureparser/gres_transportation_parser.rb'
Sketchup::require 'geores_src/geores_schema/geores_feature/gres_transportation.rb'
Sketchup::require 'geores_src/geores_parser/geores_featureparser/gres_traffic_area_parser.rb'
Sketchup::require 'geores_src/geores_parser/geores_featureparser/gres_land_use_parser.rb'
Sketchup::require 'geores_src/geores_parser/geores_featureparser/gres_generic_city_object_parser.rb'
Sketchup::require 'geores_src/geores_schema/geores_feature/gres_generic_city_object.rb'
Sketchup::require 'geores_src/geores_parser/geores_featureparser/gres_plant_cover_parser.rb'
Sketchup::require 'geores_src/geores_schema/geores_feature/gres_land_use.rb'
Sketchup::require 'geores_src/geores_schema/geores_feature/gres_plant_cover.rb'
Sketchup::require 'geores_src/geores_schema/geores_feature/gres_water_body.rb'
Sketchup::require 'geores_src/geores_schema/geores_feature/gres_t_i_n_relief.rb'
Sketchup::require 'geores_src/geores_schema/geores_feature/gres_water_boundary.rb'
Sketchup::require 'geores_src/geores_parser/geores_featureparser/gres_water_boundary_parser.rb'
Sketchup::require 'geores_src/geores_parser/geores_featureparser/gres_water_body_parser.rb'
Sketchup::require 'geores_src/geores_parser/geores_featureparser/gres_city_object_group_parser.rb'
Sketchup::require 'geores_src/geores_schema/geores_feature/gres_traffic_area.rb'

class CityObjectParserFactory
  def initialize counter
    @counter = counter
  end

  attr_reader :counter

  def getCityObjectParserForName(name)
    puts "hole Parser fuer " + name
    if(name == "bldg:Building" or name == "Building")
      bldg = GRES_Building.new()
      bldg.setname("Building" + @counter.to_s)
      @counter = @counter + 1
      return GRES_BuildingParser.new(bldg, self)
    end
    if(name == "bldg:BuildingPart" or name == "BuildingPart")
      bldg = GRES_Building.new()
      bldg.setname("BuildingPart" + @counter.to_s)
      @counter = @counter + 1
      return GRES_BuildingParser.new(bldg, self)
    end
    if(name == "bldg:BuildingInstallation" or name == "BuildingInstallation")
      bldg = GRES_Installation.new()
      bldg.setname("BuildingInstallation" + @counter.to_s)
      @counter = @counter + 1
      return GRES_InstallationParser.new(bldg, self)
    end
    if(name == "tun:Tunnel" or name == "Tunnel")
      tun = GRES_Tunnel.new()
      tun.setname("Tunnel" + @counter.to_s)
      @counter = @counter + 1
      return GRES_TunnelParser.new(tun, self)
    end
    if(name == "tun:TunnelPart" or name == "TunnelPart")
      tun = GRES_Tunnel.new()
      tun.setname("TunnelPart" + @counter.to_s)
      @counter = @counter + 1
      return GRES_TunnelParser.new(tun, self)
    end
    if(name == "tun:TunnelInstallation" or name == "TunnelInstallation")
      tun = GRES_Installation.new()
      tun.setname("TunnelInstallation" + @counter.to_s)
      @counter = @counter + 1
      return GRES_InstallationParser.new(tun, self)
    end
    if(name == "brid:Bridge" or name == "Bridge")
      brid = GRES_Bridge.new()
      brid.setname("Bridge" + @counter.to_s)
      @counter = @counter + 1
      return GRES_BridgeParser.new(brid, self)
    end
    if(name == "brid:BridgePart" or name == "BridgePart")
      brid = GRES_Bridge.new()
      brid.setname("BridgePart" + @counter.to_s)
      @counter = @counter + 1
      return GRES_BridgeParser.new(brid, self)
    end
    if(name == "brid:BridgeInstallation" or name == "BridgeInstallation")
      bldg = GRES_Installation.new()
      bldg.setname("BridgeInstallation" + @counter.to_s)
      @counter = @counter + 1
      return GRES_InstallationParser.new(bldg, self)
    end
    if(name == "brid:BridgeConstructionElement" or name == "BridgeConstructionElement")
      bldg = GRES_Installation.new()
      bldg.setname("BridgeConstructionElement" + @counter.to_s)
      @counter = @counter + 1
      return GRES_InstallationParser.new(bldg, self)
    end
    
    if(name == "bldg:WallSurface" or name == "brid:WallSurface" or name == "tun:WallSurface")
      boundary = GRES_Boundary.new()
      boundary.setname("WallSurface" + @counter.to_s)
      @counter = @counter + 1
      return GRES_BoundaryParser.new(boundary, self)
    end
    if(name == "bldg:RoofSurface" or name == "brid:RoofSurface" or name == "tun:RoofSurface")
      boundary = GRES_Boundary.new()
      boundary.setname("RoofSurface" + @counter.to_s)
      @counter = @counter + 1
      return GRES_BoundaryParser.new(boundary, self)
    end
    if(name == "bldg:GroundSurface" or name == "brid:GroundSurface" or name == "tun:GroundSurface")
      boundary = GRES_Boundary.new()
      boundary.setname("GroundSurface" + @counter.to_s)
      @counter = @counter + 1
      return GRES_BoundaryParser.new(boundary, self)
    end
    if(name == "bldg:ClosureSurface" or name == "brid:ClosureSurface" or name == "tun:ClosureSurface")
      boundary = GRES_Boundary.new()
      boundary.setname("ClosureSurface" + @counter.to_s)
      @counter = @counter + 1
      return GRES_BoundaryParser.new(boundary, self)
    end
    if(name == "bldg:CeilingSurface" or name == "brid:CeilingSurface" or name == "tun:CeilingSurface")
      boundary = GRES_Boundary.new()
      boundary.setname("CeilingSurface" + @counter.to_s)
      @counter = @counter + 1
      return GRES_BoundaryParser.new(boundary, self)
    end
    if(name == "bldg:InteriorWallSurface" or name == "brid:InteriorWallSurface" or name == "tun:InteriorWallSurface")
      boundary = GRES_Boundary.new()
      boundary.setname("InteriorWallSurface" + @counter.to_s)
      @counter = @counter + 1
      return GRES_BoundaryParser.new(boundary, self)
    end
    if(name == "bldg:FloorSurface" or name == "brid:FloorSurface" or name == "tun:FloorSurface")
      boundary = GRES_Boundary.new()
      boundary.setname("FloorSurface" + @counter.to_s)
      @counter = @counter + 1
      return GRES_BoundaryParser.new(boundary, self)
    end
     if(name == "bldg:OuterFloorSurface" or name == "brid:OuterFloorSurface" or name == "tun:OuterFloorSurface")
      boundary = GRES_Boundary.new()
      boundary.setname("OuterFloorSurface" + @counter.to_s)
      @counter = @counter + 1
      return GRES_BoundaryParser.new(boundary, self)
    end
     if(name == "bldg:OuterCeilingSurface" or name == "brid:OuterCeilingSurface" or name == "tun:OuterCeilingSurface")
      boundary = GRES_Boundary.new()
      boundary.setname("OuterCeilingSurface" + @counter.to_s)
      @counter = @counter + 1
      return GRES_BoundaryParser.new(boundary, self)
    end
    
    if(name == "bldg:Window" or name == "brid:Window" or name == "tun:Window")
      op = GRES_Opening.new()
      op.setname("Window" + @counter.to_s)
      @counter = @counter + 1
      return GRES_OpeningParser.new(op, self)
    end
    if(name == "bldg:Door" or name == "brid:Door" or name == "tun:Door")
      op = GRES_Opening.new()
      op.setname("Door" + @counter.to_s)
      @counter = @counter + 1
      return GRES_OpeningParser.new(op, self)
    end
    if(name == "dem:ReliefFeature")
      relief = GRES_ReliefFeature.new()
      relief.setname("ReliefFeature" + @counter.to_s)
      @counter = @counter + 1
      return GRES_ReliefFeatureParser.new(relief, self)
    end
    if(name == "frn:CityFurniture")
      furniture = GRES_CityFurniture.new()
      furniture.setname("CityFurniture" + @counter.to_s)
      @counter = @counter + 1
      return GRES_CityFurnitureParser.new(furniture, self)
    end
    if(name == "veg:SolitaryVegetationObject")
      solveg = GRES_SolitaryVegetationObject.new()
      solveg.setname("SolitaryVegetationObject" + @counter.to_s)
      @counter = @counter + 1
      return GRES_SolVegParser.new(solveg, self)
    end
    if(name == "tran:Road")
      road = GRES_Transportation.new()
      road.setname("Road" + @counter.to_s)
      @counter = @counter + 1
      return GRES_TransportationParser.new(road, self)
    end
    if(name == "tran:Track")
      road = GRES_Transportation.new()
      road.setname("Track" + @counter.to_s)
      @counter = @counter + 1
      return GRES_TransportationParser.new(road, self)
    end
    if(name == "tran:Railway")
      road = GRES_Transportation.new()
      road.setname("Railway" + @counter.to_s)
      @counter = @counter + 1
      return GRES_TransportationParser.new(road, self)
    end
    if(name == "tran:Square")
      road = GRES_Transportation.new()
      road.setname("Square" + @counter.to_s)
      @counter = @counter + 1
      return GRES_TransportationParser.new(road, self)
    end
    if(name == "tran:TrafficArea")
      area = GRES_TrafficArea.new()
      area.setname("TrafficArea" + @counter.to_s)
      @counter = @counter + 1
      return GRES_TrafficAreaParser.new(area, self)
    end
    if(name == "tran:AuxiliaryTrafficArea")
      area = GRES_TrafficArea.new()
      area.setname("AuxiliaryTrafficArea" + @counter.to_s)
      @counter = @counter + 1
      return GRES_TrafficAreaParser.new(area, self)
    end
    if(name == "luse:LandUse")
      luse = GRES_LandUse.new()
      luse.setname("LandUse" + @counter.to_s)
      @counter = @counter + 1
      return GRES_LandUseParser.new(luse, self)
    end
    if(name == "gen:GenericCityObject")
      gen = GRES_GenericCityObject.new()
      gen.setname("GenericCityObject" + @counter.to_s)
      @counter = @counter + 1
      return GRES_GenericCityObjectParser.new(gen, self)
    end
    if(name == "veg:PlantCover")
      #TODO
      gen = GRES_PlantCover.new()
      gen.setname("PlantCover" + @counter.to_s)
      @counter = @counter + 1
      return GRES_PlantCoverParser.new(gen, self)
    end
    if(name == "wtr:WaterBody")
      #TODO
      wtr = GRES_WaterBody.new()
      wtr.setname("WaterBody" + @counter.to_s)
      @counter = @counter + 1
      return GRES_WaterBodyParser.new(wtr, self)
    end
     if(name == "wtr:WaterGroundSurface")
      boundary = GRES_WaterBoundary.new()
      boundary.setname("WaterGroundSurface" + @counter.to_s)
      @counter = @counter + 1
      return GRES_Water_BoundaryParser.new(boundary, self)
    end
    if(name == "wtr:WaterSurface")
      boundary = GRES_WaterBoundary.new()
      boundary.setname("WaterSurface" + @counter.to_s)
      @counter = @counter + 1
      return GRES_Water_BoundaryParser.new(boundary, self)
    end
    if(name == "wtr:WaterClosureSurface")
      boundary = GRES_WaterBoundary.new()
      boundary.setname("WaterClosureSurface" + @counter.to_s)
      @counter = @counter + 1
      return GRES_Water_BoundaryParser.new(boundary, self)
    end
    if(name == "grp:CityObjectGroup")
      obj = GRES_CityObject.new()
      obj.setname("CityObjectGroup" + @counter.to_s)
      @counter = @counter + 1
      return GRES_CityObjectGroupParser.new(obj, self)
    end
    puts "keinen Parser gefunden -> returniere default Parser"
    #obj = GRES_CityObject.new()
    #obj.setname("DefaultObject" + @counter.to_s)
    @counter = @counter + 1
    return nil
  end

  def getCityObjectForName(name)
    if(name.index("BuildingInstallation") != nil)
      bldg = GRES_Installation.new()
      return bldg
    end
    if(name.index("Building") != nil)
      bldg = GRES_Building.new()
      return bldg
    end
    if(name.index("TunnelInstallation") != nil)
      bldg = GRES_Installation.new()
      return bldg
    end
    if(name.index("Tunnel") != nil)
      bldg = GRES_Tunnel.new()
      return bldg
    end
    if(name.index("BridgeInstallation") != nil or name.index("BridgeConstructionElement"))
      bldg = GRES_Installation.new()
      return bldg
    end
    if(name.index("Bridge") != nil)
      bldg = GRES_Bridge.new()
      return bldg
    end
    if(name.index("WaterGroundSurface") != nil or name.index("WaterSurface") != nil or name.index("WaterClosureSurface") != nil)
      boundary = GRES_Boundary.new()
      return boundary
    end

    if(name.index("WallSurface") != nil or name.index("RoofSurface") != nil or name.index("ClosureSurface") != nil or name.index("GroundSurface") != nil or
        name.index("CeilingSurface") != nil or name.index("FloorSurface") != nil)
      boundary = GRES_Boundary.new()
      return boundary
    end
    if(name.index("Window") != nil or name.index("Door"))
       op = GRES_Opening.new()
      return op
    end
    if(name.index("ReliefFeature") != nil or name.index("TIN") != nil)
      relief = GRES_TINRelief.new()
      return relief
    end
     if(name.index("CityFurniture") != nil)
      obj = GRES_CityFurniture.new()
      return obj
    end
    if(name.index("SolitaryVegetationObject") != nil)
      obj = GRES_SolitaryVegetationObject.new()
      return obj
    end
     if(name.index("Road") != nil or name.index("Track") != nil or name.index("Square") != nil or name.index("Railway") != nil )
      road = GRES_Transportation.new()
      return road
    end

    if(name.index("TrafficArea") != nil)
      area = GRES_TrafficArea.new()
      return area
    end
     if(name.index("LandUse") != nil)
      luse = GRES_LandUse.new()
      return luse
    end
     if(name.index("GenericCityObject") != nil)
      luse = GRES_GenericCityObject.new()
      return luse
    end
    if(name.index("PlantCover") != nil)
      luse = GRES_PlantCover.new()
      return luse
    end
     if(name.index("WaterBody") != nil)
      luse = GRES_WaterBody.new()
      return luse
    end
     if(name.index("CityObjectGroup") != nil)
      luse = GRES_CityObject.new()
      return luse
    end


    puts "kein passendes Objekt gefunden -> returniere default Parser"
    obj = GRES_CityObject.new()

    return obj
  end




end
