Sketchup::require "geores_src/geores_import/geores_rexml/child.rb"
module REXML
	module DTD
		class AttlistDecl < Child
			START = "<!ATTLIST"
			START_RE = /^\s*#{START}/um
			PATTERN_RE = /\s*(#{START}.*?>)/um
		end
	end
end
