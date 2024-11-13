require "../src/crxml"

def gen_testcase(node, xml_base)
  id = node.attributes["ID"].value
  sections = node.attributes["SECTIONS"].value
  type = node.attributes["TYPE"].value
  uri = File.join("xmlconf", xml_base.to_s, node.attributes["URI"].value)

  if attr = node.attributes["OUTPUT"]?
    output = File.join(xml_base.to_s, attr.value)
  end

  puts %(it "#{id} (Section #{sections})" do)
  puts %(  File.open(#{uri.inspect}) do |file|)
  case type
  when "valid"
    puts %(    document = CRXML.parse_xml(file))
    if output
      puts %(    # TODO: parse output (normalized))
      puts %(    # TODO: validate parsed == output)
    end
  when "invalid"
    puts %(    skip)
  when "not-wf"
    puts %(    skip)
  end
  puts %(  end)
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

document =
  File.open("xmlconf/xmlconf.xml") do |file|
    CRXML.parse_xml(file, include_external_entities: true)
  end

puts %(require "./spec_helper")
puts

profile = document.root.attributes["PROFILE"].value
puts %(describe "#{profile}" do)

document.root.each_element_child do |element|
  gen_testcases(element, "xmlconf")
end

puts %(end)
