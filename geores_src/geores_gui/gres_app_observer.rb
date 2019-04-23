# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'sketchup.rb'
Sketchup::require 'geores_src/geores_gui/gres_city_object_dialog.rb'
Sketchup::require 'geores_src/geores_parser/layer_creator.rb'

class GRES_AppObserver < Sketchup::AppObserver

  def initialize gui
    super()
    @gui = gui
  end


  def onNewModel(model)

    model.selection.add_observer(GRES_CityObjectDialog.getobserver)
    @gui.clear()
    lm = LayerCreator.new()
 end

  def onOpenModel(model)
    model.selection.add_observer(GRES_CityObjectDialog.getobserver)
    @gui.clear()
    lm = LayerCreator.new()
 end

end
