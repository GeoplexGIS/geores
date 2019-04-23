# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_schema/abstract_all.rb'
Sketchup::require 'geores_src/geores_debug/gres_cgmldebugger.rb'

class SimpleCityObjectAttribute < AbstractAll


  def initialize name, attrs
    super()
    @name = name
    @attrs = attrs
    @value = ""
  end
  
  
  def addValue value
    @value = value
  end

 attr_reader :name, :value, :attrs;

  def writeToCityGML

    retString = "<"+@name

    @attrs.each { |array|
      retString << " " + array[0].to_s + "=\"" + array[1].to_s + "\""
    }
    retString << ">"+ @value +  "</" + @name + ">\n"
    return retString
  end
  
  def buildToSKP(parent, entity, dictname, counter)
     GRES_CGMLDebugger.writedebugstring("try to put attribute " + @name + "in " + dictname + "\n")
     dictionary = entity.attribute_dictionary(dictname, true)
     if(@value == nil)
       @value = ""
     end
     dname = @name + counter.to_s
     dictionary[dname] = writeToCityGML


   end

   def buildFromSKP(entity, dictname)

   end



end
