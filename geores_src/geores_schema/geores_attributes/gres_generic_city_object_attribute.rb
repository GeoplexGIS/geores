# To change this template, choose Tools | Templates
# and open the template in the editor.
Sketchup::require 'geores_src/geores_schema/abstract_all.rb'
Sketchup::require 'geores_src/geores_debug/gres_cgmldebugger.rb'

class GRES_GenericCityObjectAttribute < AbstractAll
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
    if(@name.index("gen:") == nil)
      @name = "gen:" + @name
    end

    retString = "<"+@name

    @attrs.each { |array|
      retString << " " + array[0].to_s + "=\"" + array[1].to_s + "\""
    }
    retString << ">\n"
    retString << "<gen:Value>"+ @value + "</gen:Value>\n"
    retString << "</" + @name + ">\n"
    return retString
  end

  def buildToSKP(parent, entity, dictname, counter)
     GRES_CGMLDebugger.writedebugstring("try to put attribute " + @name + "in " + dictname + "\n")
     dictionary = entity.attribute_dictionary(dictname, true)
     dname = "GenericAttribute" + counter.to_s
     if(@value == nil)
       @value = ""
     end
      GRES_CGMLDebugger.writedebugstring("Value is " + @value + " Counter is " + counter.to_s + "\n")
      cgmlstring = writeToCityGML
      GRES_CGMLDebugger.writedebugstring("Output is " + cgmlstring + "\n")
     dictionary[dname] = cgmlstring



   end

   def buildFromSKP(entity, dictname)

   end


end
