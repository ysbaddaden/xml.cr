# Copyright 2025 Julien PORTALIER
# Distributed under the Apache-2.0 LICENSE

require "./src/dom/parser"
require "./src/sax"

class DebugHandlers < XML::SAX::Handlers
  ROOT_PATH = Path.new(Dir.current).expand

  def open_external(base : String?, uri : String, & : (String, IO) ->) : Nil
    try_open(base, uri) do |path, relative_path|
      File.open(path, "r") { |file| yield relative_path, file }
    end
  end

  def open_external(base : String?, uri : String) : {String, IO}?
    try_open(base, uri) do |path, relative_path|
      return relative_path, File.new(path, "r")
    end
  end

  # Only opens the file at *uri* if its a local file under the current
  # directory.
  private def try_open(base, uri, &)
    if uri =~ %r{^(\w+)://(.*)$}
      return unless $1 == "file"
      uri = $2
    end

    path = ROOT_PATH.join(base, uri).expand

    if (path <=> ROOT_PATH).positive?
      yield path, path.relative_to(ROOT_PATH).to_s
    end
  end

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

  def entity_decl(entity : XML::SAX::Entity) : Nil
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

source = nil
dom = false
canon = false

ARGV.each do |arg|
  case arg
  # when "--doctype" then doctype = true
  # when "--entity" then entity = true
  when "--dom"                     then dom = true
  when "--canon", "--canonicalize" then canon = true
  when .starts_with?("-")
    abort "fatal: unknown argument #{arg}"
  else
    source ||= arg
  end
end

unless source
  abort "fatal: missing source"
end

File.open(source, "r") do |file|
  base = File.dirname(source)
  if dom
    document = XML::DOM.parse(file, base)
    if canon
      document.root.canonicalize
      p document.root
    else
      p document
    end
  else
    sax = XML::SAX.new(file, DebugHandlers.new)
    sax.base = base
    sax.parse
  end
end
