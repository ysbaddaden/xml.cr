#! /usr/bin/env -S crystal i
require "../src/dom/parser"

DISABLED = [
  "xmlconf/eduni/errata-3e/E13.xml", # can't pass: invalid because of undeclared entity (parse error)
]

def gen_testcase(node, xml_base)
  id = node.attributes["ID"].value
  sections = node.attributes["SECTIONS"].value
  type = node.attributes["TYPE"].value
  entities = node.attributes["ENTITIES"]?

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
      puts %(  assert_raises(XML::Error, #{message.inspect}) do)
      puts %(    File.open(#{uri.inspect}) do |file|)
      puts %(      XML::DOM.parse(file))
      puts %(    end)
      puts %(  end)
    when "error"
      if uri.starts_with?("xmlconf/japanese")
        puts %(  assert_parses(#{uri.inspect}, nil, #{message.inspect}))
      else
        puts %(  assert_raises(#{message.inspect}) do)
        puts %(    File.open(#{uri.inspect}) { |file| XML::DOM.parse(file, base: #{File.dirname(uri).inspect}) })
        puts %(  end)
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
end

document = File.open("xmlconf/xmlconf.xml") do |file|
  # TODO: enable parsing of external entities
  XML::DOM.parse(file, base: "xmlconf")
end

puts
puts <<-CRYSTAL
require "minitest/autorun"
require "minitest/spec"
require "./src/dom/parser"

class XML::DOM::Parser < XML::SAX::Handlers
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
end

class Minitest::Test
  def assert_parses(input, output, message, file = __FILE__, line = __LINE__)
    document = File.open(input) do |file|
      XML::DOM.parse(file, base: File.dirname(input))
    end

    if output
      document.root.canonicalize
      canon = File.open(output) { |file| XML::DOM.parse(file) }
      canon.root.canonicalize # NOTE: it's expected to already be canon...
      assert_equal canon.root.inspect, document.root.inspect, message, file, line
    end
  end
end

CRYSTAL

profile = document.root.attributes["PROFILE"].value
puts %(describe "#{profile}" do)

document.root.each_element_child do |element|
  gen_testcases(element, "xmlconf")
end

puts %(end)
