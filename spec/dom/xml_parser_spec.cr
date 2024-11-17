require "../spec_helper"

describe CRXML::DOM::XMLParser do
  it "parses a XML document" do
    document = XMLParser.new(Lexer.new(<<-XML)).document
    <?xml version="1.1"?>
    <root>
      <elem id="one">
        <child id="one-1" tag="some">Lorem Ipsum</child>
      </elem>
    </root>
    XML

    assert_instance_of XMLDocument, document
    assert_equal "1.1", document.version
    assert_equal "root", document.root.name

    elem = document.root.first_element_child
    assert_equal "elem", elem.name
    assert_equal "one", elem.attributes["id"].value

    child = elem.first_element_child
    assert_equal "child", child.name
    assert_equal "one-1", child.attributes["id"].value
    assert_equal "some", child.attributes["tag"].value

    text = child.first_child.as(Text)
    assert_equal "Lorem Ipsum", text.data
  end

  it "replaces predefined entities" do
    document = XMLParser.new(Lexer.new(<<-XML)).document
    <?xml version="1.1"?>
    <root>&amp; &lt;name value=&quot;&gt;&unknown;</root>
    XML

    node = document.root.first_child
    assert_equal "&", node.as(Text).data

    node = node.next_sibling
    assert_equal " ", node.as(Text).data

    node = node.next_sibling
    assert_equal "<", node.as(Text).data

    node = node.next_sibling
    assert_equal "name value=", node.as(Text).data

    node = node.next_sibling
    assert_equal "\"", node.as(Text).data

    node = node.next_sibling
    assert_equal ">", node.as(Text).data

    node = node.next_sibling
    assert_equal "unknown", node.as(EntityRef).name
  end
end
