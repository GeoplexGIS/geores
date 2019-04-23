# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'sketchup'
Sketchup::require 'geores_src/geores_toolbar/city_g_m_l_layer_maker.rb'

toolbar = UI::Toolbar.new "CityGML Building Toolbar"
toolbarbridge = UI::Toolbar.new "CityGML Bridge Toolbar"
toolbartunnel = UI::Toolbar.new "CityGML Tunnel Toolbar"
toolbarobjects = UI::Toolbar.new "CityGML Objects Toolbar"
toolbarsurface = UI::Toolbar.new "CityGML Surface Toolbar"
layermaker = CityGMLLayerMaker.new()


if(not $toolsBuildingLoaded)
          groundSolid = UI::Command.new("GroundSurface") {
           layermaker.createlayerboundary("GroundSurface", true, "BUILDING")
         }
         groundSolid.small_icon = "geores_Images/building_ground16.png"
         groundSolid.large_icon = "geores_Images/building_ground24.png"
         groundSolid.tooltip = "Erstelle einen GroundSurface Layer, der auch Teil der Solid Geometrie ist"
         groundSolid.status_bar_text = "Erstelle eine GroundSurface"
         groundSolid.menu_text = "Erstelle einen GroundSurface"
         toolbar = toolbar.add_item groundSolid
          wallSolid = UI::Command.new("WallSurface") {
               layermaker.createlayerboundary("WallSurface", true, "BUILDING")
         }
         wallSolid.small_icon = "geores_Images/building_wall16.png"
         wallSolid.large_icon = "geores_Images/building_wall24.png"
         wallSolid.tooltip = "Erstelle einen WallSurface Layer, der auch Teil der Solid Geometrie ist"
         wallSolid.status_bar_text = "Erstelle eine WallSurface"
         wallSolid.menu_text = "Erstelle eine WallSurface"
         toolbar = toolbar.add_item wallSolid
         roofSolid = UI::Command.new("RoofSurface") {
               layermaker.createlayerboundary("RoofSurface", true, "BUILDING")
         }
         roofSolid.small_icon = "geores_Images/building_roof16.png"
         roofSolid.large_icon = "geores_Images/building_roof24.png"
         roofSolid.tooltip = "Erstelle einen RoofSurface Layer, der auch Teil der Solid Geometrie ist"
         roofSolid.status_bar_text = "Erstelle eine RoofSurface"
         roofSolid.menu_text = "Erstelle eine RoofSurface"
         toolbar = toolbar.add_item roofSolid
         closureSolid = UI::Command.new("ClosureSurface") {
              layermaker.createlayerboundary("ClosureSurface", true, "BUILDING")
         }
         closureSolid.small_icon = "geores_Images/building_closure16.png"
         closureSolid.large_icon = "geores_Images/building_closure24.png"
         closureSolid.tooltip = "Erstelle einen ClosureSurface Layer, der auch Teil der Solid Geometrie ist"
         closureSolid.status_bar_text = "Erstelle eine ClosureSurface"
         closureSolid.menu_text = "Erstelle eine ClosureSurface"
         toolbar = toolbar.add_item closureSolid
         outerFloorSolid = UI::Command.new("OuterFloorSurface") {
               layermaker.createlayerboundary("OuterFloorSurface", true, "BUILDING")
         }
         outerFloorSolid.small_icon = "geores_Images/building_outerfloor16.png"
         outerFloorSolid.large_icon = "geores_Images/building_outerfloor24.png"
         outerFloorSolid.tooltip = "Erstelle einen OuterFloorSurface Layer, der auch Teil der Solid Geometrie ist"
         outerFloorSolid.status_bar_text = "Erstelle eine OuterFloorSurface"
         outerFloorSolid.menu_text = "Erstelle eine OuterFloorSurface"
         toolbar = toolbar.add_item outerFloorSolid
         outerCeilingSolid = UI::Command.new("OuterCeilingSurface ") {
               layermaker.createlayerboundary("OuterCeilingSurface", true, "BUILDING")
         }
         outerCeilingSolid.small_icon = "geores_Images/building_outerceiling16.png"
         outerCeilingSolid.large_icon = "geores_Images/building_outerceiling24.png"
         outerCeilingSolid.tooltip = "Erstelle einen OuterCeilingSurface Layer, der auch Teil der Solid Geometrie ist"
         outerCeilingSolid.status_bar_text = "Erstelle eine OuterCeilingSurface"
         outerCeilingSolid.menu_text = "Erstelle eine OuterCeilingSurface"
         toolbar = toolbar.add_item outerCeilingSolid

        roofNoSolid = UI::Command.new("RoofSurface - no Solid ") {
               layermaker.createlayerboundary("RoofSurface", false, "BUILDING")
         }
         roofNoSolid.small_icon = "geores_Images/building_roofNoSolid16.png"
         roofNoSolid.large_icon = "geores_Images/building_roofNoSolid24.png"
         roofNoSolid.tooltip = "Erstelle einen RoofSurface Layer, der NICHT Teil der Solid Geometrie ist"
         roofNoSolid.status_bar_text = "Erstelle eine RoofSurface"
         roofNoSolid.menu_text = "Erstelle eine RoofSurface"
         toolbar = toolbar.add_item roofNoSolid


        myBui = UI::Command.new("Building") {
              layermaker.createSite("Building")
         }
         myBui.small_icon = "geores_Images/building16.png"
         myBui.large_icon = "geores_Images/building24.png"
         myBui.tooltip = "Erstelle ein neues Gebaeude"
         myBui.status_bar_text = "Erstelle ein neues Gebaeude"
         myBui.menu_text = "Erstelle ein neues Gebaeude"
         toolbar = toolbar.add_item myBui

        myBuiPart = UI::Command.new("BuildingPart") {
              layermaker.createSitePart("BuildingPart")
         }
         myBuiPart.small_icon = "geores_Images/building_bpart16.png"
         myBuiPart.large_icon = "geores_Images/building_bpart24.png"
         myBuiPart.tooltip = "Erstelle einen neuen Gebaeudeteil"
         myBuiPart.status_bar_text = "Erstelle einen neuen Gebaeudeteil"
         myBuiPart.menu_text = "Erstelle einen neuen Gebaeudeteil"
         toolbar = toolbar.add_item myBuiPart

         door = UI::Command.new("Door") {
           layermaker.createlayeropening("Door")
         }
         door.small_icon = "geores_Images/building_door16.png"
         door.large_icon = "geores_Images/building_door24.png"
         door.tooltip = "Erstelle einen Door Layer"
         door.status_bar_text = "Door"
         door.menu_text = "Door"
         toolbar = toolbar.add_item door
         window = UI::Command.new("Window") {
               layermaker.createlayeropening("Window")
         }
         window.small_icon = "geores_Images/building_window16.png"
         window.large_icon = "geores_Images/building_window24.png"
         window.tooltip = "Erstelle einen Window Layer"
         window.status_bar_text = "Window"
         window.menu_text = "Window"
         toolbar = toolbar.add_item window

         buiInst = UI::Command.new("BuildingInstallation ") {
           layermaker.createlayerinstallation("BuildingInstallation")
         }
         buiInst.small_icon = "geores_Images/building_buiInst16.png"
         buiInst.large_icon = "geores_Images/building_buiInst24.png"
         buiInst.tooltip = "Erstelle einen BuildingInstallation Layer"
         buiInst.status_bar_text = "BuildingInstallation"
         buiInst.menu_text = "BuildingInstallation"
         toolbar = toolbar.add_item buiInst
         $toolsBuildingLoaded = true
