# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'sketchup.rb'

class LayerCreator
  def initialize
    model = Sketchup.active_model
    @lod1layer = model.layers.add "lod1Geometries"
    @lod1layer.color = Sketchup::Color.new(82, 129, 237)
    @lod2layer = model.layers.add "lod2Geometries"
    @lod2layer.color = Sketchup::Color.new(165, 189, 245)
    @lod3layer = model.layers.add "lod3Geometries"
    @lod3layer.color = Sketchup::Color.new(203, 217, 250)
    @lod4layer = model.layers.add "lod4Geometries"
    @lod4layer.color = Sketchup::Color.new(226, 234, 252)
    @walls = model.layers.add "walls"
    @walls.color = Sketchup::Color.new(180, 180, 180)
    @roofs = model.layers.add "roofs"
    @roofs.color = Sketchup::Color.new(227, 40, 60)
    @grounds = model.layers.add "grounds"
    @grounds.color = Sketchup::Color.new(0, 0, 60)
    @outerceilings = model.layers.add "outerceilings"
    @outerceilings.color = Sketchup::Color.new(143, 107, 114)
    @outerfloors = model.layers.add "outerfloors"
    @outerfloors.color = Sketchup::Color.new(241, 137, 190)
    @closures = model.layers.add "closures"
    @closures.color = Sketchup::Color.new(199, 244, 254)
    @ceilings = model.layers.add "ceilings"
    @ceilings.color = Sketchup::Color.new(236, 239, 172)
    @interiorwalls = model.layers.add "interiorwalls"
    @interiorwalls.color = Sketchup::Color.new(255, 255, 255)
    @floors = model.layers.add "floors"
    @floors.color = Sketchup::Color.new(34, 44, 77)
    @windows = model.layers.add "windows"
    @windows.color = Sketchup::Color.new(203, 211, 254)
    @doors = model.layers.add "doors"
    @doors.color = Sketchup::Color.new(164, 82, 72)
    @rooms = model.layers.add "rooms"
    @rooms.color = Sketchup::Color.new(64, 128, 128)
    @furnitures = model.layers.add "furniture"
    @furnitures.color = Sketchup::Color.new(128, 64, 0)
    @cityfurnitures = model.layers.add "cityfurniture"
    @cityfurnitures.color = Sketchup::Color.new(255, 83, 0)
    @generics = model.layers.add "generic_cityobjects"
    @generics.color = Sketchup::Color.new(104, 118, 0)
    @landuse = model.layers.add "landuse"
    @landuse.color = Sketchup::Color.new(7,120,16)
    @dtm = model.layers.add "dtm"
    @dtm.color = Sketchup::Color.new(102,102,103)
    @roads = model.layers.add "road"
    @roads.color = Sketchup::Color.new(65,65,65)
    @tracks = model.layers.add "tracks"
    @tracks.color = Sketchup::Color.new(70,35,0)
    @squares = model.layers.add "squares"
    @squares.color = Sketchup::Color.new(102,102,103)
    @railways = model.layers.add "railways"
    @railways.color = Sketchup::Color.new(0,0,128)
    @plantcovers = model.layers.add "plantcovers"
    @plantcovers.color = Sketchup::Color.new(128,255,0)
    @solveg = model.layers.add "solitary_vegetation_objects"
    @solveg.color = Sketchup::Color.new(107,215,0)
    @water = model.layers.add "waterbodies"
    @water.color = Sketchup::Color.new(79,167,255)
    @trafficareas = model.layers.add "trafficareas"
    @trafficareas.color = Sketchup::Color.new(155,167,155)
    @debug = model.layers.add "unknown"



  end

  attr_reader :lod1layer, :lod2layer, :lod3layer, :lod4layer, :walls, :roofs, :grounds, :outerceilings, :outerfloors, :closures, :ceilings, :interiorwalls, :floors,
   :windows, :doors, :rooms, :furnitures, :cityfurnitures, :generics, :landuse, :dtm, :roads, :tracks, :squares, :railways, :plantcovers, :solveg, :water, :trafficareas


  def getboundarylayerforname name
    if(name.index("InteriorWallSurface") != nil)
      return @interiorwalls
    end
    if(name.index("WallSurface") != nil)
      return @walls
    end
    if(name.index("RoofSurface") != nil)
      return @roofs
    end
    if(name.index("GroundSurface") != nil)
      return @grounds
    end
    if(name.index("ClosureSurface") != nil)
      return @closures
    end
    if(name.index("OuterCeilingSurface") != nil)
      return @outerceilings
    end
    if(name.index("CeilingSurface") != nil)
      return @ceilings
    end
    if(name.index("OuterFloorSurface") != nil)
      return @outerfloors
    end
    if(name.index("FloorSurface") != nil)
      return @floors
    end
    return @debug
  end

end
