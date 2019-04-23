# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_schema/geores_material/gres_target.rb'

class GRES_AbstractAppearance
  def initialize attrs
    @attrs = attrs
    @targets = Array.new()
    @name = ""
    @material = nil
    @ids = Array.new()
  end

  def addtarget target
    @targets.push(target)
    @ids.push(target.uri)
  end

  def setname n
    @name = n
  end

  def createskpmaterial (filedir, model)

  end

  attr_reader :targets, :name, :material, :ids
end
