# To change this template, choose Tools | Templates
# and open the template in the editor.

class GRES_SelectableCityObject

  def initialize name
    @childs = Hash.new()
    @name = name
    @lod1Solid = false
    @lod2Solid = false
    @lod3Solid = false
    @lod4Solid = false

  end

  attr_reader :childs, :name, :lod1Solid, :lod2Solid, :lod3Solid, :lod4Solid

  def print_out
    uotput = @name
    @childs.each_key{ |key|
      o = @childs[key]
      uotput  = uotput + " " + o.print_out
    }
    return uotput + "\n"
  end

  def setlod1Solid boolscher_wert
    @lod1Solid = boolscher_wert
  end
  def setlod2Solid boolscher_wert
    @lod2Solid = boolscher_wert
  end
  def setlod3Solid boolscher_wert
    @lod3Solid = boolscher_wert
  end
  def setlod4Solid boolscher_wert
    @lod4Solid = boolscher_wert
  end

end