end
if(not $toolsTunnelLoaded)
          groundSolid = UI::Command.new("GroundSurface") {
           layermaker.createlayerboundary("GroundSurface", true, "TUNNEL")
         }
         groundSolid.small_icon = "geores_Images/tunnel_ground_16.png"
         groundSolid.large_icon = "geores_Images/tunnel_ground_24.png"
         groundSolid.tooltip = "Erstelle einen GroundSurface Layer"
         groundSolid.status_bar_text = "Erstelle eine GroundSurface"
         groundSolid.menu_text = "Erstelle einen GroundSurface"
         toolbartunnel = toolbartunnel.add_item groundSolid

          wallSolid = UI::Command.new("WallSurface") {
               layermaker.createlayerboundary("WallSurface", true, "TUNNEL")
         }
         wallSolid.small_icon = "geores_Images/tunnel_wall_16.png"
         wallSolid.large_icon = "geores_Images/tunnel_wall_24.png"
         wallSolid.tooltip = "Erstelle einen WallSurface Layer"
         wallSolid.status_bar_text = "Erstelle eine WallSurface"
         wallSolid.menu_text = "Erstelle eine WallSurface"
         toolbartunnel = toolbartunnel.add_item wallSolid
         roofSolid = UI::Command.new("RoofSurface") {
               layermaker.createlayerboundary("RoofSurface", true, "TUNNEL")
         }
         roofSolid.small_icon = "geores_Images/tunnel_roof_16.png"
         roofSolid.large_icon = "geores_Images/tunnel_roof_24.png"
         roofSolid.tooltip = "Erstelle einen RoofSurface Layer"
         roofSolid.status_bar_text = "Erstelle eine RoofSurface"
         roofSolid.menu_text = "Erstelle eine RoofSurface"
         toolbartunnel = toolbartunnel.add_item roofSolid

         closureSolid = UI::Command.new("ClosureSurface") {
              layermaker.createlayerboundary("ClosureSurface", true, "TUNNEL")
         }
         closureSolid.small_icon = "geores_Images/tunnel_closure_16.png"
         closureSolid.large_icon = "geores_Images/tunnel_closure_24.png"
         closureSolid.tooltip = "Erstelle einen ClosureSurface Layer"
         closureSolid.status_bar_text = "Erstelle eine ClosureSurface"
         closureSolid.menu_text = "Erstelle eine ClosureSurface"
         toolbartunnel = toolbartunnel.add_item closureSolid
         outerFloorSolid = UI::Command.new("OuterFloorSurface") {
               layermaker.createlayerboundary("OuterFloorSurface", true, "TUNNEL")
         }
         outerFloorSolid.small_icon = "geores_Images/tunnel_outerfloor_16.png"
         outerFloorSolid.large_icon = "geores_Images/tunnel_outerfloor_24.png"
         outerFloorSolid.tooltip = "Erstelle einen OuterFloorSurface Layer"
         outerFloorSolid.status_bar_text = "Erstelle eine OuterFloorSurface"
         outerFloorSolid.menu_text = "Erstelle eine OuterFloorSurface"
         toolbartunnel = toolbartunnel.add_item outerFloorSolid
         outerCeilingSolid = UI::Command.new("OuterCeilingSurface ") {
               layermaker.createlayerboundary("OuterCeilingSurface", true, "TUNNEL")
         }
         outerCeilingSolid.small_icon = "geores_Images/tunnel_outerceiling_16.png"
         outerCeilingSolid.large_icon = "geores_Images/tunnel_outerceiling_24.png"
         outerCeilingSolid.tooltip = "Erstelle einen OuterCeilingSurface Layer"
         outerCeilingSolid.status_bar_text = "Erstelle eine OuterCeilingSurface"
         outerCeilingSolid.menu_text = "Erstelle eine OuterCeilingSurface"
         toolbartunnel = toolbartunnel.add_item outerCeilingSolid


        myBui = UI::Command.new("Tunnel") {
              layermaker.createSite("Tunnel")
         }
         myBui.small_icon = "geores_Images/tunnel_16.png"
         myBui.large_icon = "geores_Images/tunnel_24.png"
         myBui.tooltip = "Erstelle einen neuen Tunnel"
         myBui.status_bar_text = "Erstelle einen neuen Tunnel"
         myBui.menu_text = "Erstelle einen neuen Tunnel"
         toolbartunnel = toolbartunnel.add_item myBui

        myBuiPart = UI::Command.new("TunnelPart") {
              layermaker.createSitePart("TunnelPart")
         }
         myBuiPart.small_icon = "geores_Images/tunnel_part_16.png"
         myBuiPart.large_icon = "geores_Images/tunnel_part_24.png"
         myBuiPart.tooltip = "Erstelle einen neuen TunnelPart"
         myBuiPart.status_bar_text = "Erstelle einen neuen TunnelPart"
         myBuiPart.menu_text = "Erstelle einen neuen TunnelPart"
         toolbartunnel = toolbartunnel.add_item myBuiPart

         door = UI::Command.new("Door") {
           layermaker.createlayeropening("Door")
         }
         door.small_icon = "geores_Images/tunnel_door_16.png"
         door.large_icon = "geores_Images/tunnel_door_24.png"
         door.tooltip = "Erstelle einen Door Layer"
         door.status_bar_text = "Door"
         door.menu_text = "Door"
         toolbartunnel = toolbartunnel.add_item door
         window = UI::Command.new("Window") {
               layermaker.createlayeropening("Window")
         }
         window.small_icon = "geores_Images/tunnel_window_16.png"
         window.large_icon = "geores_Images/tunnel_window_24.png"
         window.tooltip = "Erstelle einen Window Layer"
         window.status_bar_text = "Window"
         window.menu_text = "Window"
         toolbartunnel = toolbartunnel.add_item window

         buiInst = UI::Command.new("TunnnelInstallation ") {
           layermaker.createlayerinstallation("TunnnelInstallation")
         }
         buiInst.small_icon = "geores_Images/tunnel_installation_16.png"
         buiInst.large_icon = "geores_Images/tunnel_installation_24.png"
         buiInst.tooltip = "Erstelle einen TunnelInstallation Objekt"
         buiInst.status_bar_text = "TunnelInstallation"
         buiInst.menu_text = "TunnelInstallation"
         toolbartunnel = toolbartunnel.add_item buiInst
         $toolsTunnelLoaded = true
