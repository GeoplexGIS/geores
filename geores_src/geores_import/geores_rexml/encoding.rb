# -*- mode: ruby; ruby-indent-level: 2; indent-tabs-mode: t; tab-width: 2 -*- vim: sw=2 ts=2
module REXML
  module Encoding
    @encoding_methods = {}
    def self.register(enc, &block)
      @encoding_methods[enc] = block
    end
    def self.apply(obj, enc)
      @encoding_methods[enc][obj]
    end
    def self.encoding_method(enc)
      @encoding_methods[enc]
    end

    # Native, default format is UTF-8, so it is declared here rather than in
    # an encodings/ definition.
    UTF_8 = 'UTF-8'
    UTF_16 = 'UTF-16'
    UNILE = 'UNILE'

    # ID ---> Encoding name
    attr_reader :encoding
    def encoding=( enc )
      old_verbosity = $VERBOSE
      begin
        $VERBOSE = false
        enc = enc.nil? ? nil : enc.upcase
        return false if defined? @encoding and enc == @encoding
        if enc and enc != UTF_8 and enc != "WINDOWS-1252"
          @encoding = enc
          raise ArgumentError, "Bad encoding name #@encoding" unless @encoding =~ /^[\w-]+$/
          if RUBY_VERSION < '3.0'
            @encoding.untaint
          end
          begin
            Sketchup::require 'geores_src/geores_import/geores_rexml/geores_encodings/ICONV.rb'
          Encoding.apply(self, "ICONV")
          rescue LoadError, Exception
            begin
              enc_file = File.join( "rexml", "encodings", "#@encoding.rb" )
              require enc_file
              Encoding.apply(self, @encoding)
            rescue LoadError => err
              #puts err.message
             raise ArgumentError, "No decoder found for encoding #@encoding.  Please install iconv."
            end
          end
        else
          @encoding = UTF_8
          Sketchup::require 'geores_src/geores_import/geores_rexml/geores_encodings/UTF-8.rb'
          Encoding.apply(self, @encoding)
        end
      ensure
        $VERBOSE = old_verbosity
      end
      true
    end

    def check_encoding str
      # We have to recognize UTF-16, LSB UTF-16, and UTF-8
      return UTF_16 if /\A\xfe\xff/n =~ str
      return UNILE if /\A\xff\xfe/n =~ str
      str =~ /^\s*<\?xml\s+version\s*=\s*(['"]).*?\1\s+encoding\s*=\s*(["'])(.*?)\2/um
      return $3.upcase if $3
      return UTF_8
    end
  end
end
