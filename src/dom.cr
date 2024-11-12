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

  def self.parse_xml(string : String) : Document
    DOM::XMLParser.new(Lexer.new(string)).document
  end

  def self.parse_xml(io : IO) : Document
    DOM::XMLParser.new(Lexer.new(io)).document
  end
end
