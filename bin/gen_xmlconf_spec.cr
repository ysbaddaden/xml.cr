#! /usr/bin/env -S crystal i
# Copyright 2025 Julien PORTALIER
# Distributed under the Apache-2.0 LICENSE

require "../src/dom/parser"

DISABLED = [
  "xmlconf/eduni/errata-3e/E13.xml", # can't pass (undeclared entity is a VC but we still fail and expect the file to parse)
]

def gen_testcase(node, xml_base)
  id = node.attributes["ID"].value
  sections = node.attributes["SECTIONS"].value
  type = node.attributes["TYPE"].value
  entities = node.attributes["ENTITIES"]?

  # we only implement the last XML 1.0 edition (the fifth), skip tests for
  # previous editions (legacy)
  if attr = node.attributes["EDITION"]?
    editions = attr.value.split(' ')
    return unless editions.includes?("5")
  end

  uri = File.join("xmlconf", xml_base.to_s, node.attributes["URI"].value)
  if attr = node.attributes["OUTPUT"]?
    output = File.join("xmlconf", xml_base.to_s, attr.value)
  end

  message = node.text_content.gsub(/\s+/, ' ')
  message += " (#{uri})"

  puts %(it "#{id} (Section #{sections})" do)
  if DISABLED.includes?(uri)
    puts %(  skip "disabled test")
  else
    case type
    when "valid", "invalid"
      puts %(  assert_parses(#{uri.inspect}, #{output.inspect}, #{message.inspect}))
    when "not-wf"
      puts %(  refute_parses(#{uri.inspect}, #{message.inspect}))
    when "error"
      if uri.starts_with?("xmlconf/japanese")
        # only an error if we don't support the encodings (we do)
        puts %(  assert_parses(#{uri.inspect}, nil, #{message.inspect}))
      else
        puts %(  refute_parses(#{uri.inspect}, #{message.inspect}))
      end
    end
  end
  puts %(end)
  puts
end

def gen_testcases(node, xml_base = nil)
  profile = node.attributes["PROFILE"]?.try(&.value)

  if attr = node.attributes["xml:base"]?
    xml_base = attr.value
  end

  puts %(describe "#{profile || xml_base}" do)

  node.each_element_child do |child|
    case child.name
    when "TESTCASES"
      gen_testcases(child, xml_base)
    when "TEST"
      gen_testcase(child, xml_base)
    end
  end

  puts %(end)
  puts
end

class XML::DOM::Parser < XML::SAX::Handlers
  ROOT_PATH = Path.new(Dir.current).expand

  def open_external(base : String?, uri : String, & : (String, IO) ->) : Nil
    resolve_external(base, uri) do |path, relative_path|
      File.open(path, "r") { |file| yield relative_path, file }
    end
  end

  def open_external(base : String?, uri : String) : {String, IO}?
    resolve_external(base, uri) do |path, relative_path|
      return relative_path, File.new(path, "r")
    end
  end

  # Only opens the file at *uri* if its a local file under the current
  # directory.
  private def resolve_external(base, uri, &)
    if uri =~ %r{^(\w+)://(.*)$}
      return unless $1 == "file"
      uri = $2
    end

    path = ROOT_PATH.join(base, uri).expand

    if (path <=> ROOT_PATH).positive?
      yield path, path.relative_to(ROOT_PATH).to_s
    end
  end
end

document = File.open("xmlconf/xmlconf.xml") do |file|
  # NOTE: assumes that the xmlconf is in the current working directory
  XML::DOM.parse(file, base: "xmlconf")
end

puts %(require "./spec_helper")
puts

profile = document.root.attributes["PROFILE"].value
puts %(describe "#{profile}" do)

document.root.each_element_child do |element|
  gen_testcases(element, "xmlconf")
end

puts %(end)
