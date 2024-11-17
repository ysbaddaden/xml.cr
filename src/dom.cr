require "./dom/*"
require "./node"
require "./document"
require "./xml_document"
require "./document_type"
require "./document_fragment"
require "./element"
require "./attribute"
require "./character_data"

module CRXML
  class DOMError < Exception
  end

  def self.parse_xml(string : String, **options) : Document
    DOM::XMLParser.new(Lexer.new(string, **options)).document
  end

  def self.parse_xml(io : IO, **options) : Document
    DOM::XMLParser.new(Lexer.new(io, **options)).document
  end
end
