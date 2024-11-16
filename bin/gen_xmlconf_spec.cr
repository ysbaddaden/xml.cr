require "../src/crxml"

def gen_testcase(node, xml_base)
  id = node.attributes["ID"].value
  sections = node.attributes["SECTIONS"].value
  type = node.attributes["TYPE"].value

  uri = File.join("xmlconf", xml_base.to_s, node.attributes["URI"].value)

  if attr = node.attributes["OUTPUT"]?
    output = File.join("xmlconf", xml_base.to_s, attr.value)
  end

  message = node.text_content.gsub(/\s+/, ' ')

  puts %(it "#{id} (Section #{sections})" do)
  case type
  when "valid", "invalid"
    puts %(  document = File.open(#{uri.inspect}) { |file| CRXML.parse_xml(file) })
    if output
      puts %(  canon = File.open(#{output.inspect}) { |file| CRXML.parse_xml(file) })
      puts %(  assert_equal canon, document, #{message.inspect})
    end
  when "not-wf"
    puts %(  skip)
    # puts %(  assert_raises(CRXML::Error, #{message.inspect}) { File.open(#{uri.inspect}) { |file| CRXML.parse_xml(file) } })
  when "error"
    puts %(  skip)
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