end

if(not $toolsBridgeLoaded)
          gs = UI::Command.new("Ground") {
           layermaker.createlayerboundary("GroundSurface", false, "BRIDGE")
         }
         gs.small_icon = "geores_Images/bridge_ground_16.png"
         gs.large_icon = "geores_Images/bridge_ground_24.png"
         gs.tooltip = "Erstelle einen GroundSurface Layer"
         gs.status_bar_text = "Erstelle eine GroundSurface"
         gs.menu_text = "Erstelle einen GroundSurface"
         toolbarbridge = toolbarbridge.add_item gs

          ws = UI::Command.new("WallSurface") {
               layermaker.createlayerboundary("WallSurface", false, "BRIDGE")
         }
         ws.small_icon = "geores_Images/bridge_wall_16.png"
         ws.large_icon = "geores_Images/bridge_wall_24.png"
         ws.tooltip = "Erstelle einen WallSurface Layer"
         ws.status_bar_text = "Erstelle eine WallSurface"
         ws.menu_text = "Erstelle eine WallSurface"
         toolbarbridge = toolbarbridge.add_item ws
         rs = UI::Command.new("RoofSurface") {
               layermaker.createlayerboundary("RoofSurface", false, "BRIDGE")
         }
         rs.small_icon = "geores_Images/bridge_roof_16.png"
         rs.large_icon = "geores_Images/bridge_roof_24.png"
         rs.tooltip = "Erstelle einen RoofSurface Layer"
         rs.status_bar_text = "Erstelle eine RoofSurface"
         rs.menu_text = "Erstelle eine RoofSurface"
         toolbarbridge = toolbarbridge.add_item rs
         cs = UI::Command.new("ClosureSurface ") {
              layermaker.createlayerboundary("ClosureSurface", false, "BRIDGE")
         }
         cs.small_icon = "geores_Images/bridge_closure_16.png"
         cs.large_icon = "geores_Images/bridge_closure_24.png"
         cs.tooltip = "Erstelle einen ClosureSurface Layer"
         cs.status_bar_text = "Erstelle eine ClosureSurface"
         cs.menu_text = "Erstelle eine ClosureSurface"
         toolbarbridge = toolbarbridge.add_item cs
         fs = UI::Command.new("OuterFloorSurface") {
               layermaker.createlayerboundary("OuterFloorSurface", false, "BRIDGE")
         }
         fs.small_icon = "geores_Images/bridge_outerfloor_16.png"
         fs.large_icon = "geores_Images/bridge_outerfloor_24.png"
         fs.tooltip = "Erstelle einen OuterFloorSurface Objekt"
         fs.status_bar_text = "Erstelle eine OuterFloorSurface"
         fs.menu_text = "Erstelle eine OuterFloorSurface"
         toolbarbridge = toolbarbridge.add_item fs
         ocs = UI::Command.new("OuterCeilingSurface ") {
               layermaker.createlayerboundary("OuterCeilingSurface", false, "BRIDGE")
         }
         ocs.small_icon = "geores_Images/bridge_outerceiling_16.png"
         ocs.large_icon = "geores_Images/bridge_outerceiling_24.png"
         ocs.tooltip = "Erstelle einen OuterCeilingSurface Objekt"
         ocs.status_bar_text = "Erstelle eine OuterCeilingSurface"
         ocs.menu_text = "Erstelle eine OuterCeilingSurface"
         toolbarbridge = toolbarbridge.add_item ocs

        rns = UI::Command.new("BridgeConstructionElement") {
          layermaker.createlayerinstallation("BridgeConstructionElement")
         }
         rns.small_icon = "geores_Images/bridge_construction_16.png"
         rns.large_icon = "geores_Images/bridge_construction_24.png"
         rns.tooltip = "Erstelle einen BridgeConstructionElement Objekt"
         rns.status_bar_text = "Erstelle ein BridgeConstructionElement"
         rns.menu_text = "Erstelle ein BridgeConstructionElement"
         toolbarbridge = toolbarbridge.add_item rns

         d = UI::Command.new("Door") {
           layermaker.createlayeropening("Door")
         }
         d.small_icon = "geores_Images/bridge_door_16.png"
         d.large_icon = "geores_Images/bridge_door_24.png"
         d.tooltip = "Erstelle einen Door Layer"
         d.status_bar_text = "Door"
         d.menu_text = "Door"
         toolbarbridge = toolbarbridge.add_item d
         w = UI::Command.new("Window") {
               layermaker.createlayeropening("Window")
         }
         w.small_icon = "geores_Images/bridge_window_16.png"
         w.large_icon = "geores_Images/bridge_window_24.png"
         w.tooltip = "Erstelle einen Window Layer"
         w.status_bar_text = "Window"
         w.menu_text = "Window"
         toolbarbridge = toolbarbridge.add_item w

         bri = UI::Command.new("BridgeInstallation ") {
           layermaker.createlayerinstallation("BridgeInstallation")
         }
         bri.small_icon = "geores_Images/bridge_installation_16.png"
         bri.large_icon = "geores_Images/bridge_installation_24.png"
         bri.tooltip = "Erstelle einen BridgeInstallation Objekt"
         bri.status_bar_text = "BridgeInstallation"
         bri.menu_text = "BridgeInstallation"
         toolbarbridge = toolbarbridge.add_item bri

        myBui = UI::Command.new("Bridge") {
              layermaker.createSite("Bridge")
         }
         myBui.small_icon = "geores_Images/bridge_16.png"
         myBui.large_icon = "geores_Images/bridge_24.png"
         myBui.tooltip = "Erstelle eine neue Brücke"
         myBui.status_bar_text = "Erstelle eine neue Brücke"
         myBui.menu_text = "Erstelle eine neue Brücke"
         toolbarbridge = toolbarbridge.add_item myBui

        myBuiPart = UI::Command.new("BridgePart") {
              layermaker.createSitePart("BridgePart")
         }
         myBuiPart.small_icon = "geores_Images/bridge_part_16.png"
         myBuiPart.large_icon = "geores_Images/bridge_part_24.png"
         myBuiPart.tooltip = "Erstelle einen neuen BridgePart"
         myBuiPart.status_bar_text = "Erstelle einen neuen BridgePart"
         myBuiPart.menu_text = "Erstelle einen neuen BridgePart"
         toolbarbridge = toolbarbridge.add_item myBuiPart
         $toolsBridgeLoaded = true
