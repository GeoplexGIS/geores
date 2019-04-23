Sketchup::require 'geores_src/geores_import/geores_rexml/geores_encodings/US-ASCII.rb'

module REXML
  module Encoding
    register("ISO-8859-1", &encoding_method("US-ASCII"))
  end
end
