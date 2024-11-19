require "./dom/*"
require "./node"
require "./document"
require "./xml_document"
require "./document_type"
require "./document_fragment"
require "./element"
require "./attribute"
require "./character_data"
require "./entity"

module CRXML
  class DOMError < Exception
  end

  def self.parse_xml(
    string : String,
    external = false,
    options : Options = Options::None,
  ) : XMLDocument
    DOM::XMLParser.new(Lexer.new(string, options), external).document
  end

  def self.parse_xml(
    io : IO,
    external = false,
    options : Options = Options::None,
  ) : XMLDocument
    DOM::XMLParser.new(Lexer.new(io, options), external).document
  end
end
