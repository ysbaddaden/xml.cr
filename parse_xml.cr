# Copyright 2025 Julien PORTALIER
# Distributed under the Apache-2.0 LICENSE

require "./src/sax"

class DebugHandlers < XML::SAX::Handlers
  def xml_decl(version : String, encoding : String, standalone : Bool) : Nil
    p [:xml_decl, version, encoding, standalone]
  end

  def start_doctype_decl(name : String, system_id : String?, public_id : String?, intsubset : Bool)
    p [:start_doctype_decl, name, system_id, public_id, intsubset]
  end

  def attlist_decl(element_name : String, attribute_name : String, type : Symbol, names : Array(String)?, default : Symbol, value : String?) : Nil
    p [:attlist_decl, element_name, attribute_name, type, names, default, value]
  end

  def element_decl(name : String, content : XML::SAX::ElementDecl) : Nil
    p [:element_decl, name, content]
  end

  def entity_decl(entity : XML::SAX::EntityDecl) : Nil
    p [:entity_decl, entity]
  end

  def notation_decl(name : String, public_id : String?, system_id : String?) : Nil
    p [:notation_decl, name, public_id, system_id]
  end

  def end_doctype_decl : Nil
    p [:end_doctype_decl]
  end

  def processing_instruction(target : String, data : String) : Nil
    p [:processing_instruction, target, data]
  end

  def start_element(name : String, attributes : Array({String, String})) : Nil
    p [:start_element, name, attributes]
  end

  def end_element(name : String) : Nil
    p [:end_element, name]
  end

  def empty_element(name : String, attributes : Array({String, String})) : Nil
    p [:empty_element, name, attributes]
  end

  def character_data(data : String) : Nil
    p [:character_data, data]
  end

  def entity_reference(name : String) : Nil
    p [:entity_reference, name]
  end

  def comment(data : String) : Nil
    p [:comment, data]
  end

  def cdata_section(data : String) : Nil
    p [:cdata_section, data]
  end

  def error(message : String, location : XML::Location)
    p [:error, message, location]
  end
end

File.open(ARGV[0], "r") do |file|
  sax = XML::SAX.new(file, DebugHandlers.new)
  sax.parse
end