end

if(not $toolsObjsLoaded)


         gen = UI::Command.new("GenericCityObject") {
           defaults = ["JA"]
            prompts = ["Objekt mit impliziter Geometrie erstellen?"]
            arrayString = "JA|NEIN"
            list =  [arrayString]
            result = UI.inputbox prompts, defaults, list, "Objekt mit impliziter Geometrie erstellen"
            if(result != nil)
              if(result[0] == "JA")
                 layermaker.createImplicitRefObject("GenericCityObject")
              else
                layermaker.createlodobject("GenericCityObject")
              end
            end
          
         }
         gen.small_icon = "geores_Images/generic16.png"
         gen.large_icon = "geores_Images/generic24.png"
         gen.tooltip = "Erstelle ein GenericCityObject als Referenzobjekt"
         gen.status_bar_text = "GenericCityObject"
         gen.menu_text = "GenericCityObject"
         toolbarobjects = toolbarobjects.add_item gen

         gen2 = UI::Command.new("GenericCityObject_Impl") {
           layermaker.createImplicitObject("GenericCityObject")
         }
         gen2.small_icon = "geores_Images/generic_impl16.png"
         gen2.large_icon = "geores_Images/generic_impl24.png"
         gen2.tooltip = "Erstelle ein GenericCityObject als Kopie eines Referenzobjektes"
         gen2.status_bar_text = "GenericCityObject"
         gen2.menu_text = "GenericCityObject"
         toolbarobjects = toolbarobjects.add_item gen2


         sol = UI::Command.new("SolitaryVegetationObject") {
            defaults = ["JA"]
            prompts = ["Objekt mit impliziter Geometrie erstellen?"]
            arrayString = "JA|NEIN"
            list =  [arrayString]
            result = UI.inputbox prompts, defaults, list, "Objekt mit impliziter Geometrie erstellen"
            if(result != nil)
              if(result[0] == "JA")
                layermaker.createImplicitRefObject("SolitaryVegetationObject")
              else
                layermaker.createlodobject("SolitaryVegetationObject")
              end
            end
           
         }
         sol.small_icon = "geores_Images/solitayrVeg16.png"
         sol.large_icon = "geores_Images/solitayrVeg24.png"
         sol.tooltip = "Erstelle ein SolitaryVegetationObject als Referenzobjekt"
         sol.status_bar_text = "SolitaryVegetationObject"
         sol.menu_text = "SolitaryVegetationObject"
         toolbarobjects = toolbarobjects.add_item sol

        sol2 = UI::Command.new("SolitaryVegetationObject_Impl") {
           layermaker.createImplicitObject("SolitaryVegetationObject")
         }
         sol2.small_icon = "geores_Images/solitaryVeg_impl_16.png"
         sol2.large_icon = "geores_Images/solitaryVeg_impl_24.png"
         sol2.tooltip = "Erstelle ein SolitaryVegetationObject als Kopie eines Referenzobjekt"
         sol2.status_bar_text = "SolitaryVegetationObject"
         sol2.menu_text = "SolitaryVegetationObject"
         toolbarobjects = toolbarobjects.add_item sol2


        cf = UI::Command.new("CityFurniture") {
            defaults = ["JA"]
            prompts = ["Objekt mit impliziter Geometrie erstellen?"]
            arrayString = "JA|NEIN"
            list =  [arrayString]
            result = UI.inputbox prompts, defaults, list, "Objekt mit impliziter Geometrie erstellen"
            if(result != nil)
              if(result[0] == "JA")
                layermaker.createImplicitRefObject("CityFurniture")
              else
                layermaker.createlodobject("CityFurniture")
              end
            end
           
         }
         cf.small_icon = "geores_Images/cityfurniture_16.png"
         cf.large_icon = "geores_Images/cityfurniture_24.png"
         cf.tooltip = "Erstelle ein CityFurniture Objekt als Referenzobjekt "
         cf.status_bar_text = "CityFurniture"
         cf.menu_text = "CityFurniture"
         toolbarobjects = toolbarobjects.add_item cf

         cf2 = UI::Command.new("CityFurniture_Impl") {

           layermaker.createImplicitObject("CityFurniture")
         }
         cf2.small_icon = "geores_Images/cityfurniture_impl_16.png"
         cf2.large_icon = "geores_Images/cityfurniture_impl_24.png"
         cf2.tooltip = "Erstelle ein CityFurniture Objekt als Kopie eines Referenzobjektes"
         cf2.status_bar_text = "CityFurniture"
         cf2.menu_text = "CityFurniture"
         toolbarobjects = toolbarobjects.add_item cf2

        pla = UI::Command.new("PlantCover") {
           layermaker.createlodobject("PlantCover")
         }
         pla.small_icon = "geores_Images/plantcover16.png"
         pla.large_icon = "geores_Images/plantcover24.png"
         pla.tooltip = "Erstelle einen PlantCover Layer"
         pla.status_bar_text = "PlantCover"
         pla.menu_text = "PlantCover"
         toolbarobjects = toolbarobjects.add_item pla



    $toolsObjsLoaded = true
end
if(not $toolsSurfLoaded)
      tin = UI::Command.new("TIN ") {
           layermaker.createtin()
         }
         tin.small_icon = "geores_Images/tin16.png"
         tin.large_icon = "geores_Images/tin24.png"
         tin.tooltip = "Erstelle einen TIN Layer"
         tin.status_bar_text = "TIN"
         tin.menu_text = "TIN"
         toolbarsurface = toolbarsurface.add_item tin

        obj = UI::Command.new("Road") {
           layermaker.createlodobject("Road")
         }
         obj.small_icon = "geores_Images/road_16.png"
         obj.large_icon = "geores_Images/road_24.png"
         obj.tooltip = "Erstelle ein Road Objekt"
         obj.status_bar_text = "Road"
         obj.menu_text = "Road"
         toolbarsurface = toolbarsurface.add_item obj

        obj1 = UI::Command.new("Track") {
           layermaker.createlodobject("Track")
         }
         obj1.small_icon = "geores_Images/track_16.png"
         obj1.large_icon = "geores_Images/track_24.png"
         obj1.tooltip = "Erstelle ein Track Objekt"
         obj1.status_bar_text = "Track"
         obj1.menu_text = "Track"
         toolbarsurface = toolbarsurface.add_item obj1

        obj2 = UI::Command.new("Railway") {
           layermaker.createlodobject("Railway")
         }
         obj2.small_icon = "geores_Images/railway_16.png"
         obj2.large_icon = "geores_Images/railway_24.png"
         obj2.tooltip = "Erstelle ein Railway Objekt"
         obj2.status_bar_text = "Railway"
         obj2.menu_text = "Railway"
         toolbarsurface = toolbarsurface.add_item obj2

        obj3 = UI::Command.new("Square") {
           layermaker.createlodobject("Square")
         }
         obj3.small_icon = "geores_Images/square_16.png"
         obj3.large_icon = "geores_Images/square_24.png"
         obj3.tooltip = "Erstelle ein Square Objekt"
         obj3.status_bar_text = "Square"
         obj3.menu_text = "Square"
         toolbarsurface = toolbarsurface.add_item obj3

        obj4 = UI::Command.new("LandUse") {
           layermaker.createlodobject("LandUse")
         }
         obj4.small_icon = "geores_Images/landuse_16.png"
         obj4.large_icon = "geores_Images/landuse_24.png"
         obj4.tooltip = "Erstelle ein LandUse Objekt"
         obj4.status_bar_text = "LandUse"
         obj4.menu_text = "LandUse"
         toolbarsurface = toolbarsurface.add_item obj4

        obj5 = UI::Command.new("WaterBody") {
           layermaker.createlodobject("WaterBody")
         }
         obj5.small_icon = "geores_Images/waterbody_16.png"
         obj5.large_icon = "geores_Images/waterbody_24.png"
         obj5.tooltip = "Erstelle ein WaterBody Objekt"
         obj5.status_bar_text = "WaterBody"
         obj5.menu_text = "WaterBody"
         toolbarsurface = toolbarsurface.add_item obj5

          wallSolid = UI::Command.new("WaterGroundSurface") {
               layermaker.createlayerboundary("WaterGroundSurface", true, "WATERBODY")
         }
         wallSolid.small_icon = "geores_Images/water_ground_surface_16.png"
         wallSolid.large_icon = "geores_Images/water_ground_surface_24.png"
         wallSolid.tooltip = "Erstelle ein WaterGroundSurface Objekt"
         wallSolid.status_bar_text = "Erstelle eine WaterGroundSurface"
         wallSolid.menu_text = "Erstelle eine WaterGroundSurface"
         toolbarsurface = toolbarsurface.add_item wallSolid

          waterS = UI::Command.new("WaterSurface") {
               layermaker.createlayerboundary("WaterSurface", true, "WATERBODY")
         }
         waterS.small_icon = "geores_Images/water_surface_16.png"
         waterS.large_icon = "geores_Images/water_surface_24.png"
         waterS.tooltip = "Erstelle ein WaterSurface Objekt"
         waterS.status_bar_text = "Erstelle eine WaterSurface"
         waterS.menu_text = "Erstelle eine WaterSurface"
         toolbarsurface = toolbarsurface.add_item waterS

         obj6 = UI::Command.new("TrafficArea") {
           layermaker.createtrafficArea("TrafficArea")
         }
         obj6.small_icon = "geores_Images/trafficarea_16.png"
         obj6.large_icon = "geores_Images/trafficarea_24.png"
         obj6.tooltip = "Erstelle ein TrafficArea Objekt"
         obj6.status_bar_text = "TrafficArea"
         obj6.menu_text = "TrafficArea"
         toolbarsurface = toolbarsurface.add_item obj6

        obj7 = UI::Command.new("AuxiliaryTrafficArea") {
           layermaker.createtrafficArea("AuxiliaryTrafficArea")
         }
         obj7.small_icon = "geores_Images/aux_traffic_area_16.png"
         obj7.large_icon = "geores_Images/aux_traffic_area_24.png"
         obj7.tooltip = "Erstelle ein AuxiliaryTrafficArea Objekt"
         obj7.status_bar_text = "AuxiliaryTrafficArea"
         obj7.menu_text = "AuxiliaryTrafficArea"
         toolbarsurface = toolbarsurface.add_item obj7




    $toolsSurfLoaded = true
end
 
 toolbar.show
 toolbarbridge.show
 toolbartunnel.show
 toolbarobjects.show
 toolbarsurface.show
