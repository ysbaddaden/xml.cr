
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
    if uri =~ %r{^(w+)://(.*)$}
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
describe "XML 1.0 (2nd edition) W3C Conformance Test Suite, 6 October 2000" do
describe "James Clark  XML 1.0 Tests" do
describe "James Clark XMLTEST cases, 18-Nov-1998" do
it "not-wf-sa-001 (Section 3.1 [41])" do
  assert_raises(XML::Error, " Attribute values must start with attribute names, not \"?\".  (xmlconf/xmltest/not-wf/sa/001.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/001.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-002 (Section 2.3 [4])" do
  assert_raises(XML::Error, " Names may not start with \".\"; it's not a Letter.  (xmlconf/xmltest/not-wf/sa/002.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/002.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-003 (Section 2.6 [16])" do
  assert_raises(XML::Error, " Processing Instruction target name is required. (xmlconf/xmltest/not-wf/sa/003.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/003.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-004 (Section 2.6 [16])" do
  assert_raises(XML::Error, " SGML-ism: processing instructions end in '?>' not '>'.  (xmlconf/xmltest/not-wf/sa/004.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/004.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-005 (Section 2.6 [16])" do
  assert_raises(XML::Error, " Processing instructions end in '?>' not '?'.  (xmlconf/xmltest/not-wf/sa/005.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/005.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-006 (Section 2.5 [16])" do
  assert_raises(XML::Error, " XML comments may not contain \"--\"  (xmlconf/xmltest/not-wf/sa/006.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/006.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-007 (Section 4.1 [68])" do
  assert_raises(XML::Error, " General entity references have no whitespace after the entity name and before the semicolon.  (xmlconf/xmltest/not-wf/sa/007.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/007.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-008 (Section 2.3 [5])" do
  assert_raises(XML::Error, " Entity references must include names, which don't begin with '.' (it's not a Letter or other name start character).  (xmlconf/xmltest/not-wf/sa/008.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/008.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-009 (Section 4.1 [66])" do
  assert_raises(XML::Error, " Character references may have only decimal or numeric strings. (xmlconf/xmltest/not-wf/sa/009.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/009.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-010 (Section 4.1 [68])" do
  assert_raises(XML::Error, " Ampersand may only appear as part of a general entity reference. (xmlconf/xmltest/not-wf/sa/010.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/010.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-011 (Section 3.1 [41])" do
  assert_raises(XML::Error, " SGML-ism: attribute values must be explicitly assigned a value, it can't act as a boolean toggle.  (xmlconf/xmltest/not-wf/sa/011.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/011.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-012 (Section 2.3 [10])" do
  assert_raises(XML::Error, " SGML-ism: attribute values must be quoted in all cases.  (xmlconf/xmltest/not-wf/sa/012.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/012.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-013 (Section 2.3 [10])" do
  assert_raises(XML::Error, " The quotes on both ends of an attribute value must match.  (xmlconf/xmltest/not-wf/sa/013.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/013.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-014 (Section 2.3 [10])" do
  assert_raises(XML::Error, " Attribute values may not contain literal '<' characters.  (xmlconf/xmltest/not-wf/sa/014.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/014.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-015 (Section 3.1 [41])" do
  assert_raises(XML::Error, " Attribute values need a value, not just an equals sign.  (xmlconf/xmltest/not-wf/sa/015.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/015.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-016 (Section 3.1 [41])" do
  assert_raises(XML::Error, " Attribute values need an associated name. (xmlconf/xmltest/not-wf/sa/016.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/016.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-017 (Section 2.7 [18])" do
  assert_raises(XML::Error, " CDATA sections need a terminating ']]>'.  (xmlconf/xmltest/not-wf/sa/017.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/017.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-018 (Section 2.7 [19])" do
  assert_raises(XML::Error, " CDATA sections begin with a literal '<![CDATA[', no space. (xmlconf/xmltest/not-wf/sa/018.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/018.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-019 (Section 3.1 [42])" do
  assert_raises(XML::Error, " End tags may not be abbreviated as '</>'. (xmlconf/xmltest/not-wf/sa/019.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/019.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-020 (Section 2.3 [10])" do
  assert_raises(XML::Error, " Attribute values may not contain literal '&' characters except as part of an entity reference.  (xmlconf/xmltest/not-wf/sa/020.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/020.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-021 (Section 2.3 [10])" do
  assert_raises(XML::Error, " Attribute values may not contain literal '&' characters except as part of an entity reference.  (xmlconf/xmltest/not-wf/sa/021.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/021.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-022 (Section 4.1 [66])" do
  assert_raises(XML::Error, " Character references end with semicolons, always! (xmlconf/xmltest/not-wf/sa/022.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/022.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-023 (Section 2.3 [5])" do
  assert_raises(XML::Error, " Digits are not valid name start characters.  (xmlconf/xmltest/not-wf/sa/023.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/023.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-024 (Section 2.3 [5])" do
  assert_raises(XML::Error, " Digits are not valid name start characters.  (xmlconf/xmltest/not-wf/sa/024.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/024.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-025 (Section 2.4 [14])" do
  assert_raises(XML::Error, " Text may not contain a literal ']]>' sequence.  (xmlconf/xmltest/not-wf/sa/025.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/025.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-026 (Section 2.4 [14])" do
  assert_raises(XML::Error, " Text may not contain a literal ']]>' sequence.  (xmlconf/xmltest/not-wf/sa/026.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/026.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-027 (Section 2.5 [15])" do
  assert_raises(XML::Error, " Comments must be terminated with \"-->\". (xmlconf/xmltest/not-wf/sa/027.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/027.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-028 (Section 2.6 [16])" do
  assert_raises(XML::Error, " Processing instructions must end with '?>'.  (xmlconf/xmltest/not-wf/sa/028.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/028.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-029 (Section 2.4 [14])" do
  assert_raises(XML::Error, " Text may not contain a literal ']]>' sequence.  (xmlconf/xmltest/not-wf/sa/029.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/029.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-030 (Section 2.2 [2])" do
  assert_raises(XML::Error, " A form feed is not a legal XML character.  (xmlconf/xmltest/not-wf/sa/030.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/030.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-031 (Section 2.2 [2])" do
  assert_raises(XML::Error, " A form feed is not a legal XML character.  (xmlconf/xmltest/not-wf/sa/031.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/031.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-032 (Section 2.2 [2])" do
  assert_raises(XML::Error, " A form feed is not a legal XML character.  (xmlconf/xmltest/not-wf/sa/032.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/032.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-033 (Section 2.2 [2])" do
  assert_raises(XML::Error, " An ESC (octal 033) is not a legal XML character.  (xmlconf/xmltest/not-wf/sa/033.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/033.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-034 (Section 2.2 [2])" do
  assert_raises(XML::Error, " A form feed is not a legal XML character.  (xmlconf/xmltest/not-wf/sa/034.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/034.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-035 (Section 3.1 [43])" do
  assert_raises(XML::Error, " The '<' character is a markup delimiter and must start an element, CDATA section, PI, or comment.  (xmlconf/xmltest/not-wf/sa/035.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/035.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-036 (Section 2.8 [27])" do
  assert_raises(XML::Error, " Text may not appear after the root element.  (xmlconf/xmltest/not-wf/sa/036.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/036.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-037 (Section 2.8 [27])" do
  assert_raises(XML::Error, " Character references may not appear after the root element.  (xmlconf/xmltest/not-wf/sa/037.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/037.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-038 (Section 3.1)" do
  assert_raises(XML::Error, " Tests the \"Unique Att Spec\" WF constraint by providing multiple values for an attribute. (xmlconf/xmltest/not-wf/sa/038.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/038.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-039 (Section 3)" do
  assert_raises(XML::Error, " Tests the Element Type Match WFC - end tag name must match start tag name. (xmlconf/xmltest/not-wf/sa/039.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/039.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-040 (Section 2.8 [27])" do
  assert_raises(XML::Error, " Provides two document elements. (xmlconf/xmltest/not-wf/sa/040.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/040.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-041 (Section 2.8 [27])" do
  assert_raises(XML::Error, " Provides two document elements. (xmlconf/xmltest/not-wf/sa/041.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/041.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-042 (Section 3.1 [42])" do
  assert_raises(XML::Error, " Invalid End Tag  (xmlconf/xmltest/not-wf/sa/042.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/042.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-043 (Section 2.8 [27])" do
  assert_raises(XML::Error, " Provides #PCDATA text after the document element.  (xmlconf/xmltest/not-wf/sa/043.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/043.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-044 (Section 2.8 [27])" do
  assert_raises(XML::Error, " Provides two document elements. (xmlconf/xmltest/not-wf/sa/044.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/044.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-045 (Section 3.1 [44])" do
  assert_raises(XML::Error, " Invalid Empty Element Tag  (xmlconf/xmltest/not-wf/sa/045.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/045.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-046 (Section 3.1 [40])" do
  assert_raises(XML::Error, " This start (or empty element) tag was not terminated correctly.  (xmlconf/xmltest/not-wf/sa/046.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/046.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-047 (Section 3.1 [44])" do
  assert_raises(XML::Error, " Invalid empty element tag invalid whitespace  (xmlconf/xmltest/not-wf/sa/047.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/047.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-048 (Section 2.8 [27])" do
  assert_raises(XML::Error, " Provides a CDATA section after the root element. (xmlconf/xmltest/not-wf/sa/048.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/048.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-049 (Section 3.1 [40])" do
  assert_raises(XML::Error, " Missing start tag  (xmlconf/xmltest/not-wf/sa/049.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/049.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-050 (Section 2.1 [1])" do
  assert_raises(XML::Error, " Empty document, with no root element.  (xmlconf/xmltest/not-wf/sa/050.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/050.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-051 (Section 2.7 [18])" do
  assert_raises(XML::Error, " CDATA is invalid at top level of document. (xmlconf/xmltest/not-wf/sa/051.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/051.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-052 (Section 4.1 [66])" do
  assert_raises(XML::Error, " Invalid character reference.  (xmlconf/xmltest/not-wf/sa/052.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/052.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-053 (Section 3.1 [42])" do
  assert_raises(XML::Error, " End tag does not match start tag.  (xmlconf/xmltest/not-wf/sa/053.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/053.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-054 (Section 4.2.2 [75])" do
  assert_raises(XML::Error, " PUBLIC requires two literals. (xmlconf/xmltest/not-wf/sa/054.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/054.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-055 (Section 2.8 [28])" do
  assert_raises(XML::Error, " Invalid Document Type Definition format.  (xmlconf/xmltest/not-wf/sa/055.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/055.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-056 (Section 2.8 [28])" do
  assert_raises(XML::Error, " Invalid Document Type Definition format - misplaced comment.  (xmlconf/xmltest/not-wf/sa/056.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/056.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-057 (Section 3.2 [45])" do
  assert_raises(XML::Error, " This isn't SGML; comments can't exist in declarations.  (xmlconf/xmltest/not-wf/sa/057.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/057.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-058 (Section 3.3.1 [54])" do
  assert_raises(XML::Error, " Invalid character , in ATTLIST enumeration  (xmlconf/xmltest/not-wf/sa/058.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/058.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-059 (Section 3.3.1 [59])" do
  assert_raises(XML::Error, " String literal must be in quotes.  (xmlconf/xmltest/not-wf/sa/059.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/059.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-060 (Section 3.3.1 [56])" do
  assert_raises(XML::Error, " Invalid type NAME defined in ATTLIST. (xmlconf/xmltest/not-wf/sa/060.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/060.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-061 (Section 4.2.2 [75])" do
  assert_raises(XML::Error, " External entity declarations require whitespace between public and system IDs. (xmlconf/xmltest/not-wf/sa/061.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/061.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-062 (Section 4.2 [71])" do
  assert_raises(XML::Error, " Entity declarations need space after the entity name.  (xmlconf/xmltest/not-wf/sa/062.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/062.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-063 (Section 2.8 [29])" do
  assert_raises(XML::Error, " Conditional sections may only appear in the external DTD subset.  (xmlconf/xmltest/not-wf/sa/063.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/063.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-064 (Section 3.3 [53])" do
  assert_raises(XML::Error, " Space is required between attribute type and default values in <!ATTLIST...> declarations.  (xmlconf/xmltest/not-wf/sa/064.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/064.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-065 (Section 3.3 [53])" do
  assert_raises(XML::Error, " Space is required between attribute name and type in <!ATTLIST...> declarations.  (xmlconf/xmltest/not-wf/sa/065.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/065.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-066 (Section 3.3 [52])" do
  assert_raises(XML::Error, " Required whitespace is missing.  (xmlconf/xmltest/not-wf/sa/066.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/066.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-067 (Section 3.3 [53])" do
  assert_raises(XML::Error, " Space is required between attribute type and default values in <!ATTLIST...> declarations.  (xmlconf/xmltest/not-wf/sa/067.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/067.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-068 (Section 3.3.1 [58])" do
  assert_raises(XML::Error, " Space is required between NOTATION keyword and list of enumerated choices in <!ATTLIST...> declarations.  (xmlconf/xmltest/not-wf/sa/068.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/068.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-069 (Section 4.2.2 [76])" do
  assert_raises(XML::Error, " Space is required before an NDATA entity annotation. (xmlconf/xmltest/not-wf/sa/069.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/069.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-070 (Section 2.5 [16])" do
  assert_raises(XML::Error, " XML comments may not contain \"--\"  (xmlconf/xmltest/not-wf/sa/070.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/070.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-071 (Section 4.1 [68])" do
  assert_raises(XML::Error, " ENTITY can't reference itself directly or indirectly. (xmlconf/xmltest/not-wf/sa/071.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/071.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-072 (Section 4.1 [68])" do
  assert_raises(XML::Error, " Undefined ENTITY foo.  (xmlconf/xmltest/not-wf/sa/072.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/072.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-073 (Section 4.1 [68])" do
  assert_raises(XML::Error, " Undefined ENTITY f.  (xmlconf/xmltest/not-wf/sa/073.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/073.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-074 (Section 4.3.2)" do
  assert_raises(XML::Error, " Internal general parsed entities are only well formed if they match the \"content\" production.  (xmlconf/xmltest/not-wf/sa/074.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/074.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-075 (Section 4.1 [68])" do
  assert_raises(XML::Error, " ENTITY can't reference itself directly or indirectly.  (xmlconf/xmltest/not-wf/sa/075.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/075.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-076 (Section 4.1 [68])" do
  assert_raises(XML::Error, " Undefined ENTITY foo.  (xmlconf/xmltest/not-wf/sa/076.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/076.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-077 (Section 41. [68])" do
  assert_raises(XML::Error, " Undefined ENTITY bar.  (xmlconf/xmltest/not-wf/sa/077.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/077.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-078 (Section 4.1 [68])" do
  assert_raises(XML::Error, " Undefined ENTITY foo.  (xmlconf/xmltest/not-wf/sa/078.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/078.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-079 (Section 4.1 [68])" do
  assert_raises(XML::Error, " ENTITY can't reference itself directly or indirectly.  (xmlconf/xmltest/not-wf/sa/079.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/079.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-080 (Section 4.1 [68])" do
  assert_raises(XML::Error, " ENTITY can't reference itself directly or indirectly.  (xmlconf/xmltest/not-wf/sa/080.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/080.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-081 (Section 3.1)" do
  assert_raises(XML::Error, " This tests the No External Entity References WFC, since the entity is referred to within an attribute.  (xmlconf/xmltest/not-wf/sa/081.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/081.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-082 (Section 3.1)" do
  assert_raises(XML::Error, " This tests the No External Entity References WFC, since the entity is referred to within an attribute.  (xmlconf/xmltest/not-wf/sa/082.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/082.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-083 (Section 4.2.2 [76])" do
  assert_raises(XML::Error, " Undefined NOTATION n.  (xmlconf/xmltest/not-wf/sa/083.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/083.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-084 (Section 4.1)" do
  assert_raises(XML::Error, " Tests the Parsed Entity WFC by referring to an unparsed entity. (This precedes the error of not declaring that entity's notation, which may be detected any time before the DTD parsing is completed.)  (xmlconf/xmltest/not-wf/sa/084.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/084.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-085 (Section 2.3 [13])" do
  assert_raises(XML::Error, " Public IDs may not contain \"[\".  (xmlconf/xmltest/not-wf/sa/085.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/085.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-086 (Section 2.3 [13])" do
  assert_raises(XML::Error, " Public IDs may not contain \"[\".  (xmlconf/xmltest/not-wf/sa/086.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/086.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-087 (Section 2.3 [13])" do
  assert_raises(XML::Error, " Public IDs may not contain \"[\".  (xmlconf/xmltest/not-wf/sa/087.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/087.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-088 (Section 2.3 [10])" do
  assert_raises(XML::Error, " Attribute values are terminated by literal quote characters, and any entity expansion is done afterwards.  (xmlconf/xmltest/not-wf/sa/088.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/088.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-089 (Section 4.2 [74])" do
  assert_raises(XML::Error, " Parameter entities \"are\" always parsed; NDATA annotations are not permitted. (xmlconf/xmltest/not-wf/sa/089.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/089.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-090 (Section 2.3 [10])" do
  assert_raises(XML::Error, " Attributes may not contain a literal \"<\" character; this one has one because of reference expansion.  (xmlconf/xmltest/not-wf/sa/090.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/090.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-091 (Section 4.2 [74])" do
  assert_raises(XML::Error, " Parameter entities \"are\" always parsed; NDATA annotations are not permitted. (xmlconf/xmltest/not-wf/sa/091.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/091.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-092 (Section 4.5)" do
  assert_raises(XML::Error, " The replacement text of this entity has an illegal reference, because the character reference is expanded immediately.  (xmlconf/xmltest/not-wf/sa/092.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/092.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-093 (Section 4.1 [66])" do
  assert_raises(XML::Error, " Hexadecimal character references may not use the uppercase 'X'. (xmlconf/xmltest/not-wf/sa/093.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/093.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-094 (Section 2.8 [24])" do
  assert_raises(XML::Error, " Prolog VERSION must be lowercase.  (xmlconf/xmltest/not-wf/sa/094.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/094.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-095 (Section 2.8 [23])" do
  assert_raises(XML::Error, " VersionInfo must come before EncodingDecl.  (xmlconf/xmltest/not-wf/sa/095.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/095.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-096 (Section 2.9 [32])" do
  assert_raises(XML::Error, " Space is required before the standalone declaration.  (xmlconf/xmltest/not-wf/sa/096.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/096.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-097 (Section 2.8 [24])" do
  assert_raises(XML::Error, " Both quotes surrounding VersionNum must be the same.  (xmlconf/xmltest/not-wf/sa/097.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/097.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-098 (Section 2.8 [23])" do
  assert_raises(XML::Error, " Only one \"version=...\" string may appear in an XML declaration. (xmlconf/xmltest/not-wf/sa/098.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/098.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-099 (Section 2.8 [23])" do
  assert_raises(XML::Error, " Only three pseudo-attributes are in the XML declaration, and \"valid=...\" is not one of them.  (xmlconf/xmltest/not-wf/sa/099.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/099.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-100 (Section 2.9 [32])" do
  assert_raises(XML::Error, " Only \"yes\" and \"no\" are permitted as values of \"standalone\".  (xmlconf/xmltest/not-wf/sa/100.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/100.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-101 (Section 4.3.3 [81])" do
  assert_raises(XML::Error, " Space is not permitted in an encoding name.  (xmlconf/xmltest/not-wf/sa/101.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/101.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-102 (Section 2.8 [26])" do
  assert_raises(XML::Error, " Provides an illegal XML version number; spaces are illegal. (xmlconf/xmltest/not-wf/sa/102.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/102.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-103 (Section 4.3.2)" do
  assert_raises(XML::Error, " End-tag required for element foo.  (xmlconf/xmltest/not-wf/sa/103.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/103.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-104 (Section 4.3.2)" do
  assert_raises(XML::Error, " Internal general parsed entities are only well formed if they match the \"content\" production.  (xmlconf/xmltest/not-wf/sa/104.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/104.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-105 (Section 2.7 )" do
  assert_raises(XML::Error, " Invalid placement of CDATA section.  (xmlconf/xmltest/not-wf/sa/105.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/105.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-106 (Section 4.2)" do
  assert_raises(XML::Error, " Invalid placement of entity declaration.  (xmlconf/xmltest/not-wf/sa/106.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/106.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-107 (Section 2.8 [28])" do
  assert_raises(XML::Error, " Invalid document type declaration. CDATA alone is invalid. (xmlconf/xmltest/not-wf/sa/107.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/107.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-108 (Section 2.7 [19])" do
  assert_raises(XML::Error, " No space in '<![CDATA['. (xmlconf/xmltest/not-wf/sa/108.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/108.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-109 (Section 4.2 [70])" do
  assert_raises(XML::Error, " Tags invalid within EntityDecl.  (xmlconf/xmltest/not-wf/sa/109.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/109.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-110 (Section 4.1 [68])" do
  assert_raises(XML::Error, " Entity reference must be in content of element.  (xmlconf/xmltest/not-wf/sa/110.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/110.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-111 (Section 3.1 [43])" do
  assert_raises(XML::Error, " Entiry reference must be in content of element not Start-tag.  (xmlconf/xmltest/not-wf/sa/111.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/111.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-112 (Section 2.7 [19])" do
  assert_raises(XML::Error, " CDATA sections start '<![CDATA[', not '<!cdata['. (xmlconf/xmltest/not-wf/sa/112.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/112.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-113 (Section 2.3 [9])" do
  assert_raises(XML::Error, " Parameter entity values must use valid reference syntax; this reference is malformed. (xmlconf/xmltest/not-wf/sa/113.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/113.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-114 (Section 2.3 [9])" do
  assert_raises(XML::Error, " General entity values must use valid reference syntax; this reference is malformed. (xmlconf/xmltest/not-wf/sa/114.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/114.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-115 (Section 4.5)" do
  assert_raises(XML::Error, " The replacement text of this entity is an illegal character reference, which must be rejected when it is parsed in the context of an attribute value. (xmlconf/xmltest/not-wf/sa/115.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/115.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-116 (Section 4.3.2)" do
  assert_raises(XML::Error, " Internal general parsed entities are only well formed if they match the \"content\" production. This is a partial character reference, not a full one.  (xmlconf/xmltest/not-wf/sa/116.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/116.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-117 (Section 4.3.2)" do
  assert_raises(XML::Error, " Internal general parsed entities are only well formed if they match the \"content\" production. This is a partial character reference, not a full one.  (xmlconf/xmltest/not-wf/sa/117.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/117.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-118 (Section 4.1 [68])" do
  assert_raises(XML::Error, " Entity reference expansion is not recursive. (xmlconf/xmltest/not-wf/sa/118.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/118.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-119 (Section 4.3.2)" do
  assert_raises(XML::Error, " Internal general parsed entities are only well formed if they match the \"content\" production. This is a partial character reference, not a full one.  (xmlconf/xmltest/not-wf/sa/119.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/119.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-120 (Section 4.5)" do
  assert_raises(XML::Error, " Character references are expanded in the replacement text of an internal entity, which is then parsed as usual. Accordingly, & must be doubly quoted - encoded either as &amp; or as &#38;#38;.  (xmlconf/xmltest/not-wf/sa/120.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/120.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-121 (Section 4.1 [68])" do
  assert_raises(XML::Error, " A name of an ENTITY was started with an invalid character.  (xmlconf/xmltest/not-wf/sa/121.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/121.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-122 (Section 3.2.1 [47])" do
  assert_raises(XML::Error, " Invalid syntax mixed connectors are used.  (xmlconf/xmltest/not-wf/sa/122.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/122.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-123 (Section 3.2.1 [48])" do
  assert_raises(XML::Error, " Invalid syntax mismatched parenthesis.  (xmlconf/xmltest/not-wf/sa/123.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/123.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-124 (Section 3.2.2 [51])" do
  assert_raises(XML::Error, " Invalid format of Mixed-content declaration.  (xmlconf/xmltest/not-wf/sa/124.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/124.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-125 (Section 3.2.2 [51])" do
  assert_raises(XML::Error, " Invalid syntax extra set of parenthesis not necessary.  (xmlconf/xmltest/not-wf/sa/125.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/125.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-126 (Section 3.2.2 [51])" do
  assert_raises(XML::Error, " Invalid syntax Mixed-content must be defined as zero or more.  (xmlconf/xmltest/not-wf/sa/126.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/126.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-127 (Section 3.2.2 [51])" do
  assert_raises(XML::Error, " Invalid syntax Mixed-content must be defined as zero or more.  (xmlconf/xmltest/not-wf/sa/127.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/127.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-128 (Section 2.7 [18])" do
  assert_raises(XML::Error, " Invalid CDATA syntax.  (xmlconf/xmltest/not-wf/sa/128.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/128.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-129 (Section 3.2 [45])" do
  assert_raises(XML::Error, " Invalid syntax for Element Type Declaration.  (xmlconf/xmltest/not-wf/sa/129.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/129.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-130 (Section 3.2 [45])" do
  assert_raises(XML::Error, " Invalid syntax for Element Type Declaration.  (xmlconf/xmltest/not-wf/sa/130.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/130.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-131 (Section 3.2 [45])" do
  assert_raises(XML::Error, " Invalid syntax for Element Type Declaration.  (xmlconf/xmltest/not-wf/sa/131.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/131.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-132 (Section 3.2.1 [50])" do
  assert_raises(XML::Error, " Invalid syntax mixed connectors used.  (xmlconf/xmltest/not-wf/sa/132.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/132.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-133 (Section 3.2.1)" do
  assert_raises(XML::Error, " Illegal whitespace before optional character causes syntax error.  (xmlconf/xmltest/not-wf/sa/133.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/133.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-134 (Section 3.2.1)" do
  assert_raises(XML::Error, " Illegal whitespace before optional character causes syntax error.  (xmlconf/xmltest/not-wf/sa/134.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/134.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-135 (Section 3.2.1 [47])" do
  assert_raises(XML::Error, " Invalid character used as connector.  (xmlconf/xmltest/not-wf/sa/135.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/135.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-136 (Section 3.2 [45])" do
  assert_raises(XML::Error, " Tag omission is invalid in XML.  (xmlconf/xmltest/not-wf/sa/136.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/136.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-137 (Section 3.2 [45])" do
  assert_raises(XML::Error, " Space is required before a content model.  (xmlconf/xmltest/not-wf/sa/137.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/137.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-138 (Section 3.2.1 [48])" do
  assert_raises(XML::Error, " Invalid syntax for content particle.  (xmlconf/xmltest/not-wf/sa/138.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/138.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-139 (Section 3.2.1 [46])" do
  assert_raises(XML::Error, " The element-content model should not be empty.  (xmlconf/xmltest/not-wf/sa/139.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/139.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-140 (Section 2.3 [4])" do
  assert_raises(XML::Error, " Character '&#x309a;' is a CombiningChar, not a Letter, and so may not begin a name. (xmlconf/xmltest/not-wf/sa/140.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/140.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-141 (Section 2.3 [5])" do
  assert_raises(XML::Error, " Character #x0E5C is not legal in XML names.  (xmlconf/xmltest/not-wf/sa/141.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/141.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-142 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Character #x0000 is not legal anywhere in an XML document.  (xmlconf/xmltest/not-wf/sa/142.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/142.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-143 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Character #x001F is not legal anywhere in an XML document.  (xmlconf/xmltest/not-wf/sa/143.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/143.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-144 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Character #xFFFF is not legal anywhere in an XML document.  (xmlconf/xmltest/not-wf/sa/144.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/144.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-145 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Character #xD800 is not legal anywhere in an XML document. (If it appeared in a UTF-16 surrogate pair, it'd represent half of a UCS-4 character and so wouldn't really be in the document.)  (xmlconf/xmltest/not-wf/sa/145.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/145.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-146 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Character references must also refer to legal XML characters; #x00110000 is one more than the largest legal character. (xmlconf/xmltest/not-wf/sa/146.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/146.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-147 (Section 2.8 [22])" do
  assert_raises(XML::Error, " XML Declaration may not be preceded by whitespace. (xmlconf/xmltest/not-wf/sa/147.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/147.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-148 (Section 2.8 [22])" do
  assert_raises(XML::Error, " XML Declaration may not be preceded by comments or whitespace. (xmlconf/xmltest/not-wf/sa/148.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/148.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-149 (Section 2.8 [28])" do
  assert_raises(XML::Error, " XML Declaration may not be within a DTD. (xmlconf/xmltest/not-wf/sa/149.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/149.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-150 (Section 3.1 [43])" do
  assert_raises(XML::Error, " XML declarations may not be within element content.  (xmlconf/xmltest/not-wf/sa/150.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/150.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-151 (Section 2.8 [27])" do
  assert_raises(XML::Error, " XML declarations may not follow document content. (xmlconf/xmltest/not-wf/sa/151.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/151.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-152 (Section 2.8 [22])" do
  assert_raises(XML::Error, " XML declarations must include the \"version=...\" string. (xmlconf/xmltest/not-wf/sa/152.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/152.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-153 (Section 4.3.2)" do
  assert_raises(XML::Error, " Text declarations may not begin internal parsed entities; they may only appear at the beginning of external parsed (parameter or general) entities.  (xmlconf/xmltest/not-wf/sa/153.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/153.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-154 (Section 2.8 2.6 [23, 17])" do
  assert_raises(XML::Error, " '<?XML ...?>' is neither an XML declaration nor a legal processing instruction target name.  (xmlconf/xmltest/not-wf/sa/154.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/154.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-155 (Section 2.8 2.6 [23, 17])" do
  assert_raises(XML::Error, " '<?xmL ...?>' is neither an XML declaration nor a legal processing instruction target name.  (xmlconf/xmltest/not-wf/sa/155.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/155.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-156 (Section 2.8 2.6 [23, 17])" do
  assert_raises(XML::Error, " '<?xMl ...?>' is neither an XML declaration nor a legal processing instruction target name.  (xmlconf/xmltest/not-wf/sa/156.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/156.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-157 (Section 2.6 [17])" do
  assert_raises(XML::Error, " '<?xmL ...?>' is not a legal processing instruction target name.  (xmlconf/xmltest/not-wf/sa/157.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/157.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-158 (Section 3.3 [52])" do
  assert_raises(XML::Error, " SGML-ism: \"#NOTATION gif\" can't have attributes.  (xmlconf/xmltest/not-wf/sa/158.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/158.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-159 (Section 2.3 [9])" do
  assert_raises(XML::Error, " Uses '&' unquoted in an entity declaration, which is illegal syntax for an entity reference. (xmlconf/xmltest/not-wf/sa/159.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/159.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-160 (Section 2.8)" do
  assert_raises(XML::Error, " Violates the PEs in Internal Subset WFC by using a PE reference within a declaration.  (xmlconf/xmltest/not-wf/sa/160.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/160.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-161 (Section 2.8)" do
  assert_raises(XML::Error, " Violates the PEs in Internal Subset WFC by using a PE reference within a declaration.  (xmlconf/xmltest/not-wf/sa/161.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/161.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-162 (Section 2.8)" do
  assert_raises(XML::Error, " Violates the PEs in Internal Subset WFC by using a PE reference within a declaration.  (xmlconf/xmltest/not-wf/sa/162.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/162.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-163 (Section 4.1 [69])" do
  assert_raises(XML::Error, " Invalid placement of Parameter entity reference.  (xmlconf/xmltest/not-wf/sa/163.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/163.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-164 (Section 4.1 [69])" do
  assert_raises(XML::Error, " Invalid placement of Parameter entity reference.  (xmlconf/xmltest/not-wf/sa/164.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/164.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-165 (Section 4.2 [72])" do
  assert_raises(XML::Error, " Parameter entity declarations must have a space before the '%'.  (xmlconf/xmltest/not-wf/sa/165.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/165.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-166 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Character FFFF is not legal anywhere in an XML document.  (xmlconf/xmltest/not-wf/sa/166.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/166.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-167 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Character FFFE is not legal anywhere in an XML document.  (xmlconf/xmltest/not-wf/sa/167.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/167.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-168 (Section 2.2 [2])" do
  assert_raises(XML::Error, " An unpaired surrogate (D800) is not legal anywhere in an XML document. (xmlconf/xmltest/not-wf/sa/168.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/168.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-169 (Section 2.2 [2])" do
  assert_raises(XML::Error, " An unpaired surrogate (DC00) is not legal anywhere in an XML document. (xmlconf/xmltest/not-wf/sa/169.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/169.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-170 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Four byte UTF-8 encodings can encode UCS-4 characters which are beyond the range of legal XML characters (and can't be expressed in Unicode surrogate pairs). This document holds such a character.  (xmlconf/xmltest/not-wf/sa/170.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/170.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-171 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Character FFFF is not legal anywhere in an XML document.  (xmlconf/xmltest/not-wf/sa/171.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/171.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-172 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Character FFFF is not legal anywhere in an XML document.  (xmlconf/xmltest/not-wf/sa/172.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/172.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-173 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Character FFFF is not legal anywhere in an XML document.  (xmlconf/xmltest/not-wf/sa/173.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/173.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-174 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Character FFFF is not legal anywhere in an XML document.  (xmlconf/xmltest/not-wf/sa/174.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/174.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-175 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Character FFFF is not legal anywhere in an XML document.  (xmlconf/xmltest/not-wf/sa/175.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/175.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-176 (Section 3 [39])" do
  assert_raises(XML::Error, " Start tags must have matching end tags. (xmlconf/xmltest/not-wf/sa/176.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/176.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-177 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Character FFFF is not legal anywhere in an XML document.  (xmlconf/xmltest/not-wf/sa/177.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/177.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-178 (Section 3.1 [41])" do
  assert_raises(XML::Error, " Invalid syntax matching double quote is missing.  (xmlconf/xmltest/not-wf/sa/178.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/178.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-179 (Section 4.1 [66])" do
  assert_raises(XML::Error, " Invalid syntax matching double quote is missing.  (xmlconf/xmltest/not-wf/sa/179.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/179.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-180 (Section 4.1)" do
  assert_raises(XML::Error, " The Entity Declared WFC requires entities to be declared before they are used in an attribute list declaration.  (xmlconf/xmltest/not-wf/sa/180.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/180.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-181 (Section 4.3.2)" do
  assert_raises(XML::Error, " Internal parsed entities must match the content production to be well formed.  (xmlconf/xmltest/not-wf/sa/181.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/181.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-182 (Section 4.3.2)" do
  assert_raises(XML::Error, " Internal parsed entities must match the content production to be well formed.  (xmlconf/xmltest/not-wf/sa/182.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/182.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-183 (Section 3.2.2 [51])" do
  assert_raises(XML::Error, " Mixed content declarations may not include content particles. (xmlconf/xmltest/not-wf/sa/183.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/183.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-184 (Section 3.2.2 [51])" do
  assert_raises(XML::Error, " In mixed content models, element names must not be parenthesized.  (xmlconf/xmltest/not-wf/sa/184.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/184.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-185 (Section 4.1)" do
  assert_raises(XML::Error, " Tests the Entity Declared WFC. Note: a nonvalidating parser is permitted not to report this WFC violation, since it would need to read an external parameter entity to distinguish it from a violation of the Standalone Declaration VC. (xmlconf/xmltest/not-wf/sa/185.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/185.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-sa-186 (Section 3.1 [44])" do
  assert_raises(XML::Error, " Whitespace is required between attribute/value pairs.  (xmlconf/xmltest/not-wf/sa/186.xml)") do
    File.open("xmlconf/xmltest/not-wf/sa/186.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-not-sa-001 (Section 3.4 [62])" do
  assert_raises(XML::Error, " Conditional sections must be properly terminated (\"]>\" used instead of \"]]>\").  (xmlconf/xmltest/not-wf/not-sa/001.xml)") do
    File.open("xmlconf/xmltest/not-wf/not-sa/001.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-not-sa-002 (Section 2.6 [17])" do
  assert_raises(XML::Error, " Processing instruction target names may not be \"XML\" in any combination of cases.  (xmlconf/xmltest/not-wf/not-sa/002.xml)") do
    File.open("xmlconf/xmltest/not-wf/not-sa/002.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-not-sa-003 (Section 3.4 [62])" do
  assert_raises(XML::Error, " Conditional sections must be properly terminated (\"]]>\" omitted).  (xmlconf/xmltest/not-wf/not-sa/003.xml)") do
    File.open("xmlconf/xmltest/not-wf/not-sa/003.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-not-sa-004 (Section 3.4 [62])" do
  assert_raises(XML::Error, " Conditional sections must be properly terminated (\"]]>\" omitted).  (xmlconf/xmltest/not-wf/not-sa/004.xml)") do
    File.open("xmlconf/xmltest/not-wf/not-sa/004.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-not-sa-005 (Section 4.1)" do
  assert_raises(" Tests the Entity Declared VC by referring to an undefined parameter entity within an external entity. (xmlconf/xmltest/not-wf/not-sa/005.xml)") do
    File.open("xmlconf/xmltest/not-wf/not-sa/005.xml") { |file| XML::DOM.parse(file, base: "xmlconf/xmltest/not-wf/not-sa") }
  end
end

it "not-wf-not-sa-006 (Section 3.4 [62])" do
  assert_raises(XML::Error, " Conditional sections need a '[' after the INCLUDE or IGNORE.  (xmlconf/xmltest/not-wf/not-sa/006.xml)") do
    File.open("xmlconf/xmltest/not-wf/not-sa/006.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-not-sa-007 (Section 4.3.2 [79])" do
  assert_raises(XML::Error, " A <!DOCTYPE ...> declaration may not begin any external entity; it's only found once, in the document entity. (xmlconf/xmltest/not-wf/not-sa/007.xml)") do
    File.open("xmlconf/xmltest/not-wf/not-sa/007.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-not-sa-008 (Section 4.1 [69])" do
  assert_raises(XML::Error, " In DTDs, the '%' character must be part of a parameter entity reference. (xmlconf/xmltest/not-wf/not-sa/008.xml)") do
    File.open("xmlconf/xmltest/not-wf/not-sa/008.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-not-sa-009 (Section 2.8)" do
  assert_raises(XML::Error, " This test violates WFC:PE Between Declarations in Production 28a. The last character of a markup declaration is not contained in the same parameter-entity text replacement. (xmlconf/xmltest/not-wf/not-sa/009.xml)") do
    File.open("xmlconf/xmltest/not-wf/not-sa/009.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-ext-sa-001 (Section 4.1)" do
  assert_raises(XML::Error, " Tests the No Recursion WFC by having an external general entity be self-recursive. (xmlconf/xmltest/not-wf/ext-sa/001.xml)") do
    File.open("xmlconf/xmltest/not-wf/ext-sa/001.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-ext-sa-002 (Section 4.3.1 4.3.2 [77, 78])" do
  assert_raises(XML::Error, " External entities have \"text declarations\", which do not permit the \"standalone=...\" attribute that's allowed in XML declarations. (xmlconf/xmltest/not-wf/ext-sa/002.xml)") do
    File.open("xmlconf/xmltest/not-wf/ext-sa/002.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "not-wf-ext-sa-003 (Section 2.6 [17])" do
  assert_raises(XML::Error, " Only one text declaration is permitted; a second one looks like an illegal processing instruction (target names of \"xml\" in any case are not allowed).  (xmlconf/xmltest/not-wf/ext-sa/003.xml)") do
    File.open("xmlconf/xmltest/not-wf/ext-sa/003.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "invalid--002 (Section 3.2.1)" do
  assert_parses("xmlconf/xmltest/invalid/002.xml", nil, " Tests the \"Proper Group/PE Nesting\" validity constraint by fragmenting a content model between two parameter entities. (xmlconf/xmltest/invalid/002.xml)")
end

it "invalid--005 (Section 2.8)" do
  assert_parses("xmlconf/xmltest/invalid/005.xml", nil, " Tests the \"Proper Declaration/PE Nesting\" validity constraint by fragmenting an element declaration between two parameter entities. (xmlconf/xmltest/invalid/005.xml)")
end

it "invalid--006 (Section 2.8)" do
  assert_parses("xmlconf/xmltest/invalid/006.xml", nil, " Tests the \"Proper Declaration/PE Nesting\" validity constraint by fragmenting an element declaration between two parameter entities. (xmlconf/xmltest/invalid/006.xml)")
end

it "invalid-not-sa-022 (Section 3.4 [62])" do
  assert_parses("xmlconf/xmltest/invalid/not-sa/022.xml", "xmlconf/xmltest/invalid/not-sa/out/022.xml", " Test the \"Proper Conditional Section/ PE Nesting\" validity constraint.  (xmlconf/xmltest/invalid/not-sa/022.xml)")
end

it "valid-sa-001 (Section 3.2.2 [51])" do
  assert_parses("xmlconf/xmltest/valid/sa/001.xml", "xmlconf/xmltest/valid/sa/out/001.xml", " Test demonstrates an Element Type Declaration with Mixed Content.  (xmlconf/xmltest/valid/sa/001.xml)")
end

it "valid-sa-002 (Section 3.1 [40])" do
  assert_parses("xmlconf/xmltest/valid/sa/002.xml", "xmlconf/xmltest/valid/sa/out/002.xml", " Test demonstrates that whitespace is permitted after the tag name in a Start-tag.  (xmlconf/xmltest/valid/sa/002.xml)")
end

it "valid-sa-003 (Section 3.1 [42])" do
  assert_parses("xmlconf/xmltest/valid/sa/003.xml", "xmlconf/xmltest/valid/sa/out/003.xml", " Test demonstrates that whitespace is permitted after the tag name in an End-tag. (xmlconf/xmltest/valid/sa/003.xml)")
end

it "valid-sa-004 (Section 3.1 [41])" do
  assert_parses("xmlconf/xmltest/valid/sa/004.xml", "xmlconf/xmltest/valid/sa/out/004.xml", " Test demonstrates a valid attribute specification within a Start-tag.  (xmlconf/xmltest/valid/sa/004.xml)")
end

it "valid-sa-005 (Section 3.1 [40])" do
  assert_parses("xmlconf/xmltest/valid/sa/005.xml", "xmlconf/xmltest/valid/sa/out/005.xml", " Test demonstrates a valid attribute specification within a Start-tag that contains whitespace on both sides of the equal sign.  (xmlconf/xmltest/valid/sa/005.xml)")
end

it "valid-sa-006 (Section 3.1 [41])" do
  assert_parses("xmlconf/xmltest/valid/sa/006.xml", "xmlconf/xmltest/valid/sa/out/006.xml", " Test demonstrates that the AttValue within a Start-tag can use a single quote as a delimter.  (xmlconf/xmltest/valid/sa/006.xml)")
end

it "valid-sa-007 (Section 3.1 4.6 [43])" do
  assert_parses("xmlconf/xmltest/valid/sa/007.xml", "xmlconf/xmltest/valid/sa/out/007.xml", " Test demonstrates numeric character references can be used for element content.  (xmlconf/xmltest/valid/sa/007.xml)")
end

it "valid-sa-008 (Section 2.4 3.1 [43])" do
  assert_parses("xmlconf/xmltest/valid/sa/008.xml", "xmlconf/xmltest/valid/sa/out/008.xml", " Test demonstrates character references can be used for element content.  (xmlconf/xmltest/valid/sa/008.xml)")
end

it "valid-sa-009 (Section 2.3 3.1 [43])" do
  assert_parses("xmlconf/xmltest/valid/sa/009.xml", "xmlconf/xmltest/valid/sa/out/009.xml", " Test demonstrates that PubidChar can be used for element content.  (xmlconf/xmltest/valid/sa/009.xml)")
end

it "valid-sa-010 (Section 3.1 [40])" do
  assert_parses("xmlconf/xmltest/valid/sa/010.xml", "xmlconf/xmltest/valid/sa/out/010.xml", " Test demonstrates that whitespace is valid after the Attribute in a Start-tag.  (xmlconf/xmltest/valid/sa/010.xml)")
end

it "valid-sa-011 (Section 3.1 [40])" do
  assert_parses("xmlconf/xmltest/valid/sa/011.xml", "xmlconf/xmltest/valid/sa/out/011.xml", " Test demonstrates mutliple Attibutes within the Start-tag.  (xmlconf/xmltest/valid/sa/011.xml)")
end

it "valid-sa-012 (Section 2.3 [4])" do
  assert_parses("xmlconf/xmltest/valid/sa/012.xml", "xmlconf/xmltest/valid/sa/out/012.xml", " Uses a legal XML 1.0 name consisting of a single colon character (disallowed by the latest XML Namespaces draft). (xmlconf/xmltest/valid/sa/012.xml)")
end

it "valid-sa-013 (Section 2.3 3.1 [13] [40])" do
  assert_parses("xmlconf/xmltest/valid/sa/013.xml", "xmlconf/xmltest/valid/sa/out/013.xml", " Test demonstrates that the Attribute in a Start-tag can consist of numerals along with special characters.  (xmlconf/xmltest/valid/sa/013.xml)")
end

it "valid-sa-014 (Section 2.3 3.1 [13] [40])" do
  assert_parses("xmlconf/xmltest/valid/sa/014.xml", "xmlconf/xmltest/valid/sa/out/014.xml", " Test demonstrates that all lower case letters are valid for the Attribute in a Start-tag.  (xmlconf/xmltest/valid/sa/014.xml)")
end

it "valid-sa-015 (Section 2.3 3.1 [13] [40])" do
  assert_parses("xmlconf/xmltest/valid/sa/015.xml", "xmlconf/xmltest/valid/sa/out/015.xml", " Test demonstrates that all upper case letters are valid for the Attribute in a Start-tag.  (xmlconf/xmltest/valid/sa/015.xml)")
end

it "valid-sa-016 (Section 2.6 3.1 [16] [43])" do
  assert_parses("xmlconf/xmltest/valid/sa/016.xml", "xmlconf/xmltest/valid/sa/out/016.xml", " Test demonstrates that Processing Instructions are valid element content.  (xmlconf/xmltest/valid/sa/016.xml)")
end

it "valid-sa-017 (Section 2.6 3.1 [16] [43])" do
  assert_parses("xmlconf/xmltest/valid/sa/017.xml", "xmlconf/xmltest/valid/sa/out/017.xml", " Test demonstrates that Processing Instructions are valid element content and there can be more than one.  (xmlconf/xmltest/valid/sa/017.xml)")
end

it "valid-sa-018 (Section 2.7 3.1 [18] [43])" do
  assert_parses("xmlconf/xmltest/valid/sa/018.xml", "xmlconf/xmltest/valid/sa/out/018.xml", " Test demonstrates that CDATA sections are valid element content.  (xmlconf/xmltest/valid/sa/018.xml)")
end

it "valid-sa-019 (Section 2.7 3.1 [18] [43])" do
  assert_parses("xmlconf/xmltest/valid/sa/019.xml", "xmlconf/xmltest/valid/sa/out/019.xml", " Test demonstrates that CDATA sections are valid element content and that ampersands may occur in their literal form.  (xmlconf/xmltest/valid/sa/019.xml)")
end

it "valid-sa-020 (Section 2.7 3.1 [18] [43])" do
  assert_parses("xmlconf/xmltest/valid/sa/020.xml", "xmlconf/xmltest/valid/sa/out/020.xml", " Test demonstractes that CDATA sections are valid element content and that everyting between the CDStart and CDEnd is recognized as character data not markup.  (xmlconf/xmltest/valid/sa/020.xml)")
end

it "valid-sa-021 (Section 2.5 3.1 [15] [43])" do
  assert_parses("xmlconf/xmltest/valid/sa/021.xml", "xmlconf/xmltest/valid/sa/out/021.xml", " Test demonstrates that comments are valid element content.  (xmlconf/xmltest/valid/sa/021.xml)")
end

it "valid-sa-022 (Section 2.5 3.1 [15] [43])" do
  assert_parses("xmlconf/xmltest/valid/sa/022.xml", "xmlconf/xmltest/valid/sa/out/022.xml", " Test demonstrates that comments are valid element content and that all characters before the double-hypen right angle combination are considered part of thecomment.  (xmlconf/xmltest/valid/sa/022.xml)")
end

it "valid-sa-023 (Section 3.1 [43])" do
  assert_parses("xmlconf/xmltest/valid/sa/023.xml", "xmlconf/xmltest/valid/sa/out/023.xml", " Test demonstrates that Entity References are valid element content.  (xmlconf/xmltest/valid/sa/023.xml)")
end

it "valid-sa-024 (Section 3.1 4.1 [43] [66])" do
  assert_parses("xmlconf/xmltest/valid/sa/024.xml", "xmlconf/xmltest/valid/sa/out/024.xml", " Test demonstrates that Entity References are valid element content and also demonstrates a valid Entity Declaration.  (xmlconf/xmltest/valid/sa/024.xml)")
end

it "valid-sa-025 (Section 3.2 [46])" do
  assert_parses("xmlconf/xmltest/valid/sa/025.xml", "xmlconf/xmltest/valid/sa/out/025.xml", " Test demonstrates an Element Type Declaration and that the contentspec can be of mixed content.  (xmlconf/xmltest/valid/sa/025.xml)")
end

it "valid-sa-026 (Section 3.2 [46])" do
  assert_parses("xmlconf/xmltest/valid/sa/026.xml", "xmlconf/xmltest/valid/sa/out/026.xml", " Test demonstrates an Element Type Declaration and that EMPTY is a valid contentspec.  (xmlconf/xmltest/valid/sa/026.xml)")
end

it "valid-sa-027 (Section 3.2 [46])" do
  assert_parses("xmlconf/xmltest/valid/sa/027.xml", "xmlconf/xmltest/valid/sa/out/027.xml", " Test demonstrates an Element Type Declaration and that ANY is a valid contenspec.  (xmlconf/xmltest/valid/sa/027.xml)")
end

it "valid-sa-028 (Section 2.8 [24])" do
  assert_parses("xmlconf/xmltest/valid/sa/028.xml", "xmlconf/xmltest/valid/sa/out/028.xml", " Test demonstrates a valid prolog that uses double quotes as delimeters around the VersionNum.  (xmlconf/xmltest/valid/sa/028.xml)")
end

it "valid-sa-029 (Section 2.8 [24])" do
  assert_parses("xmlconf/xmltest/valid/sa/029.xml", "xmlconf/xmltest/valid/sa/out/029.xml", " Test demonstrates a valid prolog that uses single quotes as delimters around the VersionNum.  (xmlconf/xmltest/valid/sa/029.xml)")
end

it "valid-sa-030 (Section 2.8 [25])" do
  assert_parses("xmlconf/xmltest/valid/sa/030.xml", "xmlconf/xmltest/valid/sa/out/030.xml", " Test demonstrates a valid prolog that contains whitespace on both sides of the equal sign in the VersionInfo.  (xmlconf/xmltest/valid/sa/030.xml)")
end

it "valid-sa-031 (Section 4.3.3 [80])" do
  assert_parses("xmlconf/xmltest/valid/sa/031.xml", "xmlconf/xmltest/valid/sa/out/031.xml", " Test demonstrates a valid EncodingDecl within the prolog.  (xmlconf/xmltest/valid/sa/031.xml)")
end

it "valid-sa-032 (Section 2.9 [32])" do
  assert_parses("xmlconf/xmltest/valid/sa/032.xml", "xmlconf/xmltest/valid/sa/out/032.xml", " Test demonstrates a valid SDDecl within the prolog.  (xmlconf/xmltest/valid/sa/032.xml)")
end

it "valid-sa-033 (Section 2.8 [23])" do
  assert_parses("xmlconf/xmltest/valid/sa/033.xml", "xmlconf/xmltest/valid/sa/out/033.xml", " Test demonstrates that both a EncodingDecl and SDDecl are valid within the prolog.  (xmlconf/xmltest/valid/sa/033.xml)")
end

it "valid-sa-034 (Section 3.1 [44])" do
  assert_parses("xmlconf/xmltest/valid/sa/034.xml", "xmlconf/xmltest/valid/sa/out/034.xml", " Test demonstrates the correct syntax for an Empty element tag.  (xmlconf/xmltest/valid/sa/034.xml)")
end

it "valid-sa-035 (Section 3.1 [44])" do
  assert_parses("xmlconf/xmltest/valid/sa/035.xml", "xmlconf/xmltest/valid/sa/out/035.xml", " Test demonstrates that whitespace is permissible after the name in an Empty element tag.  (xmlconf/xmltest/valid/sa/035.xml)")
end

it "valid-sa-036 (Section 2.6 [16])" do
  assert_parses("xmlconf/xmltest/valid/sa/036.xml", "xmlconf/xmltest/valid/sa/out/036.xml", " Test demonstrates a valid processing instruction.  (xmlconf/xmltest/valid/sa/036.xml)")
end

it "valid-sa-017a (Section 2.6 3.1 [16] [43])" do
  assert_parses("xmlconf/xmltest/valid/sa/017a.xml", "xmlconf/xmltest/valid/sa/out/017a.xml", " Test demonstrates that two apparently wrong Processing Instructions make a right one, with very odd content \"some data ? > <?\".  (xmlconf/xmltest/valid/sa/017a.xml)")
end

it "valid-sa-037 (Section 2.6 [15])" do
  assert_parses("xmlconf/xmltest/valid/sa/037.xml", "xmlconf/xmltest/valid/sa/out/037.xml", " Test demonstrates a valid comment and that it may appear anywhere in the document including at the end.  (xmlconf/xmltest/valid/sa/037.xml)")
end

it "valid-sa-038 (Section 2.6 [15])" do
  assert_parses("xmlconf/xmltest/valid/sa/038.xml", "xmlconf/xmltest/valid/sa/out/038.xml", " Test demonstrates a valid comment and that it may appear anywhere in the document including the beginning.  (xmlconf/xmltest/valid/sa/038.xml)")
end

it "valid-sa-039 (Section 2.6 [16])" do
  assert_parses("xmlconf/xmltest/valid/sa/039.xml", "xmlconf/xmltest/valid/sa/out/039.xml", " Test demonstrates a valid processing instruction and that it may appear at the beginning of the document.  (xmlconf/xmltest/valid/sa/039.xml)")
end

it "valid-sa-040 (Section 3.3 3.3.1 [52] [54])" do
  assert_parses("xmlconf/xmltest/valid/sa/040.xml", "xmlconf/xmltest/valid/sa/out/040.xml", " Test demonstrates an Attribute List declaration that uses a StringType as the AttType.  (xmlconf/xmltest/valid/sa/040.xml)")
end

it "valid-sa-041 (Section 3.3.1 4.1 [54] [66])" do
  assert_parses("xmlconf/xmltest/valid/sa/041.xml", "xmlconf/xmltest/valid/sa/out/041.xml", " Test demonstrates an Attribute List declaration that uses a StringType as the AttType and also expands the CDATA attribute with a character reference.  (xmlconf/xmltest/valid/sa/041.xml)")
end

it "valid-sa-042 (Section 3.3.1 4.1 [54] [66])" do
  assert_parses("xmlconf/xmltest/valid/sa/042.xml", "xmlconf/xmltest/valid/sa/out/042.xml", " Test demonstrates an Attribute List declaration that uses a StringType as the AttType and also expands the CDATA attribute with a character reference. The test also shows that the leading zeros in the character reference are ignored.  (xmlconf/xmltest/valid/sa/042.xml)")
end

it "valid-sa-043 (Section 3.3)" do
  assert_parses("xmlconf/xmltest/valid/sa/043.xml", "xmlconf/xmltest/valid/sa/out/043.xml", " An element's attributes may be declared before its content model; and attribute values may contain newlines.  (xmlconf/xmltest/valid/sa/043.xml)")
end

it "valid-sa-044 (Section 3.1 [44])" do
  assert_parses("xmlconf/xmltest/valid/sa/044.xml", "xmlconf/xmltest/valid/sa/out/044.xml", " Test demonstrates that the empty-element tag must be use for an elements that are declared EMPTY.  (xmlconf/xmltest/valid/sa/044.xml)")
end

it "valid-sa-045 (Section 3.3 [52])" do
  assert_parses("xmlconf/xmltest/valid/sa/045.xml", "xmlconf/xmltest/valid/sa/out/045.xml", " Tests whether more than one definition can be provided for the same attribute of a given element type with the first declaration being binding.  (xmlconf/xmltest/valid/sa/045.xml)")
end

it "valid-sa-046 (Section 3.3 [52])" do
  assert_parses("xmlconf/xmltest/valid/sa/046.xml", "xmlconf/xmltest/valid/sa/out/046.xml", " Test demonstrates that when more than one AttlistDecl is provided for a given element type, the contents of all those provided are merged.  (xmlconf/xmltest/valid/sa/046.xml)")
end

it "valid-sa-047 (Section 3.1 [43])" do
  assert_parses("xmlconf/xmltest/valid/sa/047.xml", "xmlconf/xmltest/valid/sa/out/047.xml", " Test demonstrates that extra whitespace is normalized into single space character.  (xmlconf/xmltest/valid/sa/047.xml)")
end

it "valid-sa-048 (Section 2.4 3.1 [14] [43])" do
  assert_parses("xmlconf/xmltest/valid/sa/048.xml", "xmlconf/xmltest/valid/sa/out/048.xml", " Test demonstrates that character data is valid element content.  (xmlconf/xmltest/valid/sa/048.xml)")
end

it "valid-sa-049 (Section 2.2 [2])" do
  assert_parses("xmlconf/xmltest/valid/sa/049.xml", "xmlconf/xmltest/valid/sa/out/049.xml", " Test demonstrates that characters outside of normal ascii range can be used as element content.  (xmlconf/xmltest/valid/sa/049.xml)")
end

it "valid-sa-050 (Section 2.2 [2])" do
  assert_parses("xmlconf/xmltest/valid/sa/050.xml", "xmlconf/xmltest/valid/sa/out/050.xml", " Test demonstrates that characters outside of normal ascii range can be used as element content.  (xmlconf/xmltest/valid/sa/050.xml)")
end

it "valid-sa-051 (Section 2.2 [2])" do
  assert_parses("xmlconf/xmltest/valid/sa/051.xml", "xmlconf/xmltest/valid/sa/out/051.xml", " The document is encoded in UTF-16 and uses some name characters well outside of the normal ASCII range.  (xmlconf/xmltest/valid/sa/051.xml)")
end

it "valid-sa-052 (Section 2.2 [2])" do
  assert_parses("xmlconf/xmltest/valid/sa/052.xml", "xmlconf/xmltest/valid/sa/out/052.xml", " The document is encoded in UTF-8 and the text inside the root element uses two non-ASCII characters, encoded in UTF-8 and each of which expands to a Unicode surrogate pair. (xmlconf/xmltest/valid/sa/052.xml)")
end

it "valid-sa-053 (Section 4.4.2)" do
  assert_parses("xmlconf/xmltest/valid/sa/053.xml", "xmlconf/xmltest/valid/sa/out/053.xml", " Tests inclusion of a well-formed internal entity, which holds an element required by the content model. (xmlconf/xmltest/valid/sa/053.xml)")
end

it "valid-sa-054 (Section 3.1 [40] [42])" do
  assert_parses("xmlconf/xmltest/valid/sa/054.xml", "xmlconf/xmltest/valid/sa/out/054.xml", " Test demonstrates that extra whitespace within Start-tags and End-tags are nomalized into single spaces.  (xmlconf/xmltest/valid/sa/054.xml)")
end

it "valid-sa-055 (Section 2.6 2.10 [16])" do
  assert_parses("xmlconf/xmltest/valid/sa/055.xml", "xmlconf/xmltest/valid/sa/out/055.xml", " Test demonstrates that extra whitespace within a processing instruction willnormalized into s single space character.  (xmlconf/xmltest/valid/sa/055.xml)")
end

it "valid-sa-056 (Section 3.3.1 4.1 [54] [66])" do
  assert_parses("xmlconf/xmltest/valid/sa/056.xml", "xmlconf/xmltest/valid/sa/out/056.xml", " Test demonstrates an Attribute List declaration that uses a StringType as the AttType and also expands the CDATA attribute with a character reference. The test also shows that the leading zeros in the character reference are ignored.  (xmlconf/xmltest/valid/sa/056.xml)")
end

it "valid-sa-057 (Section 3.2.1 [47])" do
  assert_parses("xmlconf/xmltest/valid/sa/057.xml", "xmlconf/xmltest/valid/sa/out/057.xml", " Test demonstrates an element content model whose element can occur zero or more times.  (xmlconf/xmltest/valid/sa/057.xml)")
end

it "valid-sa-058 (Section 3.3.3)" do
  assert_parses("xmlconf/xmltest/valid/sa/058.xml", "xmlconf/xmltest/valid/sa/out/058.xml", " Test demonstrates that extra whitespace be normalized into a single space character in an attribute of type NMTOKENS.  (xmlconf/xmltest/valid/sa/058.xml)")
end

it "valid-sa-059 (Section 3.2 3.3 [46] [53])" do
  assert_parses("xmlconf/xmltest/valid/sa/059.xml", "xmlconf/xmltest/valid/sa/out/059.xml", " Test demonstrates an Element Type Declaration that uses the contentspec of EMPTY. The element cannot have any contents and must always appear as an empty element in the document. The test also shows an Attribute-list declaration with multiple AttDef's.  (xmlconf/xmltest/valid/sa/059.xml)")
end

it "valid-sa-060 (Section 4.1 [66])" do
  assert_parses("xmlconf/xmltest/valid/sa/060.xml", "xmlconf/xmltest/valid/sa/out/060.xml", " Test demonstrates the use of decimal Character References within element content.  (xmlconf/xmltest/valid/sa/060.xml)")
end

it "valid-sa-061 (Section 4.1 [66])" do
  assert_parses("xmlconf/xmltest/valid/sa/061.xml", "xmlconf/xmltest/valid/sa/out/061.xml", " Test demonstrates the use of decimal Character References within element content.  (xmlconf/xmltest/valid/sa/061.xml)")
end

it "valid-sa-062 (Section 4.1 [66])" do
  assert_parses("xmlconf/xmltest/valid/sa/062.xml", "xmlconf/xmltest/valid/sa/out/062.xml", " Test demonstrates the use of hexadecimal Character References within element.  (xmlconf/xmltest/valid/sa/062.xml)")
end

it "valid-sa-063 (Section 2.3 [5])" do
  assert_parses("xmlconf/xmltest/valid/sa/063.xml", "xmlconf/xmltest/valid/sa/out/063.xml", " The document is encoded in UTF-8 and the name of the root element type uses non-ASCII characters.  (xmlconf/xmltest/valid/sa/063.xml)")
end

it "valid-sa-064 (Section 4.1 [66])" do
  assert_parses("xmlconf/xmltest/valid/sa/064.xml", "xmlconf/xmltest/valid/sa/out/064.xml", " Tests in-line handling of two legal character references, which each expand to a Unicode surrogate pair. (xmlconf/xmltest/valid/sa/064.xml)")
end

it "valid-sa-065 (Section 4.5)" do
  assert_parses("xmlconf/xmltest/valid/sa/065.xml", "xmlconf/xmltest/valid/sa/out/065.xml", " Tests ability to define an internal entity which can't legally be expanded (contains an unquoted <). (xmlconf/xmltest/valid/sa/065.xml)")
end

it "valid-sa-066 (Section 4.1 [66])" do
  assert_parses("xmlconf/xmltest/valid/sa/066.xml", "xmlconf/xmltest/valid/sa/out/066.xml", " Expands a CDATA attribute with a character reference. (xmlconf/xmltest/valid/sa/066.xml)")
end

it "valid-sa-067 (Section 4.1 [66])" do
  assert_parses("xmlconf/xmltest/valid/sa/067.xml", "xmlconf/xmltest/valid/sa/out/067.xml", " Test demonstrates the use of decimal character references within element content.  (xmlconf/xmltest/valid/sa/067.xml)")
end

it "valid-sa-068 (Section 2.11, 4.5)" do
  assert_parses("xmlconf/xmltest/valid/sa/068.xml", "xmlconf/xmltest/valid/sa/out/068.xml", " Tests definition of an internal entity holding a carriage return character reference, which must not be normalized before reporting to the application. Line break normalization only occurs when parsing external parsed entities. (xmlconf/xmltest/valid/sa/068.xml)")
end

it "valid-sa-069 (Section 4.7)" do
  assert_parses("xmlconf/xmltest/valid/sa/069.xml", "xmlconf/xmltest/valid/sa/out/069.xml", " Verifies that an XML parser will parse a NOTATION declaration; the output phase of this test ensures that it's reported to the application.  (xmlconf/xmltest/valid/sa/069.xml)")
end

it "valid-sa-070 (Section 4.4.8)" do
  assert_parses("xmlconf/xmltest/valid/sa/070.xml", "xmlconf/xmltest/valid/sa/out/070.xml", " Verifies that internal parameter entities are correctly expanded within the internal subset. (xmlconf/xmltest/valid/sa/070.xml)")
end

it "valid-sa-071 (Section 3.3 3.3.1 [52] [56])" do
  assert_parses("xmlconf/xmltest/valid/sa/071.xml", "xmlconf/xmltest/valid/sa/out/071.xml", " Test demonstrates that an AttlistDecl can use ID as the TokenizedType within the Attribute type. The test also shows that IMPLIED is a valid DefaultDecl.  (xmlconf/xmltest/valid/sa/071.xml)")
end

it "valid-sa-072 (Section 3.3 3.3.1 [52] [56])" do
  assert_parses("xmlconf/xmltest/valid/sa/072.xml", "xmlconf/xmltest/valid/sa/out/072.xml", " Test demonstrates that an AttlistDecl can use IDREF as the TokenizedType within the Attribute type. The test also shows that IMPLIED is a valid DefaultDecl.  (xmlconf/xmltest/valid/sa/072.xml)")
end

it "valid-sa-073 (Section 3.3 3.3.1 [52] [56])" do
  assert_parses("xmlconf/xmltest/valid/sa/073.xml", "xmlconf/xmltest/valid/sa/out/073.xml", " Test demonstrates that an AttlistDecl can use IDREFS as the TokenizedType within the Attribute type. The test also shows that IMPLIED is a valid DefaultDecl.  (xmlconf/xmltest/valid/sa/073.xml)")
end

it "valid-sa-074 (Section 3.3 3.3.1 [52] [56])" do
  assert_parses("xmlconf/xmltest/valid/sa/074.xml", "xmlconf/xmltest/valid/sa/out/074.xml", " Test demonstrates that an AttlistDecl can use ENTITY as the TokenizedType within the Attribute type. The test also shows that IMPLIED is a valid DefaultDecl.  (xmlconf/xmltest/valid/sa/074.xml)")
end

it "valid-sa-075 (Section 3.3 3.3.1 [52] [56])" do
  assert_parses("xmlconf/xmltest/valid/sa/075.xml", "xmlconf/xmltest/valid/sa/out/075.xml", " Test demonstrates that an AttlistDecl can use ENTITIES as the TokenizedType within the Attribute type. The test also shows that IMPLIED is a valid DefaultDecl.  (xmlconf/xmltest/valid/sa/075.xml)")
end

it "valid-sa-076 (Section 3.3.1)" do
  assert_parses("xmlconf/xmltest/valid/sa/076.xml", "xmlconf/xmltest/valid/sa/out/076.xml", " Verifies that an XML parser will parse a NOTATION attribute; the output phase of this test ensures that both notations are reported to the application.  (xmlconf/xmltest/valid/sa/076.xml)")
end

it "valid-sa-077 (Section 3.3 3.3.1 [52] [54])" do
  assert_parses("xmlconf/xmltest/valid/sa/077.xml", "xmlconf/xmltest/valid/sa/out/077.xml", " Test demonstrates that an AttlistDecl can use an EnumeratedType within the Attribute type. The test also shows that IMPLIED is a valid DefaultDecl.  (xmlconf/xmltest/valid/sa/077.xml)")
end

it "valid-sa-078 (Section 3.3 3.3.1 [52] [54])" do
  assert_parses("xmlconf/xmltest/valid/sa/078.xml", "xmlconf/xmltest/valid/sa/out/078.xml", " Test demonstrates that an AttlistDecl can use an StringType of CDATA within the Attribute type. The test also shows that REQUIRED is a valid DefaultDecl.  (xmlconf/xmltest/valid/sa/078.xml)")
end

it "valid-sa-079 (Section 3.3 3.3.2 [52] [60])" do
  assert_parses("xmlconf/xmltest/valid/sa/079.xml", "xmlconf/xmltest/valid/sa/out/079.xml", " Test demonstrates that an AttlistDecl can use an StringType of CDATA within the Attribute type. The test also shows that FIXED is a valid DefaultDecl and that a value can be given to the attribute in the Start-tag as well as the AttListDecl.  (xmlconf/xmltest/valid/sa/079.xml)")
end

it "valid-sa-080 (Section 3.3 3.3.2 [52] [60])" do
  assert_parses("xmlconf/xmltest/valid/sa/080.xml", "xmlconf/xmltest/valid/sa/out/080.xml", " Test demonstrates that an AttlistDecl can use an StringType of CDATA within the Attribute type. The test also shows that FIXED is a valid DefaultDecl and that an value can be given to the attribute.  (xmlconf/xmltest/valid/sa/080.xml)")
end

it "valid-sa-081 (Section 3.2.1 [50])" do
  assert_parses("xmlconf/xmltest/valid/sa/081.xml", "xmlconf/xmltest/valid/sa/out/081.xml", " Test demonstrates the use of the optional character following a name or list to govern the number of times an element or content particles in the list occur.  (xmlconf/xmltest/valid/sa/081.xml)")
end

it "valid-sa-082 (Section 4.2 [72])" do
  assert_parses("xmlconf/xmltest/valid/sa/082.xml", "xmlconf/xmltest/valid/sa/out/082.xml", " Tests that an external PE may be defined (but not referenced). (xmlconf/xmltest/valid/sa/082.xml)")
end

it "valid-sa-083 (Section 4.2 [72])" do
  assert_parses("xmlconf/xmltest/valid/sa/083.xml", "xmlconf/xmltest/valid/sa/out/083.xml", " Tests that an external PE may be defined (but not referenced). (xmlconf/xmltest/valid/sa/083.xml)")
end

it "valid-sa-084 (Section 2.10)" do
  assert_parses("xmlconf/xmltest/valid/sa/084.xml", "xmlconf/xmltest/valid/sa/out/084.xml", " Test demonstrates that although whitespace can be used to set apart markup for greater readability it is not necessary.  (xmlconf/xmltest/valid/sa/084.xml)")
end

it "valid-sa-085 (Section 4)" do
  assert_parses("xmlconf/xmltest/valid/sa/085.xml", "xmlconf/xmltest/valid/sa/out/085.xml", " Parameter and General entities use different namespaces, so there can be an entity of each type with a given name. (xmlconf/xmltest/valid/sa/085.xml)")
end

it "valid-sa-086 (Section 4.2)" do
  assert_parses("xmlconf/xmltest/valid/sa/086.xml", "xmlconf/xmltest/valid/sa/out/086.xml", " Tests whether entities may be declared more than once, with the first declaration being the binding one.  (xmlconf/xmltest/valid/sa/086.xml)")
end

it "valid-sa-087 (Section 4.5)" do
  assert_parses("xmlconf/xmltest/valid/sa/087.xml", "xmlconf/xmltest/valid/sa/out/087.xml", " Tests whether character references in internal entities are expanded early enough, by relying on correct handling to make the entity be well formed. (xmlconf/xmltest/valid/sa/087.xml)")
end

it "valid-sa-088 (Section 4.5)" do
  assert_parses("xmlconf/xmltest/valid/sa/088.xml", "xmlconf/xmltest/valid/sa/out/088.xml", " Tests whether entity references in internal entities are expanded late enough, by relying on correct handling to make the expanded text be valid. (If it's expanded too early, the entity will parse as an element that's not valid in that context.) (xmlconf/xmltest/valid/sa/088.xml)")
end

it "valid-sa-089 (Section 4.1 [66])" do
  assert_parses("xmlconf/xmltest/valid/sa/089.xml", "xmlconf/xmltest/valid/sa/out/089.xml", " Tests entity expansion of three legal character references, which each expand to a Unicode surrogate pair. (xmlconf/xmltest/valid/sa/089.xml)")
end

it "valid-sa-090 (Section 3.3.1)" do
  assert_parses("xmlconf/xmltest/valid/sa/090.xml", "xmlconf/xmltest/valid/sa/out/090.xml", " Verifies that an XML parser will parse a NOTATION attribute; the output phase of this test ensures that the notation is reported to the application.  (xmlconf/xmltest/valid/sa/090.xml)")
end

it "valid-sa-091 (Section 3.3.1)" do
  assert_parses("xmlconf/xmltest/valid/sa/091.xml", "xmlconf/xmltest/valid/sa/out/091.xml", " Verifies that an XML parser will parse an ENTITY attribute; the output phase of this test ensures that the notation is reported to the application, and for validating parsers it further tests that the entity is so reported. (xmlconf/xmltest/valid/sa/091.xml)")
end

it "valid-sa-092 (Section 2.3 2.10)" do
  assert_parses("xmlconf/xmltest/valid/sa/092.xml", "xmlconf/xmltest/valid/sa/out/092.xml", " Test demostrates that extra whitespace is normalized into a single space character.  (xmlconf/xmltest/valid/sa/092.xml)")
end

it "valid-sa-093 (Section 2.10)" do
  assert_parses("xmlconf/xmltest/valid/sa/093.xml", "xmlconf/xmltest/valid/sa/out/093.xml", " Test demonstrates that extra whitespace is not intended for inclusion in the delivered version of the document.  (xmlconf/xmltest/valid/sa/093.xml)")
end

it "valid-sa-094 (Section 2.8)" do
  assert_parses("xmlconf/xmltest/valid/sa/094.xml", "xmlconf/xmltest/valid/sa/out/094.xml", " Attribute defaults with a DTD have special parsing rules, different from other strings. That means that characters found there may look like an undefined parameter entity reference \"within a markup declaration\", but they aren't ... so they can't be violating the PEs in Internal Subset WFC.  (xmlconf/xmltest/valid/sa/094.xml)")
end

it "valid-sa-095 (Section 3.3.3)" do
  assert_parses("xmlconf/xmltest/valid/sa/095.xml", "xmlconf/xmltest/valid/sa/out/095.xml", " Basically an output test, this requires extra whitespace to be normalized into a single space character in an attribute of type NMTOKENS. (xmlconf/xmltest/valid/sa/095.xml)")
end

it "valid-sa-096 (Section 3.3.3)" do
  assert_parses("xmlconf/xmltest/valid/sa/096.xml", "xmlconf/xmltest/valid/sa/out/096.xml", " Test demonstrates that extra whitespace is normalized into a single space character in an attribute of type NMTOKENS.  (xmlconf/xmltest/valid/sa/096.xml)")
end

it "valid-sa-097 (Section 3.3)" do
  assert_parses("xmlconf/xmltest/valid/sa/097.xml", "xmlconf/xmltest/valid/sa/out/097.xml", " Basically an output test, this tests whether an externally defined attribute declaration (with a default) takes proper precedence over a subsequent internal declaration. (xmlconf/xmltest/valid/sa/097.xml)")
end

it "valid-sa-098 (Section 2.6 2.10 [16])" do
  assert_parses("xmlconf/xmltest/valid/sa/098.xml", "xmlconf/xmltest/valid/sa/out/098.xml", " Test demonstrates that extra whitespace within a processing instruction is converted into a single space character. (xmlconf/xmltest/valid/sa/098.xml)")
end

it "valid-sa-099 (Section 4.3.3 [81])" do
  assert_parses("xmlconf/xmltest/valid/sa/099.xml", "xmlconf/xmltest/valid/sa/out/099.xml", " Test demonstrates the name of the encoding can be composed of lowercase characters.  (xmlconf/xmltest/valid/sa/099.xml)")
end

it "valid-sa-100 (Section 2.3 [12])" do
  assert_parses("xmlconf/xmltest/valid/sa/100.xml", "xmlconf/xmltest/valid/sa/out/100.xml", " Makes sure that PUBLIC identifiers may have some strange characters. NOTE: The XML editors have said that the XML specification errata will specify that parameter entity expansion does not occur in PUBLIC identifiers, so that the '%' character will not flag a malformed parameter entity reference. (xmlconf/xmltest/valid/sa/100.xml)")
end

it "valid-sa-101 (Section 4.5)" do
  assert_parses("xmlconf/xmltest/valid/sa/101.xml", "xmlconf/xmltest/valid/sa/out/101.xml", " This tests whether entity expansion is (incorrectly) done while processing entity declarations; if it is, the entity value literal will terminate prematurely. (xmlconf/xmltest/valid/sa/101.xml)")
end

it "valid-sa-102 (Section 3.3.3)" do
  assert_parses("xmlconf/xmltest/valid/sa/102.xml", "xmlconf/xmltest/valid/sa/out/102.xml", " Test demonstrates that a CDATA attribute can pass a double quote as its value.  (xmlconf/xmltest/valid/sa/102.xml)")
end

it "valid-sa-103 (Section 3.3.3)" do
  assert_parses("xmlconf/xmltest/valid/sa/103.xml", "xmlconf/xmltest/valid/sa/out/103.xml", " Test demonstrates that an attribute can pass a less than sign as its value.  (xmlconf/xmltest/valid/sa/103.xml)")
end

it "valid-sa-104 (Section 3.1 [40])" do
  assert_parses("xmlconf/xmltest/valid/sa/104.xml", "xmlconf/xmltest/valid/sa/out/104.xml", " Test demonstrates that extra whitespace within an Attribute of a Start-tag is normalized to a single space character.  (xmlconf/xmltest/valid/sa/104.xml)")
end

it "valid-sa-105 (Section 3.3.3)" do
  assert_parses("xmlconf/xmltest/valid/sa/105.xml", "xmlconf/xmltest/valid/sa/out/105.xml", " Basically an output test, this requires a CDATA attribute with a tab character to be passed through as one space. (xmlconf/xmltest/valid/sa/105.xml)")
end

it "valid-sa-106 (Section 3.3.3)" do
  assert_parses("xmlconf/xmltest/valid/sa/106.xml", "xmlconf/xmltest/valid/sa/out/106.xml", " Basically an output test, this requires a CDATA attribute with a newline character to be passed through as one space. (xmlconf/xmltest/valid/sa/106.xml)")
end

it "valid-sa-107 (Section 3.3.3)" do
  assert_parses("xmlconf/xmltest/valid/sa/107.xml", "xmlconf/xmltest/valid/sa/out/107.xml", " Basically an output test, this requires a CDATA attribute with a return character to be passed through as one space. (xmlconf/xmltest/valid/sa/107.xml)")
end

it "valid-sa-108 (Section 2.11, 3.3.3)" do
  assert_parses("xmlconf/xmltest/valid/sa/108.xml", "xmlconf/xmltest/valid/sa/out/108.xml", " This tests normalization of end-of-line characters (CRLF) within entities to LF, primarily as an output test.  (xmlconf/xmltest/valid/sa/108.xml)")
end

it "valid-sa-109 (Section 2.3 3.1 [10][40][41])" do
  assert_parses("xmlconf/xmltest/valid/sa/109.xml", "xmlconf/xmltest/valid/sa/out/109.xml", " Test demonstrates that an attribute can have a null value.  (xmlconf/xmltest/valid/sa/109.xml)")
end

it "valid-sa-110 (Section 3.3.3)" do
  assert_parses("xmlconf/xmltest/valid/sa/110.xml", "xmlconf/xmltest/valid/sa/out/110.xml", " Basically an output test, this requires that a CDATA attribute with a CRLF be normalized to one space. (xmlconf/xmltest/valid/sa/110.xml)")
end

it "valid-sa-111 (Section 3.3.3)" do
  assert_parses("xmlconf/xmltest/valid/sa/111.xml", "xmlconf/xmltest/valid/sa/out/111.xml", " Character references expanding to spaces doesn't affect treatment of attributes.  (xmlconf/xmltest/valid/sa/111.xml)")
end

it "valid-sa-112 (Section 3.2.1 [48][49])" do
  assert_parses("xmlconf/xmltest/valid/sa/112.xml", "xmlconf/xmltest/valid/sa/out/112.xml", " Test demonstrates shows the use of content particles within the element content.  (xmlconf/xmltest/valid/sa/112.xml)")
end

it "valid-sa-113 (Section 3.3 [52][53])" do
  assert_parses("xmlconf/xmltest/valid/sa/113.xml", "xmlconf/xmltest/valid/sa/out/113.xml", " Test demonstrates that it is not an error to have attributes declared for an element not itself declared. (xmlconf/xmltest/valid/sa/113.xml)")
end

it "valid-sa-114 (Section 2.7 [20])" do
  assert_parses("xmlconf/xmltest/valid/sa/114.xml", "xmlconf/xmltest/valid/sa/out/114.xml", " Test demonstrates that all text within a valid CDATA section is considered text and not recognized as markup.  (xmlconf/xmltest/valid/sa/114.xml)")
end

it "valid-sa-115 (Section 3.3.3)" do
  assert_parses("xmlconf/xmltest/valid/sa/115.xml", "xmlconf/xmltest/valid/sa/out/115.xml", " Test demonstrates that an entity reference is processed by recursively processing the replacement text of the entity.  (xmlconf/xmltest/valid/sa/115.xml)")
end

it "valid-sa-116 (Section 2.11)" do
  assert_parses("xmlconf/xmltest/valid/sa/116.xml", "xmlconf/xmltest/valid/sa/out/116.xml", " Test demonstrates that a line break within CDATA will be normalized.  (xmlconf/xmltest/valid/sa/116.xml)")
end

it "valid-sa-117 (Section 4.5)" do
  assert_parses("xmlconf/xmltest/valid/sa/117.xml", "xmlconf/xmltest/valid/sa/out/117.xml", " Test demonstrates that entity expansion is done while processing entity declarations.  (xmlconf/xmltest/valid/sa/117.xml)")
end

it "valid-sa-118 (Section 4.5)" do
  assert_parses("xmlconf/xmltest/valid/sa/118.xml", "xmlconf/xmltest/valid/sa/out/118.xml", " Test demonstrates that entity expansion is done while processing entity declarations.  (xmlconf/xmltest/valid/sa/118.xml)")
end

it "valid-sa-119 (Section 2.5)" do
  assert_parses("xmlconf/xmltest/valid/sa/119.xml", "xmlconf/xmltest/valid/sa/out/119.xml", " Comments may contain any legal XML characters; only the string \"--\" is disallowed. (xmlconf/xmltest/valid/sa/119.xml)")
end

it "valid-not-sa-001 (Section 4.2.2 [75])" do
  assert_parses("xmlconf/xmltest/valid/not-sa/001.xml", "xmlconf/xmltest/valid/not-sa/out/001.xml", " Test demonstrates the use of an ExternalID within a document type definition.  (xmlconf/xmltest/valid/not-sa/001.xml)")
end

it "valid-not-sa-002 (Section 4.2.2 [75])" do
  assert_parses("xmlconf/xmltest/valid/not-sa/002.xml", "xmlconf/xmltest/valid/not-sa/out/002.xml", " Test demonstrates the use of an ExternalID within a document type definition.  (xmlconf/xmltest/valid/not-sa/002.xml)")
end

it "valid-not-sa-003 (Section 4.1 [69])" do
  assert_parses("xmlconf/xmltest/valid/not-sa/003.xml", "xmlconf/xmltest/valid/not-sa/out/003.xml", " Test demonstrates the expansion of an external parameter entity that declares an attribute.  (xmlconf/xmltest/valid/not-sa/003.xml)")
end

it "valid-not-sa-004 (Section 4.1 [69])" do
  assert_parses("xmlconf/xmltest/valid/not-sa/004.xml", "xmlconf/xmltest/valid/not-sa/out/004.xml", " Expands an external parameter entity in two different ways, with one of them declaring an attribute. (xmlconf/xmltest/valid/not-sa/004.xml)")
end

it "valid-not-sa-005 (Section 4.1 [69])" do
  assert_parses("xmlconf/xmltest/valid/not-sa/005.xml", "xmlconf/xmltest/valid/not-sa/out/005.xml", " Test demonstrates the expansion of an external parameter entity that declares an attribute.  (xmlconf/xmltest/valid/not-sa/005.xml)")
end

it "valid-not-sa-006 (Section 3.3 [52])" do
  assert_parses("xmlconf/xmltest/valid/not-sa/006.xml", "xmlconf/xmltest/valid/not-sa/out/006.xml", " Test demonstrates that when more than one definition is provided for the same attribute of a given element type only the first declaration is binding.  (xmlconf/xmltest/valid/not-sa/006.xml)")
end

it "valid-not-sa-007 (Section 3.3 [52])" do
  assert_parses("xmlconf/xmltest/valid/not-sa/007.xml", "xmlconf/xmltest/valid/not-sa/out/007.xml", " Test demonstrates the use of an Attribute list declaration within an external entity.  (xmlconf/xmltest/valid/not-sa/007.xml)")
end

it "valid-not-sa-008 (Section 4.2.2 [75])" do
  assert_parses("xmlconf/xmltest/valid/not-sa/008.xml", "xmlconf/xmltest/valid/not-sa/out/008.xml", " Test demonstrates that an external identifier may include a public identifier.  (xmlconf/xmltest/valid/not-sa/008.xml)")
end

it "valid-not-sa-009 (Section 4.2.2 [75])" do
  assert_parses("xmlconf/xmltest/valid/not-sa/009.xml", "xmlconf/xmltest/valid/not-sa/out/009.xml", " Test demonstrates that an external identifier may include a public identifier.  (xmlconf/xmltest/valid/not-sa/009.xml)")
end

it "valid-not-sa-010 (Section 3.3 [52])" do
  assert_parses("xmlconf/xmltest/valid/not-sa/010.xml", "xmlconf/xmltest/valid/not-sa/out/010.xml", " Test demonstrates that when more that one definition is provided for the same attribute of a given element type only the first declaration is binding.  (xmlconf/xmltest/valid/not-sa/010.xml)")
end

it "valid-not-sa-011 (Section 4.2 4.2.1 [72] [75])" do
  assert_parses("xmlconf/xmltest/valid/not-sa/011.xml", "xmlconf/xmltest/valid/not-sa/out/011.xml", " Test demonstrates a parameter entity declaration whose parameter entity definition is an ExternalID.  (xmlconf/xmltest/valid/not-sa/011.xml)")
end

it "valid-not-sa-012 (Section 4.3.1 [77])" do
  assert_parses("xmlconf/xmltest/valid/not-sa/012.xml", "xmlconf/xmltest/valid/not-sa/out/012.xml", " Test demonstrates an enternal parsed entity that begins with a text declaration.  (xmlconf/xmltest/valid/not-sa/012.xml)")
end

it "valid-not-sa-013 (Section 3.4 [62])" do
  assert_parses("xmlconf/xmltest/valid/not-sa/013.xml", "xmlconf/xmltest/valid/not-sa/out/013.xml", " Test demonstrates the use of the conditional section INCLUDE that will include its contents as part of the DTD.  (xmlconf/xmltest/valid/not-sa/013.xml)")
end

it "valid-not-sa-014 (Section 3.4 [62])" do
  assert_parses("xmlconf/xmltest/valid/not-sa/014.xml", "xmlconf/xmltest/valid/not-sa/out/014.xml", " Test demonstrates the use of the conditional section INCLUDE that will include its contents as part of the DTD. The keyword is a parameter-entity reference.  (xmlconf/xmltest/valid/not-sa/014.xml)")
end

it "valid-not-sa-015 (Section 3.4 [63])" do
  assert_parses("xmlconf/xmltest/valid/not-sa/015.xml", "xmlconf/xmltest/valid/not-sa/out/015.xml", " Test demonstrates the use of the conditonal section IGNORE the will ignore its content from being part of the DTD. The keyword is a parameter-entity reference.  (xmlconf/xmltest/valid/not-sa/015.xml)")
end

it "valid-not-sa-016 (Section 3.4 [62])" do
  assert_parses("xmlconf/xmltest/valid/not-sa/016.xml", "xmlconf/xmltest/valid/not-sa/out/016.xml", " Test demonstrates the use of the conditional section INCLUDE that will include its contents as part of the DTD. The keyword is a parameter-entity reference. (xmlconf/xmltest/valid/not-sa/016.xml)")
end

it "valid-not-sa-017 (Section 4.2 [72])" do
  assert_parses("xmlconf/xmltest/valid/not-sa/017.xml", "xmlconf/xmltest/valid/not-sa/out/017.xml", " Test demonstrates a parameter entity declaration that contains an attribute list declaration.  (xmlconf/xmltest/valid/not-sa/017.xml)")
end

it "valid-not-sa-018 (Section 4.2.2 [75])" do
  assert_parses("xmlconf/xmltest/valid/not-sa/018.xml", "xmlconf/xmltest/valid/not-sa/out/018.xml", " Test demonstrates an EnternalID whose contents contain an parameter entity declaration and a attribute list definition.  (xmlconf/xmltest/valid/not-sa/018.xml)")
end

it "valid-not-sa-019 (Section 4.4.8)" do
  assert_parses("xmlconf/xmltest/valid/not-sa/019.xml", "xmlconf/xmltest/valid/not-sa/out/019.xml", " Test demonstrates that a parameter entity will be expanded with spaces on either side.  (xmlconf/xmltest/valid/not-sa/019.xml)")
end

it "valid-not-sa-020 (Section 4.4.8)" do
  assert_parses("xmlconf/xmltest/valid/not-sa/020.xml", "xmlconf/xmltest/valid/not-sa/out/020.xml", " Parameter entities expand with spaces on either side. (xmlconf/xmltest/valid/not-sa/020.xml)")
end

it "valid-not-sa-021 (Section 4.2 [72])" do
  assert_parses("xmlconf/xmltest/valid/not-sa/021.xml", "xmlconf/xmltest/valid/not-sa/out/021.xml", " Test demonstrates a parameter entity declaration that contains a partial attribute list declaration.  (xmlconf/xmltest/valid/not-sa/021.xml)")
end

it "valid-not-sa-023 (Section 2.3 4.1 [10] [69])" do
  assert_parses("xmlconf/xmltest/valid/not-sa/023.xml", "xmlconf/xmltest/valid/not-sa/out/023.xml", " Test demonstrates the use of a parameter entity reference within an attribute list declaration.  (xmlconf/xmltest/valid/not-sa/023.xml)")
end

it "valid-not-sa-024 (Section 2.8, 4.1 [69])" do
  assert_parses("xmlconf/xmltest/valid/not-sa/024.xml", "xmlconf/xmltest/valid/not-sa/out/024.xml", " Constructs an <!ATTLIST...> declaration from several PEs. (xmlconf/xmltest/valid/not-sa/024.xml)")
end

it "valid-not-sa-025 (Section 4.2)" do
  assert_parses("xmlconf/xmltest/valid/not-sa/025.xml", "xmlconf/xmltest/valid/not-sa/out/025.xml", " Test demonstrates that when more that one definition is provided for the same entity only the first declaration is binding.  (xmlconf/xmltest/valid/not-sa/025.xml)")
end

it "valid-not-sa-026 (Section 3.3 [52])" do
  assert_parses("xmlconf/xmltest/valid/not-sa/026.xml", "xmlconf/xmltest/valid/not-sa/out/026.xml", " Test demonstrates that when more that one definition is provided for the same attribute of a given element type only the first declaration is binding.  (xmlconf/xmltest/valid/not-sa/026.xml)")
end

it "valid-not-sa-027 (Section 4.1 [69])" do
  assert_parses("xmlconf/xmltest/valid/not-sa/027.xml", "xmlconf/xmltest/valid/not-sa/out/027.xml", " Test demonstrates a parameter entity reference whose value is NULL.  (xmlconf/xmltest/valid/not-sa/027.xml)")
end

it "valid-not-sa-028 (Section 3.4 [62])" do
  assert_parses("xmlconf/xmltest/valid/not-sa/028.xml", "xmlconf/xmltest/valid/not-sa/out/028.xml", " Test demonstrates the use of the conditional section INCLUDE that will include its contents.  (xmlconf/xmltest/valid/not-sa/028.xml)")
end

it "valid-not-sa-029 (Section 3.4 [62])" do
  assert_parses("xmlconf/xmltest/valid/not-sa/029.xml", "xmlconf/xmltest/valid/not-sa/out/029.xml", " Test demonstrates the use of the conditonal section IGNORE the will ignore its content from being used.  (xmlconf/xmltest/valid/not-sa/029.xml)")
end

it "valid-not-sa-030 (Section 3.4 [62])" do
  assert_parses("xmlconf/xmltest/valid/not-sa/030.xml", "xmlconf/xmltest/valid/not-sa/out/030.xml", " Test demonstrates the use of the conditonal section IGNORE the will ignore its content from being used.  (xmlconf/xmltest/valid/not-sa/030.xml)")
end

it "valid-not-sa-031 (Section 2.7)" do
  assert_parses("xmlconf/xmltest/valid/not-sa/031.xml", "xmlconf/xmltest/valid/not-sa/out/031.xml", " Expands a general entity which contains a CDATA section with what looks like a markup declaration (but is just text since it's in a CDATA section). (xmlconf/xmltest/valid/not-sa/031.xml)")
end

it "valid-ext-sa-001 (Section 2.11)" do
  assert_parses("xmlconf/xmltest/valid/ext-sa/001.xml", "xmlconf/xmltest/valid/ext-sa/out/001.xml", " A combination of carriage return line feed in an external entity must be normalized to a single newline.  (xmlconf/xmltest/valid/ext-sa/001.xml)")
end

it "valid-ext-sa-002 (Section 2.11)" do
  assert_parses("xmlconf/xmltest/valid/ext-sa/002.xml", "xmlconf/xmltest/valid/ext-sa/out/002.xml", " A carriage return (also CRLF) in an external entity must be normalized to a single newline.  (xmlconf/xmltest/valid/ext-sa/002.xml)")
end

it "valid-ext-sa-003 (Section 3.1 4.1 [43] [68])" do
  assert_parses("xmlconf/xmltest/valid/ext-sa/003.xml", "xmlconf/xmltest/valid/ext-sa/out/003.xml", " Test demonstrates that the content of an element can be empty. In this case the external entity is an empty file.  (xmlconf/xmltest/valid/ext-sa/003.xml)")
end

it "valid-ext-sa-004 (Section 2.11)" do
  assert_parses("xmlconf/xmltest/valid/ext-sa/004.xml", "xmlconf/xmltest/valid/ext-sa/out/004.xml", " A carriage return (also CRLF) in an external entity must be normalized to a single newline.  (xmlconf/xmltest/valid/ext-sa/004.xml)")
end

it "valid-ext-sa-005 (Section 3.2.1 4.2.2 [48] [75])" do
  assert_parses("xmlconf/xmltest/valid/ext-sa/005.xml", "xmlconf/xmltest/valid/ext-sa/out/005.xml", " Test demonstrates the use of optional character and content particles within an element content. The test also show the use of external entity.  (xmlconf/xmltest/valid/ext-sa/005.xml)")
end

it "valid-ext-sa-006 (Section 2.11 3.2.1 3.2.2 4.2.2 [48] [51] [75])" do
  assert_parses("xmlconf/xmltest/valid/ext-sa/006.xml", "xmlconf/xmltest/valid/ext-sa/out/006.xml", " Test demonstrates the use of optional character and content particles within mixed element content. The test also shows the use of an external entity and that a carriage control line feed in an external entity must be normalized to a single newline.  (xmlconf/xmltest/valid/ext-sa/006.xml)")
end

it "valid-ext-sa-007 (Section 4.2.2 4.4.3 [75])" do
  assert_parses("xmlconf/xmltest/valid/ext-sa/007.xml", "xmlconf/xmltest/valid/ext-sa/out/007.xml", " Test demonstrates the use of external entity and how replacement text is retrieved and processed.  (xmlconf/xmltest/valid/ext-sa/007.xml)")
end

it "valid-ext-sa-008 (Section 4.2.2 4.3.3. 4.4.3 [75] [80])" do
  assert_parses("xmlconf/xmltest/valid/ext-sa/008.xml", "xmlconf/xmltest/valid/ext-sa/out/008.xml", " Test demonstrates the use of external entity and how replacement text is retrieved and processed. Also tests the use of an EncodingDecl of UTF-16. (xmlconf/xmltest/valid/ext-sa/008.xml)")
end

it "valid-ext-sa-009 (Section 2.11)" do
  assert_parses("xmlconf/xmltest/valid/ext-sa/009.xml", "xmlconf/xmltest/valid/ext-sa/out/009.xml", " A carriage return (also CRLF) in an external entity must be normalized to a single newline.  (xmlconf/xmltest/valid/ext-sa/009.xml)")
end

it "valid-ext-sa-011 (Section 2.11 4.2.2 [75])" do
  assert_parses("xmlconf/xmltest/valid/ext-sa/011.xml", "xmlconf/xmltest/valid/ext-sa/out/011.xml", " Test demonstrates the use of a public identifier with and external entity. The test also show that a carriage control line feed combination in an external entity must be normalized to a single newline.  (xmlconf/xmltest/valid/ext-sa/011.xml)")
end

it "valid-ext-sa-012 (Section 4.2.1 4.2.2)" do
  assert_parses("xmlconf/xmltest/valid/ext-sa/012.xml", "xmlconf/xmltest/valid/ext-sa/out/012.xml", " Test demonstrates both internal and external entities and that processing of entity references may be required to produce the correct replacement text. (xmlconf/xmltest/valid/ext-sa/012.xml)")
end

it "valid-ext-sa-013 (Section 3.3.3)" do
  assert_parses("xmlconf/xmltest/valid/ext-sa/013.xml", "xmlconf/xmltest/valid/ext-sa/out/013.xml", " Test demonstrates that whitespace is handled by adding a single whitespace to the normalized value in the attribute list.  (xmlconf/xmltest/valid/ext-sa/013.xml)")
end

it "valid-ext-sa-014 (Section 4.1 4.4.3 [68])" do
  assert_parses("xmlconf/xmltest/valid/ext-sa/014.xml", "xmlconf/xmltest/valid/ext-sa/out/014.xml", " Test demonstrates use of characters outside of normal ASCII range. (xmlconf/xmltest/valid/ext-sa/014.xml)")
end

end

end

describe "Fuji Xerox Japanese Text Tests XML 1.0 Tests" do
describe "Fuji Xerox Japanese Text Tests" do
it "pr-xml-euc-jp (Section 4.3.3 [4,84])" do
  assert_parses("xmlconf/japanese/pr-xml-euc-jp.xml", nil, " Test support for the EUC-JP encoding, and for text which relies on Japanese characters. If a processor does not support this encoding, it must report a fatal error. (Also requires ability to process a moderately complex DTD.)  (xmlconf/japanese/pr-xml-euc-jp.xml)")
end

it "pr-xml-iso-2022-jp (Section 4.3.3 [4,84])" do
  assert_parses("xmlconf/japanese/pr-xml-iso-2022-jp.xml", nil, " Test support for the ISO-2022-JP encoding, and for text which relies on Japanese characters. If a processor does not support this encoding, it must report a fatal error. (Also requires ability to process a moderately complex DTD.)  (xmlconf/japanese/pr-xml-iso-2022-jp.xml)")
end

it "pr-xml-little (Section 4.3.3 [4,84])" do
  assert_parses("xmlconf/japanese/pr-xml-little-endian.xml", nil, " Test support for little-endian UTF-16 text which relies on Japanese characters. (Also requires ability to process a moderately complex DTD.)  (xmlconf/japanese/pr-xml-little-endian.xml)")
end

it "pr-xml-shift_jis (Section 4.3.3 [4,84])" do
  assert_parses("xmlconf/japanese/pr-xml-shift_jis.xml", nil, " Test support for the Shift_JIS encoding, and for text which relies on Japanese characters. If a processor does not support this encoding, it must report a fatal error. (Also requires ability to process a moderately complex DTD.)  (xmlconf/japanese/pr-xml-shift_jis.xml)")
end

it "pr-xml-utf-16 (Section 4.3.3 [4,84])" do
  assert_parses("xmlconf/japanese/pr-xml-utf-16.xml", nil, " Test support UTF-16 text which relies on Japanese characters. (Also requires ability to process a moderately complex DTD.)  (xmlconf/japanese/pr-xml-utf-16.xml)")
end

it "pr-xml-utf-8 (Section 4.3.3 [4,84])" do
  assert_parses("xmlconf/japanese/pr-xml-utf-8.xml", nil, " Test support for UTF-8 text which relies on Japanese characters. (Also requires ability to process a moderately complex DTD.)  (xmlconf/japanese/pr-xml-utf-8.xml)")
end

it "weekly-euc-jp (Section 4.3.3 [4,84])" do
  assert_parses("xmlconf/japanese/weekly-euc-jp.xml", nil, " Test support for EUC-JP encoding, and XML names which contain Japanese characters. If a processor does not support this encoding, it must report a fatal error.  (xmlconf/japanese/weekly-euc-jp.xml)")
end

it "weekly-iso-2022-jp (Section 4.3.3 [4,84])" do
  assert_parses("xmlconf/japanese/weekly-iso-2022-jp.xml", nil, " Test support for ISO-2022-JP encoding, and XML names which contain Japanese characters. If a processor does not support this encoding, it must report a fatal error.  (xmlconf/japanese/weekly-iso-2022-jp.xml)")
end

it "weekly-little (Section 4.3.3 [4,84])" do
  assert_parses("xmlconf/japanese/weekly-little-endian.xml", nil, " Test support for little-endian UTF-16 encoding, and XML names which contain Japanese characters.  (xmlconf/japanese/weekly-little-endian.xml)")
end

it "weekly-shift_jis (Section 4.3.3 [4,84])" do
  assert_parses("xmlconf/japanese/weekly-shift_jis.xml", nil, " Test support for Shift_JIS encoding, and XML names which contain Japanese characters. If a processor does not support this encoding, it must report a fatal error.  (xmlconf/japanese/weekly-shift_jis.xml)")
end

it "weekly-utf-16 (Section 4.3.3 [4,84])" do
  assert_parses("xmlconf/japanese/weekly-utf-16.xml", nil, " Test support for UTF-16 encoding, and XML names which contain Japanese characters.  (xmlconf/japanese/weekly-utf-16.xml)")
end

it "weekly-utf-8 (Section 4.3.3 [4,84])" do
  assert_parses("xmlconf/japanese/weekly-utf-8.xml", nil, " Test support for UTF-8 encoding and XML names which contain Japanese characters.  (xmlconf/japanese/weekly-utf-8.xml)")
end

end

end

describe "Sun Microsystems XML Tests" do
it "pe01 (Section 2.8)" do
  assert_parses("xmlconf/sun/valid/pe01.xml", nil, " Parameter entities references are NOT RECOGNIZED in default attribute values. (xmlconf/sun/valid/pe01.xml)")
end

it "dtd00 (Section 3.2.2 [51])" do
  assert_parses("xmlconf/sun/valid/dtd00.xml", "xmlconf/sun/valid/out/dtd00.xml", " Tests parsing of alternative forms of text-only mixed content declaration. (xmlconf/sun/valid/dtd00.xml)")
end

it "dtd01 (Section 2.5 [15])" do
  assert_parses("xmlconf/sun/valid/dtd01.xml", "xmlconf/sun/valid/out/dtd01.xml", " Comments don't get parameter entity expansion (xmlconf/sun/valid/dtd01.xml)")
end

it "element (Section 3)" do
  assert_parses("xmlconf/sun/valid/element.xml", "xmlconf/sun/valid/out/element.xml", " Tests clauses 1, 3, and 4 of the Element Valid validity constraint. (xmlconf/sun/valid/element.xml)")
end

it "ext01 (Section 4.3.1 4.3.2 [77] [78])" do
  assert_parses("xmlconf/sun/valid/ext01.xml", "xmlconf/sun/valid/out/ext01.xml", " Tests use of external parsed entities with and without content. (xmlconf/sun/valid/ext01.xml)")
end

it "ext02 (Section 4.3.2 [78])" do
  assert_parses("xmlconf/sun/valid/ext02.xml", "xmlconf/sun/valid/out/ext02.xml", " Tests use of external parsed entities with different encodings than the base document. (xmlconf/sun/valid/ext02.xml)")
end

it "not-sa01 (Section 2.9)" do
  assert_parses("xmlconf/sun/valid/not-sa01.xml", "xmlconf/sun/valid/out/not-sa01.xml", " A non-standalone document is valid if declared as such. (xmlconf/sun/valid/not-sa01.xml)")
end

it "not-sa02 (Section 2.9)" do
  assert_parses("xmlconf/sun/valid/not-sa02.xml", "xmlconf/sun/valid/out/not-sa02.xml", " A non-standalone document is valid if declared as such. (xmlconf/sun/valid/not-sa02.xml)")
end

it "not-sa03 (Section 2.9)" do
  assert_parses("xmlconf/sun/valid/not-sa03.xml", "xmlconf/sun/valid/out/not-sa03.xml", " A non-standalone document is valid if declared as such. (xmlconf/sun/valid/not-sa03.xml)")
end

it "not-sa04 (Section 2.9)" do
  assert_parses("xmlconf/sun/valid/not-sa04.xml", "xmlconf/sun/valid/out/not-sa04.xml", " A non-standalone document is valid if declared as such.  (xmlconf/sun/valid/not-sa04.xml)")
end

it "notation01 (Section 4.7 [82])" do
  assert_parses("xmlconf/sun/valid/notation01.xml", "xmlconf/sun/valid/out/notation01.xml", " NOTATION declarations don't need SYSTEM IDs; and externally declared notations may be used to declare unparsed entities in the internal DTD subset. The notation must be reported to the application.  (xmlconf/sun/valid/notation01.xml)")
end

it "optional (Section 3 3.2.1 [47])" do
  assert_parses("xmlconf/sun/valid/optional.xml", "xmlconf/sun/valid/out/optional.xml", " Tests declarations of \"children\" content models, and the validity constraints associated with them. (xmlconf/sun/valid/optional.xml)")
end

it "required00 (Section 3.3.2 [60])" do
  assert_parses("xmlconf/sun/valid/required00.xml", "xmlconf/sun/valid/out/required00.xml", " Tests the #REQUIRED attribute declaration syntax, and the associated validity constraint.  (xmlconf/sun/valid/required00.xml)")
end

it "sa01 (Section 2.9 [32])" do
  assert_parses("xmlconf/sun/valid/sa01.xml", "xmlconf/sun/valid/out/sa01.xml", " A document may be marked 'standalone' if any optional whitespace is defined within the internal DTD subset. (xmlconf/sun/valid/sa01.xml)")
end

it "sa02 (Section 2.9 [32])" do
  assert_parses("xmlconf/sun/valid/sa02.xml", "xmlconf/sun/valid/out/sa02.xml", " A document may be marked 'standalone' if any attributes that need normalization are defined within the internal DTD subset. (xmlconf/sun/valid/sa02.xml)")
end

it "sa03 (Section 2.9 [32])" do
  assert_parses("xmlconf/sun/valid/sa03.xml", "xmlconf/sun/valid/out/sa03.xml", " A document may be marked 'standalone' if any the defined entities need expanding are internal, and no attributes need defaulting or normalization. On output, requires notations to be correctly reported.  (xmlconf/sun/valid/sa03.xml)")
end

it "sa04 (Section 2.9 [32])" do
  assert_parses("xmlconf/sun/valid/sa04.xml", "xmlconf/sun/valid/out/sa04.xml", " Like sa03 but relies on attribute defaulting defined in the internal subset. On output, requires notations to be correctly reported.  (xmlconf/sun/valid/sa04.xml)")
end

it "sa05 (Section 2.9 [32])" do
  assert_parses("xmlconf/sun/valid/sa05.xml", "xmlconf/sun/valid/out/sa05.xml", " Like sa01 but this document is standalone since it has no optional whitespace. On output, requires notations to be correctly reported.  (xmlconf/sun/valid/sa05.xml)")
end

it "v-sgml01 (Section 3.3.1 [59])" do
  assert_parses("xmlconf/sun/valid/sgml01.xml", "xmlconf/sun/valid/out/sgml01.xml", " XML permits token reuse, while SGML does not. (xmlconf/sun/valid/sgml01.xml)")
end

it "v-lang01 (Section 2.12 [35])" do
  assert_parses("xmlconf/sun/valid/v-lang01.xml", "xmlconf/sun/valid/out/v-lang01.xml", " Tests a lowercase ISO language code. (xmlconf/sun/valid/v-lang01.xml)")
end

it "v-lang02 (Section 2.12 [35])" do
  assert_parses("xmlconf/sun/valid/v-lang02.xml", "xmlconf/sun/valid/out/v-lang02.xml", " Tests a ISO language code with a subcode. (xmlconf/sun/valid/v-lang02.xml)")
end

it "v-lang03 (Section 2.12 [36])" do
  assert_parses("xmlconf/sun/valid/v-lang03.xml", "xmlconf/sun/valid/out/v-lang03.xml", " Tests a IANA language code with a subcode. (xmlconf/sun/valid/v-lang03.xml)")
end

it "v-lang04 (Section 2.12 [37])" do
  assert_parses("xmlconf/sun/valid/v-lang04.xml", "xmlconf/sun/valid/out/v-lang04.xml", " Tests a user language code with a subcode. (xmlconf/sun/valid/v-lang04.xml)")
end

it "v-lang05 (Section 2.12 [35])" do
  assert_parses("xmlconf/sun/valid/v-lang05.xml", "xmlconf/sun/valid/out/v-lang05.xml", " Tests an uppercase ISO language code. (xmlconf/sun/valid/v-lang05.xml)")
end

it "v-lang06 (Section 2.12 [37])" do
  assert_parses("xmlconf/sun/valid/v-lang06.xml", "xmlconf/sun/valid/out/v-lang06.xml", " Tests a user language code. (xmlconf/sun/valid/v-lang06.xml)")
end

it "v-pe00 (Section 4.5)" do
  assert_parses("xmlconf/sun/valid/pe00.xml", "xmlconf/sun/valid/out/pe00.xml", " Tests construction of internal entity replacement text, using an example in the XML specification.  (xmlconf/sun/valid/pe00.xml)")
end

it "v-pe03 (Section 4.5)" do
  assert_parses("xmlconf/sun/valid/pe03.xml", "xmlconf/sun/valid/out/pe03.xml", " Tests construction of internal entity replacement text, using an example in the XML specification.  (xmlconf/sun/valid/pe03.xml)")
end

it "v-pe02 (Section 4.5)" do
  assert_parses("xmlconf/sun/valid/pe02.xml", "xmlconf/sun/valid/out/pe02.xml", " Tests construction of internal entity replacement text, using a complex example in the XML specification.  (xmlconf/sun/valid/pe02.xml)")
end

it "inv-dtd01 (Section 3.2.2)" do
  assert_parses("xmlconf/sun/invalid/dtd01.xml", nil, " Tests the No Duplicate Types VC (xmlconf/sun/invalid/dtd01.xml)")
end

it "inv-dtd02 (Section 4.2.2)" do
  assert_parses("xmlconf/sun/invalid/dtd02.xml", nil, " Tests the \"Notation Declared\" VC by using an undeclared notation name. (xmlconf/sun/invalid/dtd02.xml)")
end

it "inv-dtd03 (Section 3)" do
  assert_parses("xmlconf/sun/invalid/dtd03.xml", nil, " Tests the \"Element Valid\" VC (clause 2) by omitting a required element.  (xmlconf/sun/invalid/dtd03.xml)")
end

it "el01 (Section 3)" do
  assert_parses("xmlconf/sun/invalid/el01.xml", nil, " Tests the Element Valid VC (clause 4) by including an undeclared child element.  (xmlconf/sun/invalid/el01.xml)")
end

it "el02 (Section 3)" do
  assert_parses("xmlconf/sun/invalid/el02.xml", nil, " Tests the Element Valid VC (clause 1) by including elements in an EMPTY content model.  (xmlconf/sun/invalid/el02.xml)")
end

it "el03 (Section 3)" do
  assert_parses("xmlconf/sun/invalid/el03.xml", nil, " Tests the Element Valid VC (clause 3) by including a child element not permitted by a mixed content model.  (xmlconf/sun/invalid/el03.xml)")
end

it "el04 (Section 3.2)" do
  assert_parses("xmlconf/sun/invalid/el04.xml", nil, " Tests the Unique Element Type Declaration VC.  (xmlconf/sun/invalid/el04.xml)")
end

it "el05 (Section 3.2.2)" do
  assert_parses("xmlconf/sun/invalid/el05.xml", nil, " Tests the No Duplicate Types VC.  (xmlconf/sun/invalid/el05.xml)")
end

it "el06 (Section 3)" do
  assert_parses("xmlconf/sun/invalid/el06.xml", nil, " Tests the Element Valid VC (clause 1), using one of the predefined internal entities inside an EMPTY content model. (xmlconf/sun/invalid/el06.xml)")
end

it "id01 (Section 3.3.1)" do
  assert_parses("xmlconf/sun/invalid/id01.xml", nil, " Tests the ID (is a Name) VC (xmlconf/sun/invalid/id01.xml)")
end

it "id02 (Section 3.3.1)" do
  assert_parses("xmlconf/sun/invalid/id02.xml", nil, " Tests the ID (appears once) VC (xmlconf/sun/invalid/id02.xml)")
end

it "id03 (Section 3.3.1)" do
  assert_parses("xmlconf/sun/invalid/id03.xml", nil, " Tests the One ID per Element Type VC (xmlconf/sun/invalid/id03.xml)")
end

it "id04 (Section 3.3.1)" do
  assert_parses("xmlconf/sun/invalid/id04.xml", nil, " Tests the ID Attribute Default VC (xmlconf/sun/invalid/id04.xml)")
end

it "id05 (Section 3.3.1)" do
  assert_parses("xmlconf/sun/invalid/id05.xml", nil, " Tests the ID Attribute Default VC (xmlconf/sun/invalid/id05.xml)")
end

it "id06 (Section 3.3.1)" do
  assert_parses("xmlconf/sun/invalid/id06.xml", nil, " Tests the IDREF (is a Name) VC (xmlconf/sun/invalid/id06.xml)")
end

it "id07 (Section 3.3.1)" do
  assert_parses("xmlconf/sun/invalid/id07.xml", nil, " Tests the IDREFS (is a Names) VC (xmlconf/sun/invalid/id07.xml)")
end

it "id08 (Section 3.3.1)" do
  assert_parses("xmlconf/sun/invalid/id08.xml", nil, " Tests the IDREF (matches an ID) VC (xmlconf/sun/invalid/id08.xml)")
end

it "id09 (Section 3.3.1)" do
  assert_parses("xmlconf/sun/invalid/id09.xml", nil, " Tests the IDREF (IDREFS matches an ID) VC (xmlconf/sun/invalid/id09.xml)")
end

it "inv-not-sa01 (Section 2.9)" do
  assert_parses("xmlconf/sun/invalid/not-sa01.xml", nil, " Tests the Standalone Document Declaration VC, ensuring that optional whitespace causes a validity error. (xmlconf/sun/invalid/not-sa01.xml)")
end

it "inv-not-sa02 (Section 2.9)" do
  assert_parses("xmlconf/sun/invalid/not-sa02.xml", nil, " Tests the Standalone Document Declaration VC, ensuring that attributes needing normalization cause a validity error. (xmlconf/sun/invalid/not-sa02.xml)")
end

it "inv-not-sa04 (Section 2.9)" do
  assert_parses("xmlconf/sun/invalid/not-sa04.xml", nil, " Tests the Standalone Document Declaration VC, ensuring that attributes needing defaulting cause a validity error. (xmlconf/sun/invalid/not-sa04.xml)")
end

it "inv-not-sa05 (Section 2.9)" do
  assert_parses("xmlconf/sun/invalid/not-sa05.xml", nil, " Tests the Standalone Document Declaration VC, ensuring that a token attribute that needs normalization causes a validity error. (xmlconf/sun/invalid/not-sa05.xml)")
end

it "inv-not-sa06 (Section 2.9)" do
  assert_parses("xmlconf/sun/invalid/not-sa06.xml", nil, " Tests the Standalone Document Declaration VC, ensuring that a NOTATION attribute that needs normalization causes a validity error. (xmlconf/sun/invalid/not-sa06.xml)")
end

it "inv-not-sa07 (Section 2.9)" do
  assert_parses("xmlconf/sun/invalid/not-sa07.xml", nil, " Tests the Standalone Document Declaration VC, ensuring that an NMTOKEN attribute needing normalization causes a validity error. (xmlconf/sun/invalid/not-sa07.xml)")
end

it "inv-not-sa08 (Section 2.9)" do
  assert_parses("xmlconf/sun/invalid/not-sa08.xml", nil, " Tests the Standalone Document Declaration VC, ensuring that an NMTOKENS attribute needing normalization causes a validity error. (xmlconf/sun/invalid/not-sa08.xml)")
end

it "inv-not-sa09 (Section 2.9)" do
  assert_parses("xmlconf/sun/invalid/not-sa09.xml", nil, " Tests the Standalone Document Declaration VC, ensuring that an ID attribute needing normalization causes a validity error. (xmlconf/sun/invalid/not-sa09.xml)")
end

it "inv-not-sa10 (Section 2.9)" do
  assert_parses("xmlconf/sun/invalid/not-sa10.xml", nil, " Tests the Standalone Document Declaration VC, ensuring that an IDREF attribute needing normalization causes a validity error. (xmlconf/sun/invalid/not-sa10.xml)")
end

it "inv-not-sa11 (Section 2.9)" do
  assert_parses("xmlconf/sun/invalid/not-sa11.xml", nil, " Tests the Standalone Document Declaration VC, ensuring that an IDREFS attribute needing normalization causes a validity error. (xmlconf/sun/invalid/not-sa11.xml)")
end

it "inv-not-sa12 (Section 2.9)" do
  assert_parses("xmlconf/sun/invalid/not-sa12.xml", nil, " Tests the Standalone Document Declaration VC, ensuring that an ENTITY attribute needing normalization causes a validity error. (xmlconf/sun/invalid/not-sa12.xml)")
end

it "inv-not-sa13 (Section 2.9)" do
  assert_parses("xmlconf/sun/invalid/not-sa13.xml", nil, " Tests the Standalone Document Declaration VC, ensuring that an ENTITIES attribute needing normalization causes a validity error. (xmlconf/sun/invalid/not-sa13.xml)")
end

it "inv-not-sa14 (Section 3)" do
  assert_parses("xmlconf/sun/invalid/not-sa14.xml", nil, " CDATA sections containing only whitespace do not match the nonterminal S, and cannot appear in these positions. (xmlconf/sun/invalid/not-sa14.xml)")
end

it "optional01 (Section 3)" do
  assert_parses("xmlconf/sun/invalid/optional01.xml", nil, " Tests the Element Valid VC (clause 2) for one instance of \"children\" content model, providing no children where one is required. (xmlconf/sun/invalid/optional01.xml)")
end

it "optional02 (Section 3)" do
  assert_parses("xmlconf/sun/invalid/optional02.xml", nil, " Tests the Element Valid VC (clause 2) for one instance of \"children\" content model, providing two children where one is required. (xmlconf/sun/invalid/optional02.xml)")
end

it "optional03 (Section 3)" do
  assert_parses("xmlconf/sun/invalid/optional03.xml", nil, " Tests the Element Valid VC (clause 2) for one instance of \"children\" content model, providing no children where two are required. (xmlconf/sun/invalid/optional03.xml)")
end

it "optional04 (Section 3)" do
  assert_parses("xmlconf/sun/invalid/optional04.xml", nil, " Tests the Element Valid VC (clause 2) for one instance of \"children\" content model, providing three children where two are required. (xmlconf/sun/invalid/optional04.xml)")
end

it "optional05 (Section 3)" do
  assert_parses("xmlconf/sun/invalid/optional05.xml", nil, " Tests the Element Valid VC (clause 2) for one instance of \"children\" content model, providing no children where one or two are required (one construction of that model). (xmlconf/sun/invalid/optional05.xml)")
end

it "optional06 (Section 3)" do
  assert_parses("xmlconf/sun/invalid/optional06.xml", nil, " Tests the Element Valid VC (clause 2) for one instance of \"children\" content model, providing no children where one or two are required (a second construction of that model). (xmlconf/sun/invalid/optional06.xml)")
end

it "optional07 (Section 3)" do
  assert_parses("xmlconf/sun/invalid/optional07.xml", nil, " Tests the Element Valid VC (clause 2) for one instance of \"children\" content model, providing no children where one or two are required (a third construction of that model). (xmlconf/sun/invalid/optional07.xml)")
end

it "optional08 (Section 3)" do
  assert_parses("xmlconf/sun/invalid/optional08.xml", nil, " Tests the Element Valid VC (clause 2) for one instance of \"children\" content model, providing no children where one or two are required (a fourth construction of that model). (xmlconf/sun/invalid/optional08.xml)")
end

it "optional09 (Section 3)" do
  assert_parses("xmlconf/sun/invalid/optional09.xml", nil, " Tests the Element Valid VC (clause 2) for one instance of \"children\" content model, providing no children where one or two are required (a fifth construction of that model). (xmlconf/sun/invalid/optional09.xml)")
end

it "optional10 (Section 3)" do
  assert_parses("xmlconf/sun/invalid/optional10.xml", nil, " Tests the Element Valid VC (clause 2) for one instance of \"children\" content model, providing three children where one or two are required (a basic construction of that model). (xmlconf/sun/invalid/optional10.xml)")
end

it "optional11 (Section 3)" do
  assert_parses("xmlconf/sun/invalid/optional11.xml", nil, " Tests the Element Valid VC (clause 2) for one instance of \"children\" content model, providing three children where one or two are required (a second construction of that model). (xmlconf/sun/invalid/optional11.xml)")
end

it "optional12 (Section 3)" do
  assert_parses("xmlconf/sun/invalid/optional12.xml", nil, " Tests the Element Valid VC (clause 2) for one instance of \"children\" content model, providing three children where one or two are required (a third construction of that model). (xmlconf/sun/invalid/optional12.xml)")
end

it "optional13 (Section 3)" do
  assert_parses("xmlconf/sun/invalid/optional13.xml", nil, " Tests the Element Valid VC (clause 2) for one instance of \"children\" content model, providing three children where one or two are required (a fourth construction of that model). (xmlconf/sun/invalid/optional13.xml)")
end

it "optional14 (Section 3)" do
  assert_parses("xmlconf/sun/invalid/optional14.xml", nil, " Tests the Element Valid VC (clause 2) for one instance of \"children\" content model, providing three children where one or two are required (a fifth construction of that model). (xmlconf/sun/invalid/optional14.xml)")
end

it "optional20 (Section 3)" do
  assert_parses("xmlconf/sun/invalid/optional20.xml", nil, " Tests the Element Valid VC (clause 2) for one instance of \"children\" content model, providing no children where one or more are required (a sixth construction of that model). (xmlconf/sun/invalid/optional20.xml)")
end

it "optional21 (Section 3)" do
  assert_parses("xmlconf/sun/invalid/optional21.xml", nil, " Tests the Element Valid VC (clause 2) for one instance of \"children\" content model, providing no children where one or more are required (a seventh construction of that model). (xmlconf/sun/invalid/optional21.xml)")
end

it "optional22 (Section 3)" do
  assert_parses("xmlconf/sun/invalid/optional22.xml", nil, " Tests the Element Valid VC (clause 2) for one instance of \"children\" content model, providing no children where one or more are required (an eigth construction of that model). (xmlconf/sun/invalid/optional22.xml)")
end

it "optional23 (Section 3)" do
  assert_parses("xmlconf/sun/invalid/optional23.xml", nil, " Tests the Element Valid VC (clause 2) for one instance of \"children\" content model, providing no children where one or more are required (a ninth construction of that model). (xmlconf/sun/invalid/optional23.xml)")
end

it "optional24 (Section 3)" do
  assert_parses("xmlconf/sun/invalid/optional24.xml", nil, " Tests the Element Valid VC (clause 2) for one instance of \"children\" content model, providing no children where one or more are required (a tenth construction of that model). (xmlconf/sun/invalid/optional24.xml)")
end

it "optional25 (Section 3)" do
  assert_parses("xmlconf/sun/invalid/optional25.xml", nil, " Tests the Element Valid VC (clause 2) for one instance of \"children\" content model, providing text content where one or more elements are required. (xmlconf/sun/invalid/optional25.xml)")
end

it "inv-required00 (Section 3.3.2)" do
  assert_parses("xmlconf/sun/invalid/required00.xml", nil, " Tests the Required Attribute VC. (xmlconf/sun/invalid/required00.xml)")
end

it "inv-required01 (Section 3.1 2.10)" do
  assert_parses("xmlconf/sun/invalid/required01.xml", nil, " Tests the Attribute Value Type (declared) VC for the xml:space attribute (xmlconf/sun/invalid/required01.xml)")
end

it "inv-required02 (Section 3.1 2.12)" do
  assert_parses("xmlconf/sun/invalid/required02.xml", nil, " Tests the Attribute Value Type (declared) VC for the xml:lang attribute (xmlconf/sun/invalid/required02.xml)")
end

it "root (Section 2.8)" do
  assert_parses("xmlconf/sun/invalid/root.xml", nil, " Tests the Root Element Type VC (xmlconf/sun/invalid/root.xml)")
end

it "attr01 (Section 3.3.1)" do
  assert_parses("xmlconf/sun/invalid/attr01.xml", nil, " Tests the \"Entity Name\" VC for the ENTITY attribute type. (xmlconf/sun/invalid/attr01.xml)")
end

it "attr02 (Section 3.3.1)" do
  assert_parses("xmlconf/sun/invalid/attr02.xml", nil, " Tests the \"Entity Name\" VC for the ENTITIES attribute type. (xmlconf/sun/invalid/attr02.xml)")
end

it "attr03 (Section 3.3.1)" do
  assert_parses("xmlconf/sun/invalid/attr03.xml", nil, " Tests the \"Notation Attributes\" VC for the NOTATION attribute type, first clause: value must be one of the ones that's declared. (xmlconf/sun/invalid/attr03.xml)")
end

it "attr04 (Section 3.3.1)" do
  assert_parses("xmlconf/sun/invalid/attr04.xml", nil, " Tests the \"Notation Attributes\" VC for the NOTATION attribute type, second clause: the names in the declaration must all be declared. (xmlconf/sun/invalid/attr04.xml)")
end

it "attr05 (Section 3.3.1)" do
  assert_parses("xmlconf/sun/invalid/attr05.xml", nil, " Tests the \"Name Token\" VC for the NMTOKEN attribute type. (xmlconf/sun/invalid/attr05.xml)")
end

it "attr06 (Section 3.3.1)" do
  assert_parses("xmlconf/sun/invalid/attr06.xml", nil, " Tests the \"Name Token\" VC for the NMTOKENS attribute type. (xmlconf/sun/invalid/attr06.xml)")
end

it "attr07 (Section 3.3.1)" do
  assert_parses("xmlconf/sun/invalid/attr07.xml", nil, " Tests the \"Enumeration\" VC by providing a value which wasn't one of the choices. (xmlconf/sun/invalid/attr07.xml)")
end

it "attr08 (Section 3.3.2)" do
  assert_parses("xmlconf/sun/invalid/attr08.xml", nil, " Tests the \"Fixed Attribute Default\" VC by providing the wrong value. (xmlconf/sun/invalid/attr08.xml)")
end

it "attr09 (Section 3.3.2)" do
  assert_parses("xmlconf/sun/invalid/attr09.xml", nil, " Tests the \"Attribute Default Legal\" VC by providing an illegal IDREF value. (xmlconf/sun/invalid/attr09.xml)")
end

it "attr10 (Section 3.3.2)" do
  assert_parses("xmlconf/sun/invalid/attr10.xml", nil, " Tests the \"Attribute Default Legal\" VC by providing an illegal IDREFS value. (xmlconf/sun/invalid/attr10.xml)")
end

it "attr11 (Section 3.3.2)" do
  assert_parses("xmlconf/sun/invalid/attr11.xml", nil, " Tests the \"Attribute Default Legal\" VC by providing an illegal ENTITY value. (xmlconf/sun/invalid/attr11.xml)")
end

it "attr12 (Section 3.3.2)" do
  assert_parses("xmlconf/sun/invalid/attr12.xml", nil, " Tests the \"Attribute Default Legal\" VC by providing an illegal ENTITIES value. (xmlconf/sun/invalid/attr12.xml)")
end

it "attr13 (Section 3.3.2)" do
  assert_parses("xmlconf/sun/invalid/attr13.xml", nil, " Tests the \"Attribute Default Legal\" VC by providing an illegal NMTOKEN value. (xmlconf/sun/invalid/attr13.xml)")
end

it "attr14 (Section 3.3.2)" do
  assert_parses("xmlconf/sun/invalid/attr14.xml", nil, " Tests the \"Attribute Default Legal\" VC by providing an illegal NMTOKENS value. (xmlconf/sun/invalid/attr14.xml)")
end

it "attr15 (Section 3.3.2)" do
  assert_parses("xmlconf/sun/invalid/attr15.xml", nil, " Tests the \"Attribute Default Legal\" VC by providing an illegal NOTATIONS value. (xmlconf/sun/invalid/attr15.xml)")
end

it "attr16 (Section 3.3.2)" do
  assert_parses("xmlconf/sun/invalid/attr16.xml", nil, " Tests the \"Attribute Default Legal\" VC by providing an illegal enumeration value. (xmlconf/sun/invalid/attr16.xml)")
end

it "utf16b (Section 4.3.3 2.8)" do
  assert_parses("xmlconf/sun/invalid/utf16b.xml", nil, " Tests reading an invalid \"big endian\" UTF-16 document (xmlconf/sun/invalid/utf16b.xml)")
end

it "utf16l (Section 4.3.3 2.8)" do
  assert_parses("xmlconf/sun/invalid/utf16l.xml", nil, " Tests reading an invalid \"little endian\" UTF-16 document (xmlconf/sun/invalid/utf16l.xml)")
end

it "empty (Section 2.4 2.7 [18] 3)" do
  assert_parses("xmlconf/sun/invalid/empty.xml", nil, " CDATA section containing only white space does not match the nonterminal S, and cannot appear in these positions.  (xmlconf/sun/invalid/empty.xml)")
end

it "not-wf-sa03 (Section 2.9)" do
  assert_raises(XML::Error, " Tests the Entity Declared WFC, ensuring that a reference to externally defined entity causes a well-formedness error. (xmlconf/sun/not-wf/not-sa03.xml)") do
    File.open("xmlconf/sun/not-wf/not-sa03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "attlist01 (Section 3.3.1 [56])" do
  assert_raises(XML::Error, " SGML's NUTOKEN is not allowed. (xmlconf/sun/not-wf/attlist01.xml)") do
    File.open("xmlconf/sun/not-wf/attlist01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "attlist02 (Section 3.3.1 [56])" do
  assert_raises(XML::Error, " SGML's NUTOKENS attribute type is not allowed. (xmlconf/sun/not-wf/attlist02.xml)") do
    File.open("xmlconf/sun/not-wf/attlist02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "attlist03 (Section 3.3.1 [59])" do
  assert_raises(XML::Error, " Comma doesn't separate enumerations, unlike in SGML. (xmlconf/sun/not-wf/attlist03.xml)") do
    File.open("xmlconf/sun/not-wf/attlist03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "attlist04 (Section 3.3.1 [56])" do
  assert_raises(XML::Error, " SGML's NUMBER attribute type is not allowed. (xmlconf/sun/not-wf/attlist04.xml)") do
    File.open("xmlconf/sun/not-wf/attlist04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "attlist05 (Section 3.3.1 [56])" do
  assert_raises(XML::Error, " SGML's NUMBERS attribute type is not allowed. (xmlconf/sun/not-wf/attlist05.xml)") do
    File.open("xmlconf/sun/not-wf/attlist05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "attlist06 (Section 3.3.1 [56])" do
  assert_raises(XML::Error, " SGML's NAME attribute type is not allowed. (xmlconf/sun/not-wf/attlist06.xml)") do
    File.open("xmlconf/sun/not-wf/attlist06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "attlist07 (Section 3.3.1 [56])" do
  assert_raises(XML::Error, " SGML's NAMES attribute type is not allowed. (xmlconf/sun/not-wf/attlist07.xml)") do
    File.open("xmlconf/sun/not-wf/attlist07.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "attlist08 (Section 3.3.1 [56])" do
  assert_raises(XML::Error, " SGML's #CURRENT is not allowed. (xmlconf/sun/not-wf/attlist08.xml)") do
    File.open("xmlconf/sun/not-wf/attlist08.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "attlist09 (Section 3.3.1 [56])" do
  assert_raises(XML::Error, " SGML's #CONREF is not allowed. (xmlconf/sun/not-wf/attlist09.xml)") do
    File.open("xmlconf/sun/not-wf/attlist09.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "attlist10 (Section 3.1 [40])" do
  assert_raises(XML::Error, " Whitespace required between attributes (xmlconf/sun/not-wf/attlist10.xml)") do
    File.open("xmlconf/sun/not-wf/attlist10.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "attlist11 (Section 3.1 [44])" do
  assert_raises(XML::Error, " Whitespace required between attributes (xmlconf/sun/not-wf/attlist11.xml)") do
    File.open("xmlconf/sun/not-wf/attlist11.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "cond01 (Section 3.4 [61])" do
  assert_raises(XML::Error, " Only INCLUDE and IGNORE are conditional section keywords (xmlconf/sun/not-wf/cond01.xml)") do
    File.open("xmlconf/sun/not-wf/cond01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "cond02 (Section 3.4 [61])" do
  assert_raises(XML::Error, " Must have keyword in conditional sections (xmlconf/sun/not-wf/cond02.xml)") do
    File.open("xmlconf/sun/not-wf/cond02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "content01 (Section 3.2.1 [48])" do
  assert_raises(XML::Error, " No whitespace before \"?\" in content model (xmlconf/sun/not-wf/content01.xml)") do
    File.open("xmlconf/sun/not-wf/content01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "content02 (Section 3.2.1 [48])" do
  assert_raises(XML::Error, " No whitespace before \"*\" in content model (xmlconf/sun/not-wf/content02.xml)") do
    File.open("xmlconf/sun/not-wf/content02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "content03 (Section 3.2.1 [48])" do
  assert_raises(XML::Error, " No whitespace before \"+\" in content model (xmlconf/sun/not-wf/content03.xml)") do
    File.open("xmlconf/sun/not-wf/content03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "decl01 (Section 4.3.1 [77])" do
  assert_raises(XML::Error, " External entities may not have standalone decls.  (xmlconf/sun/not-wf/decl01.xml)") do
    File.open("xmlconf/sun/not-wf/decl01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "nwf-dtd00 (Section 3.2.1 [55])" do
  assert_raises(XML::Error, " Comma mandatory in content model (xmlconf/sun/not-wf/dtd00.xml)") do
    File.open("xmlconf/sun/not-wf/dtd00.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "nwf-dtd01 (Section 3.2.1 [55])" do
  assert_raises(XML::Error, " Can't mix comma and vertical bar in content models (xmlconf/sun/not-wf/dtd01.xml)") do
    File.open("xmlconf/sun/not-wf/dtd01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "dtd02 (Section 4.1 [69])" do
  assert_raises(XML::Error, " PE name immediately after \"%\" (xmlconf/sun/not-wf/dtd02.xml)") do
    File.open("xmlconf/sun/not-wf/dtd02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "dtd03 (Section 4.1 [69])" do
  assert_raises(XML::Error, " PE name immediately followed by \";\" (xmlconf/sun/not-wf/dtd03.xml)") do
    File.open("xmlconf/sun/not-wf/dtd03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "dtd04 (Section 4.2.2 [75])" do
  assert_raises(XML::Error, " PUBLIC literal must be quoted (xmlconf/sun/not-wf/dtd04.xml)") do
    File.open("xmlconf/sun/not-wf/dtd04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "dtd05 (Section 4.2.2 [75])" do
  assert_raises(XML::Error, " SYSTEM identifier must be quoted (xmlconf/sun/not-wf/dtd05.xml)") do
    File.open("xmlconf/sun/not-wf/dtd05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "dtd07 (Section 4.3.1 [77])" do
  assert_raises(XML::Error, " Text declarations (which optionally begin any external entity) are required to have \"encoding=...\".  (xmlconf/sun/not-wf/dtd07.xml)") do
    File.open("xmlconf/sun/not-wf/dtd07.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "element00 (Section 3.1 [42])" do
  assert_raises(XML::Error, " EOF in middle of incomplete ETAG (xmlconf/sun/not-wf/element00.xml)") do
    File.open("xmlconf/sun/not-wf/element00.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "element01 (Section 3.1 [42])" do
  assert_raises(XML::Error, " EOF in middle of incomplete ETAG (xmlconf/sun/not-wf/element01.xml)") do
    File.open("xmlconf/sun/not-wf/element01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "element02 (Section 3.1 [43])" do
  assert_raises(XML::Error, " Illegal markup (<%@ ... %>) (xmlconf/sun/not-wf/element02.xml)") do
    File.open("xmlconf/sun/not-wf/element02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "element03 (Section 3.1 [43])" do
  assert_raises(XML::Error, " Illegal markup (<% ... %>) (xmlconf/sun/not-wf/element03.xml)") do
    File.open("xmlconf/sun/not-wf/element03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "element04 (Section 3.1 [43])" do
  assert_raises(XML::Error, " Illegal markup (<!ELEMENT ... >) (xmlconf/sun/not-wf/element04.xml)") do
    File.open("xmlconf/sun/not-wf/element04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "encoding01 (Section 4.3.3 [81])" do
  assert_raises(XML::Error, " Illegal character \" \" in encoding name (xmlconf/sun/not-wf/encoding01.xml)") do
    File.open("xmlconf/sun/not-wf/encoding01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "encoding02 (Section 4.3.3 [81])" do
  assert_raises(XML::Error, " Illegal character \"/\" in encoding name (xmlconf/sun/not-wf/encoding02.xml)") do
    File.open("xmlconf/sun/not-wf/encoding02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "encoding03 (Section 4.3.3 [81])" do
  assert_raises(XML::Error, " Illegal character reference in encoding name (xmlconf/sun/not-wf/encoding03.xml)") do
    File.open("xmlconf/sun/not-wf/encoding03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "encoding04 (Section 4.3.3 [81])" do
  assert_raises(XML::Error, " Illegal character \":\" in encoding name (xmlconf/sun/not-wf/encoding04.xml)") do
    File.open("xmlconf/sun/not-wf/encoding04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "encoding05 (Section 4.3.3 [81])" do
  assert_raises(XML::Error, " Illegal character \"@\" in encoding name (xmlconf/sun/not-wf/encoding05.xml)") do
    File.open("xmlconf/sun/not-wf/encoding05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "encoding06 (Section 4.3.3 [81])" do
  assert_raises(XML::Error, " Illegal character \"+\" in encoding name (xmlconf/sun/not-wf/encoding06.xml)") do
    File.open("xmlconf/sun/not-wf/encoding06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "encoding07 (Section 4.3.1 [77])" do
  assert_raises(XML::Error, " Text declarations (which optionally begin any external entity) are required to have \"encoding=...\".  (xmlconf/sun/not-wf/encoding07.xml)") do
    File.open("xmlconf/sun/not-wf/encoding07.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "pi (Section 2.6 [16])" do
  assert_raises(XML::Error, " No space between PI target name and data (xmlconf/sun/not-wf/pi.xml)") do
    File.open("xmlconf/sun/not-wf/pi.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "pubid01 (Section 2.3 [12])" do
  assert_raises(XML::Error, " Illegal entity ref in public ID (xmlconf/sun/not-wf/pubid01.xml)") do
    File.open("xmlconf/sun/not-wf/pubid01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "pubid02 (Section 2.3 [12])" do
  assert_raises(XML::Error, " Illegal characters in public ID (xmlconf/sun/not-wf/pubid02.xml)") do
    File.open("xmlconf/sun/not-wf/pubid02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "pubid03 (Section 2.3 [12])" do
  assert_raises(XML::Error, " Illegal characters in public ID (xmlconf/sun/not-wf/pubid03.xml)") do
    File.open("xmlconf/sun/not-wf/pubid03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "pubid04 (Section 2.3 [12])" do
  assert_raises(XML::Error, " Illegal characters in public ID (xmlconf/sun/not-wf/pubid04.xml)") do
    File.open("xmlconf/sun/not-wf/pubid04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "pubid05 (Section 2.3 [12])" do
  assert_raises(XML::Error, " SGML-ism: public ID without system ID (xmlconf/sun/not-wf/pubid05.xml)") do
    File.open("xmlconf/sun/not-wf/pubid05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "sgml01 (Section 3 [39])" do
  assert_raises(XML::Error, " SGML-ism: omitted end tag for EMPTY content (xmlconf/sun/not-wf/sgml01.xml)") do
    File.open("xmlconf/sun/not-wf/sgml01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "sgml02 (Section 2.8 )" do
  assert_raises(XML::Error, " XML declaration must be at the very beginning of a document; it\"s not a processing instruction (xmlconf/sun/not-wf/sgml02.xml)") do
    File.open("xmlconf/sun/not-wf/sgml02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "sgml03 (Section 2.5 [15])" do
  assert_raises(XML::Error, " Comments may not contain \"--\" (xmlconf/sun/not-wf/sgml03.xml)") do
    File.open("xmlconf/sun/not-wf/sgml03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "sgml04 (Section 3.3 [52])" do
  assert_raises(XML::Error, " ATTLIST declarations apply to only one element, unlike SGML (xmlconf/sun/not-wf/sgml04.xml)") do
    File.open("xmlconf/sun/not-wf/sgml04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "sgml05 (Section 3.2 [45])" do
  assert_raises(XML::Error, " ELEMENT declarations apply to only one element, unlike SGML (xmlconf/sun/not-wf/sgml05.xml)") do
    File.open("xmlconf/sun/not-wf/sgml05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "sgml06 (Section 3.3 [52])" do
  assert_raises(XML::Error, " ATTLIST declarations are never global, unlike in SGML (xmlconf/sun/not-wf/sgml06.xml)") do
    File.open("xmlconf/sun/not-wf/sgml06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "sgml07 (Section 3.2 [45])" do
  assert_raises(XML::Error, " SGML Tag minimization specifications are not allowed (xmlconf/sun/not-wf/sgml07.xml)") do
    File.open("xmlconf/sun/not-wf/sgml07.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "sgml08 (Section 3.2 [45])" do
  assert_raises(XML::Error, " SGML Tag minimization specifications are not allowed (xmlconf/sun/not-wf/sgml08.xml)") do
    File.open("xmlconf/sun/not-wf/sgml08.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "sgml09 (Section 3.2 [45])" do
  assert_raises(XML::Error, " SGML Content model exception specifications are not allowed (xmlconf/sun/not-wf/sgml09.xml)") do
    File.open("xmlconf/sun/not-wf/sgml09.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "sgml10 (Section 3.2 [45])" do
  assert_raises(XML::Error, " SGML Content model exception specifications are not allowed (xmlconf/sun/not-wf/sgml10.xml)") do
    File.open("xmlconf/sun/not-wf/sgml10.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "sgml11 (Section 3.2 [46])" do
  assert_raises(XML::Error, " CDATA is not a valid content model spec (xmlconf/sun/not-wf/sgml11.xml)") do
    File.open("xmlconf/sun/not-wf/sgml11.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "sgml12 (Section 3.2 [46])" do
  assert_raises(XML::Error, " RCDATA is not a valid content model spec (xmlconf/sun/not-wf/sgml12.xml)") do
    File.open("xmlconf/sun/not-wf/sgml12.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "sgml13 (Section 3.2.1 [47])" do
  assert_raises(XML::Error, " SGML Unordered content models not allowed (xmlconf/sun/not-wf/sgml13.xml)") do
    File.open("xmlconf/sun/not-wf/sgml13.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "uri01 (Section 4.2.2 [75])" do
  assert_raises(" SYSTEM ids may not have URI fragments (xmlconf/sun/not-wf/uri01.xml)") do
    File.open("xmlconf/sun/not-wf/uri01.xml") { |file| XML::DOM.parse(file, base: "xmlconf/sun/not-wf") }
  end
end

end

describe "OASIS/NIST XML 1.0 Tests" do
describe "OASIS/NIST TESTS, 1-Nov-1998" do
it "o-p01pass2 (Section 2.2 [1])" do
  assert_parses("xmlconf/oasis/p01pass2.xml", nil, " various Misc items where they can occur  (xmlconf/oasis/p01pass2.xml)")
end

it "o-p06pass1 (Section 2.3 [6])" do
  assert_parses("xmlconf/oasis/p06pass1.xml", nil, " various satisfactions of the Names production in a NAMES attribute  (xmlconf/oasis/p06pass1.xml)")
end

it "o-p07pass1 (Section 2.3 [7])" do
  assert_parses("xmlconf/oasis/p07pass1.xml", nil, " various valid Nmtoken 's in an attribute list declaration.  (xmlconf/oasis/p07pass1.xml)")
end

it "o-p08pass1 (Section 2.3 [8])" do
  assert_parses("xmlconf/oasis/p08pass1.xml", nil, " various satisfaction of an NMTOKENS attribute value.  (xmlconf/oasis/p08pass1.xml)")
end

it "o-p09pass1 (Section 2.3 [9])" do
  assert_parses("xmlconf/oasis/p09pass1.xml", nil, " valid EntityValue's. Except for entity references, markup is not recognized.  (xmlconf/oasis/p09pass1.xml)")
end

it "o-p12pass1 (Section 2.3 [12])" do
  assert_parses("xmlconf/oasis/p12pass1.xml", nil, " valid public IDs.  (xmlconf/oasis/p12pass1.xml)")
end

it "o-p22pass4 (Section 2.8 [22])" do
  assert_parses("xmlconf/oasis/p22pass4.xml", nil, " XML decl and doctypedecl  (xmlconf/oasis/p22pass4.xml)")
end

it "o-p22pass5 (Section 2.8 [22])" do
  assert_parses("xmlconf/oasis/p22pass5.xml", nil, " just doctypedecl  (xmlconf/oasis/p22pass5.xml)")
end

it "o-p22pass6 (Section 2.8 [22])" do
  assert_parses("xmlconf/oasis/p22pass6.xml", nil, " S between decls is not required  (xmlconf/oasis/p22pass6.xml)")
end

it "o-p28pass1 (Section 3.1 [43] [44])" do
  assert_parses("xmlconf/oasis/p28pass1.xml", nil, " Empty-element tag must be used for element which are declared EMPTY.  (xmlconf/oasis/p28pass1.xml)")
end

it "o-p28pass3 (Section 2.8 4.1 [28] [69])" do
  assert_parses("xmlconf/oasis/p28pass3.xml", nil, " Valid doctypedecl with Parameter entity reference. The declaration of a parameter entity must precede any reference to it.  (xmlconf/oasis/p28pass3.xml)")
end

it "o-p28pass4 (Section 2.8 4.2.2 [28] [75])" do
  assert_parses("xmlconf/oasis/p28pass4.xml", nil, " Valid doctypedecl with ExternalID as an External Entity declaration.  (xmlconf/oasis/p28pass4.xml)")
end

it "o-p28pass5 (Section 2.8 4.1 [28] [69])" do
  assert_parses("xmlconf/oasis/p28pass5.xml", nil, " Valid doctypedecl with ExternalID as an External Entity. A parameter entity reference is also used.  (xmlconf/oasis/p28pass5.xml)")
end

it "o-p29pass1 (Section 2.8 [29])" do
  assert_parses("xmlconf/oasis/p29pass1.xml", nil, " Valid types of markupdecl.  (xmlconf/oasis/p29pass1.xml)")
end

it "o-p30pass1 (Section 2.8 4.2.2 [30] [75])" do
  assert_parses("xmlconf/oasis/p30pass1.xml", nil, " Valid doctypedecl with ExternalID as an External Entity. The external entity has an element declaration.  (xmlconf/oasis/p30pass1.xml)")
end

it "o-p30pass2 (Section 2.8 4.2.2 4.3.1 [30] [75] [77])" do
  assert_parses("xmlconf/oasis/p30pass2.xml", nil, " Valid doctypedecl with ExternalID as an Enternal Entity. The external entity begins with a Text Declaration.  (xmlconf/oasis/p30pass2.xml)")
end

it "o-p31pass1 (Section 2.8 [31])" do
  assert_parses("xmlconf/oasis/p31pass1.xml", nil, " external subset can be empty  (xmlconf/oasis/p31pass1.xml)")
end

it "o-p31pass2 (Section 2.8 3.4 4.2.2 [31] [62] [63] [75])" do
  assert_parses("xmlconf/oasis/p31pass2.xml", nil, " Valid doctypedecl with EXternalID as Enternal Entity. The external entity contains a parameter entity reference and condtional sections. (xmlconf/oasis/p31pass2.xml)")
end

it "o-p43pass1 (Section 2.4 2.5 2.6 2.7 [15] [16] [18])" do
  assert_parses("xmlconf/oasis/p43pass1.xml", nil, " Valid use of character data, comments, processing instructions and CDATA sections within the start and end tag.  (xmlconf/oasis/p43pass1.xml)")
end

it "o-p45pass1 (Section 3.2 [45])" do
  assert_parses("xmlconf/oasis/p45pass1.xml", nil, " valid element declarations  (xmlconf/oasis/p45pass1.xml)")
end

it "o-p46pass1 (Section 3.2 3.2.1 3.2.2 [45] [46] [47] [51])" do
  assert_parses("xmlconf/oasis/p46pass1.xml", nil, " Valid use of contentspec, element content models, and mixed content within an element type declaration.  (xmlconf/oasis/p46pass1.xml)")
end

it "o-p47pass1 (Section 3.2 3.2.1 [45] [46] [47] )" do
  assert_parses("xmlconf/oasis/p47pass1.xml", nil, " Valid use of contentspec, element content models, choices, sequences and content particles within an element type declaration. The optional character following a name or list governs the number of times the element or content particle may appear.  (xmlconf/oasis/p47pass1.xml)")
end

it "o-p48pass1 (Section 3.2 3.2.1 [45] [46] [47])" do
  assert_parses("xmlconf/oasis/p48pass1.xml", nil, " Valid use of contentspec, element content models, choices, sequences and content particles within an element type declaration. The optional character following a name or list governs the number of times the element or content particle may appear.  (xmlconf/oasis/p48pass1.xml)")
end

it "o-p49pass1 (Section 3.2 3.2.1 [45] [46] [47])" do
  assert_parses("xmlconf/oasis/p49pass1.xml", nil, " Valid use of contentspec, element content models, choices, and content particles within an element type declaration. The optional character following a name or list governs the number of times the element or content particle may appear. Whitespace is also valid between choices.  (xmlconf/oasis/p49pass1.xml)")
end

it "o-p50pass1 (Section 3.2 3.2.1 [45] [46] [47])" do
  assert_parses("xmlconf/oasis/p50pass1.xml", nil, " Valid use of contentspec, element content models, sequences and content particles within an element type declaration. The optional character following a name or list governs the number of times the element or content particle may appear. Whitespace is also valid between sequences.  (xmlconf/oasis/p50pass1.xml)")
end

it "o-p51pass1 (Section 3.2.2 [51])" do
  assert_parses("xmlconf/oasis/p51pass1.xml", nil, " valid Mixed contentspec's.  (xmlconf/oasis/p51pass1.xml)")
end

it "o-p52pass1 (Section 3.3 [52])" do
  assert_parses("xmlconf/oasis/p52pass1.xml", nil, " valid AttlistDecls: No AttDef's are required, and the terminating S is optional, multiple ATTLISTS per element are OK, and multiple declarations of the same attribute are OK.  (xmlconf/oasis/p52pass1.xml)")
end

it "o-p53pass1 (Section 3.3 [53])" do
  assert_parses("xmlconf/oasis/p53pass1.xml", nil, " a valid AttDef  (xmlconf/oasis/p53pass1.xml)")
end

it "o-p54pass1 (Section 3.3.1 [54])" do
  assert_parses("xmlconf/oasis/p54pass1.xml", nil, " the three kinds of attribute types  (xmlconf/oasis/p54pass1.xml)")
end

it "o-p55pass1 (Section 3.3.1 [55])" do
  assert_parses("xmlconf/oasis/p55pass1.xml", nil, " StringType = \"CDATA\"  (xmlconf/oasis/p55pass1.xml)")
end

it "o-p56pass1 (Section 3.3.1 [56])" do
  assert_parses("xmlconf/oasis/p56pass1.xml", nil, " the 7 tokenized attribute types  (xmlconf/oasis/p56pass1.xml)")
end

it "o-p57pass1 (Section 3.3.1 [57])" do
  assert_parses("xmlconf/oasis/p57pass1.xml", nil, " enumerated types are NMTOKEN or NOTATION lists  (xmlconf/oasis/p57pass1.xml)")
end

it "o-p58pass1 (Section 3.3.1 [58])" do
  assert_parses("xmlconf/oasis/p58pass1.xml", nil, " NOTATION enumeration has on or more items  (xmlconf/oasis/p58pass1.xml)")
end

it "o-p59pass1 (Section 3.3.1 [59])" do
  assert_parses("xmlconf/oasis/p59pass1.xml", nil, " NMTOKEN enumerations haveon or more items  (xmlconf/oasis/p59pass1.xml)")
end

it "o-p60pass1 (Section 3.3.2 [60])" do
  assert_parses("xmlconf/oasis/p60pass1.xml", nil, " the four types of default values  (xmlconf/oasis/p60pass1.xml)")
end

it "o-p61pass1 (Section 3.4 [61])" do
  assert_parses("xmlconf/oasis/p61pass1.xml", nil, " valid conditional sections are INCLUDE and IGNORE  (xmlconf/oasis/p61pass1.xml)")
end

it "o-p62pass1 (Section 3.4 [62])" do
  assert_parses("xmlconf/oasis/p62pass1.xml", nil, " valid INCLUDE sections -- options S before and after keyword, sections can nest  (xmlconf/oasis/p62pass1.xml)")
end

it "o-p63pass1 (Section 3.4 [63])" do
  assert_parses("xmlconf/oasis/p63pass1.xml", nil, " valid IGNORE sections  (xmlconf/oasis/p63pass1.xml)")
end

it "o-p64pass1 (Section 3.4 [64])" do
  assert_parses("xmlconf/oasis/p64pass1.xml", nil, " IGNOREd sections ignore everything except section delimiters  (xmlconf/oasis/p64pass1.xml)")
end

it "o-p68pass1 (Section 4.1 [68])" do
  assert_parses("xmlconf/oasis/p68pass1.xml", nil, " Valid entity references. Also ensures that a charref to '&' isn't interpreted as an entity reference open delimiter  (xmlconf/oasis/p68pass1.xml)")
end

it "o-p69pass1 (Section 4.1 [69])" do
  assert_parses("xmlconf/oasis/p69pass1.xml", nil, " Valid PEReferences.  (xmlconf/oasis/p69pass1.xml)")
end

it "o-p70pass1 (Section 4.2 [70])" do
  assert_parses("xmlconf/oasis/p70pass1.xml", nil, " An EntityDecl is either a GEDecl or a PEDecl  (xmlconf/oasis/p70pass1.xml)")
end

it "o-p71pass1 (Section 4.2 [71])" do
  assert_parses("xmlconf/oasis/p71pass1.xml", nil, " Valid GEDecls  (xmlconf/oasis/p71pass1.xml)")
end

it "o-p72pass1 (Section 4.2 [72])" do
  assert_parses("xmlconf/oasis/p72pass1.xml", nil, " Valid PEDecls  (xmlconf/oasis/p72pass1.xml)")
end

it "o-p73pass1 (Section 4.2 [73])" do
  assert_parses("xmlconf/oasis/p73pass1.xml", nil, " EntityDef is either Entity value or an external id, with an optional NDataDecl  (xmlconf/oasis/p73pass1.xml)")
end

it "o-p76pass1 (Section 4.2.2 [76])" do
  assert_parses("xmlconf/oasis/p76pass1.xml", nil, " valid NDataDecls  (xmlconf/oasis/p76pass1.xml)")
end

it "o-p01pass1 (Section 2.1 [1])" do
  assert_parses("xmlconf/oasis/p01pass1.xml", nil, " no prolog  (xmlconf/oasis/p01pass1.xml)")
end

it "o-p01pass3 (Section 2.1 [1])" do
  assert_parses("xmlconf/oasis/p01pass3.xml", nil, " Misc items after the document  (xmlconf/oasis/p01pass3.xml)")
end

it "o-p03pass1 (Section 2.3 [3])" do
  assert_parses("xmlconf/oasis/p03pass1.xml", nil, " all valid S characters  (xmlconf/oasis/p03pass1.xml)")
end

it "o-p04pass1 (Section 2.3 [4])" do
  assert_parses("xmlconf/oasis/p04pass1.xml", nil, " names with all valid ASCII characters, and one from each other class in NameChar  (xmlconf/oasis/p04pass1.xml)")
end

it "o-p05pass1 (Section 2.3 [5])" do
  assert_parses("xmlconf/oasis/p05pass1.xml", nil, " various valid Name constructions  (xmlconf/oasis/p05pass1.xml)")
end

it "o-p06fail1 (Section 2.3 [6])" do
  assert_parses("xmlconf/oasis/p06fail1.xml", nil, " Requires at least one name.  (xmlconf/oasis/p06fail1.xml)")
end

it "o-p08fail1 (Section 2.3 [8])" do
  assert_parses("xmlconf/oasis/p08fail1.xml", nil, " at least one Nmtoken is required.  (xmlconf/oasis/p08fail1.xml)")
end

it "o-p08fail2 (Section 2.3 [8])" do
  assert_parses("xmlconf/oasis/p08fail2.xml", nil, " an invalid Nmtoken character.  (xmlconf/oasis/p08fail2.xml)")
end

it "o-p10pass1 (Section 2.3 [10])" do
  assert_parses("xmlconf/oasis/p10pass1.xml", nil, " valid attribute values  (xmlconf/oasis/p10pass1.xml)")
end

it "o-p14pass1 (Section 2.4 [14])" do
  assert_parses("xmlconf/oasis/p14pass1.xml", nil, " valid CharData  (xmlconf/oasis/p14pass1.xml)")
end

it "o-p15pass1 (Section 2.5 [15])" do
  assert_parses("xmlconf/oasis/p15pass1.xml", nil, " valid comments  (xmlconf/oasis/p15pass1.xml)")
end

it "o-p16pass1 (Section 2.6 [16] [17])" do
  assert_parses("xmlconf/oasis/p16pass1.xml", nil, " Valid form of Processing Instruction. Shows that whitespace character data is valid before end of processing instruction.  (xmlconf/oasis/p16pass1.xml)")
end

it "o-p16pass2 (Section 2.6 [16])" do
  assert_parses("xmlconf/oasis/p16pass2.xml", nil, " Valid form of Processing Instruction. Shows that whitespace character data is valid before end of processing instruction.  (xmlconf/oasis/p16pass2.xml)")
end

it "o-p16pass3 (Section 2.6 [16])" do
  assert_parses("xmlconf/oasis/p16pass3.xml", nil, " Valid form of Processing Instruction. Shows that whitespace character data is valid before end of processing instruction.  (xmlconf/oasis/p16pass3.xml)")
end

it "o-p18pass1 (Section 2.7 [18])" do
  assert_parses("xmlconf/oasis/p18pass1.xml", nil, " valid CDSect's. Note that a CDStart in a CDSect is not recognized as such  (xmlconf/oasis/p18pass1.xml)")
end

it "o-p22pass1 (Section 2.8 [22])" do
  assert_parses("xmlconf/oasis/p22pass1.xml", nil, " prolog can be empty  (xmlconf/oasis/p22pass1.xml)")
end

it "o-p22pass2 (Section 2.8 [22])" do
  assert_parses("xmlconf/oasis/p22pass2.xml", nil, " XML declaration only  (xmlconf/oasis/p22pass2.xml)")
end

it "o-p22pass3 (Section 2.8 [22])" do
  assert_parses("xmlconf/oasis/p22pass3.xml", nil, " XML decl and Misc  (xmlconf/oasis/p22pass3.xml)")
end

it "o-p23pass1 (Section 2.8 [23])" do
  assert_parses("xmlconf/oasis/p23pass1.xml", nil, " Test shows a valid XML declaration along with version info.  (xmlconf/oasis/p23pass1.xml)")
end

it "o-p23pass2 (Section 2.8 [23])" do
  assert_parses("xmlconf/oasis/p23pass2.xml", nil, " Test shows a valid XML declaration along with encoding declaration.  (xmlconf/oasis/p23pass2.xml)")
end

it "o-p23pass3 (Section 2.8 [23])" do
  assert_parses("xmlconf/oasis/p23pass3.xml", nil, " Test shows a valid XML declaration along with Standalone Document Declaration.  (xmlconf/oasis/p23pass3.xml)")
end

it "o-p23pass4 (Section 2.8 [23])" do
  assert_parses("xmlconf/oasis/p23pass4.xml", nil, " Test shows a valid XML declaration, encoding declarationand Standalone Document Declaration.  (xmlconf/oasis/p23pass4.xml)")
end

it "o-p24pass1 (Section 2.8 [24])" do
  assert_parses("xmlconf/oasis/p24pass1.xml", nil, " Test shows a prolog that has the VersionInfo delimited by double quotes.  (xmlconf/oasis/p24pass1.xml)")
end

it "o-p24pass2 (Section 2.8 [24])" do
  assert_parses("xmlconf/oasis/p24pass2.xml", nil, " Test shows a prolog that has the VersionInfo delimited by single quotes.  (xmlconf/oasis/p24pass2.xml)")
end

it "o-p24pass3 (Section 2.8 [24])" do
  assert_parses("xmlconf/oasis/p24pass3.xml", nil, " Test shows whitespace is allowed in prolog before version info.  (xmlconf/oasis/p24pass3.xml)")
end

it "o-p24pass4 (Section 2.8 [24])" do
  assert_parses("xmlconf/oasis/p24pass4.xml", nil, " Test shows whitespace is allowed in prolog on both sides of equal sign.  (xmlconf/oasis/p24pass4.xml)")
end

it "o-p25pass1 (Section 2.8 [25])" do
  assert_parses("xmlconf/oasis/p25pass1.xml", nil, " Test shows whitespace is NOT necessary before or after equal sign of versioninfo.  (xmlconf/oasis/p25pass1.xml)")
end

it "o-p25pass2 (Section 2.8 [25])" do
  assert_parses("xmlconf/oasis/p25pass2.xml", nil, " Test shows whitespace can be used on both sides of equal sign of versioninfo.  (xmlconf/oasis/p25pass2.xml)")
end

it "o-p26pass1 (Section 2.8 [26])" do
  assert_parses("xmlconf/oasis/p26pass1.xml", nil, " The valid version number. We cannot test others because a 1.0 processor is allowed to fail them.  (xmlconf/oasis/p26pass1.xml)")
end

it "o-p27pass1 (Section 2.8 [27])" do
  assert_parses("xmlconf/oasis/p27pass1.xml", nil, " Comments are valid as the Misc part of the prolog.  (xmlconf/oasis/p27pass1.xml)")
end

it "o-p27pass2 (Section 2.8 [27])" do
  assert_parses("xmlconf/oasis/p27pass2.xml", nil, " Processing Instructions are valid as the Misc part of the prolog.  (xmlconf/oasis/p27pass2.xml)")
end

it "o-p27pass3 (Section 2.8 [27])" do
  assert_parses("xmlconf/oasis/p27pass3.xml", nil, " Whitespace is valid as the Misc part of the prolog.  (xmlconf/oasis/p27pass3.xml)")
end

it "o-p27pass4 (Section 2.8 [27])" do
  assert_parses("xmlconf/oasis/p27pass4.xml", nil, " A combination of comments, whitespaces and processing instructions are valid as the Misc part of the prolog.  (xmlconf/oasis/p27pass4.xml)")
end

it "o-p32pass1 (Section 2.9 [32])" do
  assert_parses("xmlconf/oasis/p32pass1.xml", nil, " Double quotes can be used as delimeters for the value of a Standalone Document Declaration.  (xmlconf/oasis/p32pass1.xml)")
end

it "o-p32pass2 (Section 2.9 [32])" do
  assert_parses("xmlconf/oasis/p32pass2.xml", nil, " Single quotes can be used as delimeters for the value of a Standalone Document Declaration.  (xmlconf/oasis/p32pass2.xml)")
end

it "o-p39pass1 (Section 3 3.1 [39] [44])" do
  assert_parses("xmlconf/oasis/p39pass1.xml", nil, " Empty element tag may be used for any element which has no content.  (xmlconf/oasis/p39pass1.xml)")
end

it "o-p39pass2 (Section 3 3.1 [39] [43])" do
  assert_parses("xmlconf/oasis/p39pass2.xml", nil, " Character data is valid element content.  (xmlconf/oasis/p39pass2.xml)")
end

it "o-p40pass1 (Section 3.1 [40])" do
  assert_parses("xmlconf/oasis/p40pass1.xml", nil, " Elements content can be empty.  (xmlconf/oasis/p40pass1.xml)")
end

it "o-p40pass2 (Section 3.1 [40])" do
  assert_parses("xmlconf/oasis/p40pass2.xml", nil, " Whitespace is valid within a Start-tag.  (xmlconf/oasis/p40pass2.xml)")
end

it "o-p40pass3 (Section 3.1 [40] [41])" do
  assert_parses("xmlconf/oasis/p40pass3.xml", nil, " Attributes are valid within a Start-tag.  (xmlconf/oasis/p40pass3.xml)")
end

it "o-p40pass4 (Section 3.1 [40])" do
  assert_parses("xmlconf/oasis/p40pass4.xml", nil, " Whitespace and Multiple Attributes are valid within a Start-tag.  (xmlconf/oasis/p40pass4.xml)")
end

it "o-p41pass1 (Section 3.1 [41])" do
  assert_parses("xmlconf/oasis/p41pass1.xml", nil, " Attributes are valid within a Start-tag.  (xmlconf/oasis/p41pass1.xml)")
end

it "o-p41pass2 (Section 3.1 [41])" do
  assert_parses("xmlconf/oasis/p41pass2.xml", nil, " Whitespace is valid within a Start-tags Attribute.  (xmlconf/oasis/p41pass2.xml)")
end

it "o-p42pass1 (Section 3.1 [42])" do
  assert_parses("xmlconf/oasis/p42pass1.xml", nil, " Test shows proper syntax for an End-tag.  (xmlconf/oasis/p42pass1.xml)")
end

it "o-p42pass2 (Section 3.1 [42])" do
  assert_parses("xmlconf/oasis/p42pass2.xml", nil, " Whitespace is valid after name in End-tag.  (xmlconf/oasis/p42pass2.xml)")
end

it "o-p44pass1 (Section 3.1 [44])" do
  assert_parses("xmlconf/oasis/p44pass1.xml", nil, " Valid display of an Empty Element Tag.  (xmlconf/oasis/p44pass1.xml)")
end

it "o-p44pass2 (Section 3.1 [44])" do
  assert_parses("xmlconf/oasis/p44pass2.xml", nil, " Empty Element Tags can contain an Attribute.  (xmlconf/oasis/p44pass2.xml)")
end

it "o-p44pass3 (Section 3.1 [44])" do
  assert_parses("xmlconf/oasis/p44pass3.xml", nil, " Whitespace is valid in an Empty Element Tag following the end of the attribute value.  (xmlconf/oasis/p44pass3.xml)")
end

it "o-p44pass4 (Section 3.1 [44])" do
  assert_parses("xmlconf/oasis/p44pass4.xml", nil, " Whitespace is valid after the name in an Empty Element Tag.  (xmlconf/oasis/p44pass4.xml)")
end

it "o-p44pass5 (Section 3.1 [44])" do
  assert_parses("xmlconf/oasis/p44pass5.xml", nil, " Whitespace and Multiple Attributes are valid in an Empty Element Tag.  (xmlconf/oasis/p44pass5.xml)")
end

it "o-p66pass1 (Section 4.1 [66])" do
  assert_parses("xmlconf/oasis/p66pass1.xml", nil, " valid character references  (xmlconf/oasis/p66pass1.xml)")
end

it "o-p74pass1 (Section 4.2 [74])" do
  assert_parses("xmlconf/oasis/p74pass1.xml", nil, " PEDef is either an entity value or an external id  (xmlconf/oasis/p74pass1.xml)")
end

it "o-p75pass1 (Section 4.2.2 [75])" do
  assert_parses("xmlconf/oasis/p75pass1.xml", nil, " valid external identifiers  (xmlconf/oasis/p75pass1.xml)")
end

it "o-e2 (Section 3.3.1 [58] [59] Errata [E2])" do
  assert_parses("xmlconf/oasis/e2.xml", nil, " Validity Constraint: No duplicate tokens  (xmlconf/oasis/e2.xml)")
end

it "o-p01fail1 (Section 2.1 [1])" do
  assert_raises(XML::Error, " S cannot occur before the prolog  (xmlconf/oasis/p01fail1.xml)") do
    File.open("xmlconf/oasis/p01fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p01fail2 (Section 2.1 [1])" do
  assert_raises(XML::Error, " comments cannot occur before the prolog  (xmlconf/oasis/p01fail2.xml)") do
    File.open("xmlconf/oasis/p01fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p01fail3 (Section 2.1 [1])" do
  assert_raises(XML::Error, " only one document element  (xmlconf/oasis/p01fail3.xml)") do
    File.open("xmlconf/oasis/p01fail3.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p01fail4 (Section 2.1 [1])" do
  assert_raises(XML::Error, " document element must be complete.  (xmlconf/oasis/p01fail4.xml)") do
    File.open("xmlconf/oasis/p01fail4.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p02fail1 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p02fail1.xml)") do
    File.open("xmlconf/oasis/p02fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p02fail10 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p02fail10.xml)") do
    File.open("xmlconf/oasis/p02fail10.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p02fail11 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p02fail11.xml)") do
    File.open("xmlconf/oasis/p02fail11.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p02fail12 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p02fail12.xml)") do
    File.open("xmlconf/oasis/p02fail12.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p02fail13 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p02fail13.xml)") do
    File.open("xmlconf/oasis/p02fail13.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p02fail14 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p02fail14.xml)") do
    File.open("xmlconf/oasis/p02fail14.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p02fail15 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p02fail15.xml)") do
    File.open("xmlconf/oasis/p02fail15.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p02fail16 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p02fail16.xml)") do
    File.open("xmlconf/oasis/p02fail16.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p02fail17 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p02fail17.xml)") do
    File.open("xmlconf/oasis/p02fail17.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p02fail18 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p02fail18.xml)") do
    File.open("xmlconf/oasis/p02fail18.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p02fail19 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p02fail19.xml)") do
    File.open("xmlconf/oasis/p02fail19.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p02fail2 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p02fail2.xml)") do
    File.open("xmlconf/oasis/p02fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p02fail20 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p02fail20.xml)") do
    File.open("xmlconf/oasis/p02fail20.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p02fail21 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p02fail21.xml)") do
    File.open("xmlconf/oasis/p02fail21.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p02fail22 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p02fail22.xml)") do
    File.open("xmlconf/oasis/p02fail22.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p02fail23 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p02fail23.xml)") do
    File.open("xmlconf/oasis/p02fail23.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p02fail24 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p02fail24.xml)") do
    File.open("xmlconf/oasis/p02fail24.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p02fail25 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p02fail25.xml)") do
    File.open("xmlconf/oasis/p02fail25.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p02fail26 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p02fail26.xml)") do
    File.open("xmlconf/oasis/p02fail26.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p02fail27 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p02fail27.xml)") do
    File.open("xmlconf/oasis/p02fail27.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p02fail28 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p02fail28.xml)") do
    File.open("xmlconf/oasis/p02fail28.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p02fail29 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p02fail29.xml)") do
    File.open("xmlconf/oasis/p02fail29.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p02fail3 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p02fail3.xml)") do
    File.open("xmlconf/oasis/p02fail3.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p02fail30 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p02fail30.xml)") do
    File.open("xmlconf/oasis/p02fail30.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p02fail31 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p02fail31.xml)") do
    File.open("xmlconf/oasis/p02fail31.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p02fail4 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p02fail4.xml)") do
    File.open("xmlconf/oasis/p02fail4.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p02fail5 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p02fail5.xml)") do
    File.open("xmlconf/oasis/p02fail5.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p02fail6 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p02fail6.xml)") do
    File.open("xmlconf/oasis/p02fail6.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p02fail7 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p02fail7.xml)") do
    File.open("xmlconf/oasis/p02fail7.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p02fail8 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p02fail8.xml)") do
    File.open("xmlconf/oasis/p02fail8.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p02fail9 (Section 2.2 [2])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p02fail9.xml)") do
    File.open("xmlconf/oasis/p02fail9.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p03fail1 (Section 2.3 [3])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p03fail1.xml)") do
    File.open("xmlconf/oasis/p03fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p03fail10 (Section 2.3 [3])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p03fail10.xml)") do
    File.open("xmlconf/oasis/p03fail10.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p03fail11 (Section 2.3 [3])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p03fail11.xml)") do
    File.open("xmlconf/oasis/p03fail11.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p03fail12 (Section 2.3 [3])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p03fail12.xml)") do
    File.open("xmlconf/oasis/p03fail12.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p03fail13 (Section 2.3 [3])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p03fail13.xml)") do
    File.open("xmlconf/oasis/p03fail13.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p03fail14 (Section 2.3 [3])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p03fail14.xml)") do
    File.open("xmlconf/oasis/p03fail14.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p03fail15 (Section 2.3 [3])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p03fail15.xml)") do
    File.open("xmlconf/oasis/p03fail15.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p03fail16 (Section 2.3 [3])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p03fail16.xml)") do
    File.open("xmlconf/oasis/p03fail16.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p03fail17 (Section 2.3 [3])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p03fail17.xml)") do
    File.open("xmlconf/oasis/p03fail17.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p03fail18 (Section 2.3 [3])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p03fail18.xml)") do
    File.open("xmlconf/oasis/p03fail18.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p03fail19 (Section 2.3 [3])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p03fail19.xml)") do
    File.open("xmlconf/oasis/p03fail19.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p03fail2 (Section 2.3 [3])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p03fail2.xml)") do
    File.open("xmlconf/oasis/p03fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p03fail20 (Section 2.3 [3])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p03fail20.xml)") do
    File.open("xmlconf/oasis/p03fail20.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p03fail21 (Section 2.3 [3])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p03fail21.xml)") do
    File.open("xmlconf/oasis/p03fail21.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p03fail22 (Section 2.3 [3])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p03fail22.xml)") do
    File.open("xmlconf/oasis/p03fail22.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p03fail23 (Section 2.3 [3])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p03fail23.xml)") do
    File.open("xmlconf/oasis/p03fail23.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p03fail24 (Section 2.3 [3])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p03fail24.xml)") do
    File.open("xmlconf/oasis/p03fail24.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p03fail25 (Section 2.3 [3])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p03fail25.xml)") do
    File.open("xmlconf/oasis/p03fail25.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p03fail26 (Section 2.3 [3])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p03fail26.xml)") do
    File.open("xmlconf/oasis/p03fail26.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p03fail27 (Section 2.3 [3])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p03fail27.xml)") do
    File.open("xmlconf/oasis/p03fail27.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p03fail28 (Section 2.3 [3])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p03fail28.xml)") do
    File.open("xmlconf/oasis/p03fail28.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p03fail29 (Section 2.3 [3])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p03fail29.xml)") do
    File.open("xmlconf/oasis/p03fail29.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p03fail3 (Section 2.3 [3])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p03fail3.xml)") do
    File.open("xmlconf/oasis/p03fail3.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p03fail4 (Section 2.3 [3])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p03fail4.xml)") do
    File.open("xmlconf/oasis/p03fail4.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p03fail5 (Section 2.3 [3])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p03fail5.xml)") do
    File.open("xmlconf/oasis/p03fail5.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p03fail7 (Section 2.3 [3])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p03fail7.xml)") do
    File.open("xmlconf/oasis/p03fail7.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p03fail8 (Section 2.3 [3])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p03fail8.xml)") do
    File.open("xmlconf/oasis/p03fail8.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p03fail9 (Section 2.3 [3])" do
  assert_raises(XML::Error, " Use of illegal character within XML document.  (xmlconf/oasis/p03fail9.xml)") do
    File.open("xmlconf/oasis/p03fail9.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p04fail1 (Section 2.3 [4])" do
  assert_raises(XML::Error, " Name contains invalid character.  (xmlconf/oasis/p04fail1.xml)") do
    File.open("xmlconf/oasis/p04fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p04fail2 (Section 2.3 [4])" do
  assert_raises(XML::Error, " Name contains invalid character.  (xmlconf/oasis/p04fail2.xml)") do
    File.open("xmlconf/oasis/p04fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p04fail3 (Section 2.3 [4])" do
  assert_raises(XML::Error, " Name contains invalid character.  (xmlconf/oasis/p04fail3.xml)") do
    File.open("xmlconf/oasis/p04fail3.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p05fail1 (Section 2.3 [5])" do
  assert_raises(XML::Error, " a Name cannot start with a digit  (xmlconf/oasis/p05fail1.xml)") do
    File.open("xmlconf/oasis/p05fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p05fail2 (Section 2.3 [5])" do
  assert_raises(XML::Error, " a Name cannot start with a '.'  (xmlconf/oasis/p05fail2.xml)") do
    File.open("xmlconf/oasis/p05fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p05fail3 (Section 2.3 [5])" do
  assert_raises(XML::Error, " a Name cannot start with a \"-\"  (xmlconf/oasis/p05fail3.xml)") do
    File.open("xmlconf/oasis/p05fail3.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p05fail4 (Section 2.3 [5])" do
  assert_raises(XML::Error, " a Name cannot start with a CombiningChar  (xmlconf/oasis/p05fail4.xml)") do
    File.open("xmlconf/oasis/p05fail4.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p05fail5 (Section 2.3 [5])" do
  assert_raises(XML::Error, " a Name cannot start with an Extender  (xmlconf/oasis/p05fail5.xml)") do
    File.open("xmlconf/oasis/p05fail5.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p09fail1 (Section 2.3 [9])" do
  assert_raises(XML::Error, " EntityValue excludes '%'  (xmlconf/oasis/p09fail1.xml)") do
    File.open("xmlconf/oasis/p09fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p09fail2 (Section 2.3 [9])" do
  assert_raises(XML::Error, " EntityValue excludes '&'  (xmlconf/oasis/p09fail2.xml)") do
    File.open("xmlconf/oasis/p09fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p09fail3 (Section 2.3 [9])" do
  assert_raises(XML::Error, " incomplete character reference  (xmlconf/oasis/p09fail3.xml)") do
    File.open("xmlconf/oasis/p09fail3.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p09fail4 (Section 2.3 [9])" do
  assert_raises(XML::Error, " quote types must match  (xmlconf/oasis/p09fail4.xml)") do
    File.open("xmlconf/oasis/p09fail4.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p09fail5 (Section 2.3 [9])" do
  assert_raises(XML::Error, " quote types must match  (xmlconf/oasis/p09fail5.xml)") do
    File.open("xmlconf/oasis/p09fail5.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p10fail1 (Section 2.3 [10])" do
  assert_raises(XML::Error, " attribute values exclude '<'  (xmlconf/oasis/p10fail1.xml)") do
    File.open("xmlconf/oasis/p10fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p10fail2 (Section 2.3 [10])" do
  assert_raises(XML::Error, " attribute values exclude '&'  (xmlconf/oasis/p10fail2.xml)") do
    File.open("xmlconf/oasis/p10fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p10fail3 (Section 2.3 [10])" do
  assert_raises(XML::Error, " quote types must match  (xmlconf/oasis/p10fail3.xml)") do
    File.open("xmlconf/oasis/p10fail3.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p11fail1 (Section 2.3 [11])" do
  assert_raises(XML::Error, " quote types must match  (xmlconf/oasis/p11fail1.xml)") do
    File.open("xmlconf/oasis/p11fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p11fail2 (Section 2.3 [11])" do
  assert_raises(XML::Error, " cannot contain delimiting quotes  (xmlconf/oasis/p11fail2.xml)") do
    File.open("xmlconf/oasis/p11fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p12fail1 (Section 2.3 [12])" do
  assert_raises(XML::Error, " '\"' excluded  (xmlconf/oasis/p12fail1.xml)") do
    File.open("xmlconf/oasis/p12fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p12fail2 (Section 2.3 [12])" do
  assert_raises(XML::Error, " '\\' excluded  (xmlconf/oasis/p12fail2.xml)") do
    File.open("xmlconf/oasis/p12fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p12fail3 (Section 2.3 [12])" do
  assert_raises(XML::Error, " entity references excluded  (xmlconf/oasis/p12fail3.xml)") do
    File.open("xmlconf/oasis/p12fail3.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p12fail4 (Section 2.3 [12])" do
  assert_raises(XML::Error, " '>' excluded  (xmlconf/oasis/p12fail4.xml)") do
    File.open("xmlconf/oasis/p12fail4.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p12fail5 (Section 2.3 [12])" do
  assert_raises(XML::Error, " '<' excluded  (xmlconf/oasis/p12fail5.xml)") do
    File.open("xmlconf/oasis/p12fail5.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p12fail6 (Section 2.3 [12])" do
  assert_raises(XML::Error, " built-in entity refs excluded  (xmlconf/oasis/p12fail6.xml)") do
    File.open("xmlconf/oasis/p12fail6.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p12fail7 (Section 2.3 [13])" do
  assert_raises(XML::Error, " The public ID has a tab character, which is disallowed  (xmlconf/oasis/p12fail7.xml)") do
    File.open("xmlconf/oasis/p12fail7.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p14fail1 (Section 2.4 [14])" do
  assert_raises(XML::Error, " '<' excluded  (xmlconf/oasis/p14fail1.xml)") do
    File.open("xmlconf/oasis/p14fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p14fail2 (Section 2.4 [14])" do
  assert_raises(XML::Error, " '&' excluded  (xmlconf/oasis/p14fail2.xml)") do
    File.open("xmlconf/oasis/p14fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p14fail3 (Section 2.4 [14])" do
  assert_raises(XML::Error, " \"]]>\" excluded  (xmlconf/oasis/p14fail3.xml)") do
    File.open("xmlconf/oasis/p14fail3.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p15fail1 (Section 2.5 [15])" do
  assert_raises(XML::Error, " comments can't end in '-'  (xmlconf/oasis/p15fail1.xml)") do
    File.open("xmlconf/oasis/p15fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p15fail2 (Section 2.5 [15])" do
  assert_raises(XML::Error, " one comment per comment (contrasted with SGML)  (xmlconf/oasis/p15fail2.xml)") do
    File.open("xmlconf/oasis/p15fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p15fail3 (Section 2.5 [15])" do
  assert_raises(XML::Error, " can't include 2 or more adjacent '-'s  (xmlconf/oasis/p15fail3.xml)") do
    File.open("xmlconf/oasis/p15fail3.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p16fail1 (Section 2.6 [16])" do
  assert_raises(XML::Error, " \"xml\" is an invalid PITarget  (xmlconf/oasis/p16fail1.xml)") do
    File.open("xmlconf/oasis/p16fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p16fail2 (Section 2.6 [16])" do
  assert_raises(XML::Error, " a PITarget must be present  (xmlconf/oasis/p16fail2.xml)") do
    File.open("xmlconf/oasis/p16fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p16fail3 (Section 2.6 [16])" do
  assert_raises(XML::Error, " S after PITarget is required  (xmlconf/oasis/p16fail3.xml)") do
    File.open("xmlconf/oasis/p16fail3.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p18fail1 (Section 2.7 [18])" do
  assert_raises(XML::Error, " no space before \"CDATA\"  (xmlconf/oasis/p18fail1.xml)") do
    File.open("xmlconf/oasis/p18fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p18fail2 (Section 2.7 [18])" do
  assert_raises(XML::Error, " no space after \"CDATA\"  (xmlconf/oasis/p18fail2.xml)") do
    File.open("xmlconf/oasis/p18fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p18fail3 (Section 2.7 [18])" do
  assert_raises(XML::Error, " CDSect's can't nest  (xmlconf/oasis/p18fail3.xml)") do
    File.open("xmlconf/oasis/p18fail3.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p22fail1 (Section 2.8 [22])" do
  assert_raises(XML::Error, " prolog must start with XML decl  (xmlconf/oasis/p22fail1.xml)") do
    File.open("xmlconf/oasis/p22fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p22fail2 (Section 2.8 [22])" do
  assert_raises(XML::Error, " prolog must start with XML decl  (xmlconf/oasis/p22fail2.xml)") do
    File.open("xmlconf/oasis/p22fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p23fail1 (Section 2.8 [23])" do
  assert_raises(XML::Error, " \"xml\" must be lower-case  (xmlconf/oasis/p23fail1.xml)") do
    File.open("xmlconf/oasis/p23fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p23fail2 (Section 2.8 [23])" do
  assert_raises(XML::Error, " VersionInfo must be supplied  (xmlconf/oasis/p23fail2.xml)") do
    File.open("xmlconf/oasis/p23fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p23fail3 (Section 2.8 [23])" do
  assert_raises(XML::Error, " VersionInfo must come first  (xmlconf/oasis/p23fail3.xml)") do
    File.open("xmlconf/oasis/p23fail3.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p23fail4 (Section 2.8 [23])" do
  assert_raises(XML::Error, " SDDecl must come last  (xmlconf/oasis/p23fail4.xml)") do
    File.open("xmlconf/oasis/p23fail4.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p23fail5 (Section 2.8 [23])" do
  assert_raises(XML::Error, " no SGML-type PIs  (xmlconf/oasis/p23fail5.xml)") do
    File.open("xmlconf/oasis/p23fail5.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p24fail1 (Section 2.8 [24])" do
  assert_raises(XML::Error, " quote types must match  (xmlconf/oasis/p24fail1.xml)") do
    File.open("xmlconf/oasis/p24fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p24fail2 (Section 2.8 [24])" do
  assert_raises(XML::Error, " quote types must match  (xmlconf/oasis/p24fail2.xml)") do
    File.open("xmlconf/oasis/p24fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p25fail1 (Section 2.8 [25])" do
  assert_raises(XML::Error, " Comment is illegal in VersionInfo.  (xmlconf/oasis/p25fail1.xml)") do
    File.open("xmlconf/oasis/p25fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p26fail1 (Section 2.8 [26])" do
  assert_raises(XML::Error, " Illegal character in VersionNum.  (xmlconf/oasis/p26fail1.xml)") do
    File.open("xmlconf/oasis/p26fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p26fail2 (Section 2.8 [26])" do
  assert_raises(XML::Error, " Illegal character in VersionNum.  (xmlconf/oasis/p26fail2.xml)") do
    File.open("xmlconf/oasis/p26fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p27fail1 (Section 2.8 [27])" do
  assert_raises(XML::Error, " References aren't allowed in Misc, even if they would resolve to valid Misc.  (xmlconf/oasis/p27fail1.xml)") do
    File.open("xmlconf/oasis/p27fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p28fail1 (Section 2.8 [28])" do
  assert_raises(XML::Error, " only declarations in DTD.  (xmlconf/oasis/p28fail1.xml)") do
    File.open("xmlconf/oasis/p28fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p29fail1 (Section 2.8 [29])" do
  assert_raises(XML::Error, " A processor must not pass unknown declaration types.  (xmlconf/oasis/p29fail1.xml)") do
    File.open("xmlconf/oasis/p29fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p30fail1 (Section 2.8 [30])" do
  assert_raises(XML::Error, " An XML declaration is not the same as a TextDecl  (xmlconf/oasis/p30fail1.xml)") do
    File.open("xmlconf/oasis/p30fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p31fail1 (Section 2.8 [31])" do
  assert_raises(XML::Error, " external subset excludes doctypedecl  (xmlconf/oasis/p31fail1.xml)") do
    File.open("xmlconf/oasis/p31fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p32fail1 (Section 2.9 [32])" do
  assert_raises(XML::Error, " quote types must match  (xmlconf/oasis/p32fail1.xml)") do
    File.open("xmlconf/oasis/p32fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p32fail2 (Section 2.9 [32])" do
  assert_raises(XML::Error, " quote types must match  (xmlconf/oasis/p32fail2.xml)") do
    File.open("xmlconf/oasis/p32fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p32fail3 (Section 2.9 [32])" do
  assert_raises(XML::Error, " initial S is required  (xmlconf/oasis/p32fail3.xml)") do
    File.open("xmlconf/oasis/p32fail3.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p32fail4 (Section 2.9 [32])" do
  assert_raises(XML::Error, " quotes are required  (xmlconf/oasis/p32fail4.xml)") do
    File.open("xmlconf/oasis/p32fail4.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p32fail5 (Section 2.9 [32])" do
  assert_raises(XML::Error, " yes or no must be lower case  (xmlconf/oasis/p32fail5.xml)") do
    File.open("xmlconf/oasis/p32fail5.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p39fail1 (Section 3 [39])" do
  assert_raises(XML::Error, " start-tag requires end-tag  (xmlconf/oasis/p39fail1.xml)") do
    File.open("xmlconf/oasis/p39fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p39fail2 (Section 3 [39])" do
  assert_raises(XML::Error, " end-tag requires start-tag  (xmlconf/oasis/p39fail2.xml)") do
    File.open("xmlconf/oasis/p39fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p39fail3 (Section 3 [39])" do
  assert_raises(XML::Error, " XML documents contain one or more elements (xmlconf/oasis/p39fail3.xml)") do
    File.open("xmlconf/oasis/p39fail3.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p39fail4 (Section 2.8 [23])" do
  assert_raises(XML::Error, " XML declarations must be correctly terminated  (xmlconf/oasis/p39fail4.xml)") do
    File.open("xmlconf/oasis/p39fail4.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p39fail5 (Section 2.8 [23])" do
  assert_raises(XML::Error, " XML declarations must be correctly terminated  (xmlconf/oasis/p39fail5.xml)") do
    File.open("xmlconf/oasis/p39fail5.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p40fail1 (Section 3.1 [40])" do
  assert_raises(XML::Error, " S is required between attributes  (xmlconf/oasis/p40fail1.xml)") do
    File.open("xmlconf/oasis/p40fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p40fail2 (Section 3.1 [40])" do
  assert_raises(XML::Error, " tags start with names, not nmtokens  (xmlconf/oasis/p40fail2.xml)") do
    File.open("xmlconf/oasis/p40fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p40fail3 (Section 3.1 [40])" do
  assert_raises(XML::Error, " tags start with names, not nmtokens  (xmlconf/oasis/p40fail3.xml)") do
    File.open("xmlconf/oasis/p40fail3.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p40fail4 (Section 3.1 [40])" do
  assert_raises(XML::Error, " no space before name  (xmlconf/oasis/p40fail4.xml)") do
    File.open("xmlconf/oasis/p40fail4.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p41fail1 (Section 3.1 [41])" do
  assert_raises(XML::Error, " quotes are required (contrast with SGML)  (xmlconf/oasis/p41fail1.xml)") do
    File.open("xmlconf/oasis/p41fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p41fail2 (Section 3.1 [41])" do
  assert_raises(XML::Error, " attribute name is required (contrast with SGML)  (xmlconf/oasis/p41fail2.xml)") do
    File.open("xmlconf/oasis/p41fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p41fail3 (Section 3.1 [41])" do
  assert_raises(XML::Error, " Eq required  (xmlconf/oasis/p41fail3.xml)") do
    File.open("xmlconf/oasis/p41fail3.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p42fail1 (Section 3.1 [42])" do
  assert_raises(XML::Error, " no space before name  (xmlconf/oasis/p42fail1.xml)") do
    File.open("xmlconf/oasis/p42fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p42fail2 (Section 3.1 [42])" do
  assert_raises(XML::Error, " cannot end with \"/>\"  (xmlconf/oasis/p42fail2.xml)") do
    File.open("xmlconf/oasis/p42fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p42fail3 (Section 3.1 [42])" do
  assert_raises(XML::Error, " no NET (contrast with SGML)  (xmlconf/oasis/p42fail3.xml)") do
    File.open("xmlconf/oasis/p42fail3.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p43fail1 (Section 3.1 [43])" do
  assert_raises(XML::Error, " no non-comment declarations  (xmlconf/oasis/p43fail1.xml)") do
    File.open("xmlconf/oasis/p43fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p43fail2 (Section 3.1 [43])" do
  assert_raises(XML::Error, " no conditional sections  (xmlconf/oasis/p43fail2.xml)") do
    File.open("xmlconf/oasis/p43fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p43fail3 (Section 3.1 [43])" do
  assert_raises(XML::Error, " no conditional sections  (xmlconf/oasis/p43fail3.xml)") do
    File.open("xmlconf/oasis/p43fail3.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p44fail1 (Section 3.1 [44])" do
  assert_raises(XML::Error, " Illegal space before Empty element tag.  (xmlconf/oasis/p44fail1.xml)") do
    File.open("xmlconf/oasis/p44fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p44fail2 (Section 3.1 [44])" do
  assert_raises(XML::Error, " Illegal space after Empty element tag.  (xmlconf/oasis/p44fail2.xml)") do
    File.open("xmlconf/oasis/p44fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p44fail3 (Section 3.1 [44])" do
  assert_raises(XML::Error, " Illegal comment in Empty element tag.  (xmlconf/oasis/p44fail3.xml)") do
    File.open("xmlconf/oasis/p44fail3.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p44fail4 (Section 3.1 [44])" do
  assert_raises(XML::Error, " Whitespace required between attributes.  (xmlconf/oasis/p44fail4.xml)") do
    File.open("xmlconf/oasis/p44fail4.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p44fail5 (Section 3.1 [44])" do
  assert_raises(XML::Error, " Duplicate attribute name is illegal.  (xmlconf/oasis/p44fail5.xml)") do
    File.open("xmlconf/oasis/p44fail5.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p45fail1 (Section 3.2 [45])" do
  assert_raises(XML::Error, " ELEMENT must be upper case.  (xmlconf/oasis/p45fail1.xml)") do
    File.open("xmlconf/oasis/p45fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p45fail2 (Section 3.2 [45])" do
  assert_raises(XML::Error, " S before contentspec is required.  (xmlconf/oasis/p45fail2.xml)") do
    File.open("xmlconf/oasis/p45fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p45fail3 (Section 3.2 [45])" do
  assert_raises(XML::Error, " only one content spec  (xmlconf/oasis/p45fail3.xml)") do
    File.open("xmlconf/oasis/p45fail3.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p45fail4 (Section 3.2 [45])" do
  assert_raises(XML::Error, " no comments in declarations (contrast with SGML)  (xmlconf/oasis/p45fail4.xml)") do
    File.open("xmlconf/oasis/p45fail4.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p46fail1 (Section 3.2 [46])" do
  assert_raises(XML::Error, " no parens on declared content  (xmlconf/oasis/p46fail1.xml)") do
    File.open("xmlconf/oasis/p46fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p46fail2 (Section 3.2 [46])" do
  assert_raises(XML::Error, " no inclusions (contrast with SGML)  (xmlconf/oasis/p46fail2.xml)") do
    File.open("xmlconf/oasis/p46fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p46fail3 (Section 3.2 [46])" do
  assert_raises(XML::Error, " no exclusions (contrast with SGML)  (xmlconf/oasis/p46fail3.xml)") do
    File.open("xmlconf/oasis/p46fail3.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p46fail4 (Section 3.2 [46])" do
  assert_raises(XML::Error, " no space before occurrence  (xmlconf/oasis/p46fail4.xml)") do
    File.open("xmlconf/oasis/p46fail4.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p46fail5 (Section 3.2 [46])" do
  assert_raises(XML::Error, " single group  (xmlconf/oasis/p46fail5.xml)") do
    File.open("xmlconf/oasis/p46fail5.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p46fail6 (Section 3.2 [46])" do
  assert_raises(XML::Error, " can't be both declared and modeled  (xmlconf/oasis/p46fail6.xml)") do
    File.open("xmlconf/oasis/p46fail6.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p47fail1 (Section 3.2.1 [47])" do
  assert_raises(XML::Error, " Invalid operator '|' must match previous operator ',' (xmlconf/oasis/p47fail1.xml)") do
    File.open("xmlconf/oasis/p47fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p47fail2 (Section 3.2.1 [47])" do
  assert_raises(XML::Error, " Illegal character '-' in Element-content model  (xmlconf/oasis/p47fail2.xml)") do
    File.open("xmlconf/oasis/p47fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p47fail3 (Section 3.2.1 [47])" do
  assert_raises(XML::Error, " Optional character must follow a name or list  (xmlconf/oasis/p47fail3.xml)") do
    File.open("xmlconf/oasis/p47fail3.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p47fail4 (Section 3.2.1 [47])" do
  assert_raises(XML::Error, " Illegal space before optional character (xmlconf/oasis/p47fail4.xml)") do
    File.open("xmlconf/oasis/p47fail4.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p48fail1 (Section 3.2.1 [48])" do
  assert_raises(XML::Error, " Illegal space before optional character  (xmlconf/oasis/p48fail1.xml)") do
    File.open("xmlconf/oasis/p48fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p48fail2 (Section 3.2.1 [48])" do
  assert_raises(XML::Error, " Illegal space before optional character  (xmlconf/oasis/p48fail2.xml)") do
    File.open("xmlconf/oasis/p48fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p49fail1 (Section 3.2.1 [49])" do
  assert_raises(XML::Error, " connectors must match  (xmlconf/oasis/p49fail1.xml)") do
    File.open("xmlconf/oasis/p49fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p50fail1 (Section 3.2.1 [50])" do
  assert_raises(XML::Error, " connectors must match  (xmlconf/oasis/p50fail1.xml)") do
    File.open("xmlconf/oasis/p50fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p51fail1 (Section 3.2.2 [51])" do
  assert_raises(XML::Error, " occurrence on #PCDATA group must be *  (xmlconf/oasis/p51fail1.xml)") do
    File.open("xmlconf/oasis/p51fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p51fail2 (Section 3.2.2 [51])" do
  assert_raises(XML::Error, " occurrence on #PCDATA group must be *  (xmlconf/oasis/p51fail2.xml)") do
    File.open("xmlconf/oasis/p51fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p51fail3 (Section 3.2.2 [51])" do
  assert_raises(XML::Error, " #PCDATA must come first  (xmlconf/oasis/p51fail3.xml)") do
    File.open("xmlconf/oasis/p51fail3.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p51fail4 (Section 3.2.2 [51])" do
  assert_raises(XML::Error, " occurrence on #PCDATA group must be *  (xmlconf/oasis/p51fail4.xml)") do
    File.open("xmlconf/oasis/p51fail4.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p51fail5 (Section 3.2.2 [51])" do
  assert_raises(XML::Error, " only '|' connectors  (xmlconf/oasis/p51fail5.xml)") do
    File.open("xmlconf/oasis/p51fail5.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p51fail6 (Section 3.2.2 [51])" do
  assert_raises(XML::Error, " Only '|' connectors and occurrence on #PCDATA group must be *  (xmlconf/oasis/p51fail6.xml)") do
    File.open("xmlconf/oasis/p51fail6.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p51fail7 (Section 3.2.2 [51])" do
  assert_raises(XML::Error, " no nested groups  (xmlconf/oasis/p51fail7.xml)") do
    File.open("xmlconf/oasis/p51fail7.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p52fail1 (Section 3.3 [52])" do
  assert_raises(XML::Error, " A name is required  (xmlconf/oasis/p52fail1.xml)") do
    File.open("xmlconf/oasis/p52fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p52fail2 (Section 3.3 [52])" do
  assert_raises(XML::Error, " A name is required  (xmlconf/oasis/p52fail2.xml)") do
    File.open("xmlconf/oasis/p52fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p53fail1 (Section 3.3 [53])" do
  assert_raises(XML::Error, " S is required before default  (xmlconf/oasis/p53fail1.xml)") do
    File.open("xmlconf/oasis/p53fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p53fail2 (Section 3.3 [53])" do
  assert_raises(XML::Error, " S is required before type  (xmlconf/oasis/p53fail2.xml)") do
    File.open("xmlconf/oasis/p53fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p53fail3 (Section 3.3 [53])" do
  assert_raises(XML::Error, " type is required  (xmlconf/oasis/p53fail3.xml)") do
    File.open("xmlconf/oasis/p53fail3.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p53fail4 (Section 3.3 [53])" do
  assert_raises(XML::Error, " default is required  (xmlconf/oasis/p53fail4.xml)") do
    File.open("xmlconf/oasis/p53fail4.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p53fail5 (Section 3.3 [53])" do
  assert_raises(XML::Error, " name is requried  (xmlconf/oasis/p53fail5.xml)") do
    File.open("xmlconf/oasis/p53fail5.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p54fail1 (Section 3.3.1 [54])" do
  assert_raises(XML::Error, " don't pass unknown attribute types  (xmlconf/oasis/p54fail1.xml)") do
    File.open("xmlconf/oasis/p54fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p55fail1 (Section 3.3.1 [55])" do
  assert_raises(XML::Error, " must be upper case  (xmlconf/oasis/p55fail1.xml)") do
    File.open("xmlconf/oasis/p55fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p56fail1 (Section 3.3.1 [56])" do
  assert_raises(XML::Error, " no IDS type  (xmlconf/oasis/p56fail1.xml)") do
    File.open("xmlconf/oasis/p56fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p56fail2 (Section 3.3.1 [56])" do
  assert_raises(XML::Error, " no NUMBER type  (xmlconf/oasis/p56fail2.xml)") do
    File.open("xmlconf/oasis/p56fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p56fail3 (Section 3.3.1 [56])" do
  assert_raises(XML::Error, " no NAME type  (xmlconf/oasis/p56fail3.xml)") do
    File.open("xmlconf/oasis/p56fail3.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p56fail4 (Section 3.3.1 [56])" do
  assert_raises(XML::Error, " no ENTITYS type - types must be upper case  (xmlconf/oasis/p56fail4.xml)") do
    File.open("xmlconf/oasis/p56fail4.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p56fail5 (Section 3.3.1 [56])" do
  assert_raises(XML::Error, " types must be upper case  (xmlconf/oasis/p56fail5.xml)") do
    File.open("xmlconf/oasis/p56fail5.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p57fail1 (Section 3.3.1 [57])" do
  assert_raises(XML::Error, " no keyword for NMTOKEN enumeration  (xmlconf/oasis/p57fail1.xml)") do
    File.open("xmlconf/oasis/p57fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p58fail1 (Section 3.3.1 [58])" do
  assert_raises(XML::Error, " at least one value required  (xmlconf/oasis/p58fail1.xml)") do
    File.open("xmlconf/oasis/p58fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p58fail2 (Section 3.3.1 [58])" do
  assert_raises(XML::Error, " separator must be '|'  (xmlconf/oasis/p58fail2.xml)") do
    File.open("xmlconf/oasis/p58fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p58fail3 (Section 3.3.1 [58])" do
  assert_raises(XML::Error, " notations are NAMEs, not NMTOKENs -- note: Leaving the invalid notation undeclared would cause a validating parser to fail without checking the name syntax, so the notation is declared with an invalid name. A parser that reports error positions should report an error at the AttlistDecl on line 6, before reaching the notation declaration.  (xmlconf/oasis/p58fail3.xml)") do
    File.open("xmlconf/oasis/p58fail3.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p58fail4 (Section 3.3.1 [58])" do
  assert_raises(XML::Error, " NOTATION must be upper case  (xmlconf/oasis/p58fail4.xml)") do
    File.open("xmlconf/oasis/p58fail4.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p58fail5 (Section 3.3.1 [58])" do
  assert_raises(XML::Error, " S after keyword is required  (xmlconf/oasis/p58fail5.xml)") do
    File.open("xmlconf/oasis/p58fail5.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p58fail6 (Section 3.3.1 [58])" do
  assert_raises(XML::Error, " parentheses are require  (xmlconf/oasis/p58fail6.xml)") do
    File.open("xmlconf/oasis/p58fail6.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p58fail7 (Section 3.3.1 [58])" do
  assert_raises(XML::Error, " values are unquoted  (xmlconf/oasis/p58fail7.xml)") do
    File.open("xmlconf/oasis/p58fail7.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p58fail8 (Section 3.3.1 [58])" do
  assert_raises(XML::Error, " values are unquoted  (xmlconf/oasis/p58fail8.xml)") do
    File.open("xmlconf/oasis/p58fail8.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p59fail1 (Section 3.3.1 [59])" do
  assert_raises(XML::Error, " at least one required  (xmlconf/oasis/p59fail1.xml)") do
    File.open("xmlconf/oasis/p59fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p59fail2 (Section 3.3.1 [59])" do
  assert_raises(XML::Error, " separator must be \",\"  (xmlconf/oasis/p59fail2.xml)") do
    File.open("xmlconf/oasis/p59fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p59fail3 (Section 3.3.1 [59])" do
  assert_raises(XML::Error, " values are unquoted  (xmlconf/oasis/p59fail3.xml)") do
    File.open("xmlconf/oasis/p59fail3.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p60fail1 (Section 3.3.2 [60])" do
  assert_raises(XML::Error, " keywords must be upper case  (xmlconf/oasis/p60fail1.xml)") do
    File.open("xmlconf/oasis/p60fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p60fail2 (Section 3.3.2 [60])" do
  assert_raises(XML::Error, " S is required after #FIXED  (xmlconf/oasis/p60fail2.xml)") do
    File.open("xmlconf/oasis/p60fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p60fail3 (Section 3.3.2 [60])" do
  assert_raises(XML::Error, " only #FIXED has both keyword and value  (xmlconf/oasis/p60fail3.xml)") do
    File.open("xmlconf/oasis/p60fail3.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p60fail4 (Section 3.3.2 [60])" do
  assert_raises(XML::Error, " #FIXED required value  (xmlconf/oasis/p60fail4.xml)") do
    File.open("xmlconf/oasis/p60fail4.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p60fail5 (Section 3.3.2 [60])" do
  assert_raises(XML::Error, " only one default type  (xmlconf/oasis/p60fail5.xml)") do
    File.open("xmlconf/oasis/p60fail5.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p61fail1 (Section 3.4 [61])" do
  assert_raises(XML::Error, " no other types, including TEMP, which is valid in SGML  (xmlconf/oasis/p61fail1.xml)") do
    File.open("xmlconf/oasis/p61fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p62fail1 (Section 3.4 [62])" do
  assert_raises(XML::Error, " INCLUDE must be upper case  (xmlconf/oasis/p62fail1.xml)") do
    File.open("xmlconf/oasis/p62fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p62fail2 (Section 3.4 [62])" do
  assert_raises(XML::Error, " no spaces in terminating delimiter  (xmlconf/oasis/p62fail2.xml)") do
    File.open("xmlconf/oasis/p62fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p63fail1 (Section 3.4 [63])" do
  assert_raises(XML::Error, " IGNORE must be upper case  (xmlconf/oasis/p63fail1.xml)") do
    File.open("xmlconf/oasis/p63fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p63fail2 (Section 3.4 [63])" do
  assert_raises(XML::Error, " delimiters must be balanced  (xmlconf/oasis/p63fail2.xml)") do
    File.open("xmlconf/oasis/p63fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p64fail1 (Section 3.4 [64])" do
  assert_raises(XML::Error, " section delimiters must balance  (xmlconf/oasis/p64fail1.xml)") do
    File.open("xmlconf/oasis/p64fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p64fail2 (Section 3.4 [64])" do
  assert_raises(XML::Error, " section delimiters must balance  (xmlconf/oasis/p64fail2.xml)") do
    File.open("xmlconf/oasis/p64fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p66fail1 (Section 4.1 [66])" do
  assert_raises(XML::Error, " terminating ';' is required  (xmlconf/oasis/p66fail1.xml)") do
    File.open("xmlconf/oasis/p66fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p66fail2 (Section 4.1 [66])" do
  assert_raises(XML::Error, " no S after '&#'  (xmlconf/oasis/p66fail2.xml)") do
    File.open("xmlconf/oasis/p66fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p66fail3 (Section 4.1 [66])" do
  assert_raises(XML::Error, " no hex digits in numeric reference  (xmlconf/oasis/p66fail3.xml)") do
    File.open("xmlconf/oasis/p66fail3.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p66fail4 (Section 4.1 [66])" do
  assert_raises(XML::Error, " only hex digits in hex references  (xmlconf/oasis/p66fail4.xml)") do
    File.open("xmlconf/oasis/p66fail4.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p66fail5 (Section 4.1 [66])" do
  assert_raises(XML::Error, " no references to non-characters  (xmlconf/oasis/p66fail5.xml)") do
    File.open("xmlconf/oasis/p66fail5.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p66fail6 (Section 4.1 [66])" do
  assert_raises(XML::Error, " no references to non-characters  (xmlconf/oasis/p66fail6.xml)") do
    File.open("xmlconf/oasis/p66fail6.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p68fail1 (Section 4.1 [68])" do
  assert_raises(XML::Error, " terminating ';' is required  (xmlconf/oasis/p68fail1.xml)") do
    File.open("xmlconf/oasis/p68fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p68fail2 (Section 4.1 [68])" do
  assert_raises(XML::Error, " no S after '&'  (xmlconf/oasis/p68fail2.xml)") do
    File.open("xmlconf/oasis/p68fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p68fail3 (Section 4.1 [68])" do
  assert_raises(XML::Error, " no S before ';'  (xmlconf/oasis/p68fail3.xml)") do
    File.open("xmlconf/oasis/p68fail3.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p69fail1 (Section 4.1 [69])" do
  assert_raises(XML::Error, " terminating ';' is required  (xmlconf/oasis/p69fail1.xml)") do
    File.open("xmlconf/oasis/p69fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p69fail2 (Section 4.1 [69])" do
  assert_raises(XML::Error, " no S after '%'  (xmlconf/oasis/p69fail2.xml)") do
    File.open("xmlconf/oasis/p69fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p69fail3 (Section 4.1 [69])" do
  assert_raises(XML::Error, " no S before ';'  (xmlconf/oasis/p69fail3.xml)") do
    File.open("xmlconf/oasis/p69fail3.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p70fail1 (Section 4.2 [70])" do
  assert_raises(XML::Error, " This is neither  (xmlconf/oasis/p70fail1.xml)") do
    File.open("xmlconf/oasis/p70fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p71fail1 (Section 4.2 [71])" do
  assert_raises(XML::Error, " S is required before EntityDef  (xmlconf/oasis/p71fail1.xml)") do
    File.open("xmlconf/oasis/p71fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p71fail2 (Section 4.2 [71])" do
  assert_raises(XML::Error, " Entity name is a Name, not an NMToken  (xmlconf/oasis/p71fail2.xml)") do
    File.open("xmlconf/oasis/p71fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p71fail3 (Section 4.2 [71])" do
  assert_raises(XML::Error, " no S after \"<!\"  (xmlconf/oasis/p71fail3.xml)") do
    File.open("xmlconf/oasis/p71fail3.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p71fail4 (Section 4.2 [71])" do
  assert_raises(XML::Error, " S is required after \"<!ENTITY\"  (xmlconf/oasis/p71fail4.xml)") do
    File.open("xmlconf/oasis/p71fail4.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p72fail1 (Section 4.2 [72])" do
  assert_raises(XML::Error, " S is required after \"<!ENTITY\"  (xmlconf/oasis/p72fail1.xml)") do
    File.open("xmlconf/oasis/p72fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p72fail2 (Section 4.2 [72])" do
  assert_raises(XML::Error, " S is required after '%'  (xmlconf/oasis/p72fail2.xml)") do
    File.open("xmlconf/oasis/p72fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p72fail3 (Section 4.2 [72])" do
  assert_raises(XML::Error, " S is required after name  (xmlconf/oasis/p72fail3.xml)") do
    File.open("xmlconf/oasis/p72fail3.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p72fail4 (Section 4.2 [72])" do
  assert_raises(XML::Error, " Entity name is a name, not an NMToken  (xmlconf/oasis/p72fail4.xml)") do
    File.open("xmlconf/oasis/p72fail4.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p73fail1 (Section 4.2 [73])" do
  assert_raises(XML::Error, " No typed replacement text  (xmlconf/oasis/p73fail1.xml)") do
    File.open("xmlconf/oasis/p73fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p73fail2 (Section 4.2 [73])" do
  assert_raises(XML::Error, " Only one replacement value  (xmlconf/oasis/p73fail2.xml)") do
    File.open("xmlconf/oasis/p73fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p73fail3 (Section 4.2 [73])" do
  assert_raises(XML::Error, " No NDataDecl on replacement text  (xmlconf/oasis/p73fail3.xml)") do
    File.open("xmlconf/oasis/p73fail3.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p73fail4 (Section 4.2 [73])" do
  assert_raises(XML::Error, " Value is required  (xmlconf/oasis/p73fail4.xml)") do
    File.open("xmlconf/oasis/p73fail4.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p73fail5 (Section 4.2 [73])" do
  assert_raises(XML::Error, " No NDataDecl without value  (xmlconf/oasis/p73fail5.xml)") do
    File.open("xmlconf/oasis/p73fail5.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p74fail1 (Section 4.2 [74])" do
  assert_raises(XML::Error, " no NDataDecls on parameter entities  (xmlconf/oasis/p74fail1.xml)") do
    File.open("xmlconf/oasis/p74fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p74fail2 (Section 4.2 [74])" do
  assert_raises(XML::Error, " value is required  (xmlconf/oasis/p74fail2.xml)") do
    File.open("xmlconf/oasis/p74fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p74fail3 (Section 4.2 [74])" do
  assert_raises(XML::Error, " only one value  (xmlconf/oasis/p74fail3.xml)") do
    File.open("xmlconf/oasis/p74fail3.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p75fail1 (Section 4.2.2 [75])" do
  assert_raises(XML::Error, " S required after \"PUBLIC\"  (xmlconf/oasis/p75fail1.xml)") do
    File.open("xmlconf/oasis/p75fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p75fail2 (Section 4.2.2 [75])" do
  assert_raises(XML::Error, " S required after \"SYSTEM\"  (xmlconf/oasis/p75fail2.xml)") do
    File.open("xmlconf/oasis/p75fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p75fail3 (Section 4.2.2 [75])" do
  assert_raises(XML::Error, " S required between literals  (xmlconf/oasis/p75fail3.xml)") do
    File.open("xmlconf/oasis/p75fail3.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p75fail4 (Section 4.2.2 [75])" do
  assert_raises(XML::Error, " \"SYSTEM\" implies only one literal  (xmlconf/oasis/p75fail4.xml)") do
    File.open("xmlconf/oasis/p75fail4.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p75fail5 (Section 4.2.2 [75])" do
  assert_raises(XML::Error, " only one keyword  (xmlconf/oasis/p75fail5.xml)") do
    File.open("xmlconf/oasis/p75fail5.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p75fail6 (Section 4.2.2 [75])" do
  assert_raises(XML::Error, " \"PUBLIC\" requires two literals (contrast with SGML)  (xmlconf/oasis/p75fail6.xml)") do
    File.open("xmlconf/oasis/p75fail6.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p76fail1 (Section 4.2.2 [76])" do
  assert_raises(XML::Error, " S is required before \"NDATA\"  (xmlconf/oasis/p76fail1.xml)") do
    File.open("xmlconf/oasis/p76fail1.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p76fail2 (Section 4.2.2 [76])" do
  assert_raises(XML::Error, " \"NDATA\" is upper-case  (xmlconf/oasis/p76fail2.xml)") do
    File.open("xmlconf/oasis/p76fail2.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p76fail3 (Section 4.2.2 [76])" do
  assert_raises(XML::Error, " notation name is required  (xmlconf/oasis/p76fail3.xml)") do
    File.open("xmlconf/oasis/p76fail3.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p76fail4 (Section 4.2.2 [76])" do
  assert_raises(XML::Error, " notation names are Names  (xmlconf/oasis/p76fail4.xml)") do
    File.open("xmlconf/oasis/p76fail4.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "o-p11pass1 (Section 2.3, 4.2.2 [11])" do
  assert_raises(" system literals may not contain URI fragments  (xmlconf/oasis/p11pass1.xml)") do
    File.open("xmlconf/oasis/p11pass1.xml") { |file| XML::DOM.parse(file, base: "xmlconf/oasis") }
  end
end

end

end

describe "IBM XML 1.0 Tests" do
describe "IBM XML Conformance Test Suite - invalid tests" do
describe "IBM XML Conformance Test Suite - Production 28" do
it "ibm-invalid-P28-ibm28i01.xml (Section 2.8)" do
  assert_parses("xmlconf/ibm/invalid/P28/ibm28i01.xml", "xmlconf/ibm/invalid/P28/out/ibm28i01.xml", " The test violates VC:Root Element Type in P28. The Name in the document type declaration does not match the element type of the root element.  (xmlconf/ibm/invalid/P28/ibm28i01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 32" do
it "ibm-invalid-P32-ibm32i01.xml (Section 2.9)" do
  assert_parses("xmlconf/ibm/invalid/P32/ibm32i01.xml", "xmlconf/ibm/invalid/P32/out/ibm32i01.xml", " This test violates VC: Standalone Document Declaration in P32. The standalone document declaration has the value yes, BUT there is an external markup declaration of attributes with default values, and the associated element appears in the document with specified values for those attributes.  (xmlconf/ibm/invalid/P32/ibm32i01.xml)")
end

it "ibm-invalid-P32-ibm32i03.xml (Section 2.9)" do
  assert_parses("xmlconf/ibm/invalid/P32/ibm32i03.xml", "xmlconf/ibm/invalid/P32/out/ibm32i03.xml", " This test violates VC: Standalone Document Declaration in P32. The standalone document declaration has the value yes, BUT there is an external markup declaration of attributes with values that will change if normalized.  (xmlconf/ibm/invalid/P32/ibm32i03.xml)")
end

it "ibm-invalid-P32-ibm32i04.xml (Section 2.9)" do
  assert_parses("xmlconf/ibm/invalid/P32/ibm32i04.xml", "xmlconf/ibm/invalid/P32/out/ibm32i04.xml", " This test violates VC: Standalone Document Declaration in P32. The standalone document declaration has the value yes, BUT there is an external markup declaration of element with element content, and white space occurs directly within the mixed content.  (xmlconf/ibm/invalid/P32/ibm32i04.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 39" do
it "ibm-invalid-P39-ibm39i01.xml (Section 3)" do
  assert_parses("xmlconf/ibm/invalid/P39/ibm39i01.xml", "xmlconf/ibm/invalid/P39/out/ibm39i01.xml", " This test violates VC: Element Valid in P39. Element a is declared empty in DTD, but has content in the document.  (xmlconf/ibm/invalid/P39/ibm39i01.xml)")
end

it "ibm-invalid-P39-ibm39i02.xml (Section 3)" do
  assert_parses("xmlconf/ibm/invalid/P39/ibm39i02.xml", "xmlconf/ibm/invalid/P39/out/ibm39i02.xml", " This test violates VC: Element Valid in P39. root is declared only having element children in DTD, but have text content in the document.  (xmlconf/ibm/invalid/P39/ibm39i02.xml)")
end

it "ibm-invalid-P39-ibm39i03.xml (Section 3)" do
  assert_parses("xmlconf/ibm/invalid/P39/ibm39i03.xml", "xmlconf/ibm/invalid/P39/out/ibm39i03.xml", " This test violates VC: Element Valid in P39. Illegal elements are inserted in b's content of Mixed type.  (xmlconf/ibm/invalid/P39/ibm39i03.xml)")
end

it "ibm-invalid-P39-ibm39i04.xml (Section 3)" do
  assert_parses("xmlconf/ibm/invalid/P39/ibm39i04.xml", "xmlconf/ibm/invalid/P39/out/ibm39i04.xml", " This test violates VC: Element Valid in P39. Element c has undeclared element as its content of ANY type  (xmlconf/ibm/invalid/P39/ibm39i04.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 41" do
it "ibm-invalid-P41-ibm41i01.xml (Section 3.1)" do
  assert_parses("xmlconf/ibm/invalid/P41/ibm41i01.xml", "xmlconf/ibm/invalid/P41/out/ibm41i01.xml", " This test violates VC: Attribute Value Type in P41. attr1 for Element b is not declared.  (xmlconf/ibm/invalid/P41/ibm41i01.xml)")
end

it "ibm-invalid-P41-ibm41i02.xml (Section 3.1)" do
  assert_parses("xmlconf/ibm/invalid/P41/ibm41i02.xml", "xmlconf/ibm/invalid/P41/out/ibm41i02.xml", " This test violates VC: Attribute Value Type in P41. attr3 for Element b is given a value that does not match the declaration in the DTD.  (xmlconf/ibm/invalid/P41/ibm41i02.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 45" do
it "ibm-invalid-P45-ibm45i01.xml (Section 3.2)" do
  assert_parses("xmlconf/ibm/invalid/P45/ibm45i01.xml", "xmlconf/ibm/invalid/P45/out/ibm45i01.xml", " This test violates VC: Unique Element Type Declaration. Element not_unique has been declared 3 time in the DTD.  (xmlconf/ibm/invalid/P45/ibm45i01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 49" do
it "ibm-invalid-P49-ibm49i01.xml (Section 3.2.1)" do
  assert_parses("xmlconf/ibm/invalid/P49/ibm49i01.xml", "xmlconf/ibm/invalid/P49/out/ibm49i01.xml", " Violates VC:Proper Group/PE Nesting in P49. Open and close parenthesis for a choice content model are in different PE replace Texts.  (xmlconf/ibm/invalid/P49/ibm49i01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 50" do
it "ibm-invalid-P50-ibm50i01.xml (Section 3.2.1)" do
  assert_parses("xmlconf/ibm/invalid/P50/ibm50i01.xml", "xmlconf/ibm/invalid/P50/out/ibm50i01.xml", " Violates VC:Proper Group/PE Nesting in P50. Open and close parenthesis for a seq content model are in different PE replace Texts.  (xmlconf/ibm/invalid/P50/ibm50i01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 51" do
it "ibm-invalid-P51-ibm51i01.xml (Section 3.2.2)" do
  assert_parses("xmlconf/ibm/invalid/P51/ibm51i01.xml", "xmlconf/ibm/invalid/P51/out/ibm51i01.xml", " Violates VC:Proper Group/PE Nesting in P51. Open and close parenthesis for a Mixed content model are in different PE replace Texts.  (xmlconf/ibm/invalid/P51/ibm51i01.xml)")
end

it "ibm-invalid-P51-ibm51i03.xml (Section 3.2.2)" do
  assert_parses("xmlconf/ibm/invalid/P51/ibm51i03.xml", "xmlconf/ibm/invalid/P51/out/ibm51i03.xml", " Violates VC:No Duplicate Types in P51. Element a appears twice in the Mixed content model of Element e.  (xmlconf/ibm/invalid/P51/ibm51i03.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 56" do
it "ibm-invalid-P56-ibm56i01.xml (Section 3.3.1)" do
  assert_parses("xmlconf/ibm/invalid/P56/ibm56i01.xml", "xmlconf/ibm/invalid/P56/out/ibm56i01.xml", " Tests invalid TokenizedType which is against P56 VC: ID. The value of the ID attribute \"UniqueName\" is \"@999\" which does not meet the Name production.  (xmlconf/ibm/invalid/P56/ibm56i01.xml)")
end

it "ibm-invalid-P56-ibm56i02.xml (Section 3.3.1)" do
  assert_parses("xmlconf/ibm/invalid/P56/ibm56i02.xml", "xmlconf/ibm/invalid/P56/out/ibm56i02.xml", " Tests invalid TokenizedType which is against P56 VC: ID. The two ID attributes \"attr\" and \"UniqueName\" have the same value \"Ac999\" for the element \"b\" and the element \"tokenizer\".  (xmlconf/ibm/invalid/P56/ibm56i02.xml)")
end

it "ibm-invalid-P56-ibm56i03.xml (Section 3.3.1)" do
  assert_parses("xmlconf/ibm/invalid/P56/ibm56i03.xml", "xmlconf/ibm/invalid/P56/out/ibm56i03.xml", " Tests invalid TokenizedType which is against P56 VC: ID Attribute Default. The \"#FIXED\" occurs in the DefaultDecl for the ID attribute \"UniqueName\".  (xmlconf/ibm/invalid/P56/ibm56i03.xml)")
end

it "ibm-invalid-P56-ibm56i05.xml (Section 3.3.1)" do
  assert_parses("xmlconf/ibm/invalid/P56/ibm56i05.xml", "xmlconf/ibm/invalid/P56/out/ibm56i05.xml", " Tests invalid TokenizedType which is against P56 VC: ID Attribute Default. The constant string \"BOGUS\" occurs in the DefaultDecl for the ID attribute \"UniqueName\".  (xmlconf/ibm/invalid/P56/ibm56i05.xml)")
end

it "ibm-invalid-P56-ibm56i06.xml (Section 3.3.1)" do
  assert_parses("xmlconf/ibm/invalid/P56/ibm56i06.xml", "xmlconf/ibm/invalid/P56/out/ibm56i06.xml", " Tests invalid TokenizedType which is against P56 VC: One ID per Element Type. The element \"a\" has two ID attributes \"first\" and \"second\".  (xmlconf/ibm/invalid/P56/ibm56i06.xml)")
end

it "ibm-invalid-P56-ibm56i07.xml (Section 3.3.1)" do
  assert_parses("xmlconf/ibm/invalid/P56/ibm56i07.xml", "xmlconf/ibm/invalid/P56/out/ibm56i07.xml", " Tests invalid TokenizedType which is against P56 VC: IDREF. The value of the IDREF attribute \"reference\" is \"@456\" which does not meet the Name production.  (xmlconf/ibm/invalid/P56/ibm56i07.xml)")
end

it "ibm-invalid-P56-ibm56i08.xml (Section 3.3.1)" do
  assert_parses("xmlconf/ibm/invalid/P56/ibm56i08.xml", "xmlconf/ibm/invalid/P56/out/ibm56i08.xml", " Tests invalid TokenizedType which is against P56 VC: IDREF. The value of the IDREF attribute \"reference\" is \"BC456\" which does not match the value assigned to any ID attributes.  (xmlconf/ibm/invalid/P56/ibm56i08.xml)")
end

it "ibm-invalid-P56-ibm56i09.xml (Section 3.3.1)" do
  assert_parses("xmlconf/ibm/invalid/P56/ibm56i09.xml", "xmlconf/ibm/invalid/P56/out/ibm56i09.xml", " Tests invalid TokenizedType which is against P56 VC: IDREFS. The value of the IDREFS attribute \"reference\" is \"AC456 #567\" which does not meet the Names production.  (xmlconf/ibm/invalid/P56/ibm56i09.xml)")
end

it "ibm-invalid-P56-ibm56i10.xml (Section 3.3.1)" do
  assert_parses("xmlconf/ibm/invalid/P56/ibm56i10.xml", "xmlconf/ibm/invalid/P56/out/ibm56i10.xml", " Tests invalid TokenizedType which is against P56 VC: IDREFS. The value of the IDREFS attribute \"reference\" is \"EF456 DE355\" which does not match the values assigned to two ID attributes.  (xmlconf/ibm/invalid/P56/ibm56i10.xml)")
end

it "ibm-invalid-P56-ibm56i11.xml (Section 3.3.1)" do
  assert_parses("xmlconf/ibm/invalid/P56/ibm56i11.xml", "xmlconf/ibm/invalid/P56/out/ibm56i11.xml", " Tests invalid TokenizedType which is against P56 VC: Entity Name. The value of the ENTITY attribute \"sun\" is \"ima ge\" which does not meet the Name production.  (xmlconf/ibm/invalid/P56/ibm56i11.xml)")
end

it "ibm-invalid-P56-ibm56i12.xml (Section 3.3.1)" do
  assert_parses("xmlconf/ibm/invalid/P56/ibm56i12.xml", "xmlconf/ibm/invalid/P56/out/ibm56i12.xml", " Tests invalid TokenizedType which is against P56 VC: Entity Name. The value of the ENTITY attribute \"sun\" is \"notimage\" which does not match the name of any unparsed entity declared.  (xmlconf/ibm/invalid/P56/ibm56i12.xml)")
end

it "ibm-invalid-P56-ibm56i13.xml (Section 3.3.1)" do
  assert_parses("xmlconf/ibm/invalid/P56/ibm56i13.xml", "xmlconf/ibm/invalid/P56/out/ibm56i13.xml", " Tests invalid TokenizedType which is against P56 VC: Entity Name. The value of the ENTITY attribute \"sun\" is \"parsedentity\" which matches the name of a parsed entity instead of an unparsed entity declared.  (xmlconf/ibm/invalid/P56/ibm56i13.xml)")
end

it "ibm-invalid-P56-ibm56i14.xml (Section 3.3.1)" do
  assert_parses("xmlconf/ibm/invalid/P56/ibm56i14.xml", "xmlconf/ibm/invalid/P56/out/ibm56i14.xml", " Tests invalid TokenizedType which is against P56 VC: Entity Name. The value of the ENTITIES attribute \"sun\" is \"#image1 @image\" which does not meet the Names production.  (xmlconf/ibm/invalid/P56/ibm56i14.xml)")
end

it "ibm-invalid-P56-ibm56i15.xml (Section 3.3.1)" do
  assert_parses("xmlconf/ibm/invalid/P56/ibm56i15.xml", "xmlconf/ibm/invalid/P56/out/ibm56i15.xml", " Tests invalid TokenizedType which is against P56 VC: ENTITIES. The value of the ENTITIES attribute \"sun\" is \"image3 image4\" which does not match the names of two unparsed entities declared.  (xmlconf/ibm/invalid/P56/ibm56i15.xml)")
end

it "ibm-invalid-P56-ibm56i16.xml (Section 3.3.1)" do
  assert_parses("xmlconf/ibm/invalid/P56/ibm56i16.xml", "xmlconf/ibm/invalid/P56/out/ibm56i16.xml", " Tests invalid TokenizedType which is against P56 VC: ENTITIES. The value of the ENTITIES attribute \"sun\" is \"parsedentity1 parsedentity2\" which matches the names of two parsed entities instead of two unparsed entities declared.  (xmlconf/ibm/invalid/P56/ibm56i16.xml)")
end

it "ibm-invalid-P56-ibm56i17.xml (Section 3.3.1)" do
  assert_parses("xmlconf/ibm/invalid/P56/ibm56i17.xml", "xmlconf/ibm/invalid/P56/out/ibm56i17.xml", " Tests invalid TokenizedType which is against P56 VC: Name Token. The value of the NMTOKEN attribute \"thistoken\" is \"x : image\" which does not meet the Nmtoken production.  (xmlconf/ibm/invalid/P56/ibm56i17.xml)")
end

it "ibm-invalid-P56-ibm56i18.xml (Section 3.3.1)" do
  assert_parses("xmlconf/ibm/invalid/P56/ibm56i18.xml", "xmlconf/ibm/invalid/P56/out/ibm56i18.xml", " Tests invalid TokenizedType which is against P56 VC: Name Token. The value of the NMTOKENS attribute \"thistoken\" is \"@lang y: #country\" which does not meet the Nmtokens production.  (xmlconf/ibm/invalid/P56/ibm56i18.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 58" do
it "ibm-invalid-P58-ibm58i01.xml (Section 3.3.1)" do
  assert_parses("xmlconf/ibm/invalid/P58/ibm58i01.xml", "xmlconf/ibm/invalid/P58/out/ibm58i01.xml", " Tests invalid NotationType which is against P58 VC: Notation Attributes. The attribute \"content-encoding\" with value \"raw\" is not a value from the list \"(base64|uuencode)\".  (xmlconf/ibm/invalid/P58/ibm58i01.xml)")
end

it "ibm-invalid-P58-ibm58i02.xml (Section 3.3.1)" do
  assert_parses("xmlconf/ibm/invalid/P58/ibm58i02.xml", "xmlconf/ibm/invalid/P58/out/ibm58i02.xml", " Tests invalid NotationType which is against P58 VC: Notation Attributes. The attribute \"content-encoding\" with value \"raw\" is a value from the list \"(base64|uuencode|raw|ascii)\", but \"raw\" is not a declared notation.  (xmlconf/ibm/invalid/P58/ibm58i02.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 59" do
it "ibm-invalid-P59-ibm59i01.xml (Section 3.3.1)" do
  assert_parses("xmlconf/ibm/invalid/P59/ibm59i01.xml", "xmlconf/ibm/invalid/P59/out/ibm59i01.xml", " Tests invalid Enumeration which is against P59 VC: Enumeration. The value of the attribute is \"ONE\" which matches neither \"one\" nor \"two\" as declared in the Enumeration in the AttDef in the AttlistDecl.  (xmlconf/ibm/invalid/P59/ibm59i01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 60" do
it "ibm-invalid-P60-ibm60i01.xml (Section 3.3.2)" do
  assert_parses("xmlconf/ibm/invalid/P60/ibm60i01.xml", "xmlconf/ibm/invalid/P60/out/ibm60i01.xml", " Tests invalid DefaultDecl which is against P60 VC: Required Attribute. The attribute \"chapter\" for the element \"two\" is declared as #REQUIRED in the DefaultDecl in the AttlistDecl, but the value of this attribute is not given.  (xmlconf/ibm/invalid/P60/ibm60i01.xml)")
end

it "ibm-invalid-P60-ibm60i02.xml (Section 3.3.2)" do
  assert_parses("xmlconf/ibm/invalid/P60/ibm60i02.xml", "xmlconf/ibm/invalid/P60/out/ibm60i02.xml", " Tests invalid DefaultDecl which is against P60 VC: Fixed Attribute Default.. The attribute \"chapter\" for the element \"one\" is declared as #FIXED with the given value \"Introduction\" in the DefaultDecl in the AttlistDecl, but the value of a instance of this attribute is assigned to \"JavaBeans\".  (xmlconf/ibm/invalid/P60/ibm60i02.xml)")
end

it "ibm-invalid-P60-ibm60i03.xml (Section 3.3.2)" do
  assert_parses("xmlconf/ibm/invalid/P60/ibm60i03.xml", "xmlconf/ibm/invalid/P60/out/ibm60i03.xml", " Tests invalid DefaultDecl which is against P60 VC: Attribute Default Legal. The declared default value \"c\" is not legal for the type (a|b) in the AttDef in the AttlistDecl.  (xmlconf/ibm/invalid/P60/ibm60i03.xml)")
end

it "ibm-invalid-P60-ibm60i04.xml (Section 3.3.2)" do
  assert_parses("xmlconf/ibm/invalid/P60/ibm60i04.xml", "xmlconf/ibm/invalid/P60/out/ibm60i04.xml", " Tests invalid DefaultDecl which is against P60 VC: Attribute Default Legal. The declared default value \"@#$\" is not legal for the type NMTOKEN the AttDef in the AttlistDecl.  (xmlconf/ibm/invalid/P60/ibm60i04.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 68" do
it "ibm-invalid-P68-ibm68i01.xml (Section 4.1)" do
  assert_raises(" Tests invalid EntityRef which is against P68 VC: Entity Declared. The GE with the name \"ge2\" is referred in the file ibm68i01.dtd\", but not declared.  (xmlconf/ibm/invalid/P68/ibm68i01.xml)") do
    File.open("xmlconf/ibm/invalid/P68/ibm68i01.xml") { |file| XML::DOM.parse(file, base: "xmlconf/ibm/invalid/P68") }
  end
end

it "ibm-invalid-P68-ibm68i02.xml (Section 4.1)" do
  assert_raises(" Tests invalid EntityRef which is against P68 VC: Entity Declared. The GE with the name \"ge1\" is referred before declared in the file ibm68i01.dtd\".  (xmlconf/ibm/invalid/P68/ibm68i02.xml)") do
    File.open("xmlconf/ibm/invalid/P68/ibm68i02.xml") { |file| XML::DOM.parse(file, base: "xmlconf/ibm/invalid/P68") }
  end
end

it "ibm-invalid-P68-ibm68i03.xml (Section 4.1)" do
  assert_raises(" Tests invalid EntityRef which is against P68 VC: Entity Declared. The GE with the name \"ge2\" is referred in the file ibm68i03.ent\", but not declared.  (xmlconf/ibm/invalid/P68/ibm68i03.xml)") do
    File.open("xmlconf/ibm/invalid/P68/ibm68i03.xml") { |file| XML::DOM.parse(file, base: "xmlconf/ibm/invalid/P68") }
  end
end

it "ibm-invalid-P68-ibm68i04.xml (Section 4.1)" do
  assert_raises(" Tests invalid EntityRef which is against P68 VC: Entity Declared. The GE with the name \"ge1\" is referred before declared in the file ibm68i04.ent\".  (xmlconf/ibm/invalid/P68/ibm68i04.xml)") do
    File.open("xmlconf/ibm/invalid/P68/ibm68i04.xml") { |file| XML::DOM.parse(file, base: "xmlconf/ibm/invalid/P68") }
  end
end

end

describe "IBM XML Conformance Test Suite - Production 69" do
it "ibm-invalid-P69-ibm69i01.xml (Section 4.1)" do
  assert_raises(" Tests invalid PEReference which is against P69 VC: Entity Declared. The Name \"pe2\" in the PEReference in the file ibm69i01.dtd does not match the Name of any declared PE.  (xmlconf/ibm/invalid/P69/ibm69i01.xml)") do
    File.open("xmlconf/ibm/invalid/P69/ibm69i01.xml") { |file| XML::DOM.parse(file, base: "xmlconf/ibm/invalid/P69") }
  end
end

it "ibm-invalid-P69-ibm69i02.xml (Section 4.1)" do
  assert_raises(" Tests invalid PEReference which is against P69 VC: Entity Declared. The PE with the name \"pe1\" is referred before declared in the file ibm69i02.dtd  (xmlconf/ibm/invalid/P69/ibm69i02.xml)") do
    File.open("xmlconf/ibm/invalid/P69/ibm69i02.xml") { |file| XML::DOM.parse(file, base: "xmlconf/ibm/invalid/P69") }
  end
end

it "ibm-invalid-P69-ibm69i03.xml (Section 4.1)" do
  assert_raises(" Tests invalid PEReference which is against P69 VC: Entity Declared. The Name \"pe3\" in the PEReference in the file ibm69i03.ent does not match the Name of any declared PE.  (xmlconf/ibm/invalid/P69/ibm69i03.xml)") do
    File.open("xmlconf/ibm/invalid/P69/ibm69i03.xml") { |file| XML::DOM.parse(file, base: "xmlconf/ibm/invalid/P69") }
  end
end

it "ibm-invalid-P69-ibm69i04.xml (Section 4.1)" do
  assert_raises(" Tests invalid PEReference which is against P69 VC: Entity Declared. The PE with the name \"pe2\" is referred before declared in the file ibm69i04.ent.  (xmlconf/ibm/invalid/P69/ibm69i04.xml)") do
    File.open("xmlconf/ibm/invalid/P69/ibm69i04.xml") { |file| XML::DOM.parse(file, base: "xmlconf/ibm/invalid/P69") }
  end
end

end

describe "IBM XML Conformance Test Suite - Production 76" do
it "ibm-invalid-P76-ibm76i01.xml (Section 4.2.2)" do
  assert_parses("xmlconf/ibm/invalid/P76/ibm76i01.xml", "xmlconf/ibm/invalid/P76/out/ibm76i01.xml", " Tests invalid NDataDecl which is against P76 VC: Notation declared. The Name \"JPGformat\" in the NDataDecl in the EntityDecl for \"ge2\" does not match the Name of any declared notation.  (xmlconf/ibm/invalid/P76/ibm76i01.xml)")
end

end

end

describe "IBM XML Conformance Test Suite - not-wf tests" do
describe "IBM XML Conformance Test Suite - Production 1" do
it "ibm-not-wf-P01-ibm01n01.xml (Section 2.1)" do
  assert_raises(XML::Error, " Tests a document with no element. A well-formed document should have at lease one elements.  (xmlconf/ibm/not-wf/P01/ibm01n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P01/ibm01n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P01-ibm01n02.xml (Section 2.1)" do
  assert_raises(XML::Error, " Tests a document with wrong ordering of its prolog and element. The element occurs before the xml declaration and the DTD.  (xmlconf/ibm/not-wf/P01/ibm01n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P01/ibm01n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P01-ibm01n03.xml (Section 2.1)" do
  assert_raises(XML::Error, " Tests a document with wrong combination of misc and element. One PI occurs between two elements.  (xmlconf/ibm/not-wf/P01/ibm01n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P01/ibm01n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 2" do
it "ibm-not-wf-P02-ibm02n01.xml (Section 2.2)" do
  assert_raises(XML::Error, " Tests a comment which contains an illegal Char: #x00  (xmlconf/ibm/not-wf/P02/ibm02n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P02/ibm02n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P02-ibm02n02.xml (Section 2.2)" do
  assert_raises(XML::Error, " Tests a comment which contains an illegal Char: #x01  (xmlconf/ibm/not-wf/P02/ibm02n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P02/ibm02n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P02-ibm02n03.xml (Section 2.2)" do
  assert_raises(XML::Error, " Tests a comment which contains an illegal Char: #x02  (xmlconf/ibm/not-wf/P02/ibm02n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P02/ibm02n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P02-ibm02n04.xml (Section 2.2)" do
  assert_raises(XML::Error, " Tests a comment which contains an illegal Char: #x03  (xmlconf/ibm/not-wf/P02/ibm02n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P02/ibm02n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P02-ibm02n05.xml (Section 2.2)" do
  assert_raises(XML::Error, " Tests a comment which contains an illegal Char: #x04  (xmlconf/ibm/not-wf/P02/ibm02n05.xml)") do
    File.open("xmlconf/ibm/not-wf/P02/ibm02n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P02-ibm02n06.xml (Section 2.2)" do
  assert_raises(XML::Error, " Tests a comment which contains an illegal Char: #x05  (xmlconf/ibm/not-wf/P02/ibm02n06.xml)") do
    File.open("xmlconf/ibm/not-wf/P02/ibm02n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P02-ibm02n07.xml (Section 2.2)" do
  assert_raises(XML::Error, " Tests a comment which contains an illegal Char: #x06  (xmlconf/ibm/not-wf/P02/ibm02n07.xml)") do
    File.open("xmlconf/ibm/not-wf/P02/ibm02n07.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P02-ibm02n08.xml (Section 2.2)" do
  assert_raises(XML::Error, " Tests a comment which contains an illegal Char: #x07  (xmlconf/ibm/not-wf/P02/ibm02n08.xml)") do
    File.open("xmlconf/ibm/not-wf/P02/ibm02n08.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P02-ibm02n09.xml (Section 2.2)" do
  assert_raises(XML::Error, " Tests a comment which contains an illegal Char: #x08  (xmlconf/ibm/not-wf/P02/ibm02n09.xml)") do
    File.open("xmlconf/ibm/not-wf/P02/ibm02n09.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P02-ibm02n10.xml (Section 2.2)" do
  assert_raises(XML::Error, " Tests a comment which contains an illegal Char: #x0B  (xmlconf/ibm/not-wf/P02/ibm02n10.xml)") do
    File.open("xmlconf/ibm/not-wf/P02/ibm02n10.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P02-ibm02n11.xml (Section 2.2)" do
  assert_raises(XML::Error, " Tests a comment which contains an illegal Char: #x0C  (xmlconf/ibm/not-wf/P02/ibm02n11.xml)") do
    File.open("xmlconf/ibm/not-wf/P02/ibm02n11.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P02-ibm02n12.xml (Section 2.2)" do
  assert_raises(XML::Error, " Tests a comment which contains an illegal Char: #x0E  (xmlconf/ibm/not-wf/P02/ibm02n12.xml)") do
    File.open("xmlconf/ibm/not-wf/P02/ibm02n12.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P02-ibm02n13.xml (Section 2.2)" do
  assert_raises(XML::Error, " Tests a comment which contains an illegal Char: #x0F  (xmlconf/ibm/not-wf/P02/ibm02n13.xml)") do
    File.open("xmlconf/ibm/not-wf/P02/ibm02n13.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P02-ibm02n14.xml (Section 2.2)" do
  assert_raises(XML::Error, " Tests a comment which contains an illegal Char: #x10  (xmlconf/ibm/not-wf/P02/ibm02n14.xml)") do
    File.open("xmlconf/ibm/not-wf/P02/ibm02n14.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P02-ibm02n15.xml (Section 2.2)" do
  assert_raises(XML::Error, " Tests a comment which contains an illegal Char: #x11  (xmlconf/ibm/not-wf/P02/ibm02n15.xml)") do
    File.open("xmlconf/ibm/not-wf/P02/ibm02n15.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P02-ibm02n16.xml (Section 2.2)" do
  assert_raises(XML::Error, " Tests a comment which contains an illegal Char: #x12  (xmlconf/ibm/not-wf/P02/ibm02n16.xml)") do
    File.open("xmlconf/ibm/not-wf/P02/ibm02n16.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P02-ibm02n17.xml (Section 2.2)" do
  assert_raises(XML::Error, " Tests a comment which contains an illegal Char: #x13  (xmlconf/ibm/not-wf/P02/ibm02n17.xml)") do
    File.open("xmlconf/ibm/not-wf/P02/ibm02n17.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P02-ibm02n18.xml (Section 2.2)" do
  assert_raises(XML::Error, " Tests a comment which contains an illegal Char: #x14  (xmlconf/ibm/not-wf/P02/ibm02n18.xml)") do
    File.open("xmlconf/ibm/not-wf/P02/ibm02n18.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P02-ibm02n19.xml (Section 2.2)" do
  assert_raises(XML::Error, " Tests a comment which contains an illegal Char: #x15  (xmlconf/ibm/not-wf/P02/ibm02n19.xml)") do
    File.open("xmlconf/ibm/not-wf/P02/ibm02n19.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P02-ibm02n20.xml (Section 2.2)" do
  assert_raises(XML::Error, " Tests a comment which contains an illegal Char: #x16  (xmlconf/ibm/not-wf/P02/ibm02n20.xml)") do
    File.open("xmlconf/ibm/not-wf/P02/ibm02n20.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P02-ibm02n21.xml (Section 2.2)" do
  assert_raises(XML::Error, " Tests a comment which contains an illegal Char: #x17  (xmlconf/ibm/not-wf/P02/ibm02n21.xml)") do
    File.open("xmlconf/ibm/not-wf/P02/ibm02n21.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P02-ibm02n22.xml (Section 2.2)" do
  assert_raises(XML::Error, " Tests a comment which contains an illegal Char: #x18  (xmlconf/ibm/not-wf/P02/ibm02n22.xml)") do
    File.open("xmlconf/ibm/not-wf/P02/ibm02n22.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P02-ibm02n23.xml (Section 2.2)" do
  assert_raises(XML::Error, " Tests a comment which contains an illegal Char: #x19  (xmlconf/ibm/not-wf/P02/ibm02n23.xml)") do
    File.open("xmlconf/ibm/not-wf/P02/ibm02n23.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P02-ibm02n24.xml (Section 2.2)" do
  assert_raises(XML::Error, " Tests a comment which contains an illegal Char: #x1A  (xmlconf/ibm/not-wf/P02/ibm02n24.xml)") do
    File.open("xmlconf/ibm/not-wf/P02/ibm02n24.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P02-ibm02n25.xml (Section 2.2)" do
  assert_raises(XML::Error, " Tests a comment which contains an illegal Char: #x1B  (xmlconf/ibm/not-wf/P02/ibm02n25.xml)") do
    File.open("xmlconf/ibm/not-wf/P02/ibm02n25.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P02-ibm02n26.xml (Section 2.2)" do
  assert_raises(XML::Error, " Tests a comment which contains an illegal Char: #x1C  (xmlconf/ibm/not-wf/P02/ibm02n26.xml)") do
    File.open("xmlconf/ibm/not-wf/P02/ibm02n26.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P02-ibm02n27.xml (Section 2.2)" do
  assert_raises(XML::Error, " Tests a comment which contains an illegal Char: #x1D  (xmlconf/ibm/not-wf/P02/ibm02n27.xml)") do
    File.open("xmlconf/ibm/not-wf/P02/ibm02n27.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P02-ibm02n28.xml (Section 2.2)" do
  assert_raises(XML::Error, " Tests a comment which contains an illegal Char: #x1E  (xmlconf/ibm/not-wf/P02/ibm02n28.xml)") do
    File.open("xmlconf/ibm/not-wf/P02/ibm02n28.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P02-ibm02n29.xml (Section 2.2)" do
  assert_raises(XML::Error, " Tests a comment which contains an illegal Char: #x1F  (xmlconf/ibm/not-wf/P02/ibm02n29.xml)") do
    File.open("xmlconf/ibm/not-wf/P02/ibm02n29.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P02-ibm02n30.xml (Section 2.2)" do
  assert_raises(XML::Error, " Tests a comment which contains an illegal Char: #xD800  (xmlconf/ibm/not-wf/P02/ibm02n30.xml)") do
    File.open("xmlconf/ibm/not-wf/P02/ibm02n30.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P02-ibm02n31.xml (Section 2.2)" do
  assert_raises(XML::Error, " Tests a comment which contains an illegal Char: #xDFFF  (xmlconf/ibm/not-wf/P02/ibm02n31.xml)") do
    File.open("xmlconf/ibm/not-wf/P02/ibm02n31.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P02-ibm02n32.xml (Section 2.2)" do
  assert_raises(XML::Error, " Tests a comment which contains an illegal Char: #xFFFE  (xmlconf/ibm/not-wf/P02/ibm02n32.xml)") do
    File.open("xmlconf/ibm/not-wf/P02/ibm02n32.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P02-ibm02n33.xml (Section 2.2)" do
  assert_raises(XML::Error, " Tests a comment which contains an illegal Char: #xFFFF  (xmlconf/ibm/not-wf/P02/ibm02n33.xml)") do
    File.open("xmlconf/ibm/not-wf/P02/ibm02n33.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 3" do
it "ibm-not-wf-P03-ibm03n01.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an end tag which contains an illegal space character #x3000 which follows the element name \"book\".  (xmlconf/ibm/not-wf/P03/ibm03n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P03/ibm03n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 4" do
it "ibm-not-wf-P04-ibm04n01.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element name which contains an illegal ASCII NameChar. \"IllegalNameChar\" is followed by #x21  (xmlconf/ibm/not-wf/P04/ibm04n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P04/ibm04n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P04-ibm04n02.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element name which contains an illegal ASCII NameChar. \"IllegalNameChar\" is followed by #x28  (xmlconf/ibm/not-wf/P04/ibm04n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P04/ibm04n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P04-ibm04n03.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element name which contains an illegal ASCII NameChar. \"IllegalNameChar\" is followed by #x29  (xmlconf/ibm/not-wf/P04/ibm04n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P04/ibm04n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P04-ibm04n04.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element name which contains an illegal ASCII NameChar. \"IllegalNameChar\" is followed by #x2B  (xmlconf/ibm/not-wf/P04/ibm04n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P04/ibm04n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P04-ibm04n05.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element name which contains an illegal ASCII NameChar. \"IllegalNameChar\" is followed by #x2C  (xmlconf/ibm/not-wf/P04/ibm04n05.xml)") do
    File.open("xmlconf/ibm/not-wf/P04/ibm04n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P04-ibm04n06.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element name which contains an illegal ASCII NameChar. \"IllegalNameChar\" is followed by #x2F  (xmlconf/ibm/not-wf/P04/ibm04n06.xml)") do
    File.open("xmlconf/ibm/not-wf/P04/ibm04n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P04-ibm04n07.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element name which contains an illegal ASCII NameChar. \"IllegalNameChar\" is followed by #x3B  (xmlconf/ibm/not-wf/P04/ibm04n07.xml)") do
    File.open("xmlconf/ibm/not-wf/P04/ibm04n07.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P04-ibm04n08.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element name which contains an illegal ASCII NameChar. \"IllegalNameChar\" is followed by #x3C  (xmlconf/ibm/not-wf/P04/ibm04n08.xml)") do
    File.open("xmlconf/ibm/not-wf/P04/ibm04n08.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P04-ibm04n09.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element name which contains an illegal ASCII NameChar. \"IllegalNameChar\" is followed by #x3D  (xmlconf/ibm/not-wf/P04/ibm04n09.xml)") do
    File.open("xmlconf/ibm/not-wf/P04/ibm04n09.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P04-ibm04n10.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element name which contains an illegal ASCII NameChar. \"IllegalNameChar\" is followed by #x3F  (xmlconf/ibm/not-wf/P04/ibm04n10.xml)") do
    File.open("xmlconf/ibm/not-wf/P04/ibm04n10.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P04-ibm04n11.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element name which contains an illegal ASCII NameChar. \"IllegalNameChar\" is followed by #x5B  (xmlconf/ibm/not-wf/P04/ibm04n11.xml)") do
    File.open("xmlconf/ibm/not-wf/P04/ibm04n11.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P04-ibm04n12.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element name which contains an illegal ASCII NameChar. \"IllegalNameChar\" is followed by #x5C  (xmlconf/ibm/not-wf/P04/ibm04n12.xml)") do
    File.open("xmlconf/ibm/not-wf/P04/ibm04n12.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P04-ibm04n13.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element name which contains an illegal ASCII NameChar. \"IllegalNameChar\" is followed by #x5D  (xmlconf/ibm/not-wf/P04/ibm04n13.xml)") do
    File.open("xmlconf/ibm/not-wf/P04/ibm04n13.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P04-ibm04n14.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element name which contains an illegal ASCII NameChar. \"IllegalNameChar\" is followed by #x5E  (xmlconf/ibm/not-wf/P04/ibm04n14.xml)") do
    File.open("xmlconf/ibm/not-wf/P04/ibm04n14.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P04-ibm04n15.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element name which contains an illegal ASCII NameChar. \"IllegalNameChar\" is followed by #x60  (xmlconf/ibm/not-wf/P04/ibm04n15.xml)") do
    File.open("xmlconf/ibm/not-wf/P04/ibm04n15.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P04-ibm04n16.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element name which contains an illegal ASCII NameChar. \"IllegalNameChar\" is followed by #x7B  (xmlconf/ibm/not-wf/P04/ibm04n16.xml)") do
    File.open("xmlconf/ibm/not-wf/P04/ibm04n16.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P04-ibm04n17.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element name which contains an illegal ASCII NameChar. \"IllegalNameChar\" is followed by #x7C  (xmlconf/ibm/not-wf/P04/ibm04n17.xml)") do
    File.open("xmlconf/ibm/not-wf/P04/ibm04n17.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P04-ibm04n18.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element name which contains an illegal ASCII NameChar. \"IllegalNameChar\" is followed by #x7D  (xmlconf/ibm/not-wf/P04/ibm04n18.xml)") do
    File.open("xmlconf/ibm/not-wf/P04/ibm04n18.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 5" do
it "ibm-not-wf-P05-ibm05n01.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element name which has an illegal first character. An illegal first character \".\" is followed by \"A_name-starts_with.\".  (xmlconf/ibm/not-wf/P05/ibm05n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P05/ibm05n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P05-ibm05n02.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element name which has an illegal first character. An illegal first character \"-\" is followed by \"A_name-starts_with-\".  (xmlconf/ibm/not-wf/P05/ibm05n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P05/ibm05n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P05-ibm05n03.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element name which has an illegal first character. An illegal first character \"5\" is followed by \"A_name-starts_with_digit\".  (xmlconf/ibm/not-wf/P05/ibm05n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P05/ibm05n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 9" do
it "ibm-not-wf-P09-ibm09n01.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an internal general entity with an invalid value. The entity \"Fullname\" contains \"%\".  (xmlconf/ibm/not-wf/P09/ibm09n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P09/ibm09n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P09-ibm09n02.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an internal general entity with an invalid value. The entity \"Fullname\" contains the ampersand character.  (xmlconf/ibm/not-wf/P09/ibm09n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P09/ibm09n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P09-ibm09n03.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an internal general entity with an invalid value. The entity \"Fullname\" contains the double quote character in the middle.  (xmlconf/ibm/not-wf/P09/ibm09n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P09/ibm09n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P09-ibm09n04.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an internal general entity with an invalid value. The closing bracket (double quote) is missing with the value of the entity \"FullName\".  (xmlconf/ibm/not-wf/P09/ibm09n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P09/ibm09n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 10" do
it "ibm-not-wf-P10-ibm10n01.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an attribute with an invalid value. The value of the attribute \"first\" contains the character \"less than\".  (xmlconf/ibm/not-wf/P10/ibm10n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P10/ibm10n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P10-ibm10n02.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an attribute with an invalid value. The value of the attribute \"first\" contains the character ampersand.  (xmlconf/ibm/not-wf/P10/ibm10n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P10/ibm10n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P10-ibm10n03.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an attribute with an invalid value. The value of the attribute \"first\" contains the double quote character in the middle.  (xmlconf/ibm/not-wf/P10/ibm10n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P10/ibm10n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P10-ibm10n04.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an attribute with an invalid value. The closing bracket (double quote) is missing with The value of the attribute \"first\".  (xmlconf/ibm/not-wf/P10/ibm10n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P10/ibm10n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P10-ibm10n05.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an attribute with an invalid value. The value of the attribute \"first\" contains the character \"less than\".  (xmlconf/ibm/not-wf/P10/ibm10n05.xml)") do
    File.open("xmlconf/ibm/not-wf/P10/ibm10n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P10-ibm10n06.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an attribute with an invalid value. The value of the attribute \"first\" contains the character ampersand.  (xmlconf/ibm/not-wf/P10/ibm10n06.xml)") do
    File.open("xmlconf/ibm/not-wf/P10/ibm10n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P10-ibm10n07.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an attribute with an invalid value. The value of the attribute \"first\" contains the double quote character in the middle.  (xmlconf/ibm/not-wf/P10/ibm10n07.xml)") do
    File.open("xmlconf/ibm/not-wf/P10/ibm10n07.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P10-ibm10n08.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an attribute with an invalid value. The closing bracket (single quote) is missing with the value of the attribute \"first\".  (xmlconf/ibm/not-wf/P10/ibm10n08.xml)") do
    File.open("xmlconf/ibm/not-wf/P10/ibm10n08.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 11" do
it "ibm-not-wf-P11-ibm11n01.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests SystemLiteral. The systemLiteral for the element \"student\" has a double quote character in the middle.  (xmlconf/ibm/not-wf/P11/ibm11n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P11/ibm11n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P11-ibm11n02.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests SystemLiteral. The systemLiteral for the element \"student\" has a single quote character in the middle.  (xmlconf/ibm/not-wf/P11/ibm11n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P11/ibm11n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P11-ibm11n03.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests SystemLiteral. The closing bracket (double quote) is missing with the systemLiteral for the element \"student\".  (xmlconf/ibm/not-wf/P11/ibm11n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P11/ibm11n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P11-ibm11n04.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests SystemLiteral. The closing bracket (single quote) is missing with the systemLiteral for the element \"student\".  (xmlconf/ibm/not-wf/P11/ibm11n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P11/ibm11n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 12" do
it "ibm-not-wf-P12-ibm12n01.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests PubidLiteral. The closing bracket (double quote) is missing with the value of the PubidLiteral for the entity \"info\".  (xmlconf/ibm/not-wf/P12/ibm12n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P12/ibm12n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P12-ibm12n02.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests PubidLiteral. The value of the PubidLiteral for the entity \"info\" has a single quote character in the middle..  (xmlconf/ibm/not-wf/P12/ibm12n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P12/ibm12n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P12-ibm12n03.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests PubidLiteral. The closing bracket (single quote) is missing with the value of the PubidLiteral for the entity \"info\".  (xmlconf/ibm/not-wf/P12/ibm12n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P12/ibm12n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 13" do
it "ibm-not-wf-P13-ibm13n01.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests PubidChar. The pubidChar of the PubidLiteral for the entity \"info\" contains the character \"{\".  (xmlconf/ibm/not-wf/P13/ibm13n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P13/ibm13n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P13-ibm13n02.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests PubidChar. The pubidChar of the PubidLiteral for the entity \"info\" contains the character \"~\".  (xmlconf/ibm/not-wf/P13/ibm13n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P13/ibm13n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P13-ibm13n03.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests PubidChar. The pubidChar of the PubidLiteral for the entity \"info\" contains the character double quote in the middle.  (xmlconf/ibm/not-wf/P13/ibm13n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P13/ibm13n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 14" do
it "ibm-not-wf-P14-ibm14n01.xml (Section 2.4)" do
  assert_raises(XML::Error, " Tests CharData. The content of the element \"student\" contains the sequence close-bracket close-bracket greater-than.  (xmlconf/ibm/not-wf/P14/ibm14n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P14/ibm14n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P14-ibm14n02.xml (Section 2.4)" do
  assert_raises(XML::Error, " Tests CharData. The content of the element \"student\" contains the character \"less than\".  (xmlconf/ibm/not-wf/P14/ibm14n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P14/ibm14n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P14-ibm14n03.xml (Section 2.4)" do
  assert_raises(XML::Error, " Tests CharData. The content of the element \"student\" contains the character ampersand.  (xmlconf/ibm/not-wf/P14/ibm14n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P14/ibm14n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 15" do
it "ibm-not-wf-P15-ibm15n01.xml (Section 2.5)" do
  assert_raises(XML::Error, " Tests comment. The text of the second comment contains the character \"-\".  (xmlconf/ibm/not-wf/P15/ibm15n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P15/ibm15n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P15-ibm15n02.xml (Section 2.5)" do
  assert_raises(XML::Error, " Tests comment. The second comment has a wrong closing sequence \"-(greater than)\".  (xmlconf/ibm/not-wf/P15/ibm15n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P15/ibm15n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P15-ibm15n03.xml (Section 2.5)" do
  assert_raises(XML::Error, " Tests comment. The second comment has a wrong beginning sequence \"(less than)!-\".  (xmlconf/ibm/not-wf/P15/ibm15n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P15/ibm15n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P15-ibm15n04.xml (Section 2.5)" do
  assert_raises(XML::Error, " Tests comment. The closing sequence is missing with the second comment.  (xmlconf/ibm/not-wf/P15/ibm15n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P15/ibm15n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 16" do
it "ibm-not-wf-P16-ibm16n01.xml (Section 2.6)" do
  assert_raises(XML::Error, " Tests PI. The content of the PI includes the sequence \"?(greater than)?\".  (xmlconf/ibm/not-wf/P16/ibm16n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P16/ibm16n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P16-ibm16n02.xml (Section 2.6)" do
  assert_raises(XML::Error, " Tests PI. The PITarget is missing in the PI.  (xmlconf/ibm/not-wf/P16/ibm16n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P16/ibm16n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P16-ibm16n03.xml (Section 2.6)" do
  assert_raises(XML::Error, " Tests PI. The PI has a wrong closing sequence \">\".  (xmlconf/ibm/not-wf/P16/ibm16n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P16/ibm16n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P16-ibm16n04.xml (Section 2.6)" do
  assert_raises(XML::Error, " Tests PI. The closing sequence is missing in the PI.  (xmlconf/ibm/not-wf/P16/ibm16n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P16/ibm16n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 17" do
it "ibm-not-wf-P17-ibm17n01.xml (Section 2.6)" do
  assert_raises(XML::Error, " Tests PITarget. The PITarget contains the string \"XML\".  (xmlconf/ibm/not-wf/P17/ibm17n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P17/ibm17n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P17-ibm17n02.xml (Section 2.6)" do
  assert_raises(XML::Error, " Tests PITarget. The PITarget contains the string \"xML\".  (xmlconf/ibm/not-wf/P17/ibm17n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P17/ibm17n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P17-ibm17n03.xml (Section 2.6)" do
  assert_raises(XML::Error, " Tests PITarget. The PITarget contains the string \"xml\".  (xmlconf/ibm/not-wf/P17/ibm17n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P17/ibm17n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P17-ibm17n04.xml (Section 2.6)" do
  assert_raises(XML::Error, " Tests PITarget. The PITarget contains the string \"xmL\".  (xmlconf/ibm/not-wf/P17/ibm17n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P17/ibm17n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 18" do
it "ibm-not-wf-P18-ibm18n01.xml (Section 2.7)" do
  assert_raises(XML::Error, " Tests CDSect. The CDStart is missing in the CDSect in the content of element \"student\".  (xmlconf/ibm/not-wf/P18/ibm18n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P18/ibm18n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P18-ibm18n02.xml (Section 2.7)" do
  assert_raises(XML::Error, " Tests CDSect. The CDEnd is missing in the CDSect in the content of element \"student\".  (xmlconf/ibm/not-wf/P18/ibm18n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P18/ibm18n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 19" do
it "ibm-not-wf-P19-ibm19n01.xml (Section 2.7)" do
  assert_raises(XML::Error, " Tests CDStart. The CDStart contains a lower case string \"cdata\".  (xmlconf/ibm/not-wf/P19/ibm19n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P19/ibm19n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P19-ibm19n02.xml (Section 2.7)" do
  assert_raises(XML::Error, " Tests CDStart. The CDStart contains an extra character \"[\".  (xmlconf/ibm/not-wf/P19/ibm19n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P19/ibm19n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P19-ibm19n03.xml (Section 2.7)" do
  assert_raises(XML::Error, " Tests CDStart. The CDStart contains a wrong character \"?\".  (xmlconf/ibm/not-wf/P19/ibm19n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P19/ibm19n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 20" do
it "ibm-not-wf-P20-ibm20n01.xml (Section 2.7)" do
  assert_raises(XML::Error, " Tests CDATA with an illegal sequence. The CDATA contains the sequence close-bracket close-bracket greater-than.  (xmlconf/ibm/not-wf/P20/ibm20n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P20/ibm20n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 21" do
it "ibm-not-wf-P21-ibm21n01.xml (Section 2.7)" do
  assert_raises(XML::Error, " Tests CDEnd. One \"]\" is missing in the CDEnd.  (xmlconf/ibm/not-wf/P21/ibm21n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P21/ibm21n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P21-ibm21n02.xml (Section 2.7)" do
  assert_raises(XML::Error, " Tests CDEnd. An extra \"]\" is placed in the CDEnd.  (xmlconf/ibm/not-wf/P21/ibm21n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P21/ibm21n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P21-ibm21n03.xml (Section 2.7)" do
  assert_raises(XML::Error, " Tests CDEnd. A wrong character \")\" is placed in the CDEnd.  (xmlconf/ibm/not-wf/P21/ibm21n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P21/ibm21n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 22" do
it "ibm-not-wf-P22-ibm22n01.xml (Section 2.8)" do
  assert_raises(XML::Error, " Tests prolog with wrong field ordering. The XMLDecl occurs after the DTD.  (xmlconf/ibm/not-wf/P22/ibm22n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P22/ibm22n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P22-ibm22n02.xml (Section 2.8)" do
  assert_raises(XML::Error, " Tests prolog with wrong field ordering. The Misc (comment) occurs before the XMLDecl.  (xmlconf/ibm/not-wf/P22/ibm22n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P22/ibm22n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P22-ibm22n03.xml (Section 2.8)" do
  assert_raises(XML::Error, " Tests prolog with wrong field ordering. The XMLDecl occurs after the DTD and a comment. The other comment occurs before the DTD.  (xmlconf/ibm/not-wf/P22/ibm22n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P22/ibm22n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 23" do
it "ibm-not-wf-P23-ibm23n01.xml (Section 2.8)" do
  assert_raises(XML::Error, " Tests XMLDecl with a required field missing. The Versioninfo is missing in the XMLDecl.  (xmlconf/ibm/not-wf/P23/ibm23n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P23/ibm23n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P23-ibm23n02.xml (Section 2.8)" do
  assert_raises(XML::Error, " Tests XMLDecl with wrong field ordering. The VersionInfo occurs after the EncodingDecl.  (xmlconf/ibm/not-wf/P23/ibm23n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P23/ibm23n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P23-ibm23n03.xml (Section 2.8)" do
  assert_raises(XML::Error, " Tests XMLDecl with wrong field ordering. The VersionInfo occurs after the SDDecl and the SDDecl occurs after the VersionInfo.  (xmlconf/ibm/not-wf/P23/ibm23n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P23/ibm23n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P23-ibm23n04.xml (Section 2.8)" do
  assert_raises(XML::Error, " Tests XMLDecl with wrong key word. An upper case string \"XML\" is used as the key word in the XMLDecl.  (xmlconf/ibm/not-wf/P23/ibm23n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P23/ibm23n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P23-ibm23n05.xml (Section 2.8)" do
  assert_raises(XML::Error, " Tests XMLDecl with a wrong closing sequence \">\".  (xmlconf/ibm/not-wf/P23/ibm23n05.xml)") do
    File.open("xmlconf/ibm/not-wf/P23/ibm23n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P23-ibm23n06.xml (Section 2.8)" do
  assert_raises(XML::Error, " Tests XMLDecl with a wrong opening sequence \"(less than)!\".  (xmlconf/ibm/not-wf/P23/ibm23n06.xml)") do
    File.open("xmlconf/ibm/not-wf/P23/ibm23n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 24" do
it "ibm-not-wf-P24-ibm24n01.xml (Section 2.8)" do
  assert_raises(XML::Error, " Tests VersionInfo with a required field missing. The VersionNum is missing in the VersionInfo in the XMLDecl.  (xmlconf/ibm/not-wf/P24/ibm24n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P24/ibm24n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P24-ibm24n02.xml (Section 2.8)" do
  assert_raises(XML::Error, " Tests VersionInfo with a required field missing. The white space is missing between the key word \"xml\" and the VersionInfo in the XMLDecl.  (xmlconf/ibm/not-wf/P24/ibm24n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P24/ibm24n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P24-ibm24n03.xml (Section 2.8)" do
  assert_raises(XML::Error, " Tests VersionInfo with a required field missing. The \"=\" (equal sign) is missing between the key word \"version\" and the VersionNum.  (xmlconf/ibm/not-wf/P24/ibm24n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P24/ibm24n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P24-ibm24n04.xml (Section 2.8)" do
  assert_raises(XML::Error, " Tests VersionInfo with wrong field ordering. The VersionNum occurs before \"=\" and \"version\".  (xmlconf/ibm/not-wf/P24/ibm24n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P24/ibm24n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P24-ibm24n05.xml (Section 2.8)" do
  assert_raises(XML::Error, " Tests VersionInfo with wrong field ordering. The \"=\" occurs after \"version\" and the VersionNum.  (xmlconf/ibm/not-wf/P24/ibm24n05.xml)") do
    File.open("xmlconf/ibm/not-wf/P24/ibm24n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P24-ibm24n06.xml (Section 2.8)" do
  assert_raises(XML::Error, " Tests VersionInfo with the wrong key word \"Version\".  (xmlconf/ibm/not-wf/P24/ibm24n06.xml)") do
    File.open("xmlconf/ibm/not-wf/P24/ibm24n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P24-ibm24n07.xml (Section 2.8)" do
  assert_raises(XML::Error, " Tests VersionInfo with the wrong key word \"versioN\".  (xmlconf/ibm/not-wf/P24/ibm24n07.xml)") do
    File.open("xmlconf/ibm/not-wf/P24/ibm24n07.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P24-ibm24n08.xml (Section 2.8)" do
  assert_raises(XML::Error, " Tests VersionInfo with mismatched quotes around the VersionNum. version = '1.0\" is used as the VersionInfo.  (xmlconf/ibm/not-wf/P24/ibm24n08.xml)") do
    File.open("xmlconf/ibm/not-wf/P24/ibm24n08.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P24-ibm24n09.xml (Section 2.8)" do
  assert_raises(XML::Error, " Tests VersionInfo with mismatched quotes around the VersionNum. The closing bracket for the VersionNum is missing.  (xmlconf/ibm/not-wf/P24/ibm24n09.xml)") do
    File.open("xmlconf/ibm/not-wf/P24/ibm24n09.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 25" do
it "ibm-not-wf-P25-ibm25n01.xml (Section 2.8)" do
  assert_raises(XML::Error, " Tests eq with a wrong key word \"==\".  (xmlconf/ibm/not-wf/P25/ibm25n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P25/ibm25n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P25-ibm25n02.xml (Section 2.8)" do
  assert_raises(XML::Error, " Tests eq with a wrong key word \"eq\".  (xmlconf/ibm/not-wf/P25/ibm25n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P25/ibm25n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 26" do
it "ibm-not-wf-P26-ibm26n01.xml (Section 2.8)" do
  assert_raises(XML::Error, " Tests VersionNum with an illegal character \"#\".  (xmlconf/ibm/not-wf/P26/ibm26n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P26/ibm26n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 27" do
it "ibm-not-wf-P27-ibm27n01.xml (Section 2.8)" do
  assert_raises(XML::Error, " Tests type of Misc. An element declaration is used as a type of Misc After the element \"animal\".  (xmlconf/ibm/not-wf/P27/ibm27n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P27/ibm27n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 28" do
it "ibm-not-wf-P28-ibm28n01.xml (Section 2.8)" do
  assert_raises(XML::Error, " Tests doctypedecl with a required field missing. The Name \"animal\" is missing in the doctypedecl.  (xmlconf/ibm/not-wf/P28/ibm28n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P28/ibm28n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P28-ibm28n02.xml (Section 2.8)" do
  assert_raises(XML::Error, " Tests doctypedecl with wrong field ordering. The Name \"animal\" occurs after the markup declarations inside the \"[]\".  (xmlconf/ibm/not-wf/P28/ibm28n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P28/ibm28n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P28-ibm28n03.xml (Section 2.8)" do
  assert_raises(XML::Error, " Tests doctypedecl with wrong field ordering. The Name \"animal\" occurs after the markup declarations inside the \"[]\".  (xmlconf/ibm/not-wf/P28/ibm28n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P28/ibm28n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P28-ibm28n04.xml (Section 2.8)" do
  assert_raises(XML::Error, " Tests doctypedecl with general entity reference.The \"(ampersand)generalE\" occurs in the DTD.  (xmlconf/ibm/not-wf/P28/ibm28n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P28/ibm28n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P28-ibm28n05.xml (Section 2.8)" do
  assert_raises(XML::Error, " Tests doctypedecl with wrong key word. A wrong key word \"DOCtYPE\" occurs on line 2.  (xmlconf/ibm/not-wf/P28/ibm28n05.xml)") do
    File.open("xmlconf/ibm/not-wf/P28/ibm28n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P28-ibm28n06.xml (Section 2.8)" do
  assert_raises(XML::Error, " Tests doctypedecl with mismatched brackets. The closing bracket \"]\" of the DTD is missing.  (xmlconf/ibm/not-wf/P28/ibm28n06.xml)") do
    File.open("xmlconf/ibm/not-wf/P28/ibm28n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P28-ibm28n07.xml (Section 2.8)" do
  assert_raises(XML::Error, " Tests doctypedecl with wrong bracket. The opening bracket \"{\" occurs in the DTD.  (xmlconf/ibm/not-wf/P28/ibm28n07.xml)") do
    File.open("xmlconf/ibm/not-wf/P28/ibm28n07.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P28-ibm28n08.xml (Section 2.8)" do
  assert_raises(XML::Error, " Tests doctypedecl with wrong opening sequence. The opening sequence \"(less than)?DOCTYPE\" occurs in the DTD.  (xmlconf/ibm/not-wf/P28/ibm28n08.xml)") do
    File.open("xmlconf/ibm/not-wf/P28/ibm28n08.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 28a" do
it "ibm-not-wf-p28a-ibm28an01.xml (Section 2.8)" do
  assert_raises(XML::Error, " This test violates WFC:PE Between Declarations in Production 28a. The last character of a markup declaration is not contained in the same parameter-entity text replacement.  (xmlconf/ibm/not-wf/p28a/ibm28an01.xml)") do
    File.open("xmlconf/ibm/not-wf/p28a/ibm28an01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 29" do
it "ibm-not-wf-P29-ibm29n01.xml (Section 2.8)" do
  assert_raises(XML::Error, " Tests markupdecl with an illegal markup declaration. A XMLDecl occurs inside the DTD.  (xmlconf/ibm/not-wf/P29/ibm29n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P29/ibm29n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P29-ibm29n02.xml (Section 2.8)" do
  assert_raises(XML::Error, " Tests WFC \"PEs in Internal Subset\". A PE reference occurs inside an elementdecl in the DTD.  (xmlconf/ibm/not-wf/P29/ibm29n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P29/ibm29n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P29-ibm29n03.xml (Section 2.8)" do
  assert_raises(XML::Error, " Tests WFC \"PEs in Internal Subset\". A PE reference occurs inside an ATTlistDecl in the DTD.  (xmlconf/ibm/not-wf/P29/ibm29n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P29/ibm29n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P29-ibm29n04.xml (Section 2.8)" do
  assert_raises(XML::Error, " Tests WFC \"PEs in Internal Subset\". A PE reference occurs inside an EntityDecl in the DTD.  (xmlconf/ibm/not-wf/P29/ibm29n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P29/ibm29n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P29-ibm29n05.xml (Section 2.8)" do
  assert_raises(XML::Error, " Tests WFC \"PEs in Internal Subset\". A PE reference occurs inside a PI in the DTD.  (xmlconf/ibm/not-wf/P29/ibm29n05.xml)") do
    File.open("xmlconf/ibm/not-wf/P29/ibm29n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P29-ibm29n06.xml (Section 2.8)" do
  assert_raises(XML::Error, " Tests WFC \"PEs in Internal Subset\". A PE reference occurs inside a comment in the DTD.  (xmlconf/ibm/not-wf/P29/ibm29n06.xml)") do
    File.open("xmlconf/ibm/not-wf/P29/ibm29n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P29-ibm29n07.xml (Section 2.8)" do
  assert_raises(XML::Error, " Tests WFC \"PEs in Internal Subset\". A PE reference occurs inside a NotationDecl in the DTD.  (xmlconf/ibm/not-wf/P29/ibm29n07.xml)") do
    File.open("xmlconf/ibm/not-wf/P29/ibm29n07.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 30" do
it "ibm-not-wf-P30-ibm30n01.xml (Section 2.8)" do
  assert_raises(XML::Error, " Tests extSubset with wrong field ordering. In the file \"ibm30n01.dtd\", the TextDecl occurs after the extSubsetDecl (the element declaration).  (xmlconf/ibm/not-wf/P30/ibm30n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P30/ibm30n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 31" do
it "ibm-not-wf-P31-ibm31n01.xml (Section 2.8)" do
  assert_raises(XML::Error, " Tests extSubsetDecl with an illegal field. A general entity reference occurs in file \"ibm31n01.dtd\".  (xmlconf/ibm/not-wf/P31/ibm31n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P31/ibm31n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 32" do
it "ibm-not-wf-P32-ibm32n01.xml (Section 2.9)" do
  assert_raises(XML::Error, " Tests SDDecl with a required field missing. The leading white space is missing with the SDDecl in the XMLDecl.  (xmlconf/ibm/not-wf/P32/ibm32n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P32/ibm32n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P32-ibm32n02.xml (Section 2.9)" do
  assert_raises(XML::Error, " Tests SDDecl with a required field missing. The \"=\" sign is missing in the SDDecl in the XMLDecl.  (xmlconf/ibm/not-wf/P32/ibm32n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P32/ibm32n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P32-ibm32n03.xml (Section 2.9)" do
  assert_raises(XML::Error, " Tests SDDecl with wrong key word. The word \"Standalone\" occurs in the SDDecl in the XMLDecl.  (xmlconf/ibm/not-wf/P32/ibm32n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P32/ibm32n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P32-ibm32n04.xml (Section 2.9)" do
  assert_raises(XML::Error, " Tests SDDecl with wrong key word. The word \"Yes\" occurs in the SDDecl in the XMLDecl.  (xmlconf/ibm/not-wf/P32/ibm32n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P32/ibm32n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P32-ibm32n05.xml (Section 2.9)" do
  assert_raises(XML::Error, " Tests SDDecl with wrong key word. The word \"YES\" occurs in the SDDecl in the XMLDecl.  (xmlconf/ibm/not-wf/P32/ibm32n05.xml)") do
    File.open("xmlconf/ibm/not-wf/P32/ibm32n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P32-ibm32n06.xml (Section 2.9)" do
  assert_raises(XML::Error, " Tests SDDecl with wrong key word. The word \"No\" occurs in the SDDecl in the XMLDecl.  (xmlconf/ibm/not-wf/P32/ibm32n06.xml)") do
    File.open("xmlconf/ibm/not-wf/P32/ibm32n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P32-ibm32n07.xml (Section 2.9)" do
  assert_raises(XML::Error, " Tests SDDecl with wrong key word. The word \"NO\" occurs in the SDDecl in the XMLDecl.  (xmlconf/ibm/not-wf/P32/ibm32n07.xml)") do
    File.open("xmlconf/ibm/not-wf/P32/ibm32n07.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P32-ibm32n08.xml (Section 2.9)" do
  assert_raises(XML::Error, " Tests SDDecl with wrong field ordering. The \"=\" sign occurs after the key word \"yes\" in the SDDecl in the XMLDecl.  (xmlconf/ibm/not-wf/P32/ibm32n08.xml)") do
    File.open("xmlconf/ibm/not-wf/P32/ibm32n08.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P32-ibm32n09.xml (Section 2.9)" do
  assert_raises(XML::Error, " This is test violates WFC: Entity Declared in P68. The standalone document declaration has the value yes, BUT there is an external markup declaration of an entity (other than amp, lt, gt, apos, quot), and references to this entity appear in the document.  (xmlconf/ibm/not-wf/P32/ibm32n09.xml)") do
    File.open("xmlconf/ibm/not-wf/P32/ibm32n09.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 39" do
it "ibm-not-wf-P39-ibm39n01.xml (Section 3)" do
  assert_raises(XML::Error, " Tests element with a required field missing. The ETag is missing for the element \"root\".  (xmlconf/ibm/not-wf/P39/ibm39n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P39/ibm39n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P39-ibm39n02.xml (Section 3)" do
  assert_raises(XML::Error, " Tests element with a required field missing. The STag is missing for the element \"root\".  (xmlconf/ibm/not-wf/P39/ibm39n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P39/ibm39n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P39-ibm39n03.xml (Section 3)" do
  assert_raises(XML::Error, " Tests element with required fields missing. Both the content and the ETag are missing in the element \"root\".  (xmlconf/ibm/not-wf/P39/ibm39n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P39/ibm39n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P39-ibm39n04.xml (Section 3)" do
  assert_raises(XML::Error, " Tests element with required fields missing. Both the content and the STag are missing in the element \"root\".  (xmlconf/ibm/not-wf/P39/ibm39n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P39/ibm39n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P39-ibm39n05.xml (Section 3)" do
  assert_raises(XML::Error, " Tests element with wrong field ordering. The STag and the ETag are swapped in the element \"root\".  (xmlconf/ibm/not-wf/P39/ibm39n05.xml)") do
    File.open("xmlconf/ibm/not-wf/P39/ibm39n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P39-ibm39n06.xml (Section 3)" do
  assert_raises(XML::Error, " Tests element with wrong field ordering. The content occurs after the ETag of the element \"root\".  (xmlconf/ibm/not-wf/P39/ibm39n06.xml)") do
    File.open("xmlconf/ibm/not-wf/P39/ibm39n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 40" do
it "ibm-not-wf-P40-ibm40n01.xml (Section 3.1)" do
  assert_raises(XML::Error, " Tests STag with a required field missing. The Name \"root\" is in the STag of the element \"root\".  (xmlconf/ibm/not-wf/P40/ibm40n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P40/ibm40n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P40-ibm40n02.xml (Section 3.1)" do
  assert_raises(XML::Error, " Tests STag with a required field missing. The white space between the Name \"root\" and the attribute \"attr1\" is missing in the STag of the element \"root\".  (xmlconf/ibm/not-wf/P40/ibm40n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P40/ibm40n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P40-ibm40n03.xml (Section 3.1)" do
  assert_raises(XML::Error, " Tests STag with wrong field ordering. The Name \"root\" occurs after the attribute \"attr1\" in the STag of the element \"root\".  (xmlconf/ibm/not-wf/P40/ibm40n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P40/ibm40n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P40-ibm40n04.xml (Section 3.1)" do
  assert_raises(XML::Error, " Tests STag with a wrong opening sequence. The string \"(less than)!\" is used as the opening sequence for the STag of the element \"root\".  (xmlconf/ibm/not-wf/P40/ibm40n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P40/ibm40n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P40-ibm40n05.xml (Section 3.1)" do
  assert_raises(XML::Error, " Tests STag with duplicate attribute names. The attribute name \"attr1\" occurs twice in the STag of the element \"root\".  (xmlconf/ibm/not-wf/P40/ibm40n05.xml)") do
    File.open("xmlconf/ibm/not-wf/P40/ibm40n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 41" do
it "ibm-not-wf-P41-ibm41n01.xml (Section 3.1)" do
  assert_raises(XML::Error, " Tests Attribute with a required field missing. The attribute name is missing in the Attribute in the STag of the element \"root\".  (xmlconf/ibm/not-wf/P41/ibm41n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P41/ibm41n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P41-ibm41n02.xml (Section 3.1)" do
  assert_raises(XML::Error, " Tests Attribute with a required field missing. The \"=\" is missing between the attribute name and the attribute value in the Attribute in the STag of the element \"root\".  (xmlconf/ibm/not-wf/P41/ibm41n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P41/ibm41n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P41-ibm41n03.xml (Section 3.1)" do
  assert_raises(XML::Error, " Tests Attribute with a required field missing. The AttValue is missing in the Attribute in the STag of the element \"root\".  (xmlconf/ibm/not-wf/P41/ibm41n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P41/ibm41n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P41-ibm41n04.xml (Section 3.1)" do
  assert_raises(XML::Error, " Tests Attribute with a required field missing. The Name and the \"=\" are missing in the Attribute in the STag of the element \"root\".  (xmlconf/ibm/not-wf/P41/ibm41n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P41/ibm41n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P41-ibm41n05.xml (Section 3.1)" do
  assert_raises(XML::Error, " Tests Attribute with a required field missing. The \"=\" and the AttValue are missing in the Attribute in the STag of the element \"root\".  (xmlconf/ibm/not-wf/P41/ibm41n05.xml)") do
    File.open("xmlconf/ibm/not-wf/P41/ibm41n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P41-ibm41n06.xml (Section 3.1)" do
  assert_raises(XML::Error, " Tests Attribute with a required field missing. The Name and the AttValue are missing in the Attribute in the STag of the element \"root\".  (xmlconf/ibm/not-wf/P41/ibm41n06.xml)") do
    File.open("xmlconf/ibm/not-wf/P41/ibm41n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P41-ibm41n07.xml (Section 3.1)" do
  assert_raises(XML::Error, " Tests Attribute with wrong field ordering. The \"=\" occurs after the Name and the AttValue in the Attribute in the STag of the element \"root\".  (xmlconf/ibm/not-wf/P41/ibm41n07.xml)") do
    File.open("xmlconf/ibm/not-wf/P41/ibm41n07.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P41-ibm41n08.xml (Section 3.1)" do
  assert_raises(XML::Error, " Tests Attribute with wrong field ordering. The Name and the AttValue are swapped in the Attribute in the STag of the element \"root\".  (xmlconf/ibm/not-wf/P41/ibm41n08.xml)") do
    File.open("xmlconf/ibm/not-wf/P41/ibm41n08.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P41-ibm41n09.xml (Section 3.1)" do
  assert_raises(XML::Error, " Tests Attribute with wrong field ordering. The \"=\" occurs before the Name and the AttValue in the Attribute in the STag of the element \"root\".  (xmlconf/ibm/not-wf/P41/ibm41n09.xml)") do
    File.open("xmlconf/ibm/not-wf/P41/ibm41n09.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P41-ibm41n10.xml (Section 3.1)" do
  assert_raises(XML::Error, " Tests Attribute against WFC \"no external entity references\". A direct reference to the external entity \"aExternal\" is contained in the value of the attribute \"attr1\".  (xmlconf/ibm/not-wf/P41/ibm41n10.xml)") do
    File.open("xmlconf/ibm/not-wf/P41/ibm41n10.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P41-ibm41n11.xml (Section 3.1)" do
  assert_raises(XML::Error, " Tests Attribute against WFC \"no external entity references\". A indirect reference to the external entity \"aExternal\" is contained in the value of the attribute \"attr1\".  (xmlconf/ibm/not-wf/P41/ibm41n11.xml)") do
    File.open("xmlconf/ibm/not-wf/P41/ibm41n11.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P41-ibm41n12.xml (Section 3.1)" do
  assert_raises(XML::Error, " Tests Attribute against WFC \"no external entity references\". A direct reference to the external unparsed entity \"aImage\" is contained in the value of the attribute \"attr1\".  (xmlconf/ibm/not-wf/P41/ibm41n12.xml)") do
    File.open("xmlconf/ibm/not-wf/P41/ibm41n12.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P41-ibm41n13.xml (Section 3.1)" do
  assert_raises(XML::Error, " Tests Attribute against WFC \"No (less than) character in Attribute Values\". The character \"less than\" is contained in the value of the attribute \"attr1\".  (xmlconf/ibm/not-wf/P41/ibm41n13.xml)") do
    File.open("xmlconf/ibm/not-wf/P41/ibm41n13.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P41-ibm41n14.xml (Section 3.1)" do
  assert_raises(XML::Error, " Tests Attribute against WFC \"No (less than) in Attribute Values\". The character \"less than\" is contained in the value of the attribute \"attr1\" through indirect internal entity reference.  (xmlconf/ibm/not-wf/P41/ibm41n14.xml)") do
    File.open("xmlconf/ibm/not-wf/P41/ibm41n14.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 42" do
it "ibm-not-wf-P42-ibm42n01.xml (Section 3.1)" do
  assert_raises(XML::Error, " Tests ETag with a required field missing. The Name is missing in the ETag of the element \"root\".  (xmlconf/ibm/not-wf/P42/ibm42n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P42/ibm42n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P42-ibm42n02.xml (Section 3.1)" do
  assert_raises(XML::Error, " Tests ETag with a wrong beginning sequence. The string \"(less than)\\\" is used as a beginning sequence of the ETag of the element \"root\".  (xmlconf/ibm/not-wf/P42/ibm42n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P42/ibm42n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P42-ibm42n03.xml (Section 3.1)" do
  assert_raises(XML::Error, " Tests ETag with a wrong beginning sequence. The string \"less than\" is used as a beginning sequence of the ETag of the element \"root\".  (xmlconf/ibm/not-wf/P42/ibm42n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P42/ibm42n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P42-ibm42n04.xml (Section 3.1)" do
  assert_raises(XML::Error, " Tests ETag with a wrong structure. An white space occurs between The beginning sequence and the Name of the ETag of the element \"root\".  (xmlconf/ibm/not-wf/P42/ibm42n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P42/ibm42n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P42-ibm42n05.xml (Section 3.1)" do
  assert_raises(XML::Error, " Tests ETag with a wrong structure. The ETag of the element \"root\" contains an Attribute (attr1=\"any\").  (xmlconf/ibm/not-wf/P42/ibm42n05.xml)") do
    File.open("xmlconf/ibm/not-wf/P42/ibm42n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 43" do
it "ibm-not-wf-P43-ibm43n01.xml (Section 3.1)" do
  assert_raises(XML::Error, " Tests element content with a wrong option. A NotationDecl is used as the content of the element \"root\".  (xmlconf/ibm/not-wf/P43/ibm43n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P43/ibm43n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P43-ibm43n02.xml (Section 3.1)" do
  assert_raises(XML::Error, " Tests element content with a wrong option. An elementdecl is used as the content of the element \"root\".  (xmlconf/ibm/not-wf/P43/ibm43n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P43/ibm43n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P43-ibm43n04.xml (Section 3.1)" do
  assert_raises(XML::Error, " Tests element content with a wrong option. An entitydecl is used as the content of the element \"root\".  (xmlconf/ibm/not-wf/P43/ibm43n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P43/ibm43n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P43-ibm43n05.xml (Section 3.1)" do
  assert_raises(XML::Error, " Tests element content with a wrong option. An AttlistDecl is used as the content of the element \"root\".  (xmlconf/ibm/not-wf/P43/ibm43n05.xml)") do
    File.open("xmlconf/ibm/not-wf/P43/ibm43n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 44" do
it "ibm-not-wf-P44-ibm44n01.xml (Section 3.1)" do
  assert_raises(XML::Error, " Tests EmptyElemTag with a required field missing. The Name \"root\" is missing in the EmptyElemTag.  (xmlconf/ibm/not-wf/P44/ibm44n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P44/ibm44n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P44-ibm44n02.xml (Section 3.1)" do
  assert_raises(XML::Error, " Tests EmptyElemTag with wrong field ordering. The Attribute (attri1 = \"any\") occurs before the name of the element \"root\" in the EmptyElemTag.  (xmlconf/ibm/not-wf/P44/ibm44n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P44/ibm44n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P44-ibm44n03.xml (Section 3.1)" do
  assert_raises(XML::Error, " Tests EmptyElemTag with wrong closing sequence. The string \"\\>\" is used as the closing sequence in the EmptyElemtag of the element \"root\".  (xmlconf/ibm/not-wf/P44/ibm44n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P44/ibm44n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P44-ibm44n04.xml (Section 3.1)" do
  assert_raises(XML::Error, " Tests EmptyElemTag which against the WFC \"Unique Att Spec\". The attribute name \"attr1\" occurs twice in the EmptyElemTag of the element \"root\".  (xmlconf/ibm/not-wf/P44/ibm44n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P44/ibm44n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 45" do
it "ibm-not-wf-P45-ibm45n01.xml (Section 3.2)" do
  assert_raises(XML::Error, " Tests elementdecl with a required field missing. The Name is missing in the second elementdecl in the DTD.  (xmlconf/ibm/not-wf/P45/ibm45n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P45/ibm45n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P45-ibm45n02.xml (Section 3.2)" do
  assert_raises(XML::Error, " Tests elementdecl with a required field missing. The white space is missing between \"aEle\" and \"(#PCDATA)\" in the second elementdecl in the DTD.  (xmlconf/ibm/not-wf/P45/ibm45n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P45/ibm45n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P45-ibm45n03.xml (Section 3.2)" do
  assert_raises(XML::Error, " Tests elementdecl with a required field missing. The contentspec is missing in the second elementdecl in the DTD.  (xmlconf/ibm/not-wf/P45/ibm45n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P45/ibm45n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P45-ibm45n04.xml (Section 3.2)" do
  assert_raises(XML::Error, " Tests elementdecl with a required field missing. The contentspec and the white space is missing in the second elementdecl in the DTD.  (xmlconf/ibm/not-wf/P45/ibm45n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P45/ibm45n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P45-ibm45n05.xml (Section 3.2)" do
  assert_raises(XML::Error, " Tests elementdecl with a required field missing. The Name, the white space, and the contentspec are missing in the second elementdecl in the DTD.  (xmlconf/ibm/not-wf/P45/ibm45n05.xml)") do
    File.open("xmlconf/ibm/not-wf/P45/ibm45n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P45-ibm45n06.xml (Section 3.2)" do
  assert_raises(XML::Error, " Tests elementdecl with wrong field ordering. The Name occurs after the contentspec in the second elementdecl in the DTD.  (xmlconf/ibm/not-wf/P45/ibm45n06.xml)") do
    File.open("xmlconf/ibm/not-wf/P45/ibm45n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P45-ibm45n07.xml (Section 3.2)" do
  assert_raises(XML::Error, " Tests elementdecl with wrong beginning sequence. The string \"(less than)ELEMENT\" is used as the beginning sequence in the second elementdecl in the DTD.  (xmlconf/ibm/not-wf/P45/ibm45n07.xml)") do
    File.open("xmlconf/ibm/not-wf/P45/ibm45n07.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P45-ibm45n08.xml (Section 3.2)" do
  assert_raises(XML::Error, " Tests elementdecl with wrong key word. The string \"Element\" is used as the key word in the second elementdecl in the DTD.  (xmlconf/ibm/not-wf/P45/ibm45n08.xml)") do
    File.open("xmlconf/ibm/not-wf/P45/ibm45n08.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P45-ibm45n09.xml (Section 3.2)" do
  assert_raises(XML::Error, " Tests elementdecl with wrong key word. The string \"element\" is used as the key word in the second elementdecl in the DTD.  (xmlconf/ibm/not-wf/P45/ibm45n09.xml)") do
    File.open("xmlconf/ibm/not-wf/P45/ibm45n09.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 46" do
it "ibm-not-wf-P46-ibm46n01.xml (Section 3.2)" do
  assert_raises(XML::Error, " Tests contentspec with wrong key word. the string \"empty\" is used as the key word in the contentspec of the second elementdecl in the DTD.  (xmlconf/ibm/not-wf/P46/ibm46n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P46/ibm46n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P46-ibm46n02.xml (Section 3.2)" do
  assert_raises(XML::Error, " Tests contentspec with wrong key word. the string \"Empty\" is used as the key word in the contentspec of the second elementdecl in the DTD.  (xmlconf/ibm/not-wf/P46/ibm46n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P46/ibm46n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P46-ibm46n03.xml (Section 3.2)" do
  assert_raises(XML::Error, " Tests contentspec with wrong key word. the string \"Any\" is used as the key word in the contentspec of the second elementdecl in the DTD.  (xmlconf/ibm/not-wf/P46/ibm46n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P46/ibm46n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P46-ibm46n04.xml (Section 3.2)" do
  assert_raises(XML::Error, " Tests contentspec with wrong key word. the string \"any\" is used as the key word in the contentspec of the second elementdecl in the DTD.  (xmlconf/ibm/not-wf/P46/ibm46n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P46/ibm46n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P46-ibm46n05.xml (Section 3.2)" do
  assert_raises(XML::Error, " Tests contentspec with a wrong option. The string \"#CDATA\" is used as the contentspec in the second elementdecl in the DTD.  (xmlconf/ibm/not-wf/P46/ibm46n05.xml)") do
    File.open("xmlconf/ibm/not-wf/P46/ibm46n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 47" do
it "ibm-not-wf-P47-ibm47n01.xml (Section 3.2.1)" do
  assert_raises(XML::Error, " Tests children with a required field missing. The \"+\" is used as the choice or seq field in the second elementdecl in the DTD.  (xmlconf/ibm/not-wf/P47/ibm47n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P47/ibm47n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P47-ibm47n02.xml (Section 3.2.1)" do
  assert_raises(XML::Error, " Tests children with a required field missing. The \"*\" is used as the choice or seq field in the second elementdecl in the DTD.  (xmlconf/ibm/not-wf/P47/ibm47n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P47/ibm47n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P47-ibm47n03.xml (Section 3.2.1)" do
  assert_raises(XML::Error, " Tests children with a required field missing. The \"?\" is used as the choice or seq field in the second elementdecl in the DTD.  (xmlconf/ibm/not-wf/P47/ibm47n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P47/ibm47n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P47-ibm47n04.xml (Section 3.2.1)" do
  assert_raises(XML::Error, " Tests children with wrong field ordering. The \"*\" occurs before the seq field (a,a) in the second elementdecl in the DTD.  (xmlconf/ibm/not-wf/P47/ibm47n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P47/ibm47n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P47-ibm47n05.xml (Section 3.2.1)" do
  assert_raises(XML::Error, " Tests children with wrong field ordering. The \"+\" occurs before the choice field (a|a) in the second elementdecl in the DTD.  (xmlconf/ibm/not-wf/P47/ibm47n05.xml)") do
    File.open("xmlconf/ibm/not-wf/P47/ibm47n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P47-ibm47n06.xml (Section 3.2.1)" do
  assert_raises(XML::Error, " Tests children with wrong key word. The \"^\" occurs after the seq field in the second elementdecl in the DTD.  (xmlconf/ibm/not-wf/P47/ibm47n06.xml)") do
    File.open("xmlconf/ibm/not-wf/P47/ibm47n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 48" do
it "ibm-not-wf-P48-ibm48n01.xml (Section 3.2.1)" do
  assert_raises(XML::Error, " Tests cp with a required fields missing. The field Name|choice|seq is missing in the second cp in the choice field in the third elementdecl in the DTD.  (xmlconf/ibm/not-wf/P48/ibm48n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P48/ibm48n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P48-ibm48n02.xml (Section 3.2.1)" do
  assert_raises(XML::Error, " Tests cp with a required fields missing. The field Name|choice|seq is missing in the cp in the third elementdecl in the DTD.  (xmlconf/ibm/not-wf/P48/ibm48n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P48/ibm48n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P48-ibm48n03.xml (Section 3.2.1)" do
  assert_raises(XML::Error, " Tests cp with a required fields missing. The field Name|choice|seq is missing in the first cp in the choice field in the third elementdecl in the DTD.  (xmlconf/ibm/not-wf/P48/ibm48n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P48/ibm48n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P48-ibm48n04.xml (Section 3.2.1)" do
  assert_raises(XML::Error, " Tests cp with wrong field ordering. The \"+\" occurs before the seq (a,a) in the first cp in the choice field in the third elementdecl in the DTD.  (xmlconf/ibm/not-wf/P48/ibm48n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P48/ibm48n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P48-ibm48n05.xml (Section 3.2.1)" do
  assert_raises(XML::Error, " Tests cp with wrong field ordering. The \"*\" occurs before the choice (a|b) in the first cp in the seq field in the third elementdecl in the DTD.  (xmlconf/ibm/not-wf/P48/ibm48n05.xml)") do
    File.open("xmlconf/ibm/not-wf/P48/ibm48n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P48-ibm48n06.xml (Section 3.2.1)" do
  assert_raises(XML::Error, " Tests cp with wrong field ordering. The \"?\" occurs before the Name \"a\" in the second cp in the seq field in the third elementdecl in the DTD.  (xmlconf/ibm/not-wf/P48/ibm48n06.xml)") do
    File.open("xmlconf/ibm/not-wf/P48/ibm48n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P48-ibm48n07.xml (Section 3.2.1)" do
  assert_raises(XML::Error, " Tests cp with wrong key word. The \"^\" occurs after the Name \"a\" in the first cp in the choice field in the third elementdecl in the DTD.  (xmlconf/ibm/not-wf/P48/ibm48n07.xml)") do
    File.open("xmlconf/ibm/not-wf/P48/ibm48n07.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 49" do
it "ibm-not-wf-P49-ibm49n01.xml (Section 3.2.1)" do
  assert_raises(XML::Error, " Tests choice with a required field missing. The two cps are missing in the choice field in the third elementdecl in the DTD.  (xmlconf/ibm/not-wf/P49/ibm49n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P49/ibm49n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P49-ibm49n02.xml (Section 3.2.1)" do
  assert_raises(XML::Error, " Tests choice with a required field missing. The third cp is missing in the choice field in the fourth elementdecl in the DTD.  (xmlconf/ibm/not-wf/P49/ibm49n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P49/ibm49n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P49-ibm49n03.xml (Section 3.2.1)" do
  assert_raises(XML::Error, " Tests choice with a wrong separator. The \"!\" is used as the separator in the choice field in the fourth elementdecl in the DTD.  (xmlconf/ibm/not-wf/P49/ibm49n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P49/ibm49n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P49-ibm49n04.xml (Section 3.2.1)" do
  assert_raises(XML::Error, " Tests choice with a required field missing. The separator \"|\" is missing in the choice field (a b)+ in the fourth elementdecl in the DTD.  (xmlconf/ibm/not-wf/P49/ibm49n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P49/ibm49n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P49-ibm49n05.xml (Section 3.2.1)" do
  assert_raises(XML::Error, " Tests choice with an extra separator. An extra \"|\" occurs between a and b in the choice field in the fourth elementdecl in the DTD.  (xmlconf/ibm/not-wf/P49/ibm49n05.xml)") do
    File.open("xmlconf/ibm/not-wf/P49/ibm49n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P49-ibm49n06.xml (Section 3.2.1)" do
  assert_raises(XML::Error, " Tests choice with a required field missing. The closing bracket \")\" is missing in the choice field (a |b * in the fourth elementdecl in the DTD.  (xmlconf/ibm/not-wf/P49/ibm49n06.xml)") do
    File.open("xmlconf/ibm/not-wf/P49/ibm49n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 50" do
it "ibm-not-wf-P50-ibm50n01.xml (Section 3.2.1)" do
  assert_raises(XML::Error, " Tests seq with a required field missing. The two cps are missing in the seq field in the fourth elementdecl in the DTD.  (xmlconf/ibm/not-wf/P50/ibm50n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P50/ibm50n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P50-ibm50n02.xml (Section 3.2.1)" do
  assert_raises(XML::Error, " Tests seq with a required field missing. The third cp is missing in the seq field in the fourth elementdecl in the DTD.  (xmlconf/ibm/not-wf/P50/ibm50n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P50/ibm50n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P50-ibm50n03.xml (Section 3.2.1)" do
  assert_raises(XML::Error, " Tests seq with a wrong separator. The \"|\" is used as the separator between a and b in the seq field in the fourth elementdecl in the DTD.  (xmlconf/ibm/not-wf/P50/ibm50n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P50/ibm50n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P50-ibm50n04.xml (Section 3.2.1)" do
  assert_raises(XML::Error, " Tests seq with a wrong separator. The \".\" is used as the separator between a and b in the seq field in the fourth elementdecl in the DTD.  (xmlconf/ibm/not-wf/P50/ibm50n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P50/ibm50n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P50-ibm50n05.xml (Section 3.2.1)" do
  assert_raises(XML::Error, " Tests seq with an extra separator. An extra \",\" occurs between (a|b) and a in the seq field in the fourth elementdecl in the DTD.  (xmlconf/ibm/not-wf/P50/ibm50n05.xml)") do
    File.open("xmlconf/ibm/not-wf/P50/ibm50n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P50-ibm50n06.xml (Section 3.2.1)" do
  assert_raises(XML::Error, " Tests seq with a required field missing. The separator between (a|b) and (b|a) is missing in the seq field in the fourth elementdecl in the DTD.  (xmlconf/ibm/not-wf/P50/ibm50n06.xml)") do
    File.open("xmlconf/ibm/not-wf/P50/ibm50n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P50-ibm50n07.xml (Section 3.2.1)" do
  assert_raises(XML::Error, " Tests seq with wrong closing bracket. The \"]\" is used as the closing bracket in the seq field in the fourth elementdecl in the DTD.  (xmlconf/ibm/not-wf/P50/ibm50n07.xml)") do
    File.open("xmlconf/ibm/not-wf/P50/ibm50n07.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 51" do
it "ibm-not-wf-P51-ibm51n01.xml (Section 3.2.2)" do
  assert_raises(XML::Error, " Tests Mixed with a wrong key word. The string \"#pcdata\" is used as the key word in the Mixed field in the fourth elementdecl in the DTD.  (xmlconf/ibm/not-wf/P51/ibm51n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P51/ibm51n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P51-ibm51n02.xml (Section 3.2.2)" do
  assert_raises(XML::Error, " Tests Mixed with wrong field ordering. The field #PCDATA does not occur as the first component in the Mixed field in the fourth elementdecl in the DTD.  (xmlconf/ibm/not-wf/P51/ibm51n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P51/ibm51n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P51-ibm51n03.xml (Section 3.2.2)" do
  assert_raises(XML::Error, " Tests Mixed with a separator missing. The separator \"|\" is missing in between #PCDATA and a in the Mixed field in the fourth elementdecl in the DTD.  (xmlconf/ibm/not-wf/P51/ibm51n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P51/ibm51n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P51-ibm51n04.xml (Section 3.2.2)" do
  assert_raises(XML::Error, " Tests Mixed with a wrong key word. The string \"#CDATA\" is used as the key word in the Mixed field in the fourth elementdecl in the DTD.  (xmlconf/ibm/not-wf/P51/ibm51n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P51/ibm51n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P51-ibm51n05.xml (Section 3.2.2)" do
  assert_raises(XML::Error, " Tests Mixed with a required field missing. The \"*\" is missing after the \")\" in the Mixed field in the fourth elementdecl in the DTD.  (xmlconf/ibm/not-wf/P51/ibm51n05.xml)") do
    File.open("xmlconf/ibm/not-wf/P51/ibm51n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P51-ibm51n06.xml (Section 3.2.2)" do
  assert_raises(XML::Error, " Tests Mixed with wrong closing bracket. The \"]\" is used as the closing bracket in the Mixed field in the fourth elementdecl in the DTD.  (xmlconf/ibm/not-wf/P51/ibm51n06.xml)") do
    File.open("xmlconf/ibm/not-wf/P51/ibm51n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P51-ibm51n07.xml (Section 3.2.2)" do
  assert_raises(XML::Error, " Tests Mixed with a required field missing. The closing bracket \")\" is missing after (#PCDATA in the Mixed field in the fourth elementdecl in the DTD.  (xmlconf/ibm/not-wf/P51/ibm51n07.xml)") do
    File.open("xmlconf/ibm/not-wf/P51/ibm51n07.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 52" do
it "ibm-not-wf-P52-ibm52n01.xml (Section 3.3)" do
  assert_raises(XML::Error, " Tests AttlistDecl with a required field missing. The Name is missing in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P52/ibm52n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P52/ibm52n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P52-ibm52n02.xml (Section 3.3)" do
  assert_raises(XML::Error, " Tests AttlistDecl with a required field missing. The white space is missing between the beginning sequence and the name in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P52/ibm52n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P52/ibm52n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P52-ibm52n03.xml (Section 3.3)" do
  assert_raises(XML::Error, " Tests AttlistDecl with wrong field ordering. The Name \"a\" occurs after the first AttDef in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P52/ibm52n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P52/ibm52n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P52-ibm52n04.xml (Section 3.3)" do
  assert_raises(XML::Error, " Tests AttlistDecl with wrong key word. The string \"Attlist\" is used as the key word in the beginning sequence in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P52/ibm52n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P52/ibm52n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P52-ibm52n05.xml (Section 3.3)" do
  assert_raises(XML::Error, " Tests AttlistDecl with a required field missing. The closing bracket \"greater than\" is missing in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P52/ibm52n05.xml)") do
    File.open("xmlconf/ibm/not-wf/P52/ibm52n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P52-ibm52n06.xml (Section 3.3)" do
  assert_raises(XML::Error, " Tests AttlistDecl with wrong beginning sequence. The string \"(less than)ATTLIST\" is used as the beginning sequence in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P52/ibm52n06.xml)") do
    File.open("xmlconf/ibm/not-wf/P52/ibm52n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 53" do
it "ibm-not-wf-P53-ibm53n01.xml (Section 3.3)" do
  assert_raises(XML::Error, " Tests AttDef with a required field missing. The DefaultDecl is missing in the AttDef for the name \"attr1\" in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P53/ibm53n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P53/ibm53n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P53-ibm53n02.xml (Section 3.3)" do
  assert_raises(XML::Error, " Tests AttDef with a required field missing. The white space is missing between (abc|def) and \"def\" in the AttDef in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P53/ibm53n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P53/ibm53n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P53-ibm53n03.xml (Section 3.3)" do
  assert_raises(XML::Error, " Tests AttDef with a required field missing. The AttType is missing for \"attr1\" in the AttDef in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P53/ibm53n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P53/ibm53n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P53-ibm53n04.xml (Section 3.3)" do
  assert_raises(XML::Error, " Tests AttDef with a required field missing. The white space is missing between \"attr1\" and (abc|def) in the AttDef in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P53/ibm53n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P53/ibm53n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P53-ibm53n05.xml (Section 3.3)" do
  assert_raises(XML::Error, " Tests AttDef with a required field missing. The Name is missing in the AttDef in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P53/ibm53n05.xml)") do
    File.open("xmlconf/ibm/not-wf/P53/ibm53n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P53-ibm53n06.xml (Section 3.3)" do
  assert_raises(XML::Error, " Tests AttDef with a required field missing. The white space before the name \"attr2\" is missing in the AttDef in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P53/ibm53n06.xml)") do
    File.open("xmlconf/ibm/not-wf/P53/ibm53n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P53-ibm53n07.xml (Section 3.3)" do
  assert_raises(XML::Error, " Tests AttDef with wrong field ordering. The Name \"attr1\" occurs after the AttType in the AttDef in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P53/ibm53n07.xml)") do
    File.open("xmlconf/ibm/not-wf/P53/ibm53n07.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P53-ibm53n08.xml (Section 3.3)" do
  assert_raises(XML::Error, " Tests AttDef with wrong field ordering. The Name \"attr1\" occurs after the AttType and \"default\" occurs before the AttType in the AttDef in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P53/ibm53n08.xml)") do
    File.open("xmlconf/ibm/not-wf/P53/ibm53n08.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 54" do
it "ibm-not-wf-P54-ibm54n01.xml (Section 3.3.1)" do
  assert_raises(XML::Error, " Tests AttType with a wrong option. The string \"BOGUSATTR\" is used as the AttType in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P54/ibm54n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P54/ibm54n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P54-ibm54n02.xml (Section 3.3.1)" do
  assert_raises(XML::Error, " Tests AttType with a wrong option. The string \"PCDATA\" is used as the AttType in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P54/ibm54n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P54/ibm54n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 55" do
it "ibm-not-wf-P55-ibm55n01.xml (Section 3.3.1)" do
  assert_raises(XML::Error, " Tests StringType with a wrong key word. The lower case string \"cdata\" is used as the StringType in the AttType in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P55/ibm55n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P55/ibm55n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P55-ibm55n02.xml (Section 3.3.1)" do
  assert_raises(XML::Error, " Tests StringType with a wrong key word. The string \"#CDATA\" is used as the StringType in the AttType in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P55/ibm55n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P55/ibm55n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P55-ibm55n03.xml (Section 3.3.1)" do
  assert_raises(XML::Error, " Tests StringType with a wrong key word. The string \"CData\" is used as the StringType in the AttType in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P55/ibm55n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P55/ibm55n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 56" do
it "ibm-not-wf-P56-ibm56n01.xml (Section 3.3.1)" do
  assert_raises(XML::Error, " Tests TokenizedType with wrong key word. The type \"id\" is used in the TokenizedType in the AttDef in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P56/ibm56n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P56/ibm56n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P56-ibm56n02.xml (Section 3.3.1)" do
  assert_raises(XML::Error, " Tests TokenizedType with wrong key word. The type \"Idref\" is used in the TokenizedType in the AttDef in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P56/ibm56n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P56/ibm56n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P56-ibm56n03.xml (Section 3.3.1)" do
  assert_raises(XML::Error, " Tests TokenizedType with wrong key word. The type\"Idrefs\" is used in the TokenizedType in the AttDef in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P56/ibm56n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P56/ibm56n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P56-ibm56n04.xml (Section 3.3.1)" do
  assert_raises(XML::Error, " Tests TokenizedType with wrong key word. The type \"EntitY\" is used in the TokenizedType in the AttDef in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P56/ibm56n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P56/ibm56n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P56-ibm56n05.xml (Section 3.3.1)" do
  assert_raises(XML::Error, " Tests TokenizedType with wrong key word. The type \"nmTOKEN\" is used in the TokenizedType in the AttDef in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P56/ibm56n05.xml)") do
    File.open("xmlconf/ibm/not-wf/P56/ibm56n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P56-ibm56n06.xml (Section 3.3.1)" do
  assert_raises(XML::Error, " Tests TokenizedType with wrong key word. The type \"NMtokens\" is used in the TokenizedType in the AttDef in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P56/ibm56n06.xml)") do
    File.open("xmlconf/ibm/not-wf/P56/ibm56n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P56-ibm56n07.xml (Section 3.3.1)" do
  assert_raises(XML::Error, " Tests TokenizedType with wrong key word. The type \"#ID\" is used in the TokenizedType in the AttDef in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P56/ibm56n07.xml)") do
    File.open("xmlconf/ibm/not-wf/P56/ibm56n07.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 57" do
it "ibm-not-wf-P57-ibm57n01.xml (Section 3.3.1)" do
  assert_raises(XML::Error, " Tests EnumeratedType with an illegal option. The string \"NMTOKEN (a|b)\" is used in the EnumeratedType in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P57/ibm57n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P57/ibm57n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 58" do
it "ibm-not-wf-P58-ibm58n01.xml (Section 3.3.1)" do
  assert_raises(XML::Error, " Tests NotationType with wrong key word. The lower case \"notation\" is used as the key word in the NotationType in the AttDef in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P58/ibm58n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P58/ibm58n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P58-ibm58n02.xml (Section 3.3.1)" do
  assert_raises(XML::Error, " Tests NotationType with a required field missing. The beginning bracket \"(\" is missing in the NotationType in the AttDef in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P58/ibm58n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P58/ibm58n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P58-ibm58n03.xml (Section 3.3.1)" do
  assert_raises(XML::Error, " Tests NotationType with a required field missing. The Name is missing in the \"()\" in the NotationType in the AttDef in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P58/ibm58n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P58/ibm58n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P58-ibm58n04.xml (Section 3.3.1)" do
  assert_raises(XML::Error, " Tests NotationType with a required field missing. The closing bracket is missing in the NotationType in the AttDef in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P58/ibm58n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P58/ibm58n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P58-ibm58n05.xml (Section 3.3.1)" do
  assert_raises(XML::Error, " Tests NotationType with wrong field ordering. The key word \"NOTATION\" occurs after \"(this)\" in the NotationType in the AttDef in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P58/ibm58n05.xml)") do
    File.open("xmlconf/ibm/not-wf/P58/ibm58n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P58-ibm58n06.xml (Section 3.3.1)" do
  assert_raises(XML::Error, " Tests NotationType with wrong separator. The \",\" is used as a separator between \"this\" and \"that\" in the NotationType in the AttDef in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P58/ibm58n06.xml)") do
    File.open("xmlconf/ibm/not-wf/P58/ibm58n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P58-ibm58n07.xml (Section 3.3.1)" do
  assert_raises(XML::Error, " Tests NotationType with a required field missing. The white space is missing between \"NOTATION\" and \"(this)\" in the NotationType in the AttDef in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P58/ibm58n07.xml)") do
    File.open("xmlconf/ibm/not-wf/P58/ibm58n07.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P58-ibm58n08.xml (Section 3.3.1)" do
  assert_raises(XML::Error, " Tests NotationType with extra wrong characters. The double quote character occurs after \"(\" and before \")\" in the NotationType in the AttDef in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P58/ibm58n08.xml)") do
    File.open("xmlconf/ibm/not-wf/P58/ibm58n08.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 59" do
it "ibm-not-wf-P59-ibm59n01.xml (Section 3.3.1)" do
  assert_raises(XML::Error, " Tests Enumeration with required fields missing. The Nmtokens and \"|\"s are missing in the AttDef in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P59/ibm59n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P59/ibm59n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P59-ibm59n02.xml (Section 3.3.1)" do
  assert_raises(XML::Error, " Tests Enumeration with a required field missing. The closing bracket \")\" is missing in the AttDef in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P59/ibm59n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P59/ibm59n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P59-ibm59n03.xml (Section 3.3.1)" do
  assert_raises(XML::Error, " Tests Enumeration with wrong separator. The \",\" is used as the separator in the AttDef in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P59/ibm59n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P59/ibm59n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P59-ibm59n04.xml (Section 3.3.1)" do
  assert_raises(XML::Error, " Tests Enumeration with illegal presence. The double quotes occur around the Enumeration value in the AttDef in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P59/ibm59n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P59/ibm59n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P59-ibm59n05.xml (Section 3.3.1)" do
  assert_raises(XML::Error, " Tests Enumeration with a required field missing. The white space is missing between in the AttDef in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P59/ibm59n05.xml)") do
    File.open("xmlconf/ibm/not-wf/P59/ibm59n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P59-ibm59n06.xml (Section 3.3.1)" do
  assert_raises(XML::Error, " Tests Enumeration with a required field missing. The beginning bracket \"(\" is missing in the AttDef in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P59/ibm59n06.xml)") do
    File.open("xmlconf/ibm/not-wf/P59/ibm59n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 60" do
it "ibm-not-wf-P60-ibm60n01.xml (Section 3.3.2)" do
  assert_raises(XML::Error, " Tests DefaultDecl with wrong key word. The string \"#required\" is used as the key word in the DefaultDecl in the AttDef in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P60/ibm60n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P60/ibm60n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P60-ibm60n02.xml (Section 3.3.2)" do
  assert_raises(XML::Error, " Tests DefaultDecl with wrong key word. The string \"Implied\" is used as the key word in the DefaultDecl in the AttDef in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P60/ibm60n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P60/ibm60n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P60-ibm60n03.xml (Section 3.3.2)" do
  assert_raises(XML::Error, " Tests DefaultDecl with wrong key word. The string \"!IMPLIED\" is used as the key word in the DefaultDecl in the AttDef in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P60/ibm60n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P60/ibm60n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P60-ibm60n04.xml (Section 3.3.2)" do
  assert_raises(XML::Error, " Tests DefaultDecl with a required field missing. There is no attribute value specified after the key word \"#FIXED\" in the DefaultDecl in the AttDef in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P60/ibm60n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P60/ibm60n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P60-ibm60n05.xml (Section 3.3.2)" do
  assert_raises(XML::Error, " Tests DefaultDecl with a required field missing. The white space is missing between the key word \"#FIXED\" and the attribute value in the DefaultDecl in the AttDef in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P60/ibm60n05.xml)") do
    File.open("xmlconf/ibm/not-wf/P60/ibm60n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P60-ibm60n06.xml (Section 3.3.2)" do
  assert_raises(XML::Error, " Tests DefaultDecl with wrong field ordering. The key word \"#FIXED\" occurs after the attribute value \"introduction\" in the DefaultDecl in the AttDef in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P60/ibm60n06.xml)") do
    File.open("xmlconf/ibm/not-wf/P60/ibm60n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P60-ibm60n07.xml (Section 3.3.2)" do
  assert_raises(XML::Error, " Tests DefaultDecl against WFC of P60. The text replacement of the entity \"avalue\" contains the \"less than\" character in the DefaultDecl in the AttDef in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P60/ibm60n07.xml)") do
    File.open("xmlconf/ibm/not-wf/P60/ibm60n07.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P60-ibm60n08.xml (Section 3.3.2)" do
  assert_raises(XML::Error, " Tests DefaultDecl with more than one key word. The \"#REQUIRED\" and the \"#IMPLIED\" are used as the key words in the DefaultDecl in the AttDef in the AttlistDecl in the DTD.  (xmlconf/ibm/not-wf/P60/ibm60n08.xml)") do
    File.open("xmlconf/ibm/not-wf/P60/ibm60n08.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 61" do
it "ibm-not-wf-P61-ibm61n01.xml (Section 3.4)" do
  assert_raises(XML::Error, " Tests conditionalSect with a wrong option. The word \"NOTINCLUDE\" is used as part of an option which is wrong in the coditionalSect.  (xmlconf/ibm/not-wf/P61/ibm61n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P61/ibm61n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 62" do
it "ibm-not-wf-P62-ibm62n01.xml (Section 3.4)" do
  assert_raises(XML::Error, " Tests includeSect with wrong key word. The string \"include\" is used as a key word in the beginning sequence in the includeSect in the file ibm62n01.dtd.  (xmlconf/ibm/not-wf/P62/ibm62n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P62/ibm62n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P62-ibm62n02.xml (Section 3.4)" do
  assert_raises(XML::Error, " Tests includeSect with wrong beginning sequence. An extra \"[\" occurs in the beginning sequence in the includeSect in the file ibm62n02.dtd.  (xmlconf/ibm/not-wf/P62/ibm62n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P62/ibm62n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P62-ibm62n03.xml (Section 3.4)" do
  assert_raises(XML::Error, " Tests includeSect with wrong beginning sequence. A wrong character \"?\" occurs in the beginning sequence in the includeSect in the file ibm62n03.dtd.  (xmlconf/ibm/not-wf/P62/ibm62n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P62/ibm62n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P62-ibm62n04.xml (Section 3.4)" do
  assert_raises(XML::Error, " Tests includeSect with a required field missing. The key word \"INCLUDE\" is missing in the includeSect in the file ibm62n04.dtd.  (xmlconf/ibm/not-wf/P62/ibm62n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P62/ibm62n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P62-ibm62n05.xml (Section 3.4)" do
  assert_raises(XML::Error, " Tests includeSect with a required field missing. The \"[\" is missing after the key word \"INCLUDE\" in the includeSect in the file ibm62n05.dtd.  (xmlconf/ibm/not-wf/P62/ibm62n05.xml)") do
    File.open("xmlconf/ibm/not-wf/P62/ibm62n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P62-ibm62n06.xml (Section 3.4)" do
  assert_raises(XML::Error, " Tests includeSect with wrong field ordering. The two external subset declarations occur before the key word \"INCLUDE\" in the includeSect in the file ibm62n06.dtd.  (xmlconf/ibm/not-wf/P62/ibm62n06.xml)") do
    File.open("xmlconf/ibm/not-wf/P62/ibm62n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P62-ibm62n07.xml (Section 3.4)" do
  assert_raises(XML::Error, " Tests includeSect with a required field missing. The closing sequence \"]](greater than)\" is missing in the includeSect in the file ibm62n07.dtd.  (xmlconf/ibm/not-wf/P62/ibm62n07.xml)") do
    File.open("xmlconf/ibm/not-wf/P62/ibm62n07.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P62-ibm62n08.xml (Section 3.4)" do
  assert_raises(XML::Error, " Tests includeSect with a required field missing. One \"]\" is missing in the closing sequence in the includeSect in the file ibm62n08.dtd.  (xmlconf/ibm/not-wf/P62/ibm62n08.xml)") do
    File.open("xmlconf/ibm/not-wf/P62/ibm62n08.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 63" do
it "ibm-not-wf-P63-ibm63n01.xml (Section 3.4)" do
  assert_raises(XML::Error, " Tests ignoreSect with wrong key word. The string \"ignore\" is used as a key word in the beginning sequence in the ignoreSect in the file ibm63n01.dtd.  (xmlconf/ibm/not-wf/P63/ibm63n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P63/ibm63n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P63-ibm63n02.xml (Section 3.4)" do
  assert_raises(XML::Error, " Tests ignoreSect with wrong beginning sequence. An extra \"[\" occurs in the beginning sequence in the ignoreSect in the file ibm63n02.dtd.  (xmlconf/ibm/not-wf/P63/ibm63n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P63/ibm63n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P63-ibm63n03.xml (Section 3.4)" do
  assert_raises(XML::Error, " Tests ignoreSect with wrong beginning sequence. A wrong character \"?\" occurs in the beginning sequence in the ignoreSect in the file ibm63n03.dtd.  (xmlconf/ibm/not-wf/P63/ibm63n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P63/ibm63n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P63-ibm63n04.xml (Section 3.4)" do
  assert_raises(XML::Error, " Tests ignoreSect with a required field missing. The key word \"IGNORE\" is missing in the ignoreSect in the file ibm63n04.dtd.  (xmlconf/ibm/not-wf/P63/ibm63n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P63/ibm63n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P63-ibm63n05.xml (Section 3.4)" do
  assert_raises(XML::Error, " Tests ignoreSect with a required field missing. The \"[\" is missing after the key word \"IGNORE\" in the ignoreSect in the file ibm63n05.dtd.  (xmlconf/ibm/not-wf/P63/ibm63n05.xml)") do
    File.open("xmlconf/ibm/not-wf/P63/ibm63n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P63-ibm63n06.xml (Section 3.4)" do
  assert_raises(XML::Error, " Tests includeSect with wrong field ordering. The two external subset declarations occur before the key word \"IGNORE\" in the ignoreSect in the file ibm63n06.dtd.  (xmlconf/ibm/not-wf/P63/ibm63n06.xml)") do
    File.open("xmlconf/ibm/not-wf/P63/ibm63n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P63-ibm63n07.xml (Section 3.4)" do
  assert_raises(XML::Error, " Tests ignoreSect with a required field missing. The closing sequence \"]](greater than)\" is missing in the ignoreSect in the file ibm63n07.dtd.  (xmlconf/ibm/not-wf/P63/ibm63n07.xml)") do
    File.open("xmlconf/ibm/not-wf/P63/ibm63n07.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 64" do
it "ibm-not-wf-P64-ibm64n01.xml (Section 3.4)" do
  assert_raises(XML::Error, " Tests ignoreSectContents with wrong beginning sequence. The \"?\" occurs in beginning sequence the ignoreSectContents in the file ibm64n01.dtd.  (xmlconf/ibm/not-wf/P64/ibm64n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P64/ibm64n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P64-ibm64n02.xml (Section 3.4)" do
  assert_raises(XML::Error, " Tests ignoreSectContents with a required field missing.The closing sequence is missing in the ignoreSectContents in the file ibm64n02.dtd.  (xmlconf/ibm/not-wf/P64/ibm64n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P64/ibm64n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P64-ibm64n03.xml (Section 3.4)" do
  assert_raises(XML::Error, " Tests ignoreSectContents with a required field missing.The beginning sequence is missing in the ignoreSectContents in the file ibm64n03.dtd.  (xmlconf/ibm/not-wf/P64/ibm64n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P64/ibm64n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 65" do
it "ibm-not-wf-P65-ibm65n01.xml (Section 3.4)" do
  assert_raises(XML::Error, " Tests Ignore with illegal string included. The string \"]](greater than)\" is contained before \"this\" in the Ignore in the ignoreSectContents in the file ibm65n01.dtd  (xmlconf/ibm/not-wf/P65/ibm65n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P65/ibm65n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P65-ibm65n02.xml (Section 3.4)" do
  assert_raises(XML::Error, " Tests Ignore with illegal string included. The string \"(less than)![\" is contained before \"this\" in the Ignore in the ignoreSectContents in the file ibm65n02.dtd  (xmlconf/ibm/not-wf/P65/ibm65n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P65/ibm65n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 66" do
it "ibm-not-wf-P66-ibm66n01.xml (Section 4.1)" do
  assert_raises(XML::Error, " Tests CharRef with an illegal character referred to. The \"#002f\" is used as the referred character in the CharRef in the EntityDecl in the DTD.  (xmlconf/ibm/not-wf/P66/ibm66n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P66/ibm66n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P66-ibm66n02.xml (Section 4.1)" do
  assert_raises(XML::Error, " Tests CharRef with the semicolon character missing. The semicolon character is missing at the end of the CharRef in the attribute value in the STag of element \"root\".  (xmlconf/ibm/not-wf/P66/ibm66n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P66/ibm66n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P66-ibm66n03.xml (Section 4.1)" do
  assert_raises(XML::Error, " Tests CharRef with an illegal character referred to. The \"49\" is used as the referred character in the CharRef in the EntityDecl in the DTD.  (xmlconf/ibm/not-wf/P66/ibm66n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P66/ibm66n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P66-ibm66n04.xml (Section 4.1)" do
  assert_raises(XML::Error, " Tests CharRef with an illegal character referred to. The \"#5~0\" is used as the referred character in the attribute value in the EmptyElemTag of the element \"root\".  (xmlconf/ibm/not-wf/P66/ibm66n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P66/ibm66n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P66-ibm66n05.xml (Section 4.1)" do
  assert_raises(XML::Error, " Tests CharRef with an illegal character referred to. The \"#x002g\" is used as the referred character in the CharRef in the EntityDecl in the DTD.  (xmlconf/ibm/not-wf/P66/ibm66n05.xml)") do
    File.open("xmlconf/ibm/not-wf/P66/ibm66n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P66-ibm66n06.xml (Section 4.1)" do
  assert_raises(XML::Error, " Tests CharRef with an illegal character referred to. The \"#x006G\" is used as the referred character in the attribute value in the EmptyElemTag of the element \"root\".  (xmlconf/ibm/not-wf/P66/ibm66n06.xml)") do
    File.open("xmlconf/ibm/not-wf/P66/ibm66n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P66-ibm66n07.xml (Section 4.1)" do
  assert_raises(XML::Error, " Tests CharRef with an illegal character referred to. The \"#0=2f\" is used as the referred character in the CharRef in the EntityDecl in the DTD.  (xmlconf/ibm/not-wf/P66/ibm66n07.xml)") do
    File.open("xmlconf/ibm/not-wf/P66/ibm66n07.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P66-ibm66n08.xml (Section 4.1)" do
  assert_raises(XML::Error, " Tests CharRef with an illegal character referred to. The \"#56.0\" is used as the referred character in the attribute value in the EmptyElemTag of the element \"root\".  (xmlconf/ibm/not-wf/P66/ibm66n08.xml)") do
    File.open("xmlconf/ibm/not-wf/P66/ibm66n08.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P66-ibm66n09.xml (Section 4.1)" do
  assert_raises(XML::Error, " Tests CharRef with an illegal character referred to. The \"#x00/2f\" is used as the referred character in the CharRef in the EntityDecl in the DTD.  (xmlconf/ibm/not-wf/P66/ibm66n09.xml)") do
    File.open("xmlconf/ibm/not-wf/P66/ibm66n09.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P66-ibm66n10.xml (Section 4.1)" do
  assert_raises(XML::Error, " Tests CharRef with an illegal character referred to. The \"#51)\" is used as the referred character in the attribute value in the EmptyElemTag of the element \"root\".  (xmlconf/ibm/not-wf/P66/ibm66n10.xml)") do
    File.open("xmlconf/ibm/not-wf/P66/ibm66n10.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P66-ibm66n11.xml (Section 4.1)" do
  assert_raises(XML::Error, " Tests CharRef with an illegal character referred to. The \"#00 2f\" is used as the referred character in the CharRef in the EntityDecl in the DTD.  (xmlconf/ibm/not-wf/P66/ibm66n11.xml)") do
    File.open("xmlconf/ibm/not-wf/P66/ibm66n11.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P66-ibm66n12.xml (Section 4.1)" do
  assert_raises(XML::Error, " Tests CharRef with an illegal character referred to. The \"#x0000\" is used as the referred character in the attribute value in the EmptyElemTag of the element \"root\".  (xmlconf/ibm/not-wf/P66/ibm66n12.xml)") do
    File.open("xmlconf/ibm/not-wf/P66/ibm66n12.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P66-ibm66n13.xml (Section 4.1)" do
  assert_raises(XML::Error, " Tests CharRef with an illegal character referred to. The \"#x001f\" is used as the referred character in the attribute value in the EmptyElemTag of the element \"root\".  (xmlconf/ibm/not-wf/P66/ibm66n13.xml)") do
    File.open("xmlconf/ibm/not-wf/P66/ibm66n13.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P66-ibm66n14.xml (Section 4.1)" do
  assert_raises(XML::Error, " Tests CharRef with an illegal character referred to. The \"#xfffe\" is used as the referred character in the attribute value in the EmptyElemTag of the element \"root\".  (xmlconf/ibm/not-wf/P66/ibm66n14.xml)") do
    File.open("xmlconf/ibm/not-wf/P66/ibm66n14.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P66-ibm66n15.xml (Section 4.1)" do
  assert_raises(XML::Error, " Tests CharRef with an illegal character referred to. The \"#xffff\" is used as the referred character in the attribute value in the EmptyElemTag of the element \"root\".  (xmlconf/ibm/not-wf/P66/ibm66n15.xml)") do
    File.open("xmlconf/ibm/not-wf/P66/ibm66n15.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 68" do
it "ibm-not-wf-P68-ibm68n01.xml (Section 4.1)" do
  assert_raises(XML::Error, " Tests EntityRef with a required field missing. The Name is missing in the EntityRef in the content of the element \"root\".  (xmlconf/ibm/not-wf/P68/ibm68n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P68/ibm68n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P68-ibm68n02.xml (Section 4.1)" do
  assert_raises(XML::Error, " Tests EntityRef with a required field missing. The semicolon is missing in the EntityRef in the attribute value in the element \"root\".  (xmlconf/ibm/not-wf/P68/ibm68n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P68/ibm68n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P68-ibm68n03.xml (Section 4.1)" do
  assert_raises(XML::Error, " Tests EntityRef with an extra white space. A white space occurs after the ampersand in the EntityRef in the content of the element \"root\".  (xmlconf/ibm/not-wf/P68/ibm68n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P68/ibm68n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P68-ibm68n04.xml (Section 4.1)" do
  assert_raises(XML::Error, " Tests EntityRef which is against P68 WFC: Entity Declared. The name \"aAa\" in the EntityRef in the AttValue in the STage of the element \"root\" does not match the Name of any declared entity in the DTD.  (xmlconf/ibm/not-wf/P68/ibm68n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P68/ibm68n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P68-ibm68n05.xml (Section 4.1)" do
  assert_raises(XML::Error, " Tests EntityRef which is against P68 WFC: Entity Declared. The entity with the name \"aaa\" in the EntityRef in the AttValue in the STag of the element \"root\" is not declared.  (xmlconf/ibm/not-wf/P68/ibm68n05.xml)") do
    File.open("xmlconf/ibm/not-wf/P68/ibm68n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P68-ibm68n06.xml (Section 4.1)" do
  assert_raises(XML::Error, " Tests EntityRef which is against P68 WFC: Entity Declared. The entity with the name \"aaa\" in the EntityRef in the AttValue in the STag of the element \"root\" is externally declared, but standalone is \"yes\".  (xmlconf/ibm/not-wf/P68/ibm68n06.xml)") do
    File.open("xmlconf/ibm/not-wf/P68/ibm68n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P68-ibm68n07.xml (Section 4.1)" do
  assert_raises(XML::Error, " Tests EntityRef which is against P68 WFC: Entity Declared. The entity with the name \"aaa\" in the EntityRef in the AttValue in the STag of the element \"root\" is referred before declared.  (xmlconf/ibm/not-wf/P68/ibm68n07.xml)") do
    File.open("xmlconf/ibm/not-wf/P68/ibm68n07.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P68-ibm68n08.xml (Section 4.1)" do
  assert_raises(XML::Error, " Tests EntityRef which is against P68 WFC: Parsed Entity. The EntityRef in the AttValue in the STag of the element \"root\" contains the name \"aImage\" of an unparsed entity.  (xmlconf/ibm/not-wf/P68/ibm68n08.xml)") do
    File.open("xmlconf/ibm/not-wf/P68/ibm68n08.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P68-ibm68n09.xml (Section 4.1)" do
  assert_raises(XML::Error, " Tests EntityRef which is against P68 WFC: No Recursion. The recursive entity reference occurs with the entity declarations for \"aaa\" and \"bbb\" in the DTD.  (xmlconf/ibm/not-wf/P68/ibm68n09.xml)") do
    File.open("xmlconf/ibm/not-wf/P68/ibm68n09.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P68-ibm68n10.xml (Section 4.1)" do
  assert_raises(XML::Error, " Tests EntityRef which is against P68 WFC: No Recursion. The indirect recursive entity reference occurs with the entity declarations for \"aaa\", \"bbb\", \"ccc\", \"ddd\", and \"eee\" in the DTD.  (xmlconf/ibm/not-wf/P68/ibm68n10.xml)") do
    File.open("xmlconf/ibm/not-wf/P68/ibm68n10.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 69" do
it "ibm-not-wf-P69-ibm69n01.xml (Section 4.1)" do
  assert_raises(XML::Error, " Tests PEReference with a required field missing. The Name \"paaa\" is missing in the PEReference in the DTD.  (xmlconf/ibm/not-wf/P69/ibm69n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P69/ibm69n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P69-ibm69n02.xml (Section 4.1)" do
  assert_raises(XML::Error, " Tests PEReference with a required field missing. The semicolon is missing in the PEReference \"%paaa\" in the DTD.  (xmlconf/ibm/not-wf/P69/ibm69n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P69/ibm69n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P69-ibm69n03.xml (Section 4.1)" do
  assert_raises(XML::Error, " Tests PEReference with an extra white space. There is an extra white space occurs before \";\" in the PEReference in the DTD.  (xmlconf/ibm/not-wf/P69/ibm69n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P69/ibm69n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P69-ibm69n04.xml (Section 4.1)" do
  assert_raises(XML::Error, " Tests PEReference with an extra white space. There is an extra white space occurs after \"%\" in the PEReference in the DTD.  (xmlconf/ibm/not-wf/P69/ibm69n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P69/ibm69n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P69-ibm69n05.xml (Section 4.1)" do
  assert_raises(" Based on E29 substantial source: minutes XML-Syntax 1999-02-24 E38 in XML 1.0 Errata, this WFC does not apply to P69, but the VC Entity declared still apply. Tests PEReference which is against P69 WFC: Entity Declared. The PE with the name \"paaa\" is referred before declared in the DTD.  (xmlconf/ibm/not-wf/P69/ibm69n05.xml)") do
    File.open("xmlconf/ibm/not-wf/P69/ibm69n05.xml") { |file| XML::DOM.parse(file, base: "xmlconf/ibm/not-wf/P69") }
  end
end

it "ibm-not-wf-P69-ibm69n06.xml (Section 4.1)" do
  assert_raises(XML::Error, " Tests PEReference which is against P69 WFC: No Recursion. The recursive PE reference occurs with the entity declarations for \"paaa\" and \"bbb\" in the DTD.  (xmlconf/ibm/not-wf/P69/ibm69n06.xml)") do
    File.open("xmlconf/ibm/not-wf/P69/ibm69n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P69-ibm69n07.xml (Section 4.1)" do
  assert_raises(XML::Error, " Tests PEReference which is against P69 WFC: No Recursion. The indirect recursive PE reference occurs with the entity declarations for \"paaa\", \"bbb\", \"ccc\", \"ddd\", and \"eee\" in the DTD.  (xmlconf/ibm/not-wf/P69/ibm69n07.xml)") do
    File.open("xmlconf/ibm/not-wf/P69/ibm69n07.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 71" do
it "ibm-not-wf-P71-ibm70n01.xml (Section 4.2)" do
  assert_raises(XML::Error, " Tests  (xmlconf/ibm/not-wf/P71/ibm70n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P71/ibm70n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P71-ibm71n01.xml (Section 4.2)" do
  assert_raises(XML::Error, " Tests EntityDecl with a required field missing. The white space is missing between the beginning sequence and the Name \"aaa\" in the EntityDecl in the DTD.  (xmlconf/ibm/not-wf/P71/ibm71n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P71/ibm71n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P71-ibm71n02.xml (Section 4.2)" do
  assert_raises(XML::Error, " Tests EntityDecl with a required field missing. The white space is missing between the Name \"aaa\" and the EntityDef \"aString\" in the EntityDecl in the DTD.  (xmlconf/ibm/not-wf/P71/ibm71n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P71/ibm71n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P71-ibm71n03.xml (Section 4.2)" do
  assert_raises(XML::Error, " Tests EntityDecl with a required field missing. The EntityDef is missing in the EntityDecl with the Name \"aaa\" in the DTD.  (xmlconf/ibm/not-wf/P71/ibm71n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P71/ibm71n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P71-ibm71n04.xml (Section 4.2)" do
  assert_raises(XML::Error, " Tests EntityDecl with a required field missing. The Name is missing in the EntityDecl with the EntityDef \"aString\" in the DTD.  (xmlconf/ibm/not-wf/P71/ibm71n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P71/ibm71n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P71-ibm71n05.xml (Section 4.2)" do
  assert_raises(XML::Error, " Tests EntityDecl with wrong ordering. The Name \"aaa\" occurs after the EntityDef in the EntityDecl in the DTD.  (xmlconf/ibm/not-wf/P71/ibm71n05.xml)") do
    File.open("xmlconf/ibm/not-wf/P71/ibm71n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P71-ibm71n06.xml (Section 4.2)" do
  assert_raises(XML::Error, " Tests EntityDecl with wrong key word. The string \"entity\" is used as the key word in the beginning sequence in the EntityDecl in the DTD.  (xmlconf/ibm/not-wf/P71/ibm71n06.xml)") do
    File.open("xmlconf/ibm/not-wf/P71/ibm71n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P71-ibm71n07.xml (Section 4.2)" do
  assert_raises(XML::Error, " Tests EntityDecl with a required field missing. The closing bracket (greater than) is missing in the EntityDecl in the DTD.  (xmlconf/ibm/not-wf/P71/ibm71n07.xml)") do
    File.open("xmlconf/ibm/not-wf/P71/ibm71n07.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P71-ibm71n08.xml (Section 4.2)" do
  assert_raises(XML::Error, " Tests EntityDecl with a required field missing. The exclamation mark is missing in the beginning sequence in the EntityDecl in the DTD.  (xmlconf/ibm/not-wf/P71/ibm71n08.xml)") do
    File.open("xmlconf/ibm/not-wf/P71/ibm71n08.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 72" do
it "ibm-not-wf-P72-ibm72n01.xml (Section 4.2)" do
  assert_raises(XML::Error, " Tests PEdecl with a required field missing. The white space is missing between the beginning sequence and the \"%\" in the PEDecl in the DTD.  (xmlconf/ibm/not-wf/P72/ibm72n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P72/ibm72n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P72-ibm72n02.xml (Section 4.2)" do
  assert_raises(XML::Error, " Tests PEdecl with a required field missing. The Name is missing in the PEDecl in the DTD.  (xmlconf/ibm/not-wf/P72/ibm72n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P72/ibm72n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P72-ibm72n03.xml (Section 4.2)" do
  assert_raises(XML::Error, " Tests PEdecl with a required field missing. The white space is missing between the Name and the PEDef in the PEDecl in the DTD.  (xmlconf/ibm/not-wf/P72/ibm72n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P72/ibm72n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P72-ibm72n04.xml (Section 4.2)" do
  assert_raises(XML::Error, " Tests PEdecl with a required field missing. The PEDef is missing after the Name \"paaa\" in the PEDecl in the DTD.  (xmlconf/ibm/not-wf/P72/ibm72n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P72/ibm72n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P72-ibm72n05.xml (Section 4.2)" do
  assert_raises(XML::Error, " Tests PEdecl with wrong field ordering. The Name \"paaa\" occurs after the PEDef in the PEDecl in the DTD.  (xmlconf/ibm/not-wf/P72/ibm72n05.xml)") do
    File.open("xmlconf/ibm/not-wf/P72/ibm72n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P72-ibm72n06.xml (Section 4.2)" do
  assert_raises(XML::Error, " Tests PEdecl with wrong field ordering. The \"%\" and the Name \"paaa\" occurs after the PEDef in the PEDecl in the DTD.  (xmlconf/ibm/not-wf/P72/ibm72n06.xml)") do
    File.open("xmlconf/ibm/not-wf/P72/ibm72n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P72-ibm72n07.xml (Section 4.2)" do
  assert_raises(XML::Error, " Tests PEdecl with wrong key word. The string \"entity\" is used as the key word in the beginning sequence in the PEDecl in the DTD.  (xmlconf/ibm/not-wf/P72/ibm72n07.xml)") do
    File.open("xmlconf/ibm/not-wf/P72/ibm72n07.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P72-ibm72n08.xml (Section 4.2)" do
  assert_raises(XML::Error, " Tests PEdecl with a required field missing. The closing bracket (greater than) is missing in the PEDecl in the DTD.  (xmlconf/ibm/not-wf/P72/ibm72n08.xml)") do
    File.open("xmlconf/ibm/not-wf/P72/ibm72n08.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P72-ibm72n09.xml (Section 4.2)" do
  assert_raises(XML::Error, " Tests PEdecl with wrong closing sequence. The string \"!(greater than)\" is used as the closing sequence in the PEDecl in the DTD.  (xmlconf/ibm/not-wf/P72/ibm72n09.xml)") do
    File.open("xmlconf/ibm/not-wf/P72/ibm72n09.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 73" do
it "ibm-not-wf-P73-ibm73n01.xml (Section 4.2)" do
  assert_raises(XML::Error, " Tests EntityDef with wrong field ordering. The NDataDecl \"NDATA JPGformat\" occurs before the ExternalID in the EntityDef in the EntityDecl.  (xmlconf/ibm/not-wf/P73/ibm73n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P73/ibm73n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P73-ibm73n03.xml (Section 4.2)" do
  assert_raises(XML::Error, " Tests EntityDef with a required field missing. The ExternalID is missing before the NDataDecl in the EntityDef in the EntityDecl.  (xmlconf/ibm/not-wf/P73/ibm73n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P73/ibm73n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 74" do
it "ibm-not-wf-P74-ibm74n01.xml (Section 4.2)" do
  assert_raises(XML::Error, " Tests PEDef with extra fields. The NDataDecl occurs after the ExternalID in the PEDef in the PEDecl in the DTD.  (xmlconf/ibm/not-wf/P74/ibm74n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P74/ibm74n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 75" do
it "ibm-not-wf-P75-ibm75n01.xml (Section 4.2.2)" do
  assert_raises(XML::Error, " Tests ExternalID with wrong key word. The string \"system\" is used as the key word in the ExternalID in the EntityDef in the EntityDecl.  (xmlconf/ibm/not-wf/P75/ibm75n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P75/ibm75n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P75-ibm75n02.xml (Section 4.2.2)" do
  assert_raises(XML::Error, " Tests ExternalID with wrong key word. The string \"public\" is used as the key word in the ExternalID in the doctypedecl.  (xmlconf/ibm/not-wf/P75/ibm75n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P75/ibm75n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P75-ibm75n03.xml (Section 4.2.2)" do
  assert_raises(XML::Error, " Tests ExternalID with wrong key word. The string \"Public\" is used as the key word in the ExternalID in the doctypedecl.  (xmlconf/ibm/not-wf/P75/ibm75n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P75/ibm75n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P75-ibm75n04.xml (Section 4.2.2)" do
  assert_raises(XML::Error, " Tests ExternalID with wrong field ordering. The key word \"PUBLIC\" occurs after the PublicLiteral and the SystemLiteral in the ExternalID in the doctypedecl.  (xmlconf/ibm/not-wf/P75/ibm75n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P75/ibm75n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P75-ibm75n05.xml (Section 4.2.2)" do
  assert_raises(XML::Error, " Tests ExternalID with a required field missing. The white space between \"SYSTEM\" and the Systemliteral is missing in the ExternalID in the EntityDef in the EntityDecl in the DTD.  (xmlconf/ibm/not-wf/P75/ibm75n05.xml)") do
    File.open("xmlconf/ibm/not-wf/P75/ibm75n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P75-ibm75n06.xml (Section 4.2.2)" do
  assert_raises(XML::Error, " Tests ExternalID with a required field missing. The Systemliteral is missing after \"SYSTEM\" in the ExternalID in the EntityDef in the EntityDecl in the DTD.  (xmlconf/ibm/not-wf/P75/ibm75n06.xml)") do
    File.open("xmlconf/ibm/not-wf/P75/ibm75n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P75-ibm75n07.xml (Section 4.2.2)" do
  assert_raises(XML::Error, " Tests ExternalID with a required field missing. The white space between the PublicLiteral and the Systemliteral is missing in the ExternalID in the doctypedecl.  (xmlconf/ibm/not-wf/P75/ibm75n07.xml)") do
    File.open("xmlconf/ibm/not-wf/P75/ibm75n07.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P75-ibm75n08.xml (Section 4.2.2)" do
  assert_raises(XML::Error, " Tests ExternalID with a required field missing. The key word \"PUBLIC\" is missing in the ExternalID in the doctypedecl.  (xmlconf/ibm/not-wf/P75/ibm75n08.xml)") do
    File.open("xmlconf/ibm/not-wf/P75/ibm75n08.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P75-ibm75n09.xml (Section 4.2.2)" do
  assert_raises(XML::Error, " Tests ExternalID with a required field missing. The white space between \"PUBLIC\" and the PublicLiteral is missing in the ExternalID in the doctypedecl.  (xmlconf/ibm/not-wf/P75/ibm75n09.xml)") do
    File.open("xmlconf/ibm/not-wf/P75/ibm75n09.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P75-ibm75n10.xml (Section 4.2.2)" do
  assert_raises(XML::Error, " Tests ExternalID with a required field missing. The PublicLiteral is missing in the ExternalID in the doctypedecl.  (xmlconf/ibm/not-wf/P75/ibm75n10.xml)") do
    File.open("xmlconf/ibm/not-wf/P75/ibm75n10.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P75-ibm75n11.xml (Section 4.2.2)" do
  assert_raises(XML::Error, " Tests ExternalID with a required field missing. The PublicLiteral is missing in the ExternalID in the doctypedecl.  (xmlconf/ibm/not-wf/P75/ibm75n11.xml)") do
    File.open("xmlconf/ibm/not-wf/P75/ibm75n11.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P75-ibm75n12.xml (Section 4.2.2)" do
  assert_raises(XML::Error, " Tests ExternalID with a required field missing. The SystemLiteral is missing in the ExternalID in the doctypedecl.  (xmlconf/ibm/not-wf/P75/ibm75n12.xml)") do
    File.open("xmlconf/ibm/not-wf/P75/ibm75n12.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P75-ibm75n13.xml (Section 4.2.2)" do
  assert_raises(XML::Error, " Tests ExternalID with wrong field ordering. The key word \"PUBLIC\" occurs after the PublicLiteral in the ExternalID in the doctypedecl.  (xmlconf/ibm/not-wf/P75/ibm75n13.xml)") do
    File.open("xmlconf/ibm/not-wf/P75/ibm75n13.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 76" do
it "ibm-not-wf-P76-ibm76n01.xml (Section 4.2.2)" do
  assert_raises(XML::Error, " Tests NDataDecl with wrong key word. The string \"ndata\" is used as the key word in the NDataDecl in the EntityDef in the GEDecl.  (xmlconf/ibm/not-wf/P76/ibm76n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P76/ibm76n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P76-ibm76n02.xml (Section 4.2.2)" do
  assert_raises(XML::Error, " Tests NDataDecl with wrong key word. The string \"NData\" is used as the key word in the NDataDecl in the EntityDef in the GEDecl.  (xmlconf/ibm/not-wf/P76/ibm76n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P76/ibm76n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P76-ibm76n03.xml (Section 4.2.2)" do
  assert_raises(XML::Error, " Tests NDataDecl with a required field missing. The leading white space is missing in the NDataDecl in the EntityDef in the GEDecl.  (xmlconf/ibm/not-wf/P76/ibm76n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P76/ibm76n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P76-ibm76n04.xml (Section 4.2.2)" do
  assert_raises(XML::Error, " Tests NDataDecl with a required field missing. The key word \"NDATA\" is missing in the NDataDecl in the EntityDef in the GEDecl.  (xmlconf/ibm/not-wf/P76/ibm76n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P76/ibm76n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P76-ibm76n05.xml (Section 4.2.2)" do
  assert_raises(XML::Error, " Tests NDataDecl with a required field missing. The Name after the key word \"NDATA\" is missing in the NDataDecl in the EntityDef in the GEDecl.  (xmlconf/ibm/not-wf/P76/ibm76n05.xml)") do
    File.open("xmlconf/ibm/not-wf/P76/ibm76n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P76-ibm76n06.xml (Section 4.2.2)" do
  assert_raises(XML::Error, " Tests NDataDecl with a required field missing. The white space between \"NDATA\" and the Name is missing in the NDataDecl in the EntityDef in the GEDecl.  (xmlconf/ibm/not-wf/P76/ibm76n06.xml)") do
    File.open("xmlconf/ibm/not-wf/P76/ibm76n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P76-ibm76n07.xml (Section 4.2.2)" do
  assert_raises(XML::Error, " Tests NDataDecl with wrong field ordering. The key word \"NDATA\" occurs after the Name in the NDataDecl in the EntityDef in the GEDecl.  (xmlconf/ibm/not-wf/P76/ibm76n07.xml)") do
    File.open("xmlconf/ibm/not-wf/P76/ibm76n07.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 77" do
it "ibm-not-wf-P77-ibm77n01.xml (Section 4.3.1)" do
  assert_raises(XML::Error, " Tests TextDecl with wrong field ordering. The VersionInfo occurs after the EncodingDecl in the TextDecl in the file \"ibm77n01.ent\".  (xmlconf/ibm/not-wf/P77/ibm77n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P77/ibm77n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P77-ibm77n02.xml (Section 4.3.1)" do
  assert_raises(XML::Error, " Tests TextDecl with wrong key word. The string \"XML\" is used in the beginning sequence in the TextDecl in the file \"ibm77n02.ent\".  (xmlconf/ibm/not-wf/P77/ibm77n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P77/ibm77n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P77-ibm77n03.xml (Section 4.3.1)" do
  assert_raises(XML::Error, " Tests TextDecl with wrong closing sequence. The character \"greater than\" is used as the closing sequence in the TextDecl in the file \"ibm77n03.ent\".  (xmlconf/ibm/not-wf/P77/ibm77n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P77/ibm77n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P77-ibm77n04.xml (Section 4.3.1)" do
  assert_raises(XML::Error, " Tests TextDecl with a required field missing. The closing sequence is missing in the TextDecl in the file \"ibm77n04.ent\".  (xmlconf/ibm/not-wf/P77/ibm77n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P77/ibm77n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 78" do
it "ibm-not-wf-P78-ibm78n01.xml (Section 4.3.2)" do
  assert_raises(XML::Error, " Tests extParsedEnt with wrong field ordering. The TextDecl occurs after the content in the file ibm78n01.ent.  (xmlconf/ibm/not-wf/P78/ibm78n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P78/ibm78n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P78-ibm78n02.xml (Section 4.3.2)" do
  assert_raises(XML::Error, " Tests extParsedEnt with extra field. A blank line occurs before the TextDecl in the file ibm78n02.ent.  (xmlconf/ibm/not-wf/P78/ibm78n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P78/ibm78n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 79" do
it "ibm-not-wf-P79-ibm79n01.xml (Section 4.3.2)" do
  assert_raises(XML::Error, " Tests extPE with wrong field ordering. The TextDecl occurs after the extSubsetDecl (the white space and the comment) in the file ibm79n01.ent.  (xmlconf/ibm/not-wf/P79/ibm79n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P79/ibm79n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P79-ibm79n02.xml (Section 4.3.2)" do
  assert_raises(XML::Error, " Tests extPE with extra field. A blank line occurs before the TextDecl in the file ibm78n02.ent.  (xmlconf/ibm/not-wf/P79/ibm79n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P79/ibm79n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 80" do
it "ibm-not-wf-P80-ibm80n01.xml (Section 4.3.3)" do
  assert_raises(XML::Error, " Tests EncodingDecl with a required field missing. The leading white space is missing in the EncodingDecl in the XMLDecl.  (xmlconf/ibm/not-wf/P80/ibm80n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P80/ibm80n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P80-ibm80n02.xml (Section 4.3.3)" do
  assert_raises(XML::Error, " Tests EncodingDecl with a required field missing. The \"=\" sign is missing in the EncodingDecl in the XMLDecl.  (xmlconf/ibm/not-wf/P80/ibm80n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P80/ibm80n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P80-ibm80n03.xml (Section 4.3.3)" do
  assert_raises(XML::Error, " Tests EncodingDecl with a required field missing. The double quoted EncName are missing in the EncodingDecl in the XMLDecl.  (xmlconf/ibm/not-wf/P80/ibm80n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P80/ibm80n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P80-ibm80n04.xml (Section 4.3.3)" do
  assert_raises(XML::Error, " Tests EncodingDecl with wrong field ordering. The string \"encoding=\" occurs after the double quoted EncName in the EncodingDecl in the XMLDecl.  (xmlconf/ibm/not-wf/P80/ibm80n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P80/ibm80n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P80-ibm80n05.xml (Section 4.3.3)" do
  assert_raises(XML::Error, " Tests EncodingDecl with wrong field ordering. The \"encoding\" occurs after the double quoted EncName in the EncodingDecl in the XMLDecl.  (xmlconf/ibm/not-wf/P80/ibm80n05.xml)") do
    File.open("xmlconf/ibm/not-wf/P80/ibm80n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P80-ibm80n06.xml (Section 4.3.3)" do
  assert_raises(XML::Error, " Tests EncodingDecl with wrong key word. The string \"Encoding\" is used as the key word in the EncodingDecl in the XMLDecl.  (xmlconf/ibm/not-wf/P80/ibm80n06.xml)") do
    File.open("xmlconf/ibm/not-wf/P80/ibm80n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 81" do
it "ibm-not-wf-P81-ibm81n01.xml (Section 4.3.3)" do
  assert_raises(XML::Error, " Tests EncName with an illegal character. The \"_\" is used as the first character in the EncName in the EncodingDecl in the XMLDecl.  (xmlconf/ibm/not-wf/P81/ibm81n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P81/ibm81n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P81-ibm81n02.xml (Section 4.3.3)" do
  assert_raises(XML::Error, " Tests EncName with an illegal character. The \"-\" is used as the first character in the EncName in the EncodingDecl in the XMLDecl.  (xmlconf/ibm/not-wf/P81/ibm81n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P81/ibm81n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P81-ibm81n03.xml (Section 4.3.3)" do
  assert_raises(XML::Error, " Tests EncName with an illegal character. The \".\" is used as the first character in the EncName in the EncodingDecl in the XMLDecl.  (xmlconf/ibm/not-wf/P81/ibm81n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P81/ibm81n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P81-ibm81n04.xml (Section 4.3.3)" do
  assert_raises(XML::Error, " Tests EncName with illegal characters. The \"8-\" is used as the initial characters in the EncName in the EncodingDecl in the XMLDecl.  (xmlconf/ibm/not-wf/P81/ibm81n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P81/ibm81n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P81-ibm81n05.xml (Section 4.3.3)" do
  assert_raises(XML::Error, " Tests EncName with an illegal character. The \"~\" is used as one character in the EncName in the EncodingDecl in the XMLDecl.  (xmlconf/ibm/not-wf/P81/ibm81n05.xml)") do
    File.open("xmlconf/ibm/not-wf/P81/ibm81n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P81-ibm81n06.xml (Section 4.3.3)" do
  assert_raises(XML::Error, " Tests EncName with an illegal character. The \"#\" is used as one character in the EncName in the EncodingDecl in the XMLDecl.  (xmlconf/ibm/not-wf/P81/ibm81n06.xml)") do
    File.open("xmlconf/ibm/not-wf/P81/ibm81n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P81-ibm81n07.xml (Section 4.3.3)" do
  assert_raises(XML::Error, " Tests EncName with an illegal character. The \":\" is used as one character in the EncName in the EncodingDecl in the XMLDecl.  (xmlconf/ibm/not-wf/P81/ibm81n07.xml)") do
    File.open("xmlconf/ibm/not-wf/P81/ibm81n07.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P81-ibm81n08.xml (Section 4.3.3)" do
  assert_raises(XML::Error, " Tests EncName with an illegal character. The \"/\" is used as one character in the EncName in the EncodingDecl in the XMLDecl.  (xmlconf/ibm/not-wf/P81/ibm81n08.xml)") do
    File.open("xmlconf/ibm/not-wf/P81/ibm81n08.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P81-ibm81n09.xml (Section 4.3.3)" do
  assert_raises(XML::Error, " Tests EncName with an illegal character. The \";\" is used as one character in the EncName in the EncodingDecl in the XMLDecl.  (xmlconf/ibm/not-wf/P81/ibm81n09.xml)") do
    File.open("xmlconf/ibm/not-wf/P81/ibm81n09.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 82" do
it "ibm-not-wf-P82-ibm82n01.xml (Section 4.7)" do
  assert_raises(XML::Error, " Tests NotationDecl with a required field missing. The white space after the beginning sequence of the NotationDecl is missing in the DTD.  (xmlconf/ibm/not-wf/P82/ibm82n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P82/ibm82n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P82-ibm82n02.xml (Section 4.7)" do
  assert_raises(XML::Error, " Tests NotationDecl with a required field missing. The Name in the NotationDecl is missing in the DTD.  (xmlconf/ibm/not-wf/P82/ibm82n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P82/ibm82n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P82-ibm82n03.xml (Section 4.7)" do
  assert_raises(XML::Error, " Tests NotationDecl with a required field missing. The externalID or the PublicID is missing in the NotationDecl in the DTD.  (xmlconf/ibm/not-wf/P82/ibm82n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P82/ibm82n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P82-ibm82n04.xml (Section 4.7)" do
  assert_raises(XML::Error, " Tests NotationDecl with wrong field ordering. The Name occurs after the \"SYSTEM\" and the externalID in the NotationDecl in the DTD.  (xmlconf/ibm/not-wf/P82/ibm82n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P82/ibm82n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P82-ibm82n05.xml (Section 4.7)" do
  assert_raises(XML::Error, " Tests NotationDecl with wrong key word. The string \"notation\" is used as a key word in the NotationDecl in the DTD.  (xmlconf/ibm/not-wf/P82/ibm82n05.xml)") do
    File.open("xmlconf/ibm/not-wf/P82/ibm82n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P82-ibm82n06.xml (Section 4.7)" do
  assert_raises(XML::Error, " Tests NotationDecl with a required field missing. The closing bracket (the greater than character) is missing in the NotationDecl.  (xmlconf/ibm/not-wf/P82/ibm82n06.xml)") do
    File.open("xmlconf/ibm/not-wf/P82/ibm82n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P82-ibm82n07.xml (Section 4.7)" do
  assert_raises(XML::Error, " Tests NotationDecl with wrong beginning sequence. The \"!\" is missing in the beginning sequence in the NotationDecl in the DTD.  (xmlconf/ibm/not-wf/P82/ibm82n07.xml)") do
    File.open("xmlconf/ibm/not-wf/P82/ibm82n07.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P82-ibm82n08.xml (Section 4.7)" do
  assert_raises(XML::Error, " Tests NotationDecl with wrong closing sequence. The extra \"!\" occurs in the closing sequence in the NotationDecl in the DTD.  (xmlconf/ibm/not-wf/P82/ibm82n08.xml)") do
    File.open("xmlconf/ibm/not-wf/P82/ibm82n08.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 83" do
it "ibm-not-wf-P83-ibm83n01.xml (Section 4.7)" do
  assert_raises(XML::Error, " Tests PublicID with wrong key word. The string \"public\" is used as the key word in the PublicID in the NotationDecl in the DTD.  (xmlconf/ibm/not-wf/P83/ibm83n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P83/ibm83n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P83-ibm83n02.xml (Section 4.7)" do
  assert_raises(XML::Error, " Tests PublicID with wrong key word. The string \"Public\" is used as the key word in the PublicID in the NotationDecl in the DTD.  (xmlconf/ibm/not-wf/P83/ibm83n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P83/ibm83n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P83-ibm83n03.xml (Section 4.7)" do
  assert_raises(XML::Error, " Tests PublicID with a required field missing. The key word \"PUBLIC\" is missing in the PublicID in the NotationDecl in the DTD.  (xmlconf/ibm/not-wf/P83/ibm83n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P83/ibm83n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P83-ibm83n04.xml (Section 4.7)" do
  assert_raises(XML::Error, " Tests PublicID with a required field missing. The white space between the \"PUBLIC\" and the PubidLiteral is missing in the PublicID in the NotationDecl in the DTD.  (xmlconf/ibm/not-wf/P83/ibm83n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P83/ibm83n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P83-ibm83n05.xml (Section 4.7)" do
  assert_raises(XML::Error, " Tests PublicID with a required field missing. The PubidLiteral is missing in the PublicID in the NotationDecl in the DTD.  (xmlconf/ibm/not-wf/P83/ibm83n05.xml)") do
    File.open("xmlconf/ibm/not-wf/P83/ibm83n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P83-ibm83n06.xml (Section 4.7)" do
  assert_raises(XML::Error, " Tests PublicID with wrong field ordering. The key word \"PUBLIC\" occurs after the PubidLiteral in the PublicID in the NotationDecl.  (xmlconf/ibm/not-wf/P83/ibm83n06.xml)") do
    File.open("xmlconf/ibm/not-wf/P83/ibm83n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 85" do
it "ibm-not-wf-P85-ibm85n01.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x00D7 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n02.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x00F7 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n03.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0132 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n04.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0133 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n05.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x013F occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n05.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n06.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0140 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n06.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n07.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0149 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n07.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n07.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n08.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x017F occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n08.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n08.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n09.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x01c4 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n09.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n09.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n10.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x01CC occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n10.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n10.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n100.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0BB6 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n100.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n100.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n101.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0BBA occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n101.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n101.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n102.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0C0D occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n102.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n102.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n103.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0C11 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n103.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n103.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n104.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0C29 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n104.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n104.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n105.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0C34 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n105.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n105.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n106.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0C5F occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n106.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n106.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n107.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0C62 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n107.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n107.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n108.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0C8D occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n108.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n108.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n109.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0C91 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n109.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n109.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n11.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x01F1 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n11.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n11.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n110.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0CA9 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n110.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n110.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n111.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0CB4 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n111.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n111.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n112.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0CBA occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n112.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n112.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n113.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0CDF occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n113.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n113.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n114.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0CE2 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n114.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n114.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n115.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0D0D occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n115.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n115.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n116.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0D11 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n116.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n116.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n117.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0D29 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n117.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n117.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n118.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0D3A occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n118.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n118.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n119.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0D62 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n119.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n119.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n12.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x01F3 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n12.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n12.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n120.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0E2F occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n120.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n120.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n121.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0E31 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n121.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n121.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n122.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0E34 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n122.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n122.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n123.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0E46 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n123.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n123.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n124.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0E83 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n124.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n124.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n125.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0E85 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n125.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n125.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n126.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0E89 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n126.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n126.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n127.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0E8B occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n127.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n127.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n128.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0E8E occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n128.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n128.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n129.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0E98 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n129.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n129.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n13.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x01F6 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n13.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n13.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n130.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0EA0 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n130.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n130.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n131.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0EA4 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n131.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n131.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n132.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0EA6 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n132.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n132.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n133.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0EA8 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n133.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n133.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n134.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0EAC occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n134.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n134.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n135.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0EAF occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n135.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n135.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n136.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0EB1 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n136.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n136.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n137.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0EB4 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n137.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n137.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n138.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0EBE occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n138.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n138.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n139.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0EC5 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n139.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n139.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n14.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x01F9 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n14.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n14.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n140.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0F48 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n140.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n140.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n141.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0F6A occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n141.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n141.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n142.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x10C6 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n142.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n142.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n143.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x10F7 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n143.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n143.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n144.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x1011 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n144.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n144.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n145.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x1104 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n145.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n145.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n146.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x1108 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n146.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n146.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n147.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x110A occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n147.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n147.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n148.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x110D occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n148.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n148.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n149.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x113B occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n149.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n149.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n15.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x01F9 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n15.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n15.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n150.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x113F occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n150.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n150.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n151.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x1141 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n151.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n151.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n152.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x114D occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n152.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n152.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n153.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x114f occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n153.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n153.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n154.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x1151 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n154.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n154.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n155.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x1156 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n155.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n155.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n156.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x115A occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n156.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n156.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n157.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x1162 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n157.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n157.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n158.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x1164 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n158.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n158.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n159.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x1166 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n159.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n159.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n16.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0230 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n16.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n16.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n160.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x116B occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n160.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n160.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n161.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x116F occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n161.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n161.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n162.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x1174 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n162.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n162.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n163.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x119F occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n163.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n163.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n164.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x11AC occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n164.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n164.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n165.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x11B6 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n165.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n165.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n166.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x11B9 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n166.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n166.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n167.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x11BB occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n167.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n167.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n168.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x11C3 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n168.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n168.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n169.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x11F1 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n169.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n169.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n17.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x02AF occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n17.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n17.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n170.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x11FA occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n170.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n170.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n171.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x1E9C occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n171.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n171.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n172.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x1EFA occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n172.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n172.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n173.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x1F16 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n173.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n173.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n174.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x1F1E occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n174.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n174.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n175.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x1F46 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n175.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n175.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n176.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x1F4F occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n176.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n176.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n177.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x1F58 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n177.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n177.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n178.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x1F5A occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n178.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n178.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n179.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x1F5C occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n179.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n179.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n18.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x02CF occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n18.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n18.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n180.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x1F5E occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n180.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n180.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n181.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x1F7E occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n181.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n181.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n182.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x1FB5 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n182.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n182.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n183.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x1FBD occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n183.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n183.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n184.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x1FBF occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n184.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n184.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n185.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x1FC5 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n185.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n185.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n186.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x1FCD occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n186.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n186.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n187.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x1FD5 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n187.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n187.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n188.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x1FDC occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n188.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n188.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n189.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x1FED occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n189.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n189.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n19.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0387 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n19.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n19.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n190.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x1FF5 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n190.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n190.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n191.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x1FFD occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n191.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n191.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n192.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x2127 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n192.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n192.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n193.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x212F occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n193.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n193.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n194.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x2183 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n194.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n194.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n195.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x3095 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n195.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n195.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n196.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x30FB occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n196.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n196.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n197.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x312D occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n197.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n197.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n198.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #xD7A4 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n198.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n198.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n20.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x038B occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n20.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n20.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n21.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x03A2 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n21.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n21.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n22.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x03CF occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n22.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n22.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n23.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x03D7 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n23.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n23.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n24.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x03DD occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n24.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n24.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n25.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x03E1 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n25.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n25.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n26.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x03F4 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n26.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n26.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n27.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x040D occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n27.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n27.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n28.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0450 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n28.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n28.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n29.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x045D occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n29.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n29.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n30.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0482 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n30.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n30.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n31.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x04C5 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n31.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n31.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n32.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x04C6 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n32.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n32.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n33.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x04C9 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n33.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n33.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n34.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x04EC occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n34.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n34.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n35.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x04ED occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n35.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n35.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n36.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x04F6 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n36.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n36.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n37.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x04FA occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n37.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n37.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n38.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0557 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n38.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n38.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n39.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0558 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n39.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n39.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n40.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0587 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n40.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n40.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n41.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x05EB occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n41.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n41.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n42.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x05F3 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n42.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n42.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n43.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0620 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n43.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n43.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n44.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x063B occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n44.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n44.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n45.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x064B occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n45.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n45.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n46.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x06B8 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n46.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n46.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n47.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x06BF occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n47.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n47.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n48.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x06CF occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n48.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n48.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n49.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x06D4 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n49.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n49.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n50.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x06D6 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n50.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n50.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n51.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x06E7 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n51.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n51.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n52.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x093A occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n52.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n52.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n53.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x093E occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n53.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n53.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n54.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0962 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n54.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n54.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n55.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x098D occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n55.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n55.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n56.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0991 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n56.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n56.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n57.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0992 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n57.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n57.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n58.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x09A9 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n58.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n58.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n59.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x09B1 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n59.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n59.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n60.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x09B5 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n60.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n60.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n61.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x09BA occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n61.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n61.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n62.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x09DE occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n62.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n62.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n63.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x09E2 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n63.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n63.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n64.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x09F2 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n64.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n64.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n65.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0A0B occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n65.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n65.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n66.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0A11 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n66.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n66.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n67.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0A29 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n67.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n67.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n68.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0A31 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n68.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n68.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n69.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0A34 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n69.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n69.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n70.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0A37 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n70.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n70.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n71.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0A3A occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n71.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n71.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n72.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0A5D occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n72.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n72.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n73.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0A70 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n73.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n73.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n74.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0A75 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n74.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n74.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n75.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #xA84 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n75.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n75.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n76.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0ABC occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n76.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n76.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n77.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0A92 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n77.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n77.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n78.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0AA9 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n78.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n78.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n79.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0AB1 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n79.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n79.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n80.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0AB4 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n80.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n80.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n81.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0ABA occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n81.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n81.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n82.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0B04 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n82.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n82.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n83.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0B0D occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n83.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n83.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n84.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0B11 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n84.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n84.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n85.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0B29 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n85.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n85.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n86.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0B31 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n86.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n86.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n87.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0B34 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n87.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n87.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n88.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0B3A occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n88.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n88.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n89.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0B3E occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n89.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n89.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n90.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0B5E occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n90.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n90.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n91.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0B62 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n91.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n91.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n92.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0B8B occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n92.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n92.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n93.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0B91 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n93.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n93.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n94.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0B98 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n94.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n94.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n95.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0B9B occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n95.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n95.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n96.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0B9D occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n96.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n96.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n97.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0BA0 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n97.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n97.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n98.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0BA7 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n98.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n98.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P85-ibm85n99.xml (Section B.)" do
  assert_raises(XML::Error, " Tests BaseChar with an illegal character. The character #x0BAB occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P85/ibm85n99.xml)") do
    File.open("xmlconf/ibm/not-wf/P85/ibm85n99.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 86" do
it "ibm-not-wf-P86-ibm86n01.xml (Section B.)" do
  assert_raises(XML::Error, " Tests Ideographic with an illegal character. The character #x4CFF occurs as the first character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P86/ibm86n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P86/ibm86n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P86-ibm86n02.xml (Section B.)" do
  assert_raises(XML::Error, " Tests Ideographic with an illegal character. The character #x9FA6 occurs as the first character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P86/ibm86n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P86/ibm86n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P86-ibm86n03.xml (Section B.)" do
  assert_raises(XML::Error, " Tests Ideographic with an illegal character. The character #x3008 occurs as the first character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P86/ibm86n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P86/ibm86n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P86-ibm86n04.xml (Section B.)" do
  assert_raises(XML::Error, " Tests Ideographic with an illegal character. The character #x302A occurs as the first character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P86/ibm86n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P86/ibm86n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 87" do
it "ibm-not-wf-P87-ibm87n01.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x02FF occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n02.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0346 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n03.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0362 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n04.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0487 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n05.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x05A2 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n05.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n06.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x05BA occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n06.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n07.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x05BE occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n07.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n07.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n08.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x05C0 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n08.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n08.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n09.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x05C3 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n09.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n09.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n10.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0653 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n10.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n10.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n11.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x06B8 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n11.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n11.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n12.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x06B9 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n12.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n12.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n13.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x06E9 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n13.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n13.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n14.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x06EE occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n14.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n14.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n15.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0904 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n15.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n15.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n16.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x093B occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n16.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n16.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n17.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x094E occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n17.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n17.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n18.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0955 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n18.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n18.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n19.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0964 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n19.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n19.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n20.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0984 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n20.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n20.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n21.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x09C5 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n21.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n21.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n22.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x09C9 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n22.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n22.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n23.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x09CE occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n23.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n23.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n24.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x09D8 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n24.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n24.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n25.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x09E4 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n25.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n25.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n26.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0A03 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n26.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n26.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n27.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0A3D occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n27.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n27.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n28.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0A46 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n28.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n28.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n29.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0A49 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n29.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n29.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n30.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0A4E occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n30.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n30.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n31.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0A80 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n31.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n31.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n32.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0A84 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n32.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n32.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n33.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0ABB occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n33.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n33.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n34.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0AC6 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n34.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n34.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n35.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0ACA occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n35.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n35.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n36.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0ACE occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n36.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n36.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n37.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0B04 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n37.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n37.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n38.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0B3B occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n38.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n38.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n39.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0B44 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n39.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n39.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n40.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0B4A occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n40.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n40.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n41.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0B4E occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n41.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n41.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n42.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0B58 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n42.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n42.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n43.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0B84 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n43.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n43.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n44.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0BC3 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n44.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n44.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n45.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0BC9 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n45.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n45.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n46.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0BD6 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n46.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n46.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n47.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0C0D occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n47.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n47.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n48.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0C45 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n48.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n48.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n49.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0C49 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n49.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n49.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n50.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0C54 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n50.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n50.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n51.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0C81 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n51.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n51.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n52.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0C84 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n52.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n52.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n53.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0CC5 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n53.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n53.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n54.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0CC9 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n54.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n54.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n55.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0CD4 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n55.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n55.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n56.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0CD7 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n56.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n56.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n57.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0D04 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n57.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n57.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n58.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0D45 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n58.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n58.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n59.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0D49 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n59.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n59.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n60.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0D4E occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n60.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n60.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n61.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0D58 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n61.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n61.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n62.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0E3F occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n62.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n62.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n63.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0E3B occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n63.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n63.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n64.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0E4F occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n64.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n64.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n66.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0EBA occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n66.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n66.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n67.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0EBE occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n67.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n67.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n68.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0ECE occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n68.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n68.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n69.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0F1A occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n69.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n69.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n70.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0F36 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n70.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n70.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n71.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0F38 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n71.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n71.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n72.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0F3B occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n72.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n72.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n73.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0F3A occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n73.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n73.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n74.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0F70 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n74.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n74.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n75.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0F85 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n75.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n75.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n76.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0F8C occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n76.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n76.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n77.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0F96 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n77.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n77.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n78.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0F98 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n78.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n78.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n79.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0FB0 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n79.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n79.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n80.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0FB8 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n80.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n80.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n81.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x0FBA occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n81.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n81.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n82.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x20DD occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n82.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n82.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n83.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x20E2 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n83.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n83.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n84.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x3030 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n84.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n84.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P87-ibm87n85.xml (Section B.)" do
  assert_raises(XML::Error, " Tests CombiningChar with an illegal character. The character #x309B occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P87/ibm87n85.xml)") do
    File.open("xmlconf/ibm/not-wf/P87/ibm87n85.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 88" do
it "ibm-not-wf-P88-ibm88n01.xml (Section B.)" do
  assert_raises(XML::Error, " Tests Digit with an illegal character. The character #x0029 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P88/ibm88n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P88/ibm88n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P88-ibm88n02.xml (Section B.)" do
  assert_raises(XML::Error, " Tests Digit with an illegal character. The character #x003B occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P88/ibm88n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P88/ibm88n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P88-ibm88n03.xml (Section B.)" do
  assert_raises(XML::Error, " Tests Digit with an illegal character. The character #x066A occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P88/ibm88n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P88/ibm88n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P88-ibm88n04.xml (Section B.)" do
  assert_raises(XML::Error, " Tests Digit with an illegal character. The character #x06FA occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P88/ibm88n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P88/ibm88n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P88-ibm88n05.xml (Section B.)" do
  assert_raises(XML::Error, " Tests Digit with an illegal character. The character #x0970 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P88/ibm88n05.xml)") do
    File.open("xmlconf/ibm/not-wf/P88/ibm88n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P88-ibm88n06.xml (Section B.)" do
  assert_raises(XML::Error, " Tests Digit with an illegal character. The character #x09F2 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P88/ibm88n06.xml)") do
    File.open("xmlconf/ibm/not-wf/P88/ibm88n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P88-ibm88n08.xml (Section B.)" do
  assert_raises(XML::Error, " Tests Digit with an illegal character. The character #x0AF0 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P88/ibm88n08.xml)") do
    File.open("xmlconf/ibm/not-wf/P88/ibm88n08.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P88-ibm88n09.xml (Section B.)" do
  assert_raises(XML::Error, " Tests Digit with an illegal character. The character #x0B70 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P88/ibm88n09.xml)") do
    File.open("xmlconf/ibm/not-wf/P88/ibm88n09.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P88-ibm88n10.xml (Section B.)" do
  assert_raises(XML::Error, " Tests Digit with an illegal character. The character #x0C65 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P88/ibm88n10.xml)") do
    File.open("xmlconf/ibm/not-wf/P88/ibm88n10.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P88-ibm88n11.xml (Section B.)" do
  assert_raises(XML::Error, " Tests Digit with an illegal character. The character #x0CE5 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P88/ibm88n11.xml)") do
    File.open("xmlconf/ibm/not-wf/P88/ibm88n11.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P88-ibm88n12.xml (Section B.)" do
  assert_raises(XML::Error, " Tests Digit with an illegal character. The character #x0CF0 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P88/ibm88n12.xml)") do
    File.open("xmlconf/ibm/not-wf/P88/ibm88n12.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P88-ibm88n13.xml (Section B.)" do
  assert_raises(XML::Error, " Tests Digit with an illegal character. The character #x0D70 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P88/ibm88n13.xml)") do
    File.open("xmlconf/ibm/not-wf/P88/ibm88n13.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P88-ibm88n14.xml (Section B.)" do
  assert_raises(XML::Error, " Tests Digit with an illegal character. The character #x0E5A occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P88/ibm88n14.xml)") do
    File.open("xmlconf/ibm/not-wf/P88/ibm88n14.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P88-ibm88n15.xml (Section B.)" do
  assert_raises(XML::Error, " Tests Digit with an illegal character. The character #x0EDA occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P88/ibm88n15.xml)") do
    File.open("xmlconf/ibm/not-wf/P88/ibm88n15.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P88-ibm88n16.xml (Section B.)" do
  assert_raises(XML::Error, " Tests Digit with an illegal character. The character #x0F2A occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P88/ibm88n16.xml)") do
    File.open("xmlconf/ibm/not-wf/P88/ibm88n16.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 89" do
it "ibm-not-wf-P89-ibm89n01.xml (Section B.)" do
  assert_raises(XML::Error, " Tests Extender with an illegal character. The character #x00B6 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P89/ibm89n01.xml)") do
    File.open("xmlconf/ibm/not-wf/P89/ibm89n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P89-ibm89n02.xml (Section B.)" do
  assert_raises(XML::Error, " Tests Extender with an illegal character. The character #x00B8 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P89/ibm89n02.xml)") do
    File.open("xmlconf/ibm/not-wf/P89/ibm89n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P89-ibm89n03.xml (Section B.)" do
  assert_raises(XML::Error, " Tests Extender with an illegal character. The character #x02D2 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P89/ibm89n03.xml)") do
    File.open("xmlconf/ibm/not-wf/P89/ibm89n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P89-ibm89n04.xml (Section B.)" do
  assert_raises(XML::Error, " Tests Extender with an illegal character. The character #x03FE occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P89/ibm89n04.xml)") do
    File.open("xmlconf/ibm/not-wf/P89/ibm89n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P89-ibm89n05.xml (Section B.)" do
  assert_raises(XML::Error, " Tests Extender with an illegal character. The character #x065F occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/ibm/not-wf/P89/ibm89n05.xml)") do
    File.open("xmlconf/ibm/not-wf/P89/ibm89n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P89-ibm89n06.xml (Section B.)" do
  assert_raises(XML::Error, " Tests Extender with an illegal character. The character #x0EC7 occurs as the second character in the PITarget in the PI in the DTD. [Also contains two top-level elements -- one should be removed]  (xmlconf/ibm/not-wf/P89/ibm89n06.xml)") do
    File.open("xmlconf/ibm/not-wf/P89/ibm89n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P89-ibm89n07.xml (Section B.)" do
  assert_raises(XML::Error, " Tests Extender with an illegal character. The character #x3006 occurs as the second character in the PITarget in the PI in the DTD. [Also contains two top-level elements -- one should be removed]  (xmlconf/ibm/not-wf/P89/ibm89n07.xml)") do
    File.open("xmlconf/ibm/not-wf/P89/ibm89n07.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P89-ibm89n08.xml (Section B.)" do
  assert_raises(XML::Error, " Tests Extender with an illegal character. The character #x3030 occurs as the second character in the PITarget in the PI in the DTD. [Also contains two top-level elements -- one should be removed]  (xmlconf/ibm/not-wf/P89/ibm89n08.xml)") do
    File.open("xmlconf/ibm/not-wf/P89/ibm89n08.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P89-ibm89n09.xml (Section B.)" do
  assert_raises(XML::Error, " Tests Extender with an illegal character. The character #x3036 occurs as the second character in the PITarget in the PI in the DTD. [Also contains two top-level elements -- one should be removed]  (xmlconf/ibm/not-wf/P89/ibm89n09.xml)") do
    File.open("xmlconf/ibm/not-wf/P89/ibm89n09.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P89-ibm89n10.xml (Section B.)" do
  assert_raises(XML::Error, " Tests Extender with an illegal character. The character #x309C occurs as the second character in the PITarget in the PI in the DTD. [Also contains two top-level elements -- one should be removed]  (xmlconf/ibm/not-wf/P89/ibm89n10.xml)") do
    File.open("xmlconf/ibm/not-wf/P89/ibm89n10.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P89-ibm89n11.xml (Section B.)" do
  assert_raises(XML::Error, " Tests Extender with an illegal character. The character #x309F occurs as the second character in the PITarget in the PI in the DTD. [Also contains two top-level elements -- one should be removed]  (xmlconf/ibm/not-wf/P89/ibm89n11.xml)") do
    File.open("xmlconf/ibm/not-wf/P89/ibm89n11.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-not-wf-P89-ibm89n12.xml (Section B.)" do
  assert_raises(XML::Error, " Tests Extender with an illegal character. The character #x30FF occurs as the second character in the PITarget in the PI in the DTD. [Also contains two top-level elements -- one should be removed]  (xmlconf/ibm/not-wf/P89/ibm89n12.xml)") do
    File.open("xmlconf/ibm/not-wf/P89/ibm89n12.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

end

describe "IBM XML Conformance Test Suite - valid tests" do
describe "IBM XML Conformance Test Suite - Production 1" do
it "ibm-valid-P01-ibm01v01.xml (Section 2.1)" do
  assert_parses("xmlconf/ibm/valid/P01/ibm01v01.xml", "xmlconf/ibm/valid/P01/out/ibm01v01.xml", " Tests with a xml document consisting of prolog followed by element then Misc  (xmlconf/ibm/valid/P01/ibm01v01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 2" do
it "ibm-valid-P02-ibm02v01.xml (Section 2.2)" do
  assert_parses("xmlconf/ibm/valid/P02/ibm02v01.xml", nil, " This test case covers legal character ranges plus discrete legal characters for production 02.  (xmlconf/ibm/valid/P02/ibm02v01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 3" do
it "ibm-valid-P03-ibm03v01.xml (Section 2.3)" do
  assert_parses("xmlconf/ibm/valid/P03/ibm03v01.xml", nil, " Tests all 4 legal white space characters - #x20 #x9 #xD #xA  (xmlconf/ibm/valid/P03/ibm03v01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 9" do
it "ibm-valid-P09-ibm09v01.xml (Section 2.3)" do
  assert_parses("xmlconf/ibm/valid/P09/ibm09v01.xml", "xmlconf/ibm/valid/P09/out/ibm09v01.xml", " Empty EntityValue is legal  (xmlconf/ibm/valid/P09/ibm09v01.xml)")
end

it "ibm-valid-P09-ibm09v02.xml (Section 2.3)" do
  assert_parses("xmlconf/ibm/valid/P09/ibm09v02.xml", "xmlconf/ibm/valid/P09/out/ibm09v02.xml", " Tests a normal EnitityValue  (xmlconf/ibm/valid/P09/ibm09v02.xml)")
end

it "ibm-valid-P09-ibm09v03.xml (Section 2.3)" do
  assert_parses("xmlconf/ibm/valid/P09/ibm09v03.xml", "xmlconf/ibm/valid/P09/out/ibm09v03.xml", " Tests EnitityValue referencing a Parameter Entity  (xmlconf/ibm/valid/P09/ibm09v03.xml)")
end

it "ibm-valid-P09-ibm09v04.xml (Section 2.3)" do
  assert_parses("xmlconf/ibm/valid/P09/ibm09v04.xml", "xmlconf/ibm/valid/P09/out/ibm09v04.xml", " Tests EnitityValue referencing a General Entity  (xmlconf/ibm/valid/P09/ibm09v04.xml)")
end

it "ibm-valid-P09-ibm09v05.xml (Section 2.3)" do
  assert_parses("xmlconf/ibm/valid/P09/ibm09v05.xml", "xmlconf/ibm/valid/P09/out/ibm09v05.xml", " Tests EnitityValue with combination of GE, PE and text, the GE used is declared in the student.dtd  (xmlconf/ibm/valid/P09/ibm09v05.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 10" do
it "ibm-valid-P10-ibm10v01.xml (Section 2.3)" do
  assert_parses("xmlconf/ibm/valid/P10/ibm10v01.xml", "xmlconf/ibm/valid/P10/out/ibm10v01.xml", " Tests empty AttValue with double quotes as the delimiters  (xmlconf/ibm/valid/P10/ibm10v01.xml)")
end

it "ibm-valid-P10-ibm10v02.xml (Section 2.3)" do
  assert_parses("xmlconf/ibm/valid/P10/ibm10v02.xml", "xmlconf/ibm/valid/P10/out/ibm10v02.xml", " Tests empty AttValue with single quotes as the delimiters  (xmlconf/ibm/valid/P10/ibm10v02.xml)")
end

it "ibm-valid-P10-ibm10v03.xml (Section 2.3)" do
  assert_parses("xmlconf/ibm/valid/P10/ibm10v03.xml", "xmlconf/ibm/valid/P10/out/ibm10v03.xml", " Test AttValue with double quotes as the delimiters and single quote inside  (xmlconf/ibm/valid/P10/ibm10v03.xml)")
end

it "ibm-valid-P10-ibm10v04.xml (Section 2.3)" do
  assert_parses("xmlconf/ibm/valid/P10/ibm10v04.xml", "xmlconf/ibm/valid/P10/out/ibm10v04.xml", " Test AttValue with single quotes as the delimiters and double quote inside  (xmlconf/ibm/valid/P10/ibm10v04.xml)")
end

it "ibm-valid-P10-ibm10v05.xml (Section 2.3)" do
  assert_parses("xmlconf/ibm/valid/P10/ibm10v05.xml", "xmlconf/ibm/valid/P10/out/ibm10v05.xml", " Test AttValue with a GE reference and double quotes as the delimiters  (xmlconf/ibm/valid/P10/ibm10v05.xml)")
end

it "ibm-valid-P10-ibm10v06.xml (Section 2.3)" do
  assert_parses("xmlconf/ibm/valid/P10/ibm10v06.xml", "xmlconf/ibm/valid/P10/out/ibm10v06.xml", " Test AttValue with a GE reference and single quotes as the delimiters  (xmlconf/ibm/valid/P10/ibm10v06.xml)")
end

it "ibm-valid-P10-ibm10v07.xml (Section 2.3)" do
  assert_parses("xmlconf/ibm/valid/P10/ibm10v07.xml", "xmlconf/ibm/valid/P10/out/ibm10v07.xml", " testing AttValue with mixed references and text content in double quotes  (xmlconf/ibm/valid/P10/ibm10v07.xml)")
end

it "ibm-valid-P10-ibm10v08.xml (Section 2.3)" do
  assert_parses("xmlconf/ibm/valid/P10/ibm10v08.xml", "xmlconf/ibm/valid/P10/out/ibm10v08.xml", " testing AttValue with mixed references and text content in single quotes  (xmlconf/ibm/valid/P10/ibm10v08.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 11" do
it "ibm-valid-P11-ibm11v01.xml (Section 2.3)" do
  assert_parses("xmlconf/ibm/valid/P11/ibm11v01.xml", "xmlconf/ibm/valid/P11/out/ibm11v01.xml", " Tests empty systemliteral using the double quotes  (xmlconf/ibm/valid/P11/ibm11v01.xml)")
end

it "ibm-valid-P11-ibm11v02.xml (Section 2.3)" do
  assert_parses("xmlconf/ibm/valid/P11/ibm11v02.xml", "xmlconf/ibm/valid/P11/out/ibm11v02.xml", " Tests empty systemliteral using the single quotes  (xmlconf/ibm/valid/P11/ibm11v02.xml)")
end

it "ibm-valid-P11-ibm11v03.xml (Section 2.3)" do
  assert_parses("xmlconf/ibm/valid/P11/ibm11v03.xml", "xmlconf/ibm/valid/P11/out/ibm11v03.xml", " Tests regular systemliteral using the single quotes  (xmlconf/ibm/valid/P11/ibm11v03.xml)")
end

it "ibm-valid-P11-ibm11v04.xml (Section 2.3)" do
  assert_parses("xmlconf/ibm/valid/P11/ibm11v04.xml", "xmlconf/ibm/valid/P11/out/ibm11v04.xml", " Tests regular systemliteral using the double quotes  (xmlconf/ibm/valid/P11/ibm11v04.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 12" do
it "ibm-valid-P12-ibm12v01.xml (Section 2.3)" do
  assert_parses("xmlconf/ibm/valid/P12/ibm12v01.xml", "xmlconf/ibm/valid/P12/out/ibm12v01.xml", " Tests empty systemliteral using the double quotes  (xmlconf/ibm/valid/P12/ibm12v01.xml)")
end

it "ibm-valid-P12-ibm12v02.xml (Section 2.3)" do
  assert_parses("xmlconf/ibm/valid/P12/ibm12v02.xml", "xmlconf/ibm/valid/P12/out/ibm12v02.xml", " Tests empty systemliteral using the single quotes  (xmlconf/ibm/valid/P12/ibm12v02.xml)")
end

it "ibm-valid-P12-ibm12v03.xml (Section 2.3)" do
  assert_parses("xmlconf/ibm/valid/P12/ibm12v03.xml", "xmlconf/ibm/valid/P12/out/ibm12v03.xml", " Tests regular systemliteral using the double quotes  (xmlconf/ibm/valid/P12/ibm12v03.xml)")
end

it "ibm-valid-P12-ibm12v04.xml (Section 2.3)" do
  assert_parses("xmlconf/ibm/valid/P12/ibm12v04.xml", "xmlconf/ibm/valid/P12/out/ibm12v04.xml", " Tests regular systemliteral using the single quotes  (xmlconf/ibm/valid/P12/ibm12v04.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 13" do
it "ibm-valid-P13-ibm13v01.xml (Section 2.3)" do
  assert_parses("xmlconf/ibm/valid/P13/ibm13v01.xml", "xmlconf/ibm/valid/P13/out/ibm13v01.xml", " Testing PubidChar with all legal PubidChar in a PubidLiteral  (xmlconf/ibm/valid/P13/ibm13v01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 14" do
it "ibm-valid-P14-ibm14v01.xml (Section 2.4)" do
  assert_parses("xmlconf/ibm/valid/P14/ibm14v01.xml", "xmlconf/ibm/valid/P14/out/ibm14v01.xml", " Testing CharData with empty string  (xmlconf/ibm/valid/P14/ibm14v01.xml)")
end

it "ibm-valid-P14-ibm14v02.xml (Section 2.4)" do
  assert_parses("xmlconf/ibm/valid/P14/ibm14v02.xml", "xmlconf/ibm/valid/P14/out/ibm14v02.xml", " Testing CharData with white space character  (xmlconf/ibm/valid/P14/ibm14v02.xml)")
end

it "ibm-valid-P14-ibm14v03.xml (Section 2.4)" do
  assert_parses("xmlconf/ibm/valid/P14/ibm14v03.xml", "xmlconf/ibm/valid/P14/out/ibm14v03.xml", " Testing CharData with a general text string  (xmlconf/ibm/valid/P14/ibm14v03.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 15" do
it "ibm-valid-P15-ibm15v01.xml (Section 2.5)" do
  assert_parses("xmlconf/ibm/valid/P15/ibm15v01.xml", "xmlconf/ibm/valid/P15/out/ibm15v01.xml", " Tests empty comment  (xmlconf/ibm/valid/P15/ibm15v01.xml)")
end

it "ibm-valid-P15-ibm15v02.xml (Section 2.5)" do
  assert_parses("xmlconf/ibm/valid/P15/ibm15v02.xml", "xmlconf/ibm/valid/P15/out/ibm15v02.xml", " Tests comment with regular text  (xmlconf/ibm/valid/P15/ibm15v02.xml)")
end

it "ibm-valid-P15-ibm15v03.xml (Section 2.5)" do
  assert_parses("xmlconf/ibm/valid/P15/ibm15v03.xml", "xmlconf/ibm/valid/P15/out/ibm15v03.xml", " Tests comment with one dash inside  (xmlconf/ibm/valid/P15/ibm15v03.xml)")
end

it "ibm-valid-P15-ibm15v04.xml (Section 2.5)" do
  assert_parses("xmlconf/ibm/valid/P15/ibm15v04.xml", "xmlconf/ibm/valid/P15/out/ibm15v04.xml", " Tests comment with more comprehensive content  (xmlconf/ibm/valid/P15/ibm15v04.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 16" do
it "ibm-valid-P16-ibm16v01.xml (Section 2.6)" do
  assert_parses("xmlconf/ibm/valid/P16/ibm16v01.xml", "xmlconf/ibm/valid/P16/out/ibm16v01.xml", " Tests PI definition with only PItarget name and nothing else  (xmlconf/ibm/valid/P16/ibm16v01.xml)")
end

it "ibm-valid-P16-ibm16v02.xml (Section 2.6)" do
  assert_parses("xmlconf/ibm/valid/P16/ibm16v02.xml", "xmlconf/ibm/valid/P16/out/ibm16v02.xml", " Tests PI definition with only PItarget name and a white space  (xmlconf/ibm/valid/P16/ibm16v02.xml)")
end

it "ibm-valid-P16-ibm16v03.xml (Section 2.6)" do
  assert_parses("xmlconf/ibm/valid/P16/ibm16v03.xml", "xmlconf/ibm/valid/P16/out/ibm16v03.xml", " Tests PI definition with PItarget name and text that contains question mark and right angle  (xmlconf/ibm/valid/P16/ibm16v03.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 17" do
it "ibm-valid-P17-ibm17v01.xml (Section 2.6)" do
  assert_parses("xmlconf/ibm/valid/P17/ibm17v01.xml", "xmlconf/ibm/valid/P17/out/ibm17v01.xml", " Tests PITarget name  (xmlconf/ibm/valid/P17/ibm17v01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 18" do
it "ibm-valid-P18-ibm18v01.xml (Section 2.7)" do
  assert_parses("xmlconf/ibm/valid/P18/ibm18v01.xml", "xmlconf/ibm/valid/P18/out/ibm18v01.xml", " Tests CDSect with CDStart CData CDEnd  (xmlconf/ibm/valid/P18/ibm18v01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 19" do
it "ibm-valid-P19-ibm19v01.xml (Section 2.7)" do
  assert_parses("xmlconf/ibm/valid/P19/ibm19v01.xml", "xmlconf/ibm/valid/P19/out/ibm19v01.xml", " Tests CDStart  (xmlconf/ibm/valid/P19/ibm19v01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 20" do
it "ibm-valid-P20-ibm20v01.xml (Section 2.7)" do
  assert_parses("xmlconf/ibm/valid/P20/ibm20v01.xml", "xmlconf/ibm/valid/P20/out/ibm20v01.xml", " Tests CDATA with empty string  (xmlconf/ibm/valid/P20/ibm20v01.xml)")
end

it "ibm-valid-P20-ibm20v02.xml (Section 2.7)" do
  assert_parses("xmlconf/ibm/valid/P20/ibm20v02.xml", "xmlconf/ibm/valid/P20/out/ibm20v02.xml", " Tests CDATA with regular content  (xmlconf/ibm/valid/P20/ibm20v02.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 21" do
it "ibm-valid-P21-ibm21v01.xml (Section 2.7)" do
  assert_parses("xmlconf/ibm/valid/P21/ibm21v01.xml", "xmlconf/ibm/valid/P21/out/ibm21v01.xml", " Tests CDEnd  (xmlconf/ibm/valid/P21/ibm21v01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 22" do
it "ibm-valid-P22-ibm22v01.xml (Section 2.8)" do
  assert_parses("xmlconf/ibm/valid/P22/ibm22v01.xml", "xmlconf/ibm/valid/P22/out/ibm22v01.xml", " Tests prolog with XMLDecl and doctypedecl  (xmlconf/ibm/valid/P22/ibm22v01.xml)")
end

it "ibm-valid-P22-ibm22v02.xml (Section 2.8)" do
  assert_parses("xmlconf/ibm/valid/P22/ibm22v02.xml", "xmlconf/ibm/valid/P22/out/ibm22v02.xml", " Tests prolog with doctypedecl  (xmlconf/ibm/valid/P22/ibm22v02.xml)")
end

it "ibm-valid-P22-ibm22v03.xml (Section 2.8)" do
  assert_parses("xmlconf/ibm/valid/P22/ibm22v03.xml", "xmlconf/ibm/valid/P22/out/ibm22v03.xml", " Tests prolog with Misc doctypedecl  (xmlconf/ibm/valid/P22/ibm22v03.xml)")
end

it "ibm-valid-P22-ibm22v04.xml (Section 2.8)" do
  assert_parses("xmlconf/ibm/valid/P22/ibm22v04.xml", "xmlconf/ibm/valid/P22/out/ibm22v04.xml", " Tests prolog with doctypedecl Misc  (xmlconf/ibm/valid/P22/ibm22v04.xml)")
end

it "ibm-valid-P22-ibm22v05.xml (Section 2.8)" do
  assert_parses("xmlconf/ibm/valid/P22/ibm22v05.xml", "xmlconf/ibm/valid/P22/out/ibm22v05.xml", " Tests prolog with XMLDecl Misc doctypedecl  (xmlconf/ibm/valid/P22/ibm22v05.xml)")
end

it "ibm-valid-P22-ibm22v06.xml (Section 2.8)" do
  assert_parses("xmlconf/ibm/valid/P22/ibm22v06.xml", "xmlconf/ibm/valid/P22/out/ibm22v06.xml", " Tests prolog with XMLDecl doctypedecl Misc  (xmlconf/ibm/valid/P22/ibm22v06.xml)")
end

it "ibm-valid-P22-ibm22v07.xml (Section 2.8)" do
  assert_parses("xmlconf/ibm/valid/P22/ibm22v07.xml", "xmlconf/ibm/valid/P22/out/ibm22v07.xml", " Tests prolog with XMLDecl Misc doctypedecl Misc  (xmlconf/ibm/valid/P22/ibm22v07.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 23" do
it "ibm-valid-P23-ibm23v01.xml (Section 2.8)" do
  assert_parses("xmlconf/ibm/valid/P23/ibm23v01.xml", "xmlconf/ibm/valid/P23/out/ibm23v01.xml", " Tests XMLDecl with VersionInfo only  (xmlconf/ibm/valid/P23/ibm23v01.xml)")
end

it "ibm-valid-P23-ibm23v02.xml (Section 2.8)" do
  assert_parses("xmlconf/ibm/valid/P23/ibm23v02.xml", "xmlconf/ibm/valid/P23/out/ibm23v02.xml", " Tests XMLDecl with VersionInfo EncodingDecl  (xmlconf/ibm/valid/P23/ibm23v02.xml)")
end

it "ibm-valid-P23-ibm23v03.xml (Section 2.8)" do
  assert_parses("xmlconf/ibm/valid/P23/ibm23v03.xml", "xmlconf/ibm/valid/P23/out/ibm23v03.xml", " Tests XMLDecl with VersionInfo SDDecl  (xmlconf/ibm/valid/P23/ibm23v03.xml)")
end

it "ibm-valid-P23-ibm23v04.xml (Section 2.8)" do
  assert_parses("xmlconf/ibm/valid/P23/ibm23v04.xml", "xmlconf/ibm/valid/P23/out/ibm23v04.xml", " Tests XMLDecl with VerstionInfo and a trailing whitespace char  (xmlconf/ibm/valid/P23/ibm23v04.xml)")
end

it "ibm-valid-P23-ibm23v05.xml (Section 2.8)" do
  assert_parses("xmlconf/ibm/valid/P23/ibm23v05.xml", "xmlconf/ibm/valid/P23/out/ibm23v05.xml", " Tests XMLDecl with VersionInfo EncodingDecl SDDecl  (xmlconf/ibm/valid/P23/ibm23v05.xml)")
end

it "ibm-valid-P23-ibm23v06.xml (Section 2.8)" do
  assert_parses("xmlconf/ibm/valid/P23/ibm23v06.xml", "xmlconf/ibm/valid/P23/out/ibm23v06.xml", " Tests XMLDecl with VersionInfo EncodingDecl SDDecl and a trailing whitespace  (xmlconf/ibm/valid/P23/ibm23v06.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 24" do
it "ibm-valid-P24-ibm24v01.xml (Section 2.8)" do
  assert_parses("xmlconf/ibm/valid/P24/ibm24v01.xml", "xmlconf/ibm/valid/P24/out/ibm24v01.xml", " Tests VersionInfo with single quote  (xmlconf/ibm/valid/P24/ibm24v01.xml)")
end

it "ibm-valid-P24-ibm24v02.xml (Section 2.8)" do
  assert_parses("xmlconf/ibm/valid/P24/ibm24v02.xml", "xmlconf/ibm/valid/P24/out/ibm24v02.xml", " Tests VersionInfo with double quote  (xmlconf/ibm/valid/P24/ibm24v02.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 25" do
it "ibm-valid-P25-ibm25v01.xml (Section 2.8)" do
  assert_parses("xmlconf/ibm/valid/P25/ibm25v01.xml", "xmlconf/ibm/valid/P25/out/ibm25v01.xml", " Tests EQ with =  (xmlconf/ibm/valid/P25/ibm25v01.xml)")
end

it "ibm-valid-P25-ibm25v02.xml (Section 2.8)" do
  assert_parses("xmlconf/ibm/valid/P25/ibm25v02.xml", "xmlconf/ibm/valid/P25/out/ibm25v02.xml", " Tests EQ with = and spaces on both sides  (xmlconf/ibm/valid/P25/ibm25v02.xml)")
end

it "ibm-valid-P25-ibm25v03.xml (Section 2.8)" do
  assert_parses("xmlconf/ibm/valid/P25/ibm25v03.xml", "xmlconf/ibm/valid/P25/out/ibm25v03.xml", " Tests EQ with = and space in front of it  (xmlconf/ibm/valid/P25/ibm25v03.xml)")
end

it "ibm-valid-P25-ibm25v04.xml (Section 2.8)" do
  assert_parses("xmlconf/ibm/valid/P25/ibm25v04.xml", "xmlconf/ibm/valid/P25/out/ibm25v04.xml", " Tests EQ with = and space after it  (xmlconf/ibm/valid/P25/ibm25v04.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 26" do
it "ibm-valid-P26-ibm26v01.xml (Section 2.8)" do
  assert_parses("xmlconf/ibm/valid/P26/ibm26v01.xml", "xmlconf/ibm/valid/P26/out/ibm26v01.xml", " Tests VersionNum 1.0  (xmlconf/ibm/valid/P26/ibm26v01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 27" do
it "ibm-valid-P27-ibm27v01.xml (Section 2.8)" do
  assert_parses("xmlconf/ibm/valid/P27/ibm27v01.xml", "xmlconf/ibm/valid/P27/out/ibm27v01.xml", " Tests Misc with comment  (xmlconf/ibm/valid/P27/ibm27v01.xml)")
end

it "ibm-valid-P27-ibm27v02.xml (Section 2.8)" do
  assert_parses("xmlconf/ibm/valid/P27/ibm27v02.xml", "xmlconf/ibm/valid/P27/out/ibm27v02.xml", " Tests Misc with PI  (xmlconf/ibm/valid/P27/ibm27v02.xml)")
end

it "ibm-valid-P27-ibm27v03.xml (Section 2.8)" do
  assert_parses("xmlconf/ibm/valid/P27/ibm27v03.xml", "xmlconf/ibm/valid/P27/out/ibm27v03.xml", " Tests Misc with white spaces  (xmlconf/ibm/valid/P27/ibm27v03.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 28" do
it "ibm-valid-P28-ibm28v01.xml (Section 2.8)" do
  assert_parses("xmlconf/ibm/valid/P28/ibm28v01.xml", "xmlconf/ibm/valid/P28/out/ibm28v01.xml", " Tests doctypedecl with internal DTD only  (xmlconf/ibm/valid/P28/ibm28v01.xml)")
end

it "ibm-valid-P28-ibm28v02.xml (Section 2.8)" do
  assert_parses("xmlconf/ibm/valid/P28/ibm28v02.xml", "xmlconf/ibm/valid/P28/out/ibm28v02.xml", " Tests doctypedecl with external subset and combinations of different markup declarations and PEReferences  (xmlconf/ibm/valid/P28/ibm28v02.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 29" do
it "ibm-valid-P29-ibm29v01.xml (Section 2.8)" do
  assert_parses("xmlconf/ibm/valid/P29/ibm29v01.xml", "xmlconf/ibm/valid/P29/out/ibm29v01.xml", " Tests markupdecl with combinations of elementdecl, AttlistDecl,EntityDecl, NotationDecl, PI and comment  (xmlconf/ibm/valid/P29/ibm29v01.xml)")
end

it "ibm-valid-P29-ibm29v02.xml (Section 2.8)" do
  assert_parses("xmlconf/ibm/valid/P29/ibm29v02.xml", "xmlconf/ibm/valid/P29/out/ibm29v02.xml", " Tests WFC: PE in internal subset as a positive test  (xmlconf/ibm/valid/P29/ibm29v02.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 30" do
it "ibm-valid-P30-ibm30v01.xml (Section 2.8)" do
  assert_parses("xmlconf/ibm/valid/P30/ibm30v01.xml", "xmlconf/ibm/valid/P30/out/ibm30v01.xml", " Tests extSubset with extSubsetDecl only in the dtd file  (xmlconf/ibm/valid/P30/ibm30v01.xml)")
end

it "ibm-valid-P30-ibm30v02.xml (Section 2.8)" do
  assert_parses("xmlconf/ibm/valid/P30/ibm30v02.xml", "xmlconf/ibm/valid/P30/out/ibm30v02.xml", " Tests extSubset with TextDecl and extSubsetDecl in the dtd file  (xmlconf/ibm/valid/P30/ibm30v02.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 31" do
it "ibm-valid-P31-ibm31v01.xml (Section 2.8)" do
  assert_parses("xmlconf/ibm/valid/P31/ibm31v01.xml", "xmlconf/ibm/valid/P31/out/ibm31v01.xml", " Tests extSubsetDecl with combinations of markupdecls, conditionalSects, PEReferences and white spaces  (xmlconf/ibm/valid/P31/ibm31v01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 32" do
it "ibm-valid-P32-ibm32v01.xml (Section 2.9)" do
  assert_parses("xmlconf/ibm/valid/P32/ibm32v01.xml", "xmlconf/ibm/valid/P32/out/ibm32v01.xml", " Tests VC: Standalone Document Declaration with absent attribute that has default value and standalone is no  (xmlconf/ibm/valid/P32/ibm32v01.xml)")
end

it "ibm-valid-P32-ibm32v02.xml (Section 2.9)" do
  assert_parses("xmlconf/ibm/valid/P32/ibm32v02.xml", "xmlconf/ibm/valid/P32/out/ibm32v02.xml", " Tests VC: Standalone Document Declaration with external entity reference and standalone is no  (xmlconf/ibm/valid/P32/ibm32v02.xml)")
end

it "ibm-valid-P32-ibm32v03.xml (Section 2.9)" do
  assert_parses("xmlconf/ibm/valid/P32/ibm32v03.xml", "xmlconf/ibm/valid/P32/out/ibm32v03.xml", " Tests VC: Standalone Document Declaration with attribute values that need to be normalized and standalone is no  (xmlconf/ibm/valid/P32/ibm32v03.xml)")
end

it "ibm-valid-P32-ibm32v04.xml (Section 2.9)" do
  assert_parses("xmlconf/ibm/valid/P32/ibm32v04.xml", "xmlconf/ibm/valid/P32/out/ibm32v04.xml", " Tests VC: Standalone Document Declaration with whitespace in mixed content and standalone is no  (xmlconf/ibm/valid/P32/ibm32v04.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 33" do
it "ibm-valid-P33-ibm33v01.xml (Section 2.12)" do
  assert_parses("xmlconf/ibm/valid/P33/ibm33v01.xml", "xmlconf/ibm/valid/P33/out/ibm33v01.xml", " Tests LanguageID with Langcode - Subcode  (xmlconf/ibm/valid/P33/ibm33v01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 34" do
it "ibm-valid-P34-ibm34v01.xml (Section 2.12)" do
  assert_parses("xmlconf/ibm/valid/P34/ibm34v01.xml", "xmlconf/ibm/valid/P34/out/ibm34v01.xml", " Duplicate Test as ibm33v01.xml  (xmlconf/ibm/valid/P34/ibm34v01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 35" do
it "ibm-valid-P35-ibm35v01.xml (Section 2.12)" do
  assert_parses("xmlconf/ibm/valid/P35/ibm35v01.xml", "xmlconf/ibm/valid/P35/out/ibm35v01.xml", " Tests ISO639Code  (xmlconf/ibm/valid/P35/ibm35v01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 36" do
it "ibm-valid-P36-ibm36v01.xml (Section 2.12)" do
  assert_parses("xmlconf/ibm/valid/P36/ibm36v01.xml", "xmlconf/ibm/valid/P36/out/ibm36v01.xml", " Tests IanaCode  (xmlconf/ibm/valid/P36/ibm36v01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 37" do
it "ibm-valid-P37-ibm37v01.xml (Section 2.12)" do
  assert_parses("xmlconf/ibm/valid/P37/ibm37v01.xml", "xmlconf/ibm/valid/P37/out/ibm37v01.xml", " Tests UserCode  (xmlconf/ibm/valid/P37/ibm37v01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 38" do
it "ibm-valid-P38-ibm38v01.xml (Section 2.12)" do
  assert_parses("xmlconf/ibm/valid/P38/ibm38v01.xml", "xmlconf/ibm/valid/P38/out/ibm38v01.xml", " Tests SubCode  (xmlconf/ibm/valid/P38/ibm38v01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 39" do
it "ibm-valid-P39-ibm39v01.xml (Section 3)" do
  assert_parses("xmlconf/ibm/valid/P39/ibm39v01.xml", "xmlconf/ibm/valid/P39/out/ibm39v01.xml", " Tests element with EmptyElemTag and STag content Etag, also tests the VC: Element Valid with elements that have children, Mixed and ANY contents  (xmlconf/ibm/valid/P39/ibm39v01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 40" do
it "ibm-valid-P40-ibm40v01.xml (Section 3.1)" do
  assert_parses("xmlconf/ibm/valid/P40/ibm40v01.xml", "xmlconf/ibm/valid/P40/out/ibm40v01.xml", " Tests STag with possible combinations of its fields, also tests WFC: Unique Att Spec.  (xmlconf/ibm/valid/P40/ibm40v01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 41" do
it "ibm-valid-P41-ibm41v01.xml (Section 3.1)" do
  assert_parses("xmlconf/ibm/valid/P41/ibm41v01.xml", "xmlconf/ibm/valid/P41/out/ibm41v01.xml", " Tests Attribute with Name Eq AttValue and VC: Attribute Value Type  (xmlconf/ibm/valid/P41/ibm41v01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 42" do
it "ibm-valid-P42-ibm42v01.xml (Section 3.1)" do
  assert_parses("xmlconf/ibm/valid/P42/ibm42v01.xml", "xmlconf/ibm/valid/P42/out/ibm42v01.xml", " Tests ETag with possible combinations of its fields  (xmlconf/ibm/valid/P42/ibm42v01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 43" do
it "ibm-valid-P43-ibm43v01.xml (Section 3.1)" do
  assert_parses("xmlconf/ibm/valid/P43/ibm43v01.xml", "xmlconf/ibm/valid/P43/out/ibm43v01.xml", " Tests content with all possible constructs: element, CharData, Reference, CDSect, Comment  (xmlconf/ibm/valid/P43/ibm43v01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 44" do
it "ibm-valid-P44-ibm44v01.xml (Section 3.1)" do
  assert_parses("xmlconf/ibm/valid/P44/ibm44v01.xml", "xmlconf/ibm/valid/P44/out/ibm44v01.xml", " Tests EmptyElemTag with possible combinations of its fields  (xmlconf/ibm/valid/P44/ibm44v01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 45" do
it "ibm-valid-P45-ibm45v01.xml (Section 3.2)" do
  assert_parses("xmlconf/ibm/valid/P45/ibm45v01.xml", "xmlconf/ibm/valid/P45/out/ibm45v01.xml", " Tests both P45 elementDecl and P46 contentspec with possible combinations of their constructs  (xmlconf/ibm/valid/P45/ibm45v01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 47" do
it "ibm-valid-P47-ibm47v01.xml (Section 3.2.1)" do
  assert_parses("xmlconf/ibm/valid/P47/ibm47v01.xml", "xmlconf/ibm/valid/P47/out/ibm47v01.xml", " Tests all possible children,cp,choice,seq patterns in P47,P48,P49,P50  (xmlconf/ibm/valid/P47/ibm47v01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 49" do
it "ibm-valid-P49-ibm49v01.xml (Section 3.2.1)" do
  assert_parses("xmlconf/ibm/valid/P49/ibm49v01.xml", "xmlconf/ibm/valid/P49/out/ibm49v01.xml", " Tests VC:Proper Group/PE Nesting with PEs of choices that are properly nested with parenthesized groups in external subsets  (xmlconf/ibm/valid/P49/ibm49v01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 50" do
it "ibm-valid-P50-ibm50v01.xml (Section 3.2.1)" do
  assert_parses("xmlconf/ibm/valid/P50/ibm50v01.xml", "xmlconf/ibm/valid/P50/out/ibm50v01.xml", " Tests VC:Proper Group/PE Nesting with PEs of seq that are properly nested with parenthesized groups in external subsets  (xmlconf/ibm/valid/P50/ibm50v01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 51" do
it "ibm-valid-P51-ibm51v01.xml (Section 3.2.2)" do
  assert_parses("xmlconf/ibm/valid/P51/ibm51v01.xml", "xmlconf/ibm/valid/P51/out/ibm51v01.xml", " Tests Mixed with possible combinations of its fields amd VC: No Duplicate Types  (xmlconf/ibm/valid/P51/ibm51v01.xml)")
end

it "ibm-valid-P51-ibm51v02.xml (Section 3.2.2)" do
  assert_parses("xmlconf/ibm/valid/P51/ibm51v02.xml", "xmlconf/ibm/valid/P51/out/ibm51v02.xml", " Tests VC:Proper Group/PE Nesting with PEs of Mixed that are properly nested with parenthesized groups in external subsets  (xmlconf/ibm/valid/P51/ibm51v02.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 52" do
it "ibm-valid-P52-ibm52v01.xml (Section 3.3)" do
  assert_parses("xmlconf/ibm/valid/P52/ibm52v01.xml", "xmlconf/ibm/valid/P52/out/ibm52v01.xml", " Tests all AttlistDecl and AttDef Patterns in P52 and P53  (xmlconf/ibm/valid/P52/ibm52v01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 54" do
it "ibm-valid-P54-ibm54v01.xml (Section 3.3.1)" do
  assert_parses("xmlconf/ibm/valid/P54/ibm54v01.xml", nil, " Tests all AttTypes : StringType, TokenizedTypes, EnumeratedTypes in P55,P56,P57,P58,P59. Also tests all DefaultDecls in P60.  (xmlconf/ibm/valid/P54/ibm54v01.xml)")
end

it "ibm-valid-P54-ibm54v02.xml (Section 3.3.1)" do
  assert_parses("xmlconf/ibm/valid/P54/ibm54v02.xml", "xmlconf/ibm/valid/P54/out/ibm54v02.xml", " Tests all AttTypes : StringType, TokenizedType, EnumeratedTypes in P55,P56,P57.  (xmlconf/ibm/valid/P54/ibm54v02.xml)")
end

it "ibm-valid-P54-ibm54v03.xml (Section 3.3.1)" do
  assert_parses("xmlconf/ibm/valid/P54/ibm54v03.xml", "xmlconf/ibm/valid/P54/out/ibm54v03.xml", " Tests AttTypes with StringType in P55.  (xmlconf/ibm/valid/P54/ibm54v03.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 55" do
it "ibm-valid-P55-ibm55v01.xml (Section 3.3.1)" do
  assert_parses("xmlconf/ibm/valid/P55/ibm55v01.xml", "xmlconf/ibm/valid/P55/out/ibm55v01.xml", " Tests StringType for P55. The \"CDATA\" occurs in the StringType for the attribute \"att\" for the element \"a\".  (xmlconf/ibm/valid/P55/ibm55v01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 56" do
it "ibm-valid-P56-ibm56v01.xml (Section 3.3.1)" do
  assert_parses("xmlconf/ibm/valid/P56/ibm56v01.xml", "xmlconf/ibm/valid/P56/out/ibm56v01.xml", " Tests TokenizedType for P56. The \"ID\", \"IDREF\", \"IDREFS\", \"ENTITY\", \"ENTITIES\", \"NMTOKEN\", and \"NMTOKENS\" occur in the TokenizedType for the attribute \"attr\".  (xmlconf/ibm/valid/P56/ibm56v01.xml)")
end

it "ibm-valid-P56-ibm56v02.xml (Section 3.3.1)" do
  assert_parses("xmlconf/ibm/valid/P56/ibm56v02.xml", "xmlconf/ibm/valid/P56/out/ibm56v02.xml", " Tests TokenizedType for P56 VC: ID Attribute Default. The value \"AC1999\" is assigned to the ID attribute \"attr\" with \"#REQUIRED\" in the DeaultDecl.  (xmlconf/ibm/valid/P56/ibm56v02.xml)")
end

it "ibm-valid-P56-ibm56v03.xml (Section 3.3.1)" do
  assert_parses("xmlconf/ibm/valid/P56/ibm56v03.xml", "xmlconf/ibm/valid/P56/out/ibm56v03.xml", " Tests TokenizedType for P56 VC: ID Attribute Default. The value \"AC1999\" is assigned to the ID attribute \"attr\" with \"#IMPLIED\" in the DeaultDecl.  (xmlconf/ibm/valid/P56/ibm56v03.xml)")
end

it "ibm-valid-P56-ibm56v04.xml (Section 3.3.1)" do
  assert_parses("xmlconf/ibm/valid/P56/ibm56v04.xml", "xmlconf/ibm/valid/P56/out/ibm56v04.xml", " Tests TokenizedType for P56 VC: ID. The ID attribute \"UniqueName\" appears only once in the document.  (xmlconf/ibm/valid/P56/ibm56v04.xml)")
end

it "ibm-valid-P56-ibm56v05.xml (Section 3.3.1)" do
  assert_parses("xmlconf/ibm/valid/P56/ibm56v05.xml", "xmlconf/ibm/valid/P56/out/ibm56v05.xml", " Tests TokenizedType for P56 VC: One ID per element type. The element \"a\" or \"b\" has only one ID attribute.  (xmlconf/ibm/valid/P56/ibm56v05.xml)")
end

it "ibm-valid-P56-ibm56v06.xml (Section 3.3.1)" do
  assert_parses("xmlconf/ibm/valid/P56/ibm56v06.xml", "xmlconf/ibm/valid/P56/out/ibm56v06.xml", " Tests TokenizedType for P56 VC: IDREF. The IDREF value \"AC456\" matches the value assigned to an ID attribute \"UniqueName\".  (xmlconf/ibm/valid/P56/ibm56v06.xml)")
end

it "ibm-valid-P56-ibm56v07.xml (Section 3.3.1)" do
  assert_parses("xmlconf/ibm/valid/P56/ibm56v07.xml", "xmlconf/ibm/valid/P56/out/ibm56v07.xml", " Tests TokenizedType for P56 VC: IDREF. The IDREFS value \"AC456 Q123\" matches the values assigned to the ID attribute \"UniqueName\" and \"Uname\".  (xmlconf/ibm/valid/P56/ibm56v07.xml)")
end

it "ibm-valid-P56-ibm56v08.xml (Section 3.3.1)" do
  assert_parses("xmlconf/ibm/valid/P56/ibm56v08.xml", "xmlconf/ibm/valid/P56/out/ibm56v08.xml", " Tests TokenizedType for P56 VC: Entity Name. The value \"image\" of the ENTITY attribute \"sun\" matches the name of an unparsed entity declared.  (xmlconf/ibm/valid/P56/ibm56v08.xml)")
end

it "ibm-valid-P56-ibm56v09.xml (Section 3.3.1)" do
  assert_parses("xmlconf/ibm/valid/P56/ibm56v09.xml", "xmlconf/ibm/valid/P56/out/ibm56v09.xml", " Tests TokenizedType for P56 VC: Name Token. The value of the NMTOKEN attribute \"thistoken\" matches the Nmtoken production.  (xmlconf/ibm/valid/P56/ibm56v09.xml)")
end

it "ibm-valid-P56-ibm56v10.xml (Section 3.3.1)" do
  assert_parses("xmlconf/ibm/valid/P56/ibm56v10.xml", "xmlconf/ibm/valid/P56/out/ibm56v10.xml", " Tests TokenizedType for P56 VC: Name Token. The value of the NMTOKENS attribute \"thistoken\" matches the Nmtoken production.  (xmlconf/ibm/valid/P56/ibm56v10.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 57" do
it "ibm-valid-P57-ibm57v01.xml (Section 3.3.1)" do
  assert_parses("xmlconf/ibm/valid/P57/ibm57v01.xml", "xmlconf/ibm/valid/P57/out/ibm57v01.xml", " Tests EnumeratedType in the AttType. The attribute \"att\" has a type (a|b) with the element \"a\". the  (xmlconf/ibm/valid/P57/ibm57v01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 58" do
it "ibm-valid-P58-ibm58v01.xml (Section 3.3.1)" do
  assert_parses("xmlconf/ibm/valid/P58/ibm58v01.xml", "xmlconf/ibm/valid/P58/out/ibm58v01.xml", " Tests NotationType for P58. It shows different patterns fro the NOTATION attribute \"attr\".  (xmlconf/ibm/valid/P58/ibm58v01.xml)")
end

it "ibm-valid-P58-ibm58v02.xml (Section 3.3.1)" do
  assert_parses("xmlconf/ibm/valid/P58/ibm58v02.xml", "xmlconf/ibm/valid/P58/out/ibm58v02.xml", " Tests NotationType for P58: Notation Attributes. The value \"base64\" of the NOTATION attribute \"attr\" matches one of the notation names declared.  (xmlconf/ibm/valid/P58/ibm58v02.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 59" do
it "ibm-valid-P59-ibm59v01.xml (Section 3.3.1)" do
  assert_parses("xmlconf/ibm/valid/P59/ibm59v01.xml", "xmlconf/ibm/valid/P59/out/ibm59v01.xml", " Tests Enumeration in the EnumeratedType for P59. It shows different patterns for the Enumeration attribute \"attr\".  (xmlconf/ibm/valid/P59/ibm59v01.xml)")
end

it "ibm-valid-P59-ibm59v02.xml (Section 3.3.1)" do
  assert_parses("xmlconf/ibm/valid/P59/ibm59v02.xml", "xmlconf/ibm/valid/P59/out/ibm59v02.xml", " Tests Enumeration for P59 VC: Enumeration. The value \"one\" of the Enumeration attribute \"attr\" matches one of the element names declared.  (xmlconf/ibm/valid/P59/ibm59v02.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 60" do
it "ibm-valid-P60-ibm60v01.xml (Section 3.3.2)" do
  assert_parses("xmlconf/ibm/valid/P60/ibm60v01.xml", "xmlconf/ibm/valid/P60/out/ibm60v01.xml", " Tests DefaultDecl for P60. It shows different options \"#REQUIRED\", \"#FIXED\", \"#IMPLIED\", and default for the attribute \"chapter\".  (xmlconf/ibm/valid/P60/ibm60v01.xml)")
end

it "ibm-valid-P60-ibm60v02.xml (Section 3.3.2)" do
  assert_parses("xmlconf/ibm/valid/P60/ibm60v02.xml", "xmlconf/ibm/valid/P60/out/ibm60v02.xml", " Tests DefaultDecl for P60 VC: Required Attribute. In the element \"one\" and \"two\" the value of the #REQUIRED attribute \"chapter\" is given.  (xmlconf/ibm/valid/P60/ibm60v02.xml)")
end

it "ibm-valid-P60-ibm60v03.xml (Section 3.3.2)" do
  assert_parses("xmlconf/ibm/valid/P60/ibm60v03.xml", "xmlconf/ibm/valid/P60/out/ibm60v03.xml", " Tests DefaultDecl for P60 VC: Fixed Attribute Default. The value of the #FIXED attribute \"chapter\" is exactly the same as the default value.  (xmlconf/ibm/valid/P60/ibm60v03.xml)")
end

it "ibm-valid-P60-ibm60v04.xml (Section 3.3.2)" do
  assert_parses("xmlconf/ibm/valid/P60/ibm60v04.xml", "xmlconf/ibm/valid/P60/out/ibm60v04.xml", " Tests DefaultDecl for P60 VC: Attribute Default Legal. The default value specified for the attribute \"attr\" meets the lexical constraints of the declared attribute type.  (xmlconf/ibm/valid/P60/ibm60v04.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 61" do
it "ibm-valid-P61-ibm61v01.xml (Section 3.4)" do
  assert_parses("xmlconf/ibm/valid/P61/ibm61v01.xml", "xmlconf/ibm/valid/P61/out/ibm61v01.xml", " Tests conditionalSect for P61. It takes the option \"invludeSect\" in the file ibm61v01.dtd.  (xmlconf/ibm/valid/P61/ibm61v01.xml)")
end

it "ibm-valid-P61-ibm61v02.xml (Section 3.4)" do
  assert_parses("xmlconf/ibm/valid/P61/ibm61v02.xml", "xmlconf/ibm/valid/P61/out/ibm61v02.xml", " Tests conditionalSect for P61. It takes the option \"ignoreSect\" in the file ibm61v02.dtd.  (xmlconf/ibm/valid/P61/ibm61v02.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 62" do
it "ibm-valid-P62-ibm62v01.xml (Section 3.4)" do
  assert_parses("xmlconf/ibm/valid/P62/ibm62v01.xml", "xmlconf/ibm/valid/P62/out/ibm62v01.xml", " Tests includeSect for P62. The white space is not included before the key word \"INCLUDE\" in the beginning sequence.  (xmlconf/ibm/valid/P62/ibm62v01.xml)")
end

it "ibm-valid-P62-ibm62v02.xml (Section 3.4)" do
  assert_parses("xmlconf/ibm/valid/P62/ibm62v02.xml", "xmlconf/ibm/valid/P62/out/ibm62v02.xml", " Tests includeSect for P62. The white space is not included after the key word \"INCLUDE\" in the beginning sequence.  (xmlconf/ibm/valid/P62/ibm62v02.xml)")
end

it "ibm-valid-P62-ibm62v03.xml (Section 3.4)" do
  assert_parses("xmlconf/ibm/valid/P62/ibm62v03.xml", "xmlconf/ibm/valid/P62/out/ibm62v03.xml", " Tests includeSect for P62. The white space is included after the key word \"INCLUDE\" in the beginning sequence.  (xmlconf/ibm/valid/P62/ibm62v03.xml)")
end

it "ibm-valid-P62-ibm62v04.xml (Section 3.4)" do
  assert_parses("xmlconf/ibm/valid/P62/ibm62v04.xml", "xmlconf/ibm/valid/P62/out/ibm62v04.xml", " Tests includeSect for P62. The white space is included before the key word \"INCLUDE\" in the beginning sequence.  (xmlconf/ibm/valid/P62/ibm62v04.xml)")
end

it "ibm-valid-P62-ibm62v05.xml (Section 3.4)" do
  assert_parses("xmlconf/ibm/valid/P62/ibm62v05.xml", "xmlconf/ibm/valid/P62/out/ibm62v05.xml", " Tests includeSect for P62. The extSubsetDecl is not included.  (xmlconf/ibm/valid/P62/ibm62v05.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 63" do
it "ibm-valid-P63-ibm63v01.xml (Section 3.4)" do
  assert_parses("xmlconf/ibm/valid/P63/ibm63v01.xml", "xmlconf/ibm/valid/P63/out/ibm63v01.xml", " Tests ignoreSect for P63. The white space is not included before the key word \"IGNORE\" in the beginning sequence.  (xmlconf/ibm/valid/P63/ibm63v01.xml)")
end

it "ibm-valid-P63-ibm63v02.xml (Section 3.4)" do
  assert_parses("xmlconf/ibm/valid/P63/ibm63v02.xml", "xmlconf/ibm/valid/P63/out/ibm63v02.xml", " Tests ignoreSect for P63. The white space is not included after the key word \"IGNORE\" in the beginning sequence.  (xmlconf/ibm/valid/P63/ibm63v02.xml)")
end

it "ibm-valid-P63-ibm63v03.xml (Section 3.4)" do
  assert_parses("xmlconf/ibm/valid/P63/ibm63v03.xml", "xmlconf/ibm/valid/P63/out/ibm63v03.xml", " Tests ignoreSect for P63. The white space is included after the key word \"IGNORE\" in the beginning sequence.  (xmlconf/ibm/valid/P63/ibm63v03.xml)")
end

it "ibm-valid-P63-ibm63v04.xml (Section 3.4)" do
  assert_parses("xmlconf/ibm/valid/P63/ibm63v04.xml", "xmlconf/ibm/valid/P63/out/ibm63v04.xml", " Tests ignoreSect for P63. The ignireSectContents is included.  (xmlconf/ibm/valid/P63/ibm63v04.xml)")
end

it "ibm-valid-P63-ibm63v05.xml (Section 3.4)" do
  assert_parses("xmlconf/ibm/valid/P63/ibm63v05.xml", "xmlconf/ibm/valid/P63/out/ibm63v05.xml", " Tests ignoreSect for P63. The white space is included before and after the key word \"IGNORE\" in the beginning sequence.  (xmlconf/ibm/valid/P63/ibm63v05.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 64" do
it "ibm-valid-P64-ibm64v01.xml (Section 3.4)" do
  assert_parses("xmlconf/ibm/valid/P64/ibm64v01.xml", "xmlconf/ibm/valid/P64/out/ibm64v01.xml", " Tests ignoreSectContents for P64. One \"ignore\" field is included.  (xmlconf/ibm/valid/P64/ibm64v01.xml)")
end

it "ibm-valid-P64-ibm64v02.xml (Section 3.4)" do
  assert_parses("xmlconf/ibm/valid/P64/ibm64v02.xml", "xmlconf/ibm/valid/P64/out/ibm64v02.xml", " Tests ignoreSectContents for P64. Two \"ignore\" and one \"ignoreSectContents\" fields are included.  (xmlconf/ibm/valid/P64/ibm64v02.xml)")
end

it "ibm-valid-P64-ibm64v03.xml (Section 3.4)" do
  assert_parses("xmlconf/ibm/valid/P64/ibm64v03.xml", "xmlconf/ibm/valid/P64/out/ibm64v03.xml", " Tests ignoreSectContents for P64. Four \"ignore\" and three \"ignoreSectContents\" fields are included.  (xmlconf/ibm/valid/P64/ibm64v03.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 65" do
it "ibm-valid-P65-ibm65v01.xml (Section 3.4)" do
  assert_parses("xmlconf/ibm/valid/P65/ibm65v01.xml", "xmlconf/ibm/valid/P65/out/ibm65v01.xml", " Tests Ignore for P65. An empty string occurs in the Ignore filed.  (xmlconf/ibm/valid/P65/ibm65v01.xml)")
end

it "ibm-valid-P65-ibm65v02.xml (Section 3.4)" do
  assert_parses("xmlconf/ibm/valid/P65/ibm65v02.xml", "xmlconf/ibm/valid/P65/out/ibm65v02.xml", " Tests Ignore for P65. An string not including the brackets occurs in each of the Ignore filed.  (xmlconf/ibm/valid/P65/ibm65v02.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 66" do
it "ibm-valid-P66-ibm66v01.xml (Section 4.1)" do
  assert_parses("xmlconf/ibm/valid/P66/ibm66v01.xml", "xmlconf/ibm/valid/P66/out/ibm66v01.xml", " Tests all legal CharRef's.  (xmlconf/ibm/valid/P66/ibm66v01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 67" do
it "ibm-valid-P67-ibm67v01.xml (Section 4.1)" do
  assert_parses("xmlconf/ibm/valid/P67/ibm67v01.xml", "xmlconf/ibm/valid/P67/out/ibm67v01.xml", " Tests Reference could be EntityRef or CharRef.  (xmlconf/ibm/valid/P67/ibm67v01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 68" do
it "ibm-valid-P68-ibm68v01.xml (Section 4.1)" do
  assert_parses("xmlconf/ibm/valid/P68/ibm68v01.xml", "xmlconf/ibm/valid/P68/out/ibm68v01.xml", " Tests P68 VC:Entity Declared with Entities in External Subset , standalone is no  (xmlconf/ibm/valid/P68/ibm68v01.xml)")
end

it "ibm-valid-P68-ibm68v02.xml (Section 4.1)" do
  assert_parses("xmlconf/ibm/valid/P68/ibm68v02.xml", "xmlconf/ibm/valid/P68/out/ibm68v02.xml", " Tests P68 VC:Entity Declared with Entities in External Parameter Entities , standalone is no  (xmlconf/ibm/valid/P68/ibm68v02.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 69" do
it "ibm-valid-P69-ibm69v01.xml (Section 4.1)" do
  assert_parses("xmlconf/ibm/valid/P69/ibm69v01.xml", "xmlconf/ibm/valid/P69/out/ibm69v01.xml", " Tests P68 VC:Entity Declared with Parameter Entities in External Subset , standalone is no  (xmlconf/ibm/valid/P69/ibm69v01.xml)")
end

it "ibm-valid-P69-ibm69v02.xml (Section 4.1)" do
  assert_parses("xmlconf/ibm/valid/P69/ibm69v02.xml", "xmlconf/ibm/valid/P69/out/ibm69v02.xml", " Tests P68 VC:Entity Declared with Parameter Entities in External Parameter Entities, standalone is no  (xmlconf/ibm/valid/P69/ibm69v02.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 70" do
it "ibm-valid-P70-ibm70v01.xml (Section 4.2)" do
  assert_parses("xmlconf/ibm/valid/P70/ibm70v01.xml", "xmlconf/ibm/valid/P70/out/ibm70v01.xml", " Tests all legal GEDecls and PEDecls constructs derived from P70-76  (xmlconf/ibm/valid/P70/ibm70v01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 78" do
it "ibm-valid-P78-ibm78v01.xml (Section 4.3.2)" do
  assert_parses("xmlconf/ibm/valid/P78/ibm78v01.xml", "xmlconf/ibm/valid/P78/out/ibm78v01.xml", " Tests ExtParsedEnt, also TextDecl in P77 and EncodingDecl in P80  (xmlconf/ibm/valid/P78/ibm78v01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 79" do
it "ibm-valid-P79-ibm79v01.xml (Section 4.3.2)" do
  assert_parses("xmlconf/ibm/valid/P79/ibm79v01.xml", nil, " Tests extPE  (xmlconf/ibm/valid/P79/ibm79v01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 82" do
it "ibm-valid-P82-ibm82v01.xml (Section 4.7)" do
  assert_parses("xmlconf/ibm/valid/P82/ibm82v01.xml", "xmlconf/ibm/valid/P82/out/ibm82v01.xml", " Tests NotationDecl in P82 and PublicID in P83  (xmlconf/ibm/valid/P82/ibm82v01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 85" do
it "ibm-valid-P85-ibm85v01.xml (Section B.)" do
  assert_parses("xmlconf/ibm/valid/P85/ibm85v01.xml", nil, " This test case covers 149 legal character ranges plus 51 single legal characters for BaseChar in P85 using a PI target Name  (xmlconf/ibm/valid/P85/ibm85v01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 86" do
it "ibm-valid-P86-ibm86v01.xml (Section B.)" do
  assert_parses("xmlconf/ibm/valid/P86/ibm86v01.xml", nil, " This test case covers 2 legal character ranges plus 1 single legal characters for IdeoGraphic in P86 using a PI target Name  (xmlconf/ibm/valid/P86/ibm86v01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 87" do
it "ibm-valid-P87-ibm87v01.xml (Section B.)" do
  assert_parses("xmlconf/ibm/valid/P87/ibm87v01.xml", nil, " This test case covers 65 legal character ranges plus 30 single legal characters for CombiningChar in P87 using a PI target Name  (xmlconf/ibm/valid/P87/ibm87v01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 88" do
it "ibm-valid-P88-ibm88v01.xml (Section B.)" do
  assert_parses("xmlconf/ibm/valid/P88/ibm88v01.xml", nil, " This test case covers 15 legal character ranges for Digit in P88 using a PI target Name  (xmlconf/ibm/valid/P88/ibm88v01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 89" do
it "ibm-valid-P89-ibm89v01.xml (Section B.)" do
  assert_parses("xmlconf/ibm/valid/P89/ibm89v01.xml", nil, " This test case covers 3 legal character ranges plus 8 single legal characters for Extender in P89 using a PI target Name  (xmlconf/ibm/valid/P89/ibm89v01.xml)")
end

end

end

end

describe "IBM XML 1.1 Tests" do
describe "IBM Invalid Conformance Tests for XML 1.1 CR October 15, 2002" do
describe "IBM XML Conformance Test Suite" do
it "ibm-1-1-valid-P46-ibm46i01.xml (Section 3.2.1, 2.2)" do
  assert_parses("xmlconf/ibm/xml-1.1/invalid/P46/ibm46i01.xml", nil, " An element with Element-Only content contains the character #x85 (NEL not a whitespace character as defined by S).  (xmlconf/ibm/xml-1.1/invalid/P46/ibm46i01.xml)")
end

it "ibm-1-1-valid-P46-ibm46i02.xml (Section 3.2.1, 2.2)" do
  assert_parses("xmlconf/ibm/xml-1.1/invalid/P46/ibm46i02.xml", nil, " An element with Element-Only content contains the character #x2028 (LESP not a whitespace character as defined by S).  (xmlconf/ibm/xml-1.1/invalid/P46/ibm46i02.xml)")
end

end

end

describe "IBM Not-WF Conformance Tests for XML 1.1 CR October 15, 2002" do
describe "IBM XML Conformance Test Suite - Production 2" do
it "ibm-1-1-not-wf-P02-ibm02n01.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x1.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n01.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n02.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x2.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n02.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n03.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x3.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n03.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n04.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x4.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n04.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n05.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x5.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n05.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n06.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x6.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n06.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n07.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x7.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n07.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n07.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n08.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x8.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n08.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n08.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n09.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x0.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n09.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n09.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n10.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x100.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n10.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n10.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n11.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x0B.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n11.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n11.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n12.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x0C.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n12.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n12.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n14.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x0E.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n14.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n14.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n15.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x0F.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n15.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n15.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n16.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x10.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n16.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n16.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n17.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x11.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n17.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n17.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n18.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x12.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n18.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n18.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n19.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x13.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n19.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n19.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n20.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x14.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n20.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n20.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n21.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x15.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n21.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n21.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n22.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x16.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n22.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n22.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n23.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x17.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n23.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n23.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n24.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x18.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n24.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n24.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n25.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x19.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n25.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n25.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n26.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x1A.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n26.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n26.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n27.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x1B.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n27.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n27.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n28.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x1C.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n28.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n28.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n29.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x1D.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n29.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n29.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n30.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x1E.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n30.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n30.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n31.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x1F.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n31.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n31.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n32.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x7F.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n32.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n32.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n33.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x80.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n33.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n33.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n34.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x81.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n34.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n34.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n35.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x82.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n35.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n35.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n36.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x83.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n36.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n36.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n37.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x84.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n37.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n37.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n38.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control characters x82, x83 and x84.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n38.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n38.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n39.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x86.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n39.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n39.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n40.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x87.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n40.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n40.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n41.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x88.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n41.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n41.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n42.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x89.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n42.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n42.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n43.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x8A.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n43.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n43.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n44.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x8B.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n44.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n44.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n45.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x8C.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n45.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n45.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n46.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x8D.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n46.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n46.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n47.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x8E.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n47.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n47.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n48.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x8F.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n48.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n48.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n49.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x90.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n49.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n49.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n50.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x91.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n50.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n50.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n51.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x92.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n51.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n51.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n52.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x93.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n52.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n52.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n53.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x94.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n53.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n53.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n54.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x95.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n54.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n54.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n55.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x96.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n55.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n55.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n56.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x97.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n56.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n56.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n57.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x98.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n57.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n57.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n58.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x99.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n58.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n58.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n59.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x9A.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n59.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n59.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n60.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x9B.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n60.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n60.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n61.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x9C.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n61.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n61.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n62.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x9D.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n62.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n62.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n63.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control character 0x9E.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n63.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n63.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n64.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control characters present in an external entity.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n64.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n64.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n65.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control characters present in an external entity.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n65.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n65.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n66.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded control characters present in an external entity.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n66.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n66.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n67.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded character 0xD800. (Invalid UTF8 sequence)  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n67.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n67.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n68.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded character 0xFFFE.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n68.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n68.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n69.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains embeded character 0xFFFF.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n69.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n69.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n70.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains a reference to character 0xFFFE.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n70.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n70.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P02-ibm02n71.xml (Section 2.2,4.1)" do
  assert_raises(XML::Error, " This test contains a reference to character 0xFFFF.  (xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n71.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P02/ibm02n71.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 4" do
it "ibm-1-1-not-wf-P04-ibm04n01.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameStartChar: #x300  (xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n01.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04-ibm04n02.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameStartChar: #0x333  (xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n02.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04-ibm04n03.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameStartChar: #0x369  (xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n03.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04-ibm04n04.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameStartChar: #0x37E  (xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n04.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04-ibm04n05.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameStartChar: #0x2000  (xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n05.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04-ibm04n06.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameStartChar: #0x2001  (xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n06.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04-ibm04n07.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameStartChar: #0x2002  (xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n07.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n07.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04-ibm04n08.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameStartChar: #0x2005  (xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n08.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n08.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04-ibm04n09.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameStartChar: #0x200B  (xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n09.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n09.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04-ibm04n10.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameStartChar: #0x200E  (xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n10.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n10.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04-ibm04n11.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameStartChar: #0x200F  (xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n11.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n11.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04-ibm04n12.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameStartChar: #0x2069  (xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n12.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n12.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04-ibm04n13.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameStartChar: #0x2190  (xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n13.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n13.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04-ibm04n14.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameStartChar: #0x23FF  (xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n14.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n14.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04-ibm04n15.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameStartChar: #0x280F  (xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n15.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n15.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04-ibm04n16.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameStartChar: #0x2A00  (xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n16.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n16.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04-ibm04n17.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameStartChar: #0x2EDC  (xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n17.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n17.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04-ibm04n18.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameStartChar: #0x2B00  (xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n18.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n18.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04-ibm04n19.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameStartChar: #0x2BFF  (xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n19.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n19.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04-ibm04n20.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameStartChar: #0x3000  (xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n20.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n20.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04-ibm04n21.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameStartChar: #0xD800  (xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n21.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n21.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04-ibm04n22.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameStartChar: #0xD801  (xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n22.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n22.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04-ibm04n23.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameStartChar: #0xDAFF  (xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n23.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n23.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04-ibm04n24.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameStartChar: #0xDFFF  (xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n24.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n24.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04-ibm04n25.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameStartChar: #0xEFFF  (xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n25.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n25.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04-ibm04n26.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameStartChar: #0xF1FF  (xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n26.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n26.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04-ibm04n27.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameStartChar: #0xF8FF  (xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n27.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n27.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04-ibm04n28.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameStartChar: #0xFFFFF  (xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n28.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04/ibm04n28.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 4a" do
it "ibm-1-1-not-wf-P04a-ibm04an01.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameChar: #xB8  (xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an01.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04a-ibm04an02.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameChar: #0xA1  (xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an02.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04a-ibm04an03.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameChar: #0xAF  (xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an03.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04a-ibm04an04.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameChar: #0x37E  (xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an04.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04a-ibm04an05.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameChar: #0x2000  (xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an05.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04a-ibm04an06.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameChar: #0x2001  (xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an06.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04a-ibm04an07.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameChar: #0x2002  (xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an07.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an07.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04a-ibm04an08.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameChar: #0x2005  (xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an08.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an08.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04a-ibm04an09.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameChar: #0x200B  (xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an09.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an09.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04a-ibm04an10.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameChar: #0x200E  (xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an10.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an10.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04a-ibm04an11.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameChar: #0x2038  (xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an11.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an11.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04a-ibm04an12.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameChar: #0x2041  (xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an12.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an12.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04a-ibm04an13.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameChar: #0x2190  (xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an13.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an13.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04a-ibm04an14.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameChar: #0x23FF  (xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an14.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an14.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04a-ibm04an15.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameChar: #0x280F  (xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an15.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an15.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04a-ibm04an16.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameChar: #0x2A00  (xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an16.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an16.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04a-ibm04an17.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameChar: #0xFDD0  (xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an17.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an17.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04a-ibm04an18.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameChar: #0xFDEF  (xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an18.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an18.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04a-ibm04an19.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameChar: #0x2FFF  (xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an19.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an19.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04a-ibm04an20.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameChar: #0x3000  (xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an20.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an20.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04a-ibm04an21.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameChar: #0xD800  (xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an21.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an21.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04a-ibm04an22.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameChar: #0xD801  (xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an22.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an22.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04a-ibm04an23.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameChar: #0xDAFF  (xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an23.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an23.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04a-ibm04an24.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameChar: #0xDFFF  (xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an24.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an24.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04a-ibm04an25.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameChar: #0xEFFF  (xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an25.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an25.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04a-ibm04an26.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameChar: #0xF1FF  (xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an26.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an26.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04a-ibm04an27.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameChar: #0xF8FF  (xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an27.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an27.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P04a-ibm04an28.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal NameChar: #0xFFFFF  (xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an28.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P04a/ibm04an28.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 5" do
it "ibm-1-1-not-wf-P05-ibm05n01.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal Name containing #0x0B  (xmlconf/ibm/xml-1.1/not-wf/P05/ibm05n01.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P05/ibm05n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P05-ibm05n02.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal Name containing #0x300  (xmlconf/ibm/xml-1.1/not-wf/P05/ibm05n02.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P05/ibm05n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P05-ibm05n03.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal Name containing #0x36F  (xmlconf/ibm/xml-1.1/not-wf/P05/ibm05n03.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P05/ibm05n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P05-ibm05n04.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal Name containing #0x203F  (xmlconf/ibm/xml-1.1/not-wf/P05/ibm05n04.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P05/ibm05n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P05-ibm05n05.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal Name containing #x2040  (xmlconf/ibm/xml-1.1/not-wf/P05/ibm05n05.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P05/ibm05n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P05-ibm05n06.xml (Section 2.3)" do
  assert_raises(XML::Error, " Tests an element with an illegal Name containing #0xB7  (xmlconf/ibm/xml-1.1/not-wf/P05/ibm05n06.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P05/ibm05n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

describe "IBM XML Conformance Test Suite - Production 77" do
it "ibm-1-1-not-wf-P77-ibm77n01.xml (Section 4.3.4)" do
  assert_raises(XML::Error, " The VersionNum of the document entity is 1.1 and that of the external dtd 1.0. The external dtd contains the invalid XML1.1 but valid XML 1.0 character #x7F.  (xmlconf/ibm/xml-1.1/not-wf/P77/ibm77n01.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P77/ibm77n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P77-ibm77n02.xml (Section 4.3.4)" do
  assert_raises(XML::Error, " The VersionNum of the document entity is 1.1 and that of the external dtd 1.0. The external dtd contains a comment with the invalid XML1.1 but valid XML 1.0 character #x80.  (xmlconf/ibm/xml-1.1/not-wf/P77/ibm77n02.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P77/ibm77n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P77-ibm77n03.xml (Section 4.3.4)" do
  assert_raises(XML::Error, " The VersionNum of the document entity is 1.1 and that of the external dtd 1.0. The external dtd contains a PI with the invalid XML1.1 but valid XML 1.0 character #x9F.  (xmlconf/ibm/xml-1.1/not-wf/P77/ibm77n03.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P77/ibm77n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P77-ibm77n04.xml (Section 4.3.4)" do
  assert_raises(XML::Error, " The VersionNum of the document entity is 1.1 and that of the external entity 1.0. The external entity the contains invalid XML1.1 but valid XML 1.0 character #x89.  (xmlconf/ibm/xml-1.1/not-wf/P77/ibm77n04.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P77/ibm77n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P77-ibm77n05.xml (Section 4.3.4)" do
  assert_raises(XML::Error, " The VersionNum of the document entity is 1.1 and that of the external entity 1.0. The external entity contains the invalid XML1.1 but valid XML 1.0 character #x94.  (xmlconf/ibm/xml-1.1/not-wf/P77/ibm77n05.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P77/ibm77n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P77-ibm77n06.xml (Section 4.3.4)" do
  assert_raises(XML::Error, " The VersionNum of the document entity is 1.1 and that of the external entity 1.0. The external entity contains the invalid XML1.1 but valid XML 1.0 character #x9F.  (xmlconf/ibm/xml-1.1/not-wf/P77/ibm77n06.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P77/ibm77n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P77-ibm77n07.xml (Section 4.3.4)" do
  assert_raises(XML::Error, " The VersionNum of the document entity is 1.1 and the external dtd does not contain a textDecl. The external entity contains the invalid XML1.1 but valid XML 1.0 character #x7F.  (xmlconf/ibm/xml-1.1/not-wf/P77/ibm77n07.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P77/ibm77n07.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P77-ibm77n08.xml (Section 4.3.4)" do
  assert_raises(XML::Error, " The VersionNum of the document entity is 1.1 and the external dtd does not contain a VersionNum in the textDecl. The external entity contains the invalid XML1.1 but valid XML 1.0 character #x9B.  (xmlconf/ibm/xml-1.1/not-wf/P77/ibm77n08.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P77/ibm77n08.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P77-ibm77n09.xml (Section 4.3.4)" do
  assert_raises(XML::Error, " The VersionNum of the document entity is 1.1 and the external dtd does not contain a textDecl. The external entity contains the invalid XML1.1 but valid XML 1.0 character #x8D.  (xmlconf/ibm/xml-1.1/not-wf/P77/ibm77n09.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P77/ibm77n09.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P77-ibm77n10.xml (Section 4.3.4)" do
  assert_raises(XML::Error, " The VersionNum of the document entity is 1.1 and the external dtd does not contain a VersionNum in the textDecl. The external entity contains the invalid XML 1.1 but valid XML 1.0 character #x84.  (xmlconf/ibm/xml-1.1/not-wf/P77/ibm77n10.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P77/ibm77n10.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P77-ibm77n11.xml (Section 4.3.4)" do
  assert_raises(XML::Error, " The VersionNum of the document entity is 1.1 and the external dtd does not contain a textDecl. The external entity contains the invalid XML 1.1 but valid XML 1.0 character #x88.  (xmlconf/ibm/xml-1.1/not-wf/P77/ibm77n11.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P77/ibm77n11.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P77-ibm77n12.xml (Section 4.3.4)" do
  assert_raises(XML::Error, " The VersionNum of the document entity is 1.1 and the external dtd does not contain a textDecl. The external entity contains the invalid XML 1.1 but valid XML 1.0 character #x8E.  (xmlconf/ibm/xml-1.1/not-wf/P77/ibm77n12.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P77/ibm77n12.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P77-ibm77n13.xml (Section 4.3.4)" do
  assert_raises(XML::Error, " The VersionNum of the primary document entity is 1.0 and that of the external dtd is 1.0. The external dtd contains an external entity whose VersionNum is 1.1.  (xmlconf/ibm/xml-1.1/not-wf/P77/ibm77n13.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P77/ibm77n13.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P77-ibm77n14.xml (Section 4.3.4)" do
  assert_raises(XML::Error, " The VersionNum of the primary document entity is 1.1 and that of the external dtd is 1.0. The external dtd contains an element declaration with an invalid XML 1.1 and 1.0 name.  (xmlconf/ibm/xml-1.1/not-wf/P77/ibm77n14.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P77/ibm77n14.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P77-ibm77n15.xml (Section 4.3.4)" do
  assert_raises(XML::Error, " The VersionNum of the primary document entity is 1.1 and testDecl of the external dtd is absent. The external dtd contains an external entity whose VersionNum is 1.1 containing a valid XML1.0 but an invalid XML 1.1 character #x7F.  (xmlconf/ibm/xml-1.1/not-wf/P77/ibm77n15.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P77/ibm77n15.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P77-ibm77n16.xml (Section 4.3.4)" do
  assert_raises(XML::Error, " The VersionNum of the primary document entity is 1.0 and VersioNum of the external entity is absent. The replacement text of the entity contains an element followed by the valid XML 1.1 of line character NEL #x85 in its empty elem tag.  (xmlconf/ibm/xml-1.1/not-wf/P77/ibm77n16.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P77/ibm77n16.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P77-ibm77n17.xml (Section 4.3.4)" do
  assert_raises(XML::Error, " The VersionNum of the primary document entity is absent and that of the external entity is 1.0. The textDecl in the external entity contains an invalid XML1.0 but valid XML 1.1 enf of line character NEL #x85.  (xmlconf/ibm/xml-1.1/not-wf/P77/ibm77n17.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P77/ibm77n17.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P77-ibm77n18.xml (Section 4.3.4)" do
  assert_raises(XML::Error, " The VersionNum of the primary document entity is absent and that of the external entity is 1.0. The textDecl in the external entity contains an invalid XML1.0 but valid XML 1.1 of line character Unicode line separator #x2028.  (xmlconf/ibm/xml-1.1/not-wf/P77/ibm77n18.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P77/ibm77n18.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P77-ibm77n19.xml (Section 4.3.4)" do
  assert_raises(XML::Error, " The VersionNum of the primary document entity is 1.1 and that of the external dtd is absent. The external dtd contains an external entity whose VersionNum is absent and it contains a valid XML 1.0 but an invalid XML 1.1 character #x94.  (xmlconf/ibm/xml-1.1/not-wf/P77/ibm77n19.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P77/ibm77n19.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P77-ibm77n20.xml (Section 4.3.4)" do
  assert_raises(XML::Error, " The VersionNum of the primary document entity is 1.1 and that of the external dtd is 1.1. The external dtd contains an external entity whose VersionNum is absent and it contains a valid XML 1.0 but an invalid XML 1.1 character #x8F.  (xmlconf/ibm/xml-1.1/not-wf/P77/ibm77n20.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P77/ibm77n20.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ibm-1-1-not-wf-P77-ibm77n21.xml (Section 4.3.4)" do
  assert_raises(XML::Error, " The VersionNum of the primary document entity is 1.1 and the texlDecl of the external dtd is absent. The external dtd contains a reference to an external parameter entity whose VersionNum is absent from the textDecl and it contains an invalid XML 1.1 character #x8F.  (xmlconf/ibm/xml-1.1/not-wf/P77/ibm77n21.xml)") do
    File.open("xmlconf/ibm/xml-1.1/not-wf/P77/ibm77n21.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

end

describe "IBM Valid Conformance Tests for XML 1.1 CR October 15, 2002" do
describe "IBM XML Conformance Test Suite - Production 2" do
it "ibm-1-1-valid-P02-ibm02v01.xml (Section 2.2)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P02/ibm02v01.xml", nil, " This test case covers legal character ranges plus discrete legal characters for production 02 of the XML1.1 sepcification.  (xmlconf/ibm/xml-1.1/valid/P02/ibm02v01.xml)")
end

it "ibm-1-1-valid-P02-ibm02v02.xml (Section 2.2,4.1)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P02/ibm02v02.xml", nil, " This test case covers control characters x1 to x1F and x7F to x9F which should only appear as character references.  (xmlconf/ibm/xml-1.1/valid/P02/ibm02v02.xml)")
end

it "ibm-1-1-valid-P02-ibm02v03.xml (Section 2.2,4.1)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P02/ibm02v03.xml", nil, " This test case covers control characters x1 to x1F and x7F to x9F which appear as character references as an entity's replacement text.  (xmlconf/ibm/xml-1.1/valid/P02/ibm02v03.xml)")
end

it "ibm-1-1-valid-P02-ibm02v04.xml (Section 2.2,4.1)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P02/ibm02v04.xml", nil, " This test case contains embeded whitespace characters some form the range 1 - 1F.  (xmlconf/ibm/xml-1.1/valid/P02/ibm02v04.xml)")
end

it "ibm-1-1-valid-P02-ibm02v05.xml (Section 2.2,4.1)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P02/ibm02v05.xml", nil, " This test case contains valid char references that match the char production.  (xmlconf/ibm/xml-1.1/valid/P02/ibm02v05.xml)")
end

it "ibm-1-1-valid-P02-ibm02v06.xml (Section 2.2,4.1)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P02/ibm02v06.xml", nil, " This test case contains valid char references in the CDATA section, comment and processing instruction of an external entity that match the char production.  (xmlconf/ibm/xml-1.1/valid/P02/ibm02v06.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 3" do
it "ibm-1-1-valid-P03-ibm03v01.xml (Section 2.11)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P03/ibm03v01.xml", "xmlconf/ibm/xml-1.1/valid/P03/out/ibm03v01.xml", " The two character sequence #x0D #x85 in an external entity must be normalized to a single newline.  (xmlconf/ibm/xml-1.1/valid/P03/ibm03v01.xml)")
end

it "ibm-1-1-valid-P03-ibm03v02.xml (Section 2.11)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P03/ibm03v02.xml", "xmlconf/ibm/xml-1.1/valid/P03/out/ibm03v02.xml", " The single character sequence #x85 in an external entity must be normalized to a single newline.  (xmlconf/ibm/xml-1.1/valid/P03/ibm03v02.xml)")
end

it "ibm-1-1-valid-P03-ibm03v03.xml (Section 2.11)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P03/ibm03v03.xml", "xmlconf/ibm/xml-1.1/valid/P03/out/ibm03v03.xml", " The two character sequence #x0D #x85 in an external entity must be normalized to a single newline.  (xmlconf/ibm/xml-1.1/valid/P03/ibm03v03.xml)")
end

it "ibm-1-1-valid-P03-ibm03v04.xml (Section 2.11)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P03/ibm03v04.xml", "xmlconf/ibm/xml-1.1/valid/P03/out/ibm03v04.xml", " The single character sequence #x85 in an external entity must be normalized to a single newline.  (xmlconf/ibm/xml-1.1/valid/P03/ibm03v04.xml)")
end

it "ibm-1-1-valid-P03-ibm03v05.xml (Section 2.11)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P03/ibm03v05.xml", "xmlconf/ibm/xml-1.1/valid/P03/out/ibm03v05.xml", " The two character sequence #x0D #x85 in a document entity must be normalized to a single newline.  (xmlconf/ibm/xml-1.1/valid/P03/ibm03v05.xml)")
end

it "ibm-1-1-valid-P03-ibm03v06.xml (Section 2.11)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P03/ibm03v06.xml", "xmlconf/ibm/xml-1.1/valid/P03/out/ibm03v06.xml", " The single character sequence #x85 in a document entity must be normalized to a single newline.  (xmlconf/ibm/xml-1.1/valid/P03/ibm03v06.xml)")
end

it "ibm-1-1-valid-P03-ibm03v07.xml (Section 2.11)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P03/ibm03v07.xml", "xmlconf/ibm/xml-1.1/valid/P03/out/ibm03v07.xml", " The single character sequence #x2028 in a document entity must be normalized to a single newline.  (xmlconf/ibm/xml-1.1/valid/P03/ibm03v07.xml)")
end

it "ibm-1-1-valid-P03-ibm03v08.xml (Section 2.11)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P03/ibm03v08.xml", "xmlconf/ibm/xml-1.1/valid/P03/out/ibm03v08.xml", " The single character sequence #x85 in the XMLDecl must be normalized to a single newline.  (xmlconf/ibm/xml-1.1/valid/P03/ibm03v08.xml)")
end

it "ibm-1-1-valid-P03-ibm03v09.xml (Section 2.11)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P03/ibm03v09.xml", "xmlconf/ibm/xml-1.1/valid/P03/out/ibm03v09.xml", " The single character sequence #x2028 in the XMLDecl must be normalized to a single newline. (This test is questionable)  (xmlconf/ibm/xml-1.1/valid/P03/ibm03v09.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 4" do
it "ibm-1-1-valid-P04-ibm04v01.xml (Section 2.3)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P04/ibm04v01.xml", nil, " This test case covers legal NameStartChars character ranges plus discrete legal characters for production 04.  (xmlconf/ibm/xml-1.1/valid/P04/ibm04v01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 4a" do
it "ibm-1-1-valid-P04-ibm04av01.xml (Section 2.3)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P04a/ibm04av01.xml", nil, " This test case covers legal NameChars character ranges plus discrete legal characters for production 04a.  (xmlconf/ibm/xml-1.1/valid/P04a/ibm04av01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 5" do
it "ibm-1-1-valid-P05-ibm05v01.xml (Section 2.3)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P05/ibm05v01.xml", nil, " This test case covers legal Element Names as per production 5.  (xmlconf/ibm/xml-1.1/valid/P05/ibm05v01.xml)")
end

it "ibm-1-1-valid-P05-ibm05v02.xml (Section 2.3)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P05/ibm05v02.xml", nil, " This test case covers legal PITarget (Names) as per production 5.  (xmlconf/ibm/xml-1.1/valid/P05/ibm05v02.xml)")
end

it "ibm-1-1-valid-P05-ibm05v03.xml (Section 2.3)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P05/ibm05v03.xml", nil, " This test case covers legal Attribute (Names) as per production 5.  (xmlconf/ibm/xml-1.1/valid/P05/ibm05v03.xml)")
end

it "ibm-1-1-valid-P05-ibm05v04.xml (Section 2.3)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P05/ibm05v04.xml", nil, " This test case covers legal ID/IDREF (Names) as per production 5.  (xmlconf/ibm/xml-1.1/valid/P05/ibm05v04.xml)")
end

it "ibm-1-1-valid-P05-ibm05v05.xml (Section 2.3)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P05/ibm05v05.xml", nil, " This test case covers legal ENTITY (Names) as per production 5.  (xmlconf/ibm/xml-1.1/valid/P05/ibm05v05.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 7" do
it "ibm-1-1-valid-P047-ibm07v01.xml (Section 2.3)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P07/ibm07v01.xml", nil, " This test case covers legal NMTOKEN Name character ranges plus discrete legal characters for production 7.  (xmlconf/ibm/xml-1.1/valid/P07/ibm07v01.xml)")
end

end

describe "IBM XML Conformance Test Suite - Production 77" do
it "ibm-1-1-valid-P77-ibm77v01.xml (Section 4.3.4)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P77/ibm77v01.xml", nil, " The VersionNum of the document entity is 1.1 whereas the VersionNum of the external DTD is 1.0. The character #xC0 which is a valid XML 1.1 but an invalid XML 1.0 character is present in both documents.  (xmlconf/ibm/xml-1.1/valid/P77/ibm77v01.xml)")
end

it "ibm-1-1-valid-P77-ibm77v02.xml (Section 4.3.4)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P77/ibm77v02.xml", nil, " The VersionNum of the document entity is 1.1 whereas the VersionNum of the external DTD is 1.0. The character #x1FFF which is a valid XML 1.1 but an invalid XML 1.0 character is present in both documents.  (xmlconf/ibm/xml-1.1/valid/P77/ibm77v02.xml)")
end

it "ibm-1-1-valid-P77-ibm77v03.xml (Section 4.3.4)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P77/ibm77v03.xml", nil, " The VersionNum of the document entity is 1.1 whereas the VersionNum of the external DTD is 1.0. The character #xF901 which is a valid XML 1.1 but an invalid XML 1.0 character is present in both documents.  (xmlconf/ibm/xml-1.1/valid/P77/ibm77v03.xml)")
end

it "ibm-1-1-valid-P77-ibm77v04.xml (Section 4.3.4)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P77/ibm77v04.xml", nil, " The VersionNum of the document entity is 1.1 whereas the VersionNum of the external entity is 1.0. The character #xD6 which is a valid XML 1.1 but an invalid XML 1.0 character is present in both documents.  (xmlconf/ibm/xml-1.1/valid/P77/ibm77v04.xml)")
end

it "ibm-1-1-valid-P77-ibm77v05.xml (Section 4.3.4)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P77/ibm77v05.xml", nil, " The VersionNum of the document entity is 1.1 whereas the VersionNum of the external entity is 1.0. The character #x1FFF which is a valid XML 1.1 but an invalid XML 1.0 character is present in both documents.  (xmlconf/ibm/xml-1.1/valid/P77/ibm77v05.xml)")
end

it "ibm-1-1-valid-P77-ibm77v06.xml (Section 4.3.4)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P77/ibm77v06.xml", nil, " The VersionNum of the document entity is 1.1 whereas the VersionNum of the external entity is 1.0. The character #xF901 which is a valid XML 1.1 but an invalid XML 1.0 character is present in both documents.  (xmlconf/ibm/xml-1.1/valid/P77/ibm77v06.xml)")
end

it "ibm-1-1-valid-P77-ibm77v07.xml (Section 4.3.4)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P77/ibm77v07.xml", nil, " The VersionNum of the document and external dtd is 1.1 and both contain the valid XML1.1 but invalid XML1.0 character #xD8.  (xmlconf/ibm/xml-1.1/valid/P77/ibm77v07.xml)")
end

it "ibm-1-1-valid-P77-ibm77v08.xml (Section 4.3.4)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P77/ibm77v08.xml", nil, " The VersionNum of the document and external dtd is 1.1 and both contain the valid XML1.1 but invalid XML1.0 character #x1FFF.  (xmlconf/ibm/xml-1.1/valid/P77/ibm77v08.xml)")
end

it "ibm-1-1-valid-P77-ibm77v09.xml (Section 4.3.4)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P77/ibm77v09.xml", nil, " The VersionNum of the document and external dtd is 1.1 and both contain the valid XML1.1 but invalid XML1.0 character #xF901.  (xmlconf/ibm/xml-1.1/valid/P77/ibm77v09.xml)")
end

it "ibm-1-1-valid-P77-ibm77v10.xml (Section 4.3.4)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P77/ibm77v10.xml", nil, " The VersionNum of the document and external entity is 1.1 and both contain the valid XML1.1 but invalid XML1.0 character #xF6.  (xmlconf/ibm/xml-1.1/valid/P77/ibm77v10.xml)")
end

it "ibm-1-1-valid-P77-ibm77v11.xml (Section 4.3.4)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P77/ibm77v11.xml", nil, " The VersionNum of the document and external entity is 1.1 and both contain the valid XML1.1 but invalid XML1.0 character #x1FFF.  (xmlconf/ibm/xml-1.1/valid/P77/ibm77v11.xml)")
end

it "ibm-1-1-valid-P77-ibm77v12.xml (Section 4.3.4)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P77/ibm77v12.xml", nil, " The VersionNum of the document and external entity is 1.1 and both contain the valid XML1.1 but invalid XML1.0 character #xF901.  (xmlconf/ibm/xml-1.1/valid/P77/ibm77v12.xml)")
end

it "ibm-1-1-valid-P77-ibm77v13.xml (Section 4.3.4)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P77/ibm77v13.xml", nil, " The VersionNum of the document entity is 1.1 but the external dtd does not contain a textDecl and both contain the valid XML1.1 but invalid XML1.0 character #xF8.  (xmlconf/ibm/xml-1.1/valid/P77/ibm77v13.xml)")
end

it "ibm-1-1-valid-P77-ibm77v14.xml (Section 4.3.4)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P77/ibm77v14.xml", nil, " The VersionNum of the document entity is 1.1 but the external dtd does not contain a textDecl and both contain the valid XML1.1 but invalid XML1.0 character #x1FFF.  (xmlconf/ibm/xml-1.1/valid/P77/ibm77v14.xml)")
end

it "ibm-1-1-valid-P77-ibm77v15.xml (Section 4.3.4)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P77/ibm77v15.xml", nil, " The VersionNum of the document entity is 1.1 but the external dtd does not contain a textDecl and both contain the valid XML1.1 but invalid XML1.0 character #xF901.  (xmlconf/ibm/xml-1.1/valid/P77/ibm77v15.xml)")
end

it "ibm-1-1-valid-P77-ibm77v16.xml (Section 4.3.4)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P77/ibm77v16.xml", nil, " The VersionNum of the document entity is 1.1 but the external entity does not contain a textDecl and both contain the valid XML1.1 but invalid XML1.0 character #x2FF.  (xmlconf/ibm/xml-1.1/valid/P77/ibm77v16.xml)")
end

it "ibm-1-1-valid-P77-ibm77v17.xml (Section 4.3.4)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P77/ibm77v17.xml", nil, " The VersionNum of the document entity is 1.1 but the external entity does not contain a textDecl and both contain the valid XML1.1 but invalid XML1.0 character #x1FFF.  (xmlconf/ibm/xml-1.1/valid/P77/ibm77v17.xml)")
end

it "ibm-1-1-valid-P77-ibm77v18.xml (Section 4.3.4)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P77/ibm77v18.xml", nil, " The VersionNum of the document entity is 1.1 but the external entity does not contain a textDecl and both contain the valid XML1.1 but invalid XML1.0 character #xF901.  (xmlconf/ibm/xml-1.1/valid/P77/ibm77v18.xml)")
end

it "ibm-1-1-valid-P77-ibm77v19.xml (Section 4.3.4)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P77/ibm77v19.xml", nil, " The VersionNum of the document and external dtd is 1.1. The replacement text of an entity declared in the external DTD contains a reference to the character #x7F. This entity is not referenced in the document entity.  (xmlconf/ibm/xml-1.1/valid/P77/ibm77v19.xml)")
end

it "ibm-1-1-valid-P77-ibm77v20.xml (Section 4.3.4)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P77/ibm77v20.xml", nil, " The VersionNum of the document and external dtd is 1.1. The replacement text of an entity declared in the external DTD contains a reference to the character #x80. This entity is not referenced in the document entity.  (xmlconf/ibm/xml-1.1/valid/P77/ibm77v20.xml)")
end

it "ibm-1-1-valid-P77-ibm77v21.xml (Section 4.3.4)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P77/ibm77v21.xml", nil, " The VersionNum of the document and external dtd is 1.1. The replacement text of an entity declared in the external DTD contains a reference to the character #x9F. This entity is not referenced in the document entity.  (xmlconf/ibm/xml-1.1/valid/P77/ibm77v21.xml)")
end

it "ibm-1-1-valid-P77-ibm77v22.xml (Section 4.3.4)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P77/ibm77v22.xml", nil, " The VersionNum of the document and the external entity is 1.1. The entity contains a reference to the character #x7F.  (xmlconf/ibm/xml-1.1/valid/P77/ibm77v22.xml)")
end

it "ibm-1-1-valid-P77-ibm77v23.xml (Section 4.3.4)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P77/ibm77v23.xml", nil, " The VersionNum of the document and the external entity is 1.1. The entity contains a reference to the character #x80.  (xmlconf/ibm/xml-1.1/valid/P77/ibm77v23.xml)")
end

it "ibm-1-1-valid-P77-ibm77v24.xml (Section 4.3.4)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P77/ibm77v24.xml", nil, " The VersionNum of the document and the external entity is 1.1. The entity contains a reference to the character #x9F.  (xmlconf/ibm/xml-1.1/valid/P77/ibm77v24.xml)")
end

it "ibm-1-1-valid-P77-ibm77v25.xml (Section 4.3.4)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P77/ibm77v25.xml", nil, " The VersionNum of the document is 1.1 and the textDecl is missing in the external DTD. The replacement text of an entity declared in the external DTD contains a reference to the character #x7F, #x8F. This entity is not referenced in the document entity.  (xmlconf/ibm/xml-1.1/valid/P77/ibm77v25.xml)")
end

it "ibm-1-1-valid-P77-ibm77v26.xml (Section 4.3.4)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P77/ibm77v26.xml", nil, " The VersionNum of the document is 1.1 and the textDecl is missing in the external DTD. The replacement text of an entity declared in the external DTD contains a reference to the character #x80, #x90. This entity is not referenced in the document entity.  (xmlconf/ibm/xml-1.1/valid/P77/ibm77v26.xml)")
end

it "ibm-1-1-valid-P77-ibm77v27.xml (Section 4.3.4)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P77/ibm77v27.xml", nil, " The VersionNum of the document is 1.1 and the textDecl is missing in the external DTD. The replacement text of an entity declared in the external DTD contains a reference to the character #x81, #x9F. This entity is not referenced in the document entity.  (xmlconf/ibm/xml-1.1/valid/P77/ibm77v27.xml)")
end

it "ibm-1-1-valid-P77-ibm77v28.xml (Section 4.3.4)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P77/ibm77v28.xml", nil, " The VersionNum of the document is 1.1 and the textDecl is missing in the external entity. The replacement text of an entity declared in the external DTD contains a reference to the character #x7F, #x80, #x9F.  (xmlconf/ibm/xml-1.1/valid/P77/ibm77v28.xml)")
end

it "ibm-1-1-valid-P77-ibm77v29.xml (Section 4.3.4)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P77/ibm77v29.xml", nil, " The VersionNum of the document is 1.1 and the textDecl is missing in the external entity. The replacement text of an entity declared in the external DTD contains a reference to the character #x85, #x8F.  (xmlconf/ibm/xml-1.1/valid/P77/ibm77v29.xml)")
end

it "ibm-1-1-valid-P77-ibm77v30.xml (Section 4.3.4)" do
  assert_parses("xmlconf/ibm/xml-1.1/valid/P77/ibm77v30.xml", nil, " The VersionNum of the document is 1.1 and the textDecl is missing in the external entity. The replacement text of an entity declared in the external DTD contains a reference to the character #x1, #x7F.  (xmlconf/ibm/xml-1.1/valid/P77/ibm77v30.xml)")
end

end

end

end

describe "eduni/errata-2e/" do
describe "Richard Tobin's XML 1.0 2nd edition errata test suite 21 Jul 2003" do
it "rmt-e2e-2a (Section E2)" do
  assert_parses("xmlconf/eduni/errata-2e/E2a.xml", nil, " Duplicate token in enumerated attribute declaration  (xmlconf/eduni/errata-2e/E2a.xml)")
end

it "rmt-e2e-2b (Section E2)" do
  assert_parses("xmlconf/eduni/errata-2e/E2b.xml", nil, " Duplicate token in NOTATION attribute declaration  (xmlconf/eduni/errata-2e/E2b.xml)")
end

it "rmt-e2e-9a (Section E9)" do
  assert_parses("xmlconf/eduni/errata-2e/E9a.xml", nil, " An unused attribute default need only be syntactically correct  (xmlconf/eduni/errata-2e/E9a.xml)")
end

it "rmt-e2e-9b (Section E9)" do
  assert_parses("xmlconf/eduni/errata-2e/E9b.xml", nil, " An attribute default must be syntactically correct even if unused  (xmlconf/eduni/errata-2e/E9b.xml)")
end

it "rmt-e2e-14 (Section E14)" do
  assert_parses("xmlconf/eduni/errata-2e/E14.xml", nil, " Declarations mis-nested wrt parameter entities are just validity errors (but note that some parsers treat some such errors as fatal)  (xmlconf/eduni/errata-2e/E14.xml)")
end

it "rmt-e2e-15a (Section E15)" do
  assert_parses("xmlconf/eduni/errata-2e/E15a.xml", nil, " Empty content can't contain an entity reference  (xmlconf/eduni/errata-2e/E15a.xml)")
end

it "rmt-e2e-15b (Section E15)" do
  assert_parses("xmlconf/eduni/errata-2e/E15b.xml", nil, " Empty content can't contain a comment  (xmlconf/eduni/errata-2e/E15b.xml)")
end

it "rmt-e2e-15c (Section E15)" do
  assert_parses("xmlconf/eduni/errata-2e/E15c.xml", nil, " Empty content can't contain a PI  (xmlconf/eduni/errata-2e/E15c.xml)")
end

it "rmt-e2e-15d (Section E15)" do
  assert_parses("xmlconf/eduni/errata-2e/E15d.xml", nil, " Empty content can't contain whitespace  (xmlconf/eduni/errata-2e/E15d.xml)")
end

it "rmt-e2e-15e (Section E15)" do
  assert_parses("xmlconf/eduni/errata-2e/E15e.xml", nil, " Element content can contain entity reference if replacement text is whitespace  (xmlconf/eduni/errata-2e/E15e.xml)")
end

it "rmt-e2e-15f (Section E15)" do
  assert_parses("xmlconf/eduni/errata-2e/E15f.xml", nil, " Element content can contain entity reference if replacement text is whitespace, even if it came from a character reference in the literal entity value  (xmlconf/eduni/errata-2e/E15f.xml)")
end

it "rmt-e2e-15g (Section E15)" do
  assert_parses("xmlconf/eduni/errata-2e/E15g.xml", nil, " Element content can't contain character reference to whitespace  (xmlconf/eduni/errata-2e/E15g.xml)")
end

it "rmt-e2e-15h (Section E15)" do
  assert_parses("xmlconf/eduni/errata-2e/E15h.xml", nil, " Element content can't contain entity reference if replacement text is character reference to whitespace  (xmlconf/eduni/errata-2e/E15h.xml)")
end

it "rmt-e2e-15i (Section E15)" do
  assert_parses("xmlconf/eduni/errata-2e/E15i.xml", nil, " Element content can contain a comment  (xmlconf/eduni/errata-2e/E15i.xml)")
end

it "rmt-e2e-15j (Section E15)" do
  assert_parses("xmlconf/eduni/errata-2e/E15j.xml", nil, " Element content can contain a PI  (xmlconf/eduni/errata-2e/E15j.xml)")
end

it "rmt-e2e-15k (Section E15)" do
  assert_parses("xmlconf/eduni/errata-2e/E15k.xml", nil, " Mixed content can contain a comment  (xmlconf/eduni/errata-2e/E15k.xml)")
end

it "rmt-e2e-15l (Section E15)" do
  assert_parses("xmlconf/eduni/errata-2e/E15l.xml", nil, " Mixed content can contain a PI  (xmlconf/eduni/errata-2e/E15l.xml)")
end

it "rmt-e2e-18 (Section E18)" do
  assert_parses("xmlconf/eduni/errata-2e/E18.xml", "xmlconf/eduni/errata-2e/out/E18.xml", " External entity containing start of entity declaration is base URI for system identifier  (xmlconf/eduni/errata-2e/E18.xml)")
end

it "rmt-e2e-19 (Section E19)" do
  assert_parses("xmlconf/eduni/errata-2e/E19.xml", "xmlconf/eduni/errata-2e/out/E19.xml", " Parameter entities and character references are included-in-literal, but general entities are bypassed.  (xmlconf/eduni/errata-2e/E19.xml)")
end

it "rmt-e2e-20 (Section E20)" do
  assert_parses("xmlconf/eduni/errata-2e/E20.xml", nil, " Tokens, after normalization, must be separated by space, not other whitespace characters  (xmlconf/eduni/errata-2e/E20.xml)")
end

it "rmt-e2e-22 (Section E22)" do
  assert_parses("xmlconf/eduni/errata-2e/E22.xml", nil, " UTF-8 entities may start with a BOM  (xmlconf/eduni/errata-2e/E22.xml)")
end

it "rmt-e2e-24 (Section E24)" do
  assert_parses("xmlconf/eduni/errata-2e/E24.xml", nil, " Either the built-in entity or a character reference can be used to represent greater-than after two close-square-brackets  (xmlconf/eduni/errata-2e/E24.xml)")
end

it "rmt-e2e-27 (Section E27)" do
  assert_raises(XML::Error, " Contains an irregular UTF-8 sequence (i.e. a surrogate pair)  (xmlconf/eduni/errata-2e/E27.xml)") do
    File.open("xmlconf/eduni/errata-2e/E27.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "rmt-e2e-29 (Section E29)" do
  assert_parses("xmlconf/eduni/errata-2e/E29.xml", nil, " Three-letter language codes are allowed  (xmlconf/eduni/errata-2e/E29.xml)")
end

it "rmt-e2e-34 (Section E34)" do
  assert_raises(" A non-deterministic content model is an error even if the element type is not used.  (xmlconf/eduni/errata-2e/E34.xml)") do
    File.open("xmlconf/eduni/errata-2e/E34.xml") { |file| XML::DOM.parse(file, base: "xmlconf/eduni/errata-2e") }
  end
end

it "rmt-e2e-36 (Section E36)" do
  assert_parses("xmlconf/eduni/errata-2e/E36.xml", nil, " An external ATTLIST declaration does not make a document non-standalone if the normalization would have been the same without the declaration  (xmlconf/eduni/errata-2e/E36.xml)")
end

it "rmt-e2e-38 (Section E38)" do
  assert_raises(XML::Error, " XML 1.0 document refers to 1.1 entity  (xmlconf/eduni/errata-2e/E38.xml)") do
    File.open("xmlconf/eduni/errata-2e/E38.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "rmt-e2e-41 (Section E41)" do
  assert_parses("xmlconf/eduni/errata-2e/E41.xml", nil, " An xml:lang attribute may be empty  (xmlconf/eduni/errata-2e/E41.xml)")
end

it "rmt-e2e-48 (Section E48)" do
  assert_parses("xmlconf/eduni/errata-2e/E48.xml", nil, " ANY content allows character data  (xmlconf/eduni/errata-2e/E48.xml)")
end

it "rmt-e2e-50 (Section E50)" do
  assert_parses("xmlconf/eduni/errata-2e/E50.xml", nil, " All line-ends are normalized, even those not passed to the application. NB this can only be tested effectively in XML 1.1, since CR is in the S production; in 1.1 we can use NEL which isn't.  (xmlconf/eduni/errata-2e/E50.xml)")
end

it "rmt-e2e-55 (Section E55)" do
  assert_raises(" A reference to an unparsed entity in an entity value is an error rather than forbidden (unless the entity is referenced, of course)  (xmlconf/eduni/errata-2e/E55.xml)") do
    File.open("xmlconf/eduni/errata-2e/E55.xml") { |file| XML::DOM.parse(file, base: "xmlconf/eduni/errata-2e") }
  end
end

it "rmt-e2e-57 (Section E57)" do
  assert_raises(" A value other than preserve or default for xml:space is an error  (xmlconf/eduni/errata-2e/E57.xml)") do
    File.open("xmlconf/eduni/errata-2e/E57.xml") { |file| XML::DOM.parse(file, base: "xmlconf/eduni/errata-2e") }
  end
end

it "rmt-e2e-60 (Section E60)" do
  assert_parses("xmlconf/eduni/errata-2e/E60.xml", nil, " Conditional sections are allowed in external parameter entities referred to from the internal subset.  (xmlconf/eduni/errata-2e/E60.xml)")
end

it "rmt-e2e-61 (Section E61)" do
  assert_raises(XML::Error, " (From John Cowan) An encoding declaration in ASCII specifying an encoding that is not compatible with ASCII (so the document is not in its declared encoding). It should generate a fatal error.  (xmlconf/eduni/errata-2e/E61.xml)") do
    File.open("xmlconf/eduni/errata-2e/E61.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

end

describe "eduni/xml-1.1/" do
describe "Richard Tobin's XML 1.1 test suite 13 Feb 2003" do
it "rmt-001 (Section 2.8 4.3.4)" do
  assert_raises(XML::Error, " External subset has later version number  (xmlconf/eduni/xml-1.1/001.xml)") do
    File.open("xmlconf/eduni/xml-1.1/001.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "rmt-002 (Section 2.8 4.3.4)" do
  assert_raises(XML::Error, " External PE has later version number  (xmlconf/eduni/xml-1.1/002.xml)") do
    File.open("xmlconf/eduni/xml-1.1/002.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "rmt-003 (Section 2.8 4.3.4)" do
  assert_raises(XML::Error, " External general entity has later version number  (xmlconf/eduni/xml-1.1/003.xml)") do
    File.open("xmlconf/eduni/xml-1.1/003.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "rmt-004 (Section 2.8 4.3.4)" do
  assert_raises(XML::Error, " External general entity has later version number (no decl means 1.0)  (xmlconf/eduni/xml-1.1/004.xml)") do
    File.open("xmlconf/eduni/xml-1.1/004.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "rmt-005 (Section 2.8 4.3.4)" do
  assert_raises(XML::Error, " Indirect external general entity has later version number  (xmlconf/eduni/xml-1.1/005.xml)") do
    File.open("xmlconf/eduni/xml-1.1/005.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "rmt-006 (Section 2.8 4.3.4)" do
  assert_parses("xmlconf/eduni/xml-1.1/006.xml", "xmlconf/eduni/xml-1.1/out/006.xml", " Second-level external general entity has later version number than first-level, but not later than document, so not an error.  (xmlconf/eduni/xml-1.1/006.xml)")
end

it "rmt-007 (Section 2.8 4.3.4)" do
  assert_parses("xmlconf/eduni/xml-1.1/007.xml", "xmlconf/eduni/xml-1.1/out/007.xml", " A vanilla XML 1.1 document  (xmlconf/eduni/xml-1.1/007.xml)")
end

it "rmt-008 (Section 2.8 4.3.4)" do
  assert_raises(" an implausibly-versioned document  (xmlconf/eduni/xml-1.1/008.xml)") do
    File.open("xmlconf/eduni/xml-1.1/008.xml") { |file| XML::DOM.parse(file, base: "xmlconf/eduni/xml-1.1") }
  end
end

it "rmt-009 (Section 2.8 4.3.4)" do
  assert_raises(" External general entity has implausible version number  (xmlconf/eduni/xml-1.1/009.xml)") do
    File.open("xmlconf/eduni/xml-1.1/009.xml") { |file| XML::DOM.parse(file, base: "xmlconf/eduni/xml-1.1") }
  end
end

it "rmt-010 (Section 2.2)" do
  assert_parses("xmlconf/eduni/xml-1.1/010.xml", "xmlconf/eduni/xml-1.1/out/010.xml", " Contains a C1 control, legal in XML 1.0, illegal in XML 1.1  (xmlconf/eduni/xml-1.1/010.xml)")
end

it "rmt-011 (Section 2.2)" do
  assert_raises(XML::Error, " Contains a C1 control, legal in XML 1.0, illegal in XML 1.1  (xmlconf/eduni/xml-1.1/011.xml)") do
    File.open("xmlconf/eduni/xml-1.1/011.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "rmt-012 (Section 2.2)" do
  assert_parses("xmlconf/eduni/xml-1.1/012.xml", "xmlconf/eduni/xml-1.1/out/012.xml", " Contains a DEL, legal in XML 1.0, illegal in XML 1.1  (xmlconf/eduni/xml-1.1/012.xml)")
end

it "rmt-013 (Section 2.2)" do
  assert_raises(XML::Error, " Contains a DEL, legal in XML 1.0, illegal in XML 1.1  (xmlconf/eduni/xml-1.1/013.xml)") do
    File.open("xmlconf/eduni/xml-1.1/013.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "rmt-014 (Section 2.3)" do
  assert_raises(XML::Error, " Has a \"long s\" in a name, legal in XML 1.1, illegal in XML 1.0 thru 4th edition  (xmlconf/eduni/xml-1.1/014.xml)") do
    File.open("xmlconf/eduni/xml-1.1/014.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "rmt-015 (Section 2.3)" do
  assert_parses("xmlconf/eduni/xml-1.1/015.xml", "xmlconf/eduni/xml-1.1/out/015.xml", " Has a \"long s\" in a name, legal in XML 1.1, illegal in XML 1.0 thru 4th edition  (xmlconf/eduni/xml-1.1/015.xml)")
end

it "rmt-016 (Section 2.3)" do
  assert_raises(XML::Error, " Has a Byzantine Musical Symbol Kratimata in a name, legal in XML 1.1, illegal in XML 1.0 thru 4th edition  (xmlconf/eduni/xml-1.1/016.xml)") do
    File.open("xmlconf/eduni/xml-1.1/016.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "rmt-017 (Section 2.3)" do
  assert_parses("xmlconf/eduni/xml-1.1/017.xml", "xmlconf/eduni/xml-1.1/out/017.xml", " Has a Byzantine Musical Symbol Kratimata in a name, legal in XML 1.1, illegal in XML 1.0 thru 4th edition  (xmlconf/eduni/xml-1.1/017.xml)")
end

it "rmt-018 (Section 2.3)" do
  assert_parses("xmlconf/eduni/xml-1.1/018.xml", "xmlconf/eduni/xml-1.1/out/018.xml", " Has the last legal namechar in XML 1.1, illegal in XML 1.0 thru 4th edition  (xmlconf/eduni/xml-1.1/018.xml)")
end

it "rmt-019 (Section 2.3)" do
  assert_raises(XML::Error, " Has the last legal namechar in XML 1.1, illegal in XML 1.0 thru 4th edition  (xmlconf/eduni/xml-1.1/019.xml)") do
    File.open("xmlconf/eduni/xml-1.1/019.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "rmt-020 (Section 2.3)" do
  assert_raises(XML::Error, " Has the first character after the last legal namechar in XML 1.1, illegal in both XML 1.0 and 1.1  (xmlconf/eduni/xml-1.1/020.xml)") do
    File.open("xmlconf/eduni/xml-1.1/020.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "rmt-021 (Section 2.3)" do
  assert_raises(XML::Error, " Has the first character after the last legal namechar in XML 1.1, illegal in both XML 1.0 and 1.1  (xmlconf/eduni/xml-1.1/021.xml)") do
    File.open("xmlconf/eduni/xml-1.1/021.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "rmt-022 (Section 2.11)" do
  assert_parses("xmlconf/eduni/xml-1.1/022.xml", "xmlconf/eduni/xml-1.1/out/022.xml", " Has a NEL character; legal in both XML 1.0 and 1.1, but different canonical output because of normalization in 1.1  (xmlconf/eduni/xml-1.1/022.xml)")
end

it "rmt-023 (Section 2.11)" do
  assert_parses("xmlconf/eduni/xml-1.1/023.xml", "xmlconf/eduni/xml-1.1/out/023.xml", " Has a NEL character; legal in both XML 1.0 and 1.1, but different canonical output because of normalization in 1.1  (xmlconf/eduni/xml-1.1/023.xml)")
end

it "rmt-024 (Section 2.11)" do
  assert_parses("xmlconf/eduni/xml-1.1/024.xml", "xmlconf/eduni/xml-1.1/out/024.xml", " Has an LSEP character; legal in both XML 1.0 and 1.1, but different canonical output because of normalization in 1.1  (xmlconf/eduni/xml-1.1/024.xml)")
end

it "rmt-025 (Section 2.11)" do
  assert_parses("xmlconf/eduni/xml-1.1/025.xml", "xmlconf/eduni/xml-1.1/out/025.xml", " Has an LSEP character; legal in both XML 1.0 and 1.1, but different canonical output because of normalization in 1.1  (xmlconf/eduni/xml-1.1/025.xml)")
end

it "rmt-026 (Section 2.11)" do
  assert_parses("xmlconf/eduni/xml-1.1/026.xml", "xmlconf/eduni/xml-1.1/out/026.xml", " Has CR-NEL; legal in both XML 1.0 and 1.1, but different canonical output because of normalization in 1.1  (xmlconf/eduni/xml-1.1/026.xml)")
end

it "rmt-027 (Section 2.11)" do
  assert_parses("xmlconf/eduni/xml-1.1/027.xml", "xmlconf/eduni/xml-1.1/out/027.xml", " Has CR-NEL; legal in both XML 1.0 and 1.1, but different canonical output because of normalization in 1.1  (xmlconf/eduni/xml-1.1/027.xml)")
end

it "rmt-028 (Section 2.11)" do
  assert_parses("xmlconf/eduni/xml-1.1/028.xml", "xmlconf/eduni/xml-1.1/out/028.xml", " Has CR-LSEP; legal in both XML 1.0 and 1.1, but different canonical output because of normalization in 1.1. Note that CR and LSEP are not combined into a single LF  (xmlconf/eduni/xml-1.1/028.xml)")
end

it "rmt-029 (Section 2.11)" do
  assert_parses("xmlconf/eduni/xml-1.1/029.xml", "xmlconf/eduni/xml-1.1/out/029.xml", " Has CR-LSEP; legal in both XML 1.0 and 1.1, but different canonical output because of normalization in 1.1  (xmlconf/eduni/xml-1.1/029.xml)")
end

it "rmt-030 (Section 2.11)" do
  assert_parses("xmlconf/eduni/xml-1.1/030.xml", "xmlconf/eduni/xml-1.1/out/030.xml", " Has a NEL character in an NMTOKENS attribute; well-formed in both XML 1.0 and 1.1, but valid only in 1.1  (xmlconf/eduni/xml-1.1/030.xml)")
end

it "rmt-031 (Section 2.11)" do
  assert_parses("xmlconf/eduni/xml-1.1/031.xml", "xmlconf/eduni/xml-1.1/out/031.xml", " Has a NEL character in an NMTOKENS attribute; well-formed in both XML 1.0 and 1.1, but valid only in 1.1  (xmlconf/eduni/xml-1.1/031.xml)")
end

it "rmt-032 (Section 2.11)" do
  assert_parses("xmlconf/eduni/xml-1.1/032.xml", "xmlconf/eduni/xml-1.1/out/032.xml", " Has an LSEP character in an NMTOKENS attribute; well-formed in both XML 1.0 and 1.1, but valid only in 1.1  (xmlconf/eduni/xml-1.1/032.xml)")
end

it "rmt-033 (Section 2.11)" do
  assert_parses("xmlconf/eduni/xml-1.1/033.xml", "xmlconf/eduni/xml-1.1/out/033.xml", " Has an LSEP character in an NMTOKENS attribute; well-formed in both XML 1.0 and 1.1, but valid only in 1.1  (xmlconf/eduni/xml-1.1/033.xml)")
end

it "rmt-034 (Section 2.3)" do
  assert_parses("xmlconf/eduni/xml-1.1/034.xml", "xmlconf/eduni/xml-1.1/out/034.xml", " Has an NMTOKENS attribute containing a CR character that comes from a character reference in an internal entity. Because CR is in the S production, this is valid in both XML 1.0 and 1.1.  (xmlconf/eduni/xml-1.1/034.xml)")
end

it "rmt-035 (Section 2.3)" do
  assert_parses("xmlconf/eduni/xml-1.1/035.xml", "xmlconf/eduni/xml-1.1/out/035.xml", " Has an NMTOKENS attribute containing a CR character that comes from a character reference in an internal entity. Because CR is in the S production, this is valid in both XML 1.0 and 1.1.  (xmlconf/eduni/xml-1.1/035.xml)")
end

it "rmt-036 (Section 2.3)" do
  assert_parses("xmlconf/eduni/xml-1.1/036.xml", "xmlconf/eduni/xml-1.1/out/036.xml", " Has an NMTOKENS attribute containing a NEL character that comes from a character reference in an internal entity. Because NEL is not in the S production (even though real NELs are converted to LF on input), this is invalid in both XML 1.0 and 1.1.  (xmlconf/eduni/xml-1.1/036.xml)")
end

it "rmt-037 (Section 2.3)" do
  assert_parses("xmlconf/eduni/xml-1.1/037.xml", "xmlconf/eduni/xml-1.1/out/037.xml", " Has an NMTOKENS attribute containing a NEL character that comes from a character reference in an internal entity. Because NEL is not in the S production (even though real NELs are converted to LF on input), this is invalid in both XML 1.0 and 1.1.  (xmlconf/eduni/xml-1.1/037.xml)")
end

it "rmt-038 (Section 2.2)" do
  assert_raises(XML::Error, " Contains a C0 control character (form-feed), illegal in both XML 1.0 and 1.1  (xmlconf/eduni/xml-1.1/038.xml)") do
    File.open("xmlconf/eduni/xml-1.1/038.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "rmt-039 (Section 2.2)" do
  assert_raises(XML::Error, " Contains a C0 control character (form-feed), illegal in both XML 1.0 and 1.1  (xmlconf/eduni/xml-1.1/039.xml)") do
    File.open("xmlconf/eduni/xml-1.1/039.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "rmt-040 (Section 2.2)" do
  assert_parses("xmlconf/eduni/xml-1.1/040.xml", "xmlconf/eduni/xml-1.1/out/040.xml", " Contains a C1 control character (partial line up), legal in XML 1.0 but not 1.1  (xmlconf/eduni/xml-1.1/040.xml)")
end

it "rmt-041 (Section 2.2)" do
  assert_raises(XML::Error, " Contains a C1 control character (partial line up), legal in XML 1.0 but not 1.1  (xmlconf/eduni/xml-1.1/041.xml)") do
    File.open("xmlconf/eduni/xml-1.1/041.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "rmt-042 (Section 4.1)" do
  assert_raises(XML::Error, " Contains a character reference to a C0 control character (form-feed), legal in XML 1.1 but not 1.0  (xmlconf/eduni/xml-1.1/042.xml)") do
    File.open("xmlconf/eduni/xml-1.1/042.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "rmt-043 (Section 4.1)" do
  assert_parses("xmlconf/eduni/xml-1.1/043.xml", "xmlconf/eduni/xml-1.1/out/043.xml", " Contains a character reference to a C0 control character (form-feed), legal in XML 1.1 but not 1.0  (xmlconf/eduni/xml-1.1/043.xml)")
end

it "rmt-044 (Section 4.1)" do
  assert_parses("xmlconf/eduni/xml-1.1/044.xml", "xmlconf/eduni/xml-1.1/out/044.xml", " Contains a character reference to a C1 control character (partial line up), legal in both XML 1.0 and 1.1 (but for different reasons)  (xmlconf/eduni/xml-1.1/044.xml)")
end

it "rmt-045 (Section 4.1)" do
  assert_parses("xmlconf/eduni/xml-1.1/045.xml", "xmlconf/eduni/xml-1.1/out/045.xml", " Contains a character reference to a C1 control character (partial line up), legal in both XML 1.0 and 1.1 (but for different reasons)  (xmlconf/eduni/xml-1.1/045.xml)")
end

it "rmt-046 (Section 2.11)" do
  assert_parses("xmlconf/eduni/xml-1.1/046.xml", "xmlconf/eduni/xml-1.1/out/046.xml", " Has a NEL character in element content whitespace; well-formed in both XML 1.0 and 1.1, but valid only in 1.1  (xmlconf/eduni/xml-1.1/046.xml)")
end

it "rmt-047 (Section 2.11)" do
  assert_parses("xmlconf/eduni/xml-1.1/047.xml", "xmlconf/eduni/xml-1.1/out/047.xml", " Has a NEL character in element content whitespace; well-formed in both XML 1.0 and 1.1, but valid only in 1.1  (xmlconf/eduni/xml-1.1/047.xml)")
end

it "rmt-048 (Section 2.11)" do
  assert_parses("xmlconf/eduni/xml-1.1/048.xml", "xmlconf/eduni/xml-1.1/out/048.xml", " Has an LSEP character in element content whitespace; well-formed in both XML 1.0 and 1.1, but valid only in 1.1  (xmlconf/eduni/xml-1.1/048.xml)")
end

it "rmt-049 (Section 2.11)" do
  assert_parses("xmlconf/eduni/xml-1.1/049.xml", "xmlconf/eduni/xml-1.1/out/049.xml", " has an LSEP character in element content whitespace; well-formed in both XML 1.0 and 1.1, but valid only in 1.1  (xmlconf/eduni/xml-1.1/049.xml)")
end

it "rmt-050 (Section 2.3)" do
  assert_parses("xmlconf/eduni/xml-1.1/050.xml", "xmlconf/eduni/xml-1.1/out/050.xml", " Has element content whitespace containing a CR character that comes from a character reference in an internal entity. Because CR is in the S production, this is valid in both XML 1.0 and 1.1.  (xmlconf/eduni/xml-1.1/050.xml)")
end

it "rmt-051 (Section 2.3)" do
  assert_parses("xmlconf/eduni/xml-1.1/051.xml", "xmlconf/eduni/xml-1.1/out/051.xml", " Has element content whitespace containing a CR character that comes from a character reference in an internal entity. Because CR is in the S production, this is valid in both XML 1.0 and 1.1.  (xmlconf/eduni/xml-1.1/051.xml)")
end

it "rmt-052 (Section 2.3)" do
  assert_parses("xmlconf/eduni/xml-1.1/052.xml", "xmlconf/eduni/xml-1.1/out/052.xml", " Has element content whitespace containing a NEL character that comes from a character reference in an internal entity. Because NEL is not in the S production (even though real NELs are converted to LF on input), this is invalid in both XML 1.0 and 1.1.  (xmlconf/eduni/xml-1.1/052.xml)")
end

it "rmt-053 (Section 2.3)" do
  assert_parses("xmlconf/eduni/xml-1.1/053.xml", "xmlconf/eduni/xml-1.1/out/053.xml", " Has element content whitespace containing a NEL character that comes from a character reference in an internal entity. Because NEL is not in the S production (even though real NELs are converted to LF on input), this is invalid in both XML 1.0 and 1.1.  (xmlconf/eduni/xml-1.1/053.xml)")
end

it "rmt-054 (Section 4.3.2)" do
  assert_parses("xmlconf/eduni/xml-1.1/054.xml", "xmlconf/eduni/xml-1.1/out/054.xml", " Contains a character reference to a C0 control character (form-feed) in an entity value. This will be legal (in XML 1.1) when the entity declaration is parsed, but what about when it is used? According to the grammar in the CR spec, it should be illegal (because the replacement text must match \"content\"), but this is probably not intended. This will be fixed in the PR version.  (xmlconf/eduni/xml-1.1/054.xml)")
end

it "rmt-055 (Section 2.11)" do
  assert_raises(" Has a Latin-1 NEL in the XML declaration (to be made an error in PR)  (xmlconf/eduni/xml-1.1/055.xml)") do
    File.open("xmlconf/eduni/xml-1.1/055.xml") { |file| XML::DOM.parse(file, base: "xmlconf/eduni/xml-1.1") }
  end
end

it "rmt-056 (Section 2.11)" do
  assert_raises(" Has a UTF-8 NEL in the XML declaration (to be made an error in PR)  (xmlconf/eduni/xml-1.1/056.xml)") do
    File.open("xmlconf/eduni/xml-1.1/056.xml") { |file| XML::DOM.parse(file, base: "xmlconf/eduni/xml-1.1") }
  end
end

it "rmt-057 (Section 2.11)" do
  assert_raises(" Has a UTF-8 LSEP in the XML declaration (to be made an error in PR)  (xmlconf/eduni/xml-1.1/057.xml)") do
    File.open("xmlconf/eduni/xml-1.1/057.xml") { |file| XML::DOM.parse(file, base: "xmlconf/eduni/xml-1.1") }
  end
end

end

end

describe "eduni/namespaces/1.0/" do
describe "Richard Tobin's XML Namespaces 1.0 test suite 14 Feb 2003" do
it "rmt-ns10-001 (Section 2)" do
  assert_parses("xmlconf/eduni/namespaces/1.0/001.xml", nil, " Namespace name test: a perfectly good http URI  (xmlconf/eduni/namespaces/1.0/001.xml)")
end

it "rmt-ns10-002 (Section 2)" do
  assert_parses("xmlconf/eduni/namespaces/1.0/002.xml", nil, " Namespace name test: a syntactically plausible URI with a fictitious scheme  (xmlconf/eduni/namespaces/1.0/002.xml)")
end

it "rmt-ns10-003 (Section 2)" do
  assert_parses("xmlconf/eduni/namespaces/1.0/003.xml", nil, " Namespace name test: a perfectly good http URI with a fragment  (xmlconf/eduni/namespaces/1.0/003.xml)")
end

it "rmt-ns10-004 (Section 2)" do
  assert_raises(" Namespace name test: a relative URI (deprecated)  (xmlconf/eduni/namespaces/1.0/004.xml)") do
    File.open("xmlconf/eduni/namespaces/1.0/004.xml") { |file| XML::DOM.parse(file, base: "xmlconf/eduni/namespaces/1.0") }
  end
end

it "rmt-ns10-005 (Section 2)" do
  assert_raises(" Namespace name test: a same-document relative URI (deprecated)  (xmlconf/eduni/namespaces/1.0/005.xml)") do
    File.open("xmlconf/eduni/namespaces/1.0/005.xml") { |file| XML::DOM.parse(file, base: "xmlconf/eduni/namespaces/1.0") }
  end
end

it "rmt-ns10-006 (Section 2)" do
  assert_raises(" Namespace name test: an http IRI that is not a URI  (xmlconf/eduni/namespaces/1.0/006.xml)") do
    File.open("xmlconf/eduni/namespaces/1.0/006.xml") { |file| XML::DOM.parse(file, base: "xmlconf/eduni/namespaces/1.0") }
  end
end

it "rmt-ns10-007 (Section 1)" do
  assert_parses("xmlconf/eduni/namespaces/1.0/007.xml", nil, " Namespace inequality test: different capitalization  (xmlconf/eduni/namespaces/1.0/007.xml)")
end

it "rmt-ns10-008 (Section 1)" do
  assert_parses("xmlconf/eduni/namespaces/1.0/008.xml", nil, " Namespace inequality test: different escaping  (xmlconf/eduni/namespaces/1.0/008.xml)")
end

it "rmt-ns10-009 (Section 1)" do
  assert_raises(XML::Error, " Namespace equality test: plain repetition  (xmlconf/eduni/namespaces/1.0/009.xml)") do
    File.open("xmlconf/eduni/namespaces/1.0/009.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "rmt-ns10-010 (Section 1)" do
  assert_raises(XML::Error, " Namespace equality test: use of character reference  (xmlconf/eduni/namespaces/1.0/010.xml)") do
    File.open("xmlconf/eduni/namespaces/1.0/010.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "rmt-ns10-011 (Section 1)" do
  assert_raises(XML::Error, " Namespace equality test: use of entity reference  (xmlconf/eduni/namespaces/1.0/011.xml)") do
    File.open("xmlconf/eduni/namespaces/1.0/011.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "rmt-ns10-012 (Section 1)" do
  assert_raises(XML::Error, " Namespace inequality test: equal after attribute value normalization  (xmlconf/eduni/namespaces/1.0/012.xml)") do
    File.open("xmlconf/eduni/namespaces/1.0/012.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "rmt-ns10-013 (Section 3)" do
  assert_raises(XML::Error, " Bad QName syntax: multiple colons  (xmlconf/eduni/namespaces/1.0/013.xml)") do
    File.open("xmlconf/eduni/namespaces/1.0/013.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "rmt-ns10-014 (Section 3)" do
  assert_raises(XML::Error, " Bad QName syntax: colon at end  (xmlconf/eduni/namespaces/1.0/014.xml)") do
    File.open("xmlconf/eduni/namespaces/1.0/014.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "rmt-ns10-015 (Section 3)" do
  assert_raises(XML::Error, " Bad QName syntax: colon at start  (xmlconf/eduni/namespaces/1.0/015.xml)") do
    File.open("xmlconf/eduni/namespaces/1.0/015.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "rmt-ns10-016 (Section 2)" do
  assert_raises(XML::Error, " Bad QName syntax: xmlns:  (xmlconf/eduni/namespaces/1.0/016.xml)") do
    File.open("xmlconf/eduni/namespaces/1.0/016.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "rmt-ns10-017 (Section -)" do
  assert_parses("xmlconf/eduni/namespaces/1.0/017.xml", nil, " Simple legal case: no namespaces  (xmlconf/eduni/namespaces/1.0/017.xml)")
end

it "rmt-ns10-018 (Section 5.2)" do
  assert_parses("xmlconf/eduni/namespaces/1.0/018.xml", nil, " Simple legal case: default namespace  (xmlconf/eduni/namespaces/1.0/018.xml)")
end

it "rmt-ns10-019 (Section 4)" do
  assert_parses("xmlconf/eduni/namespaces/1.0/019.xml", nil, " Simple legal case: prefixed element  (xmlconf/eduni/namespaces/1.0/019.xml)")
end

it "rmt-ns10-020 (Section 4)" do
  assert_parses("xmlconf/eduni/namespaces/1.0/020.xml", nil, " Simple legal case: prefixed attribute  (xmlconf/eduni/namespaces/1.0/020.xml)")
end

it "rmt-ns10-021 (Section 5.2)" do
  assert_parses("xmlconf/eduni/namespaces/1.0/021.xml", nil, " Simple legal case: default namespace and unbinding  (xmlconf/eduni/namespaces/1.0/021.xml)")
end

it "rmt-ns10-022 (Section 5.2)" do
  assert_parses("xmlconf/eduni/namespaces/1.0/022.xml", nil, " Simple legal case: default namespace and rebinding  (xmlconf/eduni/namespaces/1.0/022.xml)")
end

it "rmt-ns10-023 (Section 2)" do
  assert_raises(XML::Error, " Illegal use of 1.1-style prefix unbinding in 1.0 document  (xmlconf/eduni/namespaces/1.0/023.xml)") do
    File.open("xmlconf/eduni/namespaces/1.0/023.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "rmt-ns10-024 (Section 5.1)" do
  assert_parses("xmlconf/eduni/namespaces/1.0/024.xml", nil, " Simple legal case: prefix rebinding  (xmlconf/eduni/namespaces/1.0/024.xml)")
end

it "rmt-ns10-025 (Section 4)" do
  assert_raises(XML::Error, " Unbound element prefix  (xmlconf/eduni/namespaces/1.0/025.xml)") do
    File.open("xmlconf/eduni/namespaces/1.0/025.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "rmt-ns10-026 (Section 4)" do
  assert_raises(XML::Error, " Unbound attribute prefix  (xmlconf/eduni/namespaces/1.0/026.xml)") do
    File.open("xmlconf/eduni/namespaces/1.0/026.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "rmt-ns10-027 (Section 2)" do
  assert_parses("xmlconf/eduni/namespaces/1.0/027.xml", nil, " Reserved prefixes and namespaces: using the xml prefix undeclared  (xmlconf/eduni/namespaces/1.0/027.xml)")
end

it "rmt-ns10-028 (Section NE05)" do
  assert_parses("xmlconf/eduni/namespaces/1.0/028.xml", nil, " Reserved prefixes and namespaces: declaring the xml prefix correctly  (xmlconf/eduni/namespaces/1.0/028.xml)")
end

it "rmt-ns10-029 (Section NE05)" do
  assert_raises(XML::Error, " Reserved prefixes and namespaces: declaring the xml prefix incorrectly  (xmlconf/eduni/namespaces/1.0/029.xml)") do
    File.open("xmlconf/eduni/namespaces/1.0/029.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "rmt-ns10-030 (Section NE05)" do
  assert_raises(XML::Error, " Reserved prefixes and namespaces: binding another prefix to the xml namespace  (xmlconf/eduni/namespaces/1.0/030.xml)") do
    File.open("xmlconf/eduni/namespaces/1.0/030.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "rmt-ns10-031 (Section NE05)" do
  assert_raises(XML::Error, " Reserved prefixes and namespaces: declaring the xmlns prefix with its correct URI (illegal)  (xmlconf/eduni/namespaces/1.0/031.xml)") do
    File.open("xmlconf/eduni/namespaces/1.0/031.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "rmt-ns10-032 (Section NE05)" do
  assert_raises(XML::Error, " Reserved prefixes and namespaces: declaring the xmlns prefix with an incorrect URI  (xmlconf/eduni/namespaces/1.0/032.xml)") do
    File.open("xmlconf/eduni/namespaces/1.0/032.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "rmt-ns10-033 (Section NE05)" do
  assert_raises(XML::Error, " Reserved prefixes and namespaces: binding another prefix to the xmlns namespace  (xmlconf/eduni/namespaces/1.0/033.xml)") do
    File.open("xmlconf/eduni/namespaces/1.0/033.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "rmt-ns10-034 (Section NE05)" do
  assert_parses("xmlconf/eduni/namespaces/1.0/034.xml", nil, " Reserved prefixes and namespaces: binding a reserved prefix  (xmlconf/eduni/namespaces/1.0/034.xml)")
end

it "rmt-ns10-035 (Section 5.3)" do
  assert_raises(XML::Error, " Attribute uniqueness: repeated identical attribute  (xmlconf/eduni/namespaces/1.0/035.xml)") do
    File.open("xmlconf/eduni/namespaces/1.0/035.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "rmt-ns10-036 (Section 5.3)" do
  assert_raises(XML::Error, " Attribute uniqueness: repeated attribute with different prefixes  (xmlconf/eduni/namespaces/1.0/036.xml)") do
    File.open("xmlconf/eduni/namespaces/1.0/036.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "rmt-ns10-037 (Section 5.3)" do
  assert_parses("xmlconf/eduni/namespaces/1.0/037.xml", nil, " Attribute uniqueness: different attributes with same local name  (xmlconf/eduni/namespaces/1.0/037.xml)")
end

it "rmt-ns10-038 (Section 5.3)" do
  assert_parses("xmlconf/eduni/namespaces/1.0/038.xml", nil, " Attribute uniqueness: prefixed and unprefixed attributes with same local name  (xmlconf/eduni/namespaces/1.0/038.xml)")
end

it "rmt-ns10-039 (Section 5.3)" do
  assert_parses("xmlconf/eduni/namespaces/1.0/039.xml", nil, " Attribute uniqueness: prefixed and unprefixed attributes with same local name, with default namespace  (xmlconf/eduni/namespaces/1.0/039.xml)")
end

it "rmt-ns10-040 (Section 5.3)" do
  assert_parses("xmlconf/eduni/namespaces/1.0/040.xml", nil, " Attribute uniqueness: prefixed and unprefixed attributes with same local name, with default namespace and element in default namespace  (xmlconf/eduni/namespaces/1.0/040.xml)")
end

it "rmt-ns10-041 (Section 5.3)" do
  assert_parses("xmlconf/eduni/namespaces/1.0/041.xml", nil, " Attribute uniqueness: prefixed and unprefixed attributes with same local name, element in same namespace as prefixed attribute  (xmlconf/eduni/namespaces/1.0/041.xml)")
end

it "rmt-ns10-042 (Section NE08)" do
  assert_raises(XML::Error, " Colon in PI name  (xmlconf/eduni/namespaces/1.0/042.xml)") do
    File.open("xmlconf/eduni/namespaces/1.0/042.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "rmt-ns10-043 (Section NE08)" do
  assert_raises(XML::Error, " Colon in entity name  (xmlconf/eduni/namespaces/1.0/043.xml)") do
    File.open("xmlconf/eduni/namespaces/1.0/043.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "rmt-ns10-044 (Section NE08)" do
  assert_raises(XML::Error, " Colon in entity name  (xmlconf/eduni/namespaces/1.0/044.xml)") do
    File.open("xmlconf/eduni/namespaces/1.0/044.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "rmt-ns10-045 (Section NE08)" do
  assert_parses("xmlconf/eduni/namespaces/1.0/045.xml", nil, " Colon in ID attribute name  (xmlconf/eduni/namespaces/1.0/045.xml)")
end

it "rmt-ns10-046 (Section NE08)" do
  assert_parses("xmlconf/eduni/namespaces/1.0/046.xml", nil, " Colon in ID attribute name  (xmlconf/eduni/namespaces/1.0/046.xml)")
end

it "ht-ns10-047 (Section NE03)" do
  assert_parses("xmlconf/eduni/namespaces/1.0/047.xml", nil, " Reserved name: _not_ an error  (xmlconf/eduni/namespaces/1.0/047.xml)")
end

it "ht-ns10-048 (Section NE03)" do
  assert_parses("xmlconf/eduni/namespaces/1.0/048.xml", nil, " Reserved name: _not_ an error  (xmlconf/eduni/namespaces/1.0/048.xml)")
end

end

end

describe "eduni/namespaces/1.1/" do
describe "Richard Tobin's XML Namespaces 1.1 test suite 14 Feb 2003" do
it "rmt-ns11-001 (Section 2.1)" do
  assert_parses("xmlconf/eduni/namespaces/1.1/001.xml", nil, " Namespace name test: a perfectly good http IRI that is not a URI  (xmlconf/eduni/namespaces/1.1/001.xml)")
end

it "rmt-ns11-002 (Section 2.3)" do
  assert_parses("xmlconf/eduni/namespaces/1.1/002.xml", nil, " Namespace inequality test: different escaping of non-ascii letter  (xmlconf/eduni/namespaces/1.1/002.xml)")
end

it "rmt-ns11-003 (Section 6.1)" do
  assert_parses("xmlconf/eduni/namespaces/1.1/003.xml", nil, " 1.1 style prefix unbinding  (xmlconf/eduni/namespaces/1.1/003.xml)")
end

it "rmt-ns11-004 (Section 6.1)" do
  assert_parses("xmlconf/eduni/namespaces/1.1/004.xml", nil, " 1.1 style prefix unbinding and rebinding  (xmlconf/eduni/namespaces/1.1/004.xml)")
end

it "rmt-ns11-005 (Section 5)" do
  assert_raises(XML::Error, " Illegal use of prefix that has been unbound  (xmlconf/eduni/namespaces/1.1/005.xml)") do
    File.open("xmlconf/eduni/namespaces/1.1/005.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "rmt-ns11-006 (Section 2.1)" do
  assert_parses("xmlconf/eduni/namespaces/1.1/006.xml", nil, " Test whether non-Latin-1 characters are accepted in IRIs, and whether they are correctly distinguished  (xmlconf/eduni/namespaces/1.1/006.xml)")
end

it "ht-bh-ns11-007 (Section 3)" do
  assert_raises(XML::Error, " Attempt to unbind xmlns 'namespace'  (xmlconf/eduni/namespaces/1.1/007.xml)") do
    File.open("xmlconf/eduni/namespaces/1.1/007.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "ht-bh-ns11-008 (Section 3)" do
  assert_raises(XML::Error, " Attempt to unbind xml namespace  (xmlconf/eduni/namespaces/1.1/008.xml)") do
    File.open("xmlconf/eduni/namespaces/1.1/008.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

end

describe "eduni/errata-3e/" do
describe "Richard Tobin's XML 1.0 3rd edition errata test suite 1 June 2006" do
it "rmt-e3e-05a (Section E05)" do
  assert_parses("xmlconf/eduni/errata-3e/E05a.xml", nil, " CDATA sections may occur in Mixed content.  (xmlconf/eduni/errata-3e/E05a.xml)")
end

it "rmt-e3e-05b (Section E05)" do
  assert_parses("xmlconf/eduni/errata-3e/E05b.xml", nil, " CDATA sections, comments and PIs may occur in ANY content.  (xmlconf/eduni/errata-3e/E05b.xml)")
end

it "rmt-e3e-06a (Section E06)" do
  assert_parses("xmlconf/eduni/errata-3e/E06a.xml", nil, " Default values for IDREF attributes must match Name.  (xmlconf/eduni/errata-3e/E06a.xml)")
end

it "rmt-e3e-06b (Section E06)" do
  assert_parses("xmlconf/eduni/errata-3e/E06b.xml", nil, " Default values for ENTITY attributes must match Name.  (xmlconf/eduni/errata-3e/E06b.xml)")
end

it "rmt-e3e-06c (Section E06)" do
  assert_parses("xmlconf/eduni/errata-3e/E06c.xml", nil, " Default values for IDREFS attributes must match Names.  (xmlconf/eduni/errata-3e/E06c.xml)")
end

it "rmt-e3e-06d (Section E06)" do
  assert_parses("xmlconf/eduni/errata-3e/E06d.xml", nil, " Default values for ENTITIES attributes must match Names.  (xmlconf/eduni/errata-3e/E06d.xml)")
end

it "rmt-e3e-06e (Section E06)" do
  assert_parses("xmlconf/eduni/errata-3e/E06e.xml", nil, " Default values for NMTOKEN attributes must match Nmtoken.  (xmlconf/eduni/errata-3e/E06e.xml)")
end

it "rmt-e3e-06f (Section E06)" do
  assert_parses("xmlconf/eduni/errata-3e/E06f.xml", nil, " Default values for NMTOKENS attributes must match Nmtokens.  (xmlconf/eduni/errata-3e/E06f.xml)")
end

it "rmt-e3e-06g (Section E06)" do
  assert_parses("xmlconf/eduni/errata-3e/E06g.xml", nil, " Default values for NOTATION attributes must match one of the enumerated values.  (xmlconf/eduni/errata-3e/E06g.xml)")
end

it "rmt-e3e-06h (Section E06)" do
  assert_parses("xmlconf/eduni/errata-3e/E06h.xml", nil, " Default values for enumerated attributes must match one of the enumerated values.  (xmlconf/eduni/errata-3e/E06h.xml)")
end

it "rmt-e3e-06i (Section E06)" do
  assert_parses("xmlconf/eduni/errata-3e/E06i.xml", nil, " Non-syntactic validity errors in default attributes only happen if the attribute is in fact defaulted.  (xmlconf/eduni/errata-3e/E06i.xml)")
end

it "rmt-e3e-12 (Section E12)" do
  assert_raises(XML::Error, " Default values for attributes may not contain references to external entities.  (xmlconf/eduni/errata-3e/E12.xml)") do
    File.open("xmlconf/eduni/errata-3e/E12.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "rmt-e3e-13 (Section E13)" do
  skip "disabled test"
end

end

end

describe "eduni/errata-4e/" do
describe "University of Edinburgh tests for XML 1.0 5th edition" do
it "invalid-bo-1 (Section 4.3.3)" do
  assert_parses("xmlconf/eduni/errata-4e/inclbom_be.xml", "xmlconf/eduni/errata-4e/inclbom_out.xml", "Byte order mark in general entity should go away (big-endian) (xmlconf/eduni/errata-4e/inclbom_be.xml)")
end

it "invalid-bo-2 (Section 4.3.3)" do
  assert_parses("xmlconf/eduni/errata-4e/inclbom_le.xml", "xmlconf/eduni/errata-4e/inclbom_out.xml", "Byte order mark in general entity should go away (little-endian) (xmlconf/eduni/errata-4e/inclbom_le.xml)")
end

it "invalid-bo-3 (Section 4.3.3)" do
  assert_parses("xmlconf/eduni/errata-4e/incl8bom.xml", "xmlconf/eduni/errata-4e/inclbom_out.xml", "Byte order mark in general entity should go away (utf-8) (xmlconf/eduni/errata-4e/incl8bom.xml)")
end

it "invalid-bo-4 (Section 4.3.3)" do
  assert_parses("xmlconf/eduni/errata-4e/inclbombom_be.xml", "xmlconf/eduni/errata-4e/inclbombom_out.xml", "Two byte order marks in general entity produce only one (big-endian) (xmlconf/eduni/errata-4e/inclbombom_be.xml)")
end

it "invalid-bo-5 (Section 4.3.3)" do
  assert_parses("xmlconf/eduni/errata-4e/inclbombom_le.xml", "xmlconf/eduni/errata-4e/inclbombom_out.xml", "Two byte order marks in general entity produce only one (little-endian) (xmlconf/eduni/errata-4e/inclbombom_le.xml)")
end

it "invalid-bo-6 (Section 4.3.3)" do
  assert_parses("xmlconf/eduni/errata-4e/incl8bombom.xml", "xmlconf/eduni/errata-4e/inclbombom_out.xml", "Two byte order marks in general entity produce only one (utf-8) (xmlconf/eduni/errata-4e/incl8bombom.xml)")
end

it "invalid-bo-7 (Section 4.3.3)" do
  assert_raises("A byte order mark and a backwards one in general entity cause an illegal char. error (big-endian) (xmlconf/eduni/errata-4e/inclbomboom_be.xml)") do
    File.open("xmlconf/eduni/errata-4e/inclbomboom_be.xml") { |file| XML::DOM.parse(file, base: "xmlconf/eduni/errata-4e") }
  end
end

it "invalid-bo-8 (Section 4.3.3)" do
  assert_raises("A byte order mark and a backwards one in general entity cause an illegal char. error (little-endian) (xmlconf/eduni/errata-4e/inclbomboom_le.xml)") do
    File.open("xmlconf/eduni/errata-4e/inclbomboom_le.xml") { |file| XML::DOM.parse(file, base: "xmlconf/eduni/errata-4e") }
  end
end

it "invalid-bo-9 (Section 4.3.3)" do
  assert_raises("A byte order mark and a backwards one in general entity cause an illegal char. error (utf-8) (xmlconf/eduni/errata-4e/incl8bomboom.xml)") do
    File.open("xmlconf/eduni/errata-4e/incl8bomboom.xml") { |file| XML::DOM.parse(file, base: "xmlconf/eduni/errata-4e") }
  end
end

it "invalid-sa-140 (Section 2.3 [4])" do
  assert_parses("xmlconf/eduni/errata-4e/140.xml", nil, "Character '&#x309a;' is a CombiningChar, not a Letter, but as of 5th edition, may begin a name (c.f. xmltest/not-wf/sa/140.xml). (xmlconf/eduni/errata-4e/140.xml)")
end

it "invalid-sa-141 (Section 2.3 [5])" do
  assert_parses("xmlconf/eduni/errata-4e/141.xml", nil, "As of 5th edition, character #x0E5C is legal in XML names (c.f. xmltest/not-wf/sa/141.xml). (xmlconf/eduni/errata-4e/141.xml)")
end

it "x-rmt-008 (Section 2.8 4.3.4)" do
  assert_raises(" a document with version=1.7, illegal in XML 1.0 through 4th edition  (xmlconf/eduni/errata-4e/008.xml)") do
    File.open("xmlconf/eduni/errata-4e/008.xml") { |file| XML::DOM.parse(file, base: "xmlconf/eduni/errata-4e") }
  end
end

it "x-rmt-008b (Section 2.8 4.3.4)" do
  assert_parses("xmlconf/eduni/errata-4e/008.xml", nil, " a document with version=1.7, legal in XML 1.0 from 5th edition  (xmlconf/eduni/errata-4e/008.xml)")
end

it "x-rmt5-014 (Section 2.3)" do
  assert_parses("xmlconf/eduni/errata-4e/014.xml", nil, "Has a \"long s\" in a name, legal in XML 1.1, legal in XML 1.0 5th edition (xmlconf/eduni/errata-4e/014.xml)")
end

it "x-rmt5-014a (Section 2.3)" do
  assert_parses("xmlconf/eduni/errata-4e/014a.xml", nil, "Has a \"long s\" in a name, legal in XML 1.1, legal in XML 1.0 5th edition (xmlconf/eduni/errata-4e/014a.xml)")
end

it "x-rmt5-016 (Section 2.3)" do
  assert_parses("xmlconf/eduni/errata-4e/016.xml", nil, "Has a Byzantine Musical Symbol Kratimata in a name, legal in XML 1.1, legal in XML 1.0 5th edition (xmlconf/eduni/errata-4e/016.xml)")
end

it "x-rmt5-019 (Section 2.3)" do
  assert_parses("xmlconf/eduni/errata-4e/019.xml", nil, "Has the last legal namechar in XML 1.1, legal in XML 1.0 5th edition (xmlconf/eduni/errata-4e/019.xml)")
end

it "x-ibm-1-0.5-not-wf-P04-ibm04n02.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameStartChar: #0x333 (xmlconf/eduni/errata-4e/ibm04n02.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04-ibm04n03.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameStartChar: #0x369 (xmlconf/eduni/errata-4e/ibm04n03.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04-ibm04n04.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameStartChar: #0x37E (xmlconf/eduni/errata-4e/ibm04n04.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04-ibm04n05.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameStartChar: #0x2000 (xmlconf/eduni/errata-4e/ibm04n05.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04-ibm04n06.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameStartChar: #0x2001 (xmlconf/eduni/errata-4e/ibm04n06.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04-ibm04n07.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameStartChar: #0x2002 (xmlconf/eduni/errata-4e/ibm04n07.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04n07.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04-ibm04n08.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameStartChar: #0x2005 (xmlconf/eduni/errata-4e/ibm04n08.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04n08.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04-ibm04n09.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameStartChar: #0x200B (xmlconf/eduni/errata-4e/ibm04n09.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04n09.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04-ibm04n10.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameStartChar: #0x200E (xmlconf/eduni/errata-4e/ibm04n10.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04n10.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04-ibm04n11.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameStartChar: #0x200F (xmlconf/eduni/errata-4e/ibm04n11.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04n11.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04-ibm04n12.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameStartChar: #0x2069 (xmlconf/eduni/errata-4e/ibm04n12.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04n12.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04-ibm04n13.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameStartChar: #0x2190 (xmlconf/eduni/errata-4e/ibm04n13.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04n13.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04-ibm04n14.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameStartChar: #0x23FF (xmlconf/eduni/errata-4e/ibm04n14.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04n14.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04-ibm04n15.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameStartChar: #0x280F (xmlconf/eduni/errata-4e/ibm04n15.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04n15.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04-ibm04n16.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameStartChar: #0x2A00 (xmlconf/eduni/errata-4e/ibm04n16.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04n16.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04-ibm04n17.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameStartChar: #0x2EDC (xmlconf/eduni/errata-4e/ibm04n17.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04n17.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04-ibm04n18.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameStartChar: #0x2B00 (xmlconf/eduni/errata-4e/ibm04n18.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04n18.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04-ibm04n19.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameStartChar: #0x2BFF (xmlconf/eduni/errata-4e/ibm04n19.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04n19.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04-ibm04n20.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameStartChar: #0x3000 (xmlconf/eduni/errata-4e/ibm04n20.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04n20.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04-ibm04n21.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameStartChar: #0xD800 (xmlconf/eduni/errata-4e/ibm04n21.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04n21.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04-ibm04n22.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameStartChar: #0xD801 (xmlconf/eduni/errata-4e/ibm04n22.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04n22.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04-ibm04n23.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameStartChar: #0xDAFF (xmlconf/eduni/errata-4e/ibm04n23.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04n23.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04-ibm04n24.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameStartChar: #0xDFFF (xmlconf/eduni/errata-4e/ibm04n24.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04n24.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04-ibm04n25.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameStartChar: #0xEFFF (xmlconf/eduni/errata-4e/ibm04n25.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04n25.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04-ibm04n26.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameStartChar: #0xF1FF (xmlconf/eduni/errata-4e/ibm04n26.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04n26.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04-ibm04n27.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameStartChar: #0xF8FF (xmlconf/eduni/errata-4e/ibm04n27.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04n27.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04-ibm04n28.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameStartChar: #0xFFFFF (xmlconf/eduni/errata-4e/ibm04n28.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04n28.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04a-ibm04an01.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameChar: #xB8 (xmlconf/eduni/errata-4e/ibm04an01.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04an01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04a-ibm04an02.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameChar: #0xA1 (xmlconf/eduni/errata-4e/ibm04an02.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04an02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04a-ibm04an03.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameChar: #0xAF (xmlconf/eduni/errata-4e/ibm04an03.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04an03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04a-ibm04an04.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameChar: #0x37E (xmlconf/eduni/errata-4e/ibm04an04.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04an04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04a-ibm04an05.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameChar: #0x2000 (xmlconf/eduni/errata-4e/ibm04an05.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04an05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04a-ibm04an06.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameChar: #0x2001 (xmlconf/eduni/errata-4e/ibm04an06.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04an06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04a-ibm04an07.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameChar: #0x2002 (xmlconf/eduni/errata-4e/ibm04an07.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04an07.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04a-ibm04an08.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameChar: #0x2005 (xmlconf/eduni/errata-4e/ibm04an08.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04an08.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04a-ibm04an09.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameChar: #0x200B (xmlconf/eduni/errata-4e/ibm04an09.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04an09.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04a-ibm04an10.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameChar: #0x200E (xmlconf/eduni/errata-4e/ibm04an10.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04an10.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04a-ibm04an11.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameChar: #0x2038 (xmlconf/eduni/errata-4e/ibm04an11.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04an11.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04a-ibm04an12.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameChar: #0x2041 (xmlconf/eduni/errata-4e/ibm04an12.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04an12.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04a-ibm04an13.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameChar: #0x2190 (xmlconf/eduni/errata-4e/ibm04an13.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04an13.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04a-ibm04an14.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameChar: #0x23FF (xmlconf/eduni/errata-4e/ibm04an14.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04an14.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04a-ibm04an15.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameChar: #0x280F (xmlconf/eduni/errata-4e/ibm04an15.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04an15.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04a-ibm04an16.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameChar: #0x2A00 (xmlconf/eduni/errata-4e/ibm04an16.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04an16.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04a-ibm04an17.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameChar: #0xFDD0 (xmlconf/eduni/errata-4e/ibm04an17.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04an17.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04a-ibm04an18.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameChar: #0xFDEF (xmlconf/eduni/errata-4e/ibm04an18.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04an18.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04a-ibm04an19.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameChar: #0x2FFF (xmlconf/eduni/errata-4e/ibm04an19.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04an19.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04a-ibm04an20.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameChar: #0x3000 (xmlconf/eduni/errata-4e/ibm04an20.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04an20.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04a-ibm04an21.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameChar: #0xD800 (xmlconf/eduni/errata-4e/ibm04an21.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04an21.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04a-ibm04an22.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameChar: #0xD801 (xmlconf/eduni/errata-4e/ibm04an22.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04an22.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04a-ibm04an23.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameChar: #0xDAFF (xmlconf/eduni/errata-4e/ibm04an23.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04an23.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04a-ibm04an24.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameChar: #0xDFFF (xmlconf/eduni/errata-4e/ibm04an24.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04an24.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04a-ibm04an25.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameChar: #0xEFFF (xmlconf/eduni/errata-4e/ibm04an25.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04an25.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04a-ibm04an26.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameChar: #0xF1FF (xmlconf/eduni/errata-4e/ibm04an26.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04an26.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04a-ibm04an27.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameChar: #0xF8FF (xmlconf/eduni/errata-4e/ibm04an27.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04an27.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P04a-ibm04an28.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal NameChar: #0xFFFFF (xmlconf/eduni/errata-4e/ibm04an28.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm04an28.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P05-ibm05n01.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal Name containing #0x0B (xmlconf/eduni/errata-4e/ibm05n01.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm05n01.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P05-ibm05n02.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal Name containing #0x300 (xmlconf/eduni/errata-4e/ibm05n02.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm05n02.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P05-ibm05n03.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal Name containing #0x36F (xmlconf/eduni/errata-4e/ibm05n03.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm05n03.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P05-ibm05n04.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal Name containing #0x203F (xmlconf/eduni/errata-4e/ibm05n04.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm05n04.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P05-ibm05n05.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal Name containing #x2040 (xmlconf/eduni/errata-4e/ibm05n05.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm05n05.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-not-wf-P05-ibm05n06.xml (Section 2.3)" do
  assert_raises(XML::Error, "Tests an element with an illegal Name containing #0xB7 (xmlconf/eduni/errata-4e/ibm05n06.xml)") do
    File.open("xmlconf/eduni/errata-4e/ibm05n06.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "x-ibm-1-0.5-valid-P04-ibm04v01.xml (Section 2.3)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm04v01.xml", nil, "This test case covers legal NameStartChars character ranges plus discrete legal characters for production 04. (xmlconf/eduni/errata-4e/ibm04v01.xml)")
end

it "x-ibm-1-0.5-valid-P04-ibm04av01.xml (Section 2.3)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm04av01.xml", nil, "This test case covers legal NameChars character ranges plus discrete legal characters for production 04a. (xmlconf/eduni/errata-4e/ibm04av01.xml)")
end

it "x-ibm-1-0.5-valid-P05-ibm05v01.xml (Section 2.3)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm05v01.xml", nil, "This test case covers legal Element Names as per production 5. (xmlconf/eduni/errata-4e/ibm05v01.xml)")
end

it "x-ibm-1-0.5-valid-P05-ibm05v02.xml (Section 2.3)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm05v02.xml", nil, "This test case covers legal PITarget (Names) as per production 5. (xmlconf/eduni/errata-4e/ibm05v02.xml)")
end

it "x-ibm-1-0.5-valid-P05-ibm05v03.xml (Section 2.3)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm05v03.xml", nil, "This test case covers legal Attribute (Names) as per production 5. (xmlconf/eduni/errata-4e/ibm05v03.xml)")
end

it "x-ibm-1-0.5-valid-P05-ibm05v04.xml (Section 2.3)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm05v04.xml", nil, "This test case covers legal ID/IDREF (Names) as per production 5. (xmlconf/eduni/errata-4e/ibm05v04.xml)")
end

it "x-ibm-1-0.5-valid-P05-ibm05v05.xml (Section 2.3)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm05v05.xml", nil, "This test case covers legal ENTITY (Names) as per production 5. (xmlconf/eduni/errata-4e/ibm05v05.xml)")
end

it "x-ibm-1-0.5-valid-P047-ibm07v01.xml (Section 2.3)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm07v01.xml", nil, "This test case covers legal NMTOKEN Name character ranges plus discrete legal characters for production 7. (xmlconf/eduni/errata-4e/ibm07v01.xml)")
end

it "ibm-valid-P85-ibm85n03.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n03.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0132 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n03.xml)")
end

it "ibm-valid-P85-ibm85n04.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n04.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0133 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n04.xml)")
end

it "ibm-valid-P85-ibm85n05.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n05.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x013F occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n05.xml)")
end

it "ibm-valid-P85-ibm85n06.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n06.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0140 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n06.xml)")
end

it "ibm-valid-P85-ibm85n07.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n07.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0149 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n07.xml)")
end

it "ibm-valid-P85-ibm85n08.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n08.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x017F occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n08.xml)")
end

it "ibm-valid-P85-ibm85n09.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n09.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x01c4 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n09.xml)")
end

it "ibm-valid-P85-ibm85n10.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n10.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x01CC occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n10.xml)")
end

it "ibm-valid-P85-ibm85n100.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n100.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0BB6 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n100.xml)")
end

it "ibm-valid-P85-ibm85n101.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n101.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0BBA occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n101.xml)")
end

it "ibm-valid-P85-ibm85n102.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n102.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0C0D occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n102.xml)")
end

it "ibm-valid-P85-ibm85n103.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n103.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0C11 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n103.xml)")
end

it "ibm-valid-P85-ibm85n104.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n104.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0C29 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n104.xml)")
end

it "ibm-valid-P85-ibm85n105.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n105.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0C34 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n105.xml)")
end

it "ibm-valid-P85-ibm85n106.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n106.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0C5F occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n106.xml)")
end

it "ibm-valid-P85-ibm85n107.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n107.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0C62 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n107.xml)")
end

it "ibm-valid-P85-ibm85n108.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n108.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0C8D occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n108.xml)")
end

it "ibm-valid-P85-ibm85n109.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n109.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0C91 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n109.xml)")
end

it "ibm-valid-P85-ibm85n11.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n11.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x01F1 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n11.xml)")
end

it "ibm-valid-P85-ibm85n110.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n110.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0CA9 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n110.xml)")
end

it "ibm-valid-P85-ibm85n111.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n111.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0CB4 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n111.xml)")
end

it "ibm-valid-P85-ibm85n112.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n112.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0CBA occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n112.xml)")
end

it "ibm-valid-P85-ibm85n113.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n113.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0CDF occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n113.xml)")
end

it "ibm-valid-P85-ibm85n114.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n114.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0CE2 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n114.xml)")
end

it "ibm-valid-P85-ibm85n115.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n115.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0D0D occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n115.xml)")
end

it "ibm-valid-P85-ibm85n116.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n116.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0D11 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n116.xml)")
end

it "ibm-valid-P85-ibm85n117.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n117.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0D29 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n117.xml)")
end

it "ibm-valid-P85-ibm85n118.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n118.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0D3A occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n118.xml)")
end

it "ibm-valid-P85-ibm85n119.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n119.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0D62 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n119.xml)")
end

it "ibm-valid-P85-ibm85n12.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n12.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x01F3 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n12.xml)")
end

it "ibm-valid-P85-ibm85n120.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n120.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0E2F occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n120.xml)")
end

it "ibm-valid-P85-ibm85n121.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n121.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0E31 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n121.xml)")
end

it "ibm-valid-P85-ibm85n122.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n122.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0E34 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n122.xml)")
end

it "ibm-valid-P85-ibm85n123.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n123.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0E46 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n123.xml)")
end

it "ibm-valid-P85-ibm85n124.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n124.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0E83 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n124.xml)")
end

it "ibm-valid-P85-ibm85n125.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n125.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0E85 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n125.xml)")
end

it "ibm-valid-P85-ibm85n126.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n126.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0E89 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n126.xml)")
end

it "ibm-valid-P85-ibm85n127.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n127.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0E8B occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n127.xml)")
end

it "ibm-valid-P85-ibm85n128.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n128.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0E8E occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n128.xml)")
end

it "ibm-valid-P85-ibm85n129.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n129.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0E98 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n129.xml)")
end

it "ibm-valid-P85-ibm85n13.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n13.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x01F6 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n13.xml)")
end

it "ibm-valid-P85-ibm85n130.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n130.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0EA0 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n130.xml)")
end

it "ibm-valid-P85-ibm85n131.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n131.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0EA4 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n131.xml)")
end

it "ibm-valid-P85-ibm85n132.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n132.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0EA6 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n132.xml)")
end

it "ibm-valid-P85-ibm85n133.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n133.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0EA8 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n133.xml)")
end

it "ibm-valid-P85-ibm85n134.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n134.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0EAC occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n134.xml)")
end

it "ibm-valid-P85-ibm85n135.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n135.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0EAF occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n135.xml)")
end

it "ibm-valid-P85-ibm85n136.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n136.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0EB1 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n136.xml)")
end

it "ibm-valid-P85-ibm85n137.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n137.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0EB4 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n137.xml)")
end

it "ibm-valid-P85-ibm85n138.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n138.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0EBE occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n138.xml)")
end

it "ibm-valid-P85-ibm85n139.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n139.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0EC5 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n139.xml)")
end

it "ibm-valid-P85-ibm85n14.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n14.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x01F9 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n14.xml)")
end

it "ibm-valid-P85-ibm85n140.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n140.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0F48 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n140.xml)")
end

it "ibm-valid-P85-ibm85n141.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n141.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0F6A occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n141.xml)")
end

it "ibm-valid-P85-ibm85n142.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n142.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x10C6 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n142.xml)")
end

it "ibm-valid-P85-ibm85n143.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n143.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x10F7 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n143.xml)")
end

it "ibm-valid-P85-ibm85n144.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n144.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x1011 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n144.xml)")
end

it "ibm-valid-P85-ibm85n145.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n145.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x1104 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n145.xml)")
end

it "ibm-valid-P85-ibm85n146.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n146.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x1108 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n146.xml)")
end

it "ibm-valid-P85-ibm85n147.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n147.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x110A occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n147.xml)")
end

it "ibm-valid-P85-ibm85n148.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n148.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x110D occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n148.xml)")
end

it "ibm-valid-P85-ibm85n149.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n149.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x113B occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n149.xml)")
end

it "ibm-valid-P85-ibm85n15.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n15.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x01F9 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n15.xml)")
end

it "ibm-valid-P85-ibm85n150.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n150.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x113F occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n150.xml)")
end

it "ibm-valid-P85-ibm85n151.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n151.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x1141 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n151.xml)")
end

it "ibm-valid-P85-ibm85n152.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n152.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x114D occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n152.xml)")
end

it "ibm-valid-P85-ibm85n153.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n153.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x114f occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n153.xml)")
end

it "ibm-valid-P85-ibm85n154.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n154.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x1151 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n154.xml)")
end

it "ibm-valid-P85-ibm85n155.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n155.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x1156 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n155.xml)")
end

it "ibm-valid-P85-ibm85n156.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n156.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x115A occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n156.xml)")
end

it "ibm-valid-P85-ibm85n157.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n157.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x1162 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n157.xml)")
end

it "ibm-valid-P85-ibm85n158.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n158.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x1164 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n158.xml)")
end

it "ibm-valid-P85-ibm85n159.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n159.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x1166 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n159.xml)")
end

it "ibm-valid-P85-ibm85n16.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n16.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0230 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n16.xml)")
end

it "ibm-valid-P85-ibm85n160.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n160.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x116B occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n160.xml)")
end

it "ibm-valid-P85-ibm85n161.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n161.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x116F occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n161.xml)")
end

it "ibm-valid-P85-ibm85n162.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n162.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x1174 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n162.xml)")
end

it "ibm-valid-P85-ibm85n163.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n163.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x119F occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n163.xml)")
end

it "ibm-valid-P85-ibm85n164.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n164.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x11AC occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n164.xml)")
end

it "ibm-valid-P85-ibm85n165.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n165.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x11B6 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n165.xml)")
end

it "ibm-valid-P85-ibm85n166.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n166.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x11B9 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n166.xml)")
end

it "ibm-valid-P85-ibm85n167.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n167.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x11BB occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n167.xml)")
end

it "ibm-valid-P85-ibm85n168.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n168.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x11C3 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n168.xml)")
end

it "ibm-valid-P85-ibm85n169.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n169.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x11F1 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n169.xml)")
end

it "ibm-valid-P85-ibm85n17.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n17.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x02AF occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n17.xml)")
end

it "ibm-valid-P85-ibm85n170.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n170.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x11FA occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n170.xml)")
end

it "ibm-valid-P85-ibm85n171.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n171.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x1E9C occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n171.xml)")
end

it "ibm-valid-P85-ibm85n172.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n172.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x1EFA occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n172.xml)")
end

it "ibm-valid-P85-ibm85n173.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n173.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x1F16 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n173.xml)")
end

it "ibm-valid-P85-ibm85n174.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n174.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x1F1E occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n174.xml)")
end

it "ibm-valid-P85-ibm85n175.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n175.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x1F46 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n175.xml)")
end

it "ibm-valid-P85-ibm85n176.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n176.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x1F4F occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n176.xml)")
end

it "ibm-valid-P85-ibm85n177.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n177.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x1F58 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n177.xml)")
end

it "ibm-valid-P85-ibm85n178.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n178.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x1F5A occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n178.xml)")
end

it "ibm-valid-P85-ibm85n179.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n179.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x1F5C occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n179.xml)")
end

it "ibm-valid-P85-ibm85n18.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n18.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x02CF occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n18.xml)")
end

it "ibm-valid-P85-ibm85n180.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n180.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x1F5E occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n180.xml)")
end

it "ibm-valid-P85-ibm85n181.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n181.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x1F7E occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n181.xml)")
end

it "ibm-valid-P85-ibm85n182.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n182.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x1FB5 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n182.xml)")
end

it "ibm-valid-P85-ibm85n183.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n183.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x1FBD occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n183.xml)")
end

it "ibm-valid-P85-ibm85n184.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n184.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x1FBF occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n184.xml)")
end

it "ibm-valid-P85-ibm85n185.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n185.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x1FC5 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n185.xml)")
end

it "ibm-valid-P85-ibm85n186.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n186.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x1FCD occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n186.xml)")
end

it "ibm-valid-P85-ibm85n187.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n187.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x1FD5 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n187.xml)")
end

it "ibm-valid-P85-ibm85n188.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n188.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x1FDC occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n188.xml)")
end

it "ibm-valid-P85-ibm85n189.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n189.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x1FED occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n189.xml)")
end

it "ibm-valid-P85-ibm85n19.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n19.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0387 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n19.xml)")
end

it "ibm-valid-P85-ibm85n190.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n190.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x1FF5 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n190.xml)")
end

it "ibm-valid-P85-ibm85n191.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n191.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x1FFD occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n191.xml)")
end

it "ibm-valid-P85-ibm85n192.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n192.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x2127 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n192.xml)")
end

it "ibm-valid-P85-ibm85n193.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n193.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x212F occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n193.xml)")
end

it "ibm-valid-P85-ibm85n194.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n194.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x2183 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n194.xml)")
end

it "ibm-valid-P85-ibm85n195.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n195.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x3095 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n195.xml)")
end

it "ibm-valid-P85-ibm85n196.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n196.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x30FB occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n196.xml)")
end

it "ibm-valid-P85-ibm85n197.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n197.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x312D occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n197.xml)")
end

it "ibm-valid-P85-ibm85n198.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n198.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #xD7A4 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n198.xml)")
end

it "ibm-valid-P85-ibm85n20.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n20.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x038B occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n20.xml)")
end

it "ibm-valid-P85-ibm85n21.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n21.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x03A2 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n21.xml)")
end

it "ibm-valid-P85-ibm85n22.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n22.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x03CF occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n22.xml)")
end

it "ibm-valid-P85-ibm85n23.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n23.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x03D7 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n23.xml)")
end

it "ibm-valid-P85-ibm85n24.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n24.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x03DD occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n24.xml)")
end

it "ibm-valid-P85-ibm85n25.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n25.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x03E1 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n25.xml)")
end

it "ibm-valid-P85-ibm85n26.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n26.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x03F4 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n26.xml)")
end

it "ibm-valid-P85-ibm85n27.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n27.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x040D occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n27.xml)")
end

it "ibm-valid-P85-ibm85n28.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n28.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0450 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n28.xml)")
end

it "ibm-valid-P85-ibm85n29.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n29.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x045D occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n29.xml)")
end

it "ibm-valid-P85-ibm85n30.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n30.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0482 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n30.xml)")
end

it "ibm-valid-P85-ibm85n31.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n31.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x04C5 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n31.xml)")
end

it "ibm-valid-P85-ibm85n32.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n32.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x04C6 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n32.xml)")
end

it "ibm-valid-P85-ibm85n33.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n33.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x04C9 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n33.xml)")
end

it "ibm-valid-P85-ibm85n34.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n34.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x04EC occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n34.xml)")
end

it "ibm-valid-P85-ibm85n35.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n35.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x04ED occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n35.xml)")
end

it "ibm-valid-P85-ibm85n36.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n36.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x04F6 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n36.xml)")
end

it "ibm-valid-P85-ibm85n37.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n37.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x04FA occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n37.xml)")
end

it "ibm-valid-P85-ibm85n38.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n38.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0557 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n38.xml)")
end

it "ibm-valid-P85-ibm85n39.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n39.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0558 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n39.xml)")
end

it "ibm-valid-P85-ibm85n40.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n40.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0587 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n40.xml)")
end

it "ibm-valid-P85-ibm85n41.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n41.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x05EB occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n41.xml)")
end

it "ibm-valid-P85-ibm85n42.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n42.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x05F3 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n42.xml)")
end

it "ibm-valid-P85-ibm85n43.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n43.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0620 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n43.xml)")
end

it "ibm-valid-P85-ibm85n44.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n44.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x063B occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n44.xml)")
end

it "ibm-valid-P85-ibm85n45.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n45.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x064B occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n45.xml)")
end

it "ibm-valid-P85-ibm85n46.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n46.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x06B8 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n46.xml)")
end

it "ibm-valid-P85-ibm85n47.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n47.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x06BF occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n47.xml)")
end

it "ibm-valid-P85-ibm85n48.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n48.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x06CF occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n48.xml)")
end

it "ibm-valid-P85-ibm85n49.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n49.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x06D4 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n49.xml)")
end

it "ibm-valid-P85-ibm85n50.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n50.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x06D6 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n50.xml)")
end

it "ibm-valid-P85-ibm85n51.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n51.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x06E7 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n51.xml)")
end

it "ibm-valid-P85-ibm85n52.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n52.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x093A occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n52.xml)")
end

it "ibm-valid-P85-ibm85n53.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n53.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x093E occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n53.xml)")
end

it "ibm-valid-P85-ibm85n54.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n54.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0962 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n54.xml)")
end

it "ibm-valid-P85-ibm85n55.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n55.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x098D occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n55.xml)")
end

it "ibm-valid-P85-ibm85n56.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n56.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0991 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n56.xml)")
end

it "ibm-valid-P85-ibm85n57.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n57.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0992 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n57.xml)")
end

it "ibm-valid-P85-ibm85n58.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n58.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x09A9 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n58.xml)")
end

it "ibm-valid-P85-ibm85n59.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n59.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x09B1 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n59.xml)")
end

it "ibm-valid-P85-ibm85n60.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n60.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x09B5 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n60.xml)")
end

it "ibm-valid-P85-ibm85n61.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n61.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x09BA occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n61.xml)")
end

it "ibm-valid-P85-ibm85n62.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n62.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x09DE occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n62.xml)")
end

it "ibm-valid-P85-ibm85n63.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n63.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x09E2 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n63.xml)")
end

it "ibm-valid-P85-ibm85n64.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n64.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x09F2 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n64.xml)")
end

it "ibm-valid-P85-ibm85n65.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n65.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0A0B occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n65.xml)")
end

it "ibm-valid-P85-ibm85n66.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n66.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0A11 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n66.xml)")
end

it "ibm-valid-P85-ibm85n67.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n67.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0A29 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n67.xml)")
end

it "ibm-valid-P85-ibm85n68.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n68.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0A31 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n68.xml)")
end

it "ibm-valid-P85-ibm85n69.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n69.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0A34 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n69.xml)")
end

it "ibm-valid-P85-ibm85n70.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n70.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0A37 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n70.xml)")
end

it "ibm-valid-P85-ibm85n71.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n71.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0A3A occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n71.xml)")
end

it "ibm-valid-P85-ibm85n72.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n72.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0A5D occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n72.xml)")
end

it "ibm-valid-P85-ibm85n73.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n73.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0A70 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n73.xml)")
end

it "ibm-valid-P85-ibm85n74.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n74.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0A75 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n74.xml)")
end

it "ibm-valid-P85-ibm85n75.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n75.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #xA84 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n75.xml)")
end

it "ibm-valid-P85-ibm85n76.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n76.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0ABC occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n76.xml)")
end

it "ibm-valid-P85-ibm85n77.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n77.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0A92 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n77.xml)")
end

it "ibm-valid-P85-ibm85n78.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n78.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0AA9 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n78.xml)")
end

it "ibm-valid-P85-ibm85n79.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n79.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0AB1 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n79.xml)")
end

it "ibm-valid-P85-ibm85n80.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n80.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0AB4 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n80.xml)")
end

it "ibm-valid-P85-ibm85n81.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n81.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0ABA occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n81.xml)")
end

it "ibm-valid-P85-ibm85n82.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n82.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0B04 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n82.xml)")
end

it "ibm-valid-P85-ibm85n83.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n83.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0B0D occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n83.xml)")
end

it "ibm-valid-P85-ibm85n84.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n84.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0B11 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n84.xml)")
end

it "ibm-valid-P85-ibm85n85.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n85.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0B29 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n85.xml)")
end

it "ibm-valid-P85-ibm85n86.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n86.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0B31 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n86.xml)")
end

it "ibm-valid-P85-ibm85n87.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n87.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0B34 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n87.xml)")
end

it "ibm-valid-P85-ibm85n88.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n88.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0B3A occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n88.xml)")
end

it "ibm-valid-P85-ibm85n89.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n89.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0B3E occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n89.xml)")
end

it "ibm-valid-P85-ibm85n90.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n90.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0B5E occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n90.xml)")
end

it "ibm-valid-P85-ibm85n91.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n91.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0B62 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n91.xml)")
end

it "ibm-valid-P85-ibm85n92.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n92.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0B8B occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n92.xml)")
end

it "ibm-valid-P85-ibm85n93.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n93.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0B91 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n93.xml)")
end

it "ibm-valid-P85-ibm85n94.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n94.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0B98 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n94.xml)")
end

it "ibm-valid-P85-ibm85n95.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n95.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0B9B occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n95.xml)")
end

it "ibm-valid-P85-ibm85n96.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n96.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0B9D occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n96.xml)")
end

it "ibm-valid-P85-ibm85n97.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n97.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0BA0 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n97.xml)")
end

it "ibm-valid-P85-ibm85n98.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n98.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0BA7 occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n98.xml)")
end

it "ibm-valid-P85-ibm85n99.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm85n99.xml", nil, " Tests BaseChar with an only legal per 5th edition character. The character #x0BAB occurs as the first character of the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm85n99.xml)")
end

it "ibm-valid-P86-ibm86n01.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm86n01.xml", nil, " Tests Ideographic with an only legal per 5th edition character. The character #x4CFF occurs as the first character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm86n01.xml)")
end

it "ibm-valid-P86-ibm86n02.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm86n02.xml", nil, " Tests Ideographic with an only legal per 5th edition character. The character #x9FA6 occurs as the first character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm86n02.xml)")
end

it "ibm-valid-P86-ibm86n03.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm86n03.xml", nil, " Tests Ideographic with an only legal per 5th edition character. The character #x3008 occurs as the first character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm86n03.xml)")
end

it "ibm-valid-P86-ibm86n04.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm86n04.xml", nil, " Tests Ideographic with an only legal per 5th edition character. The character #x302A occurs as the first character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm86n04.xml)")
end

it "ibm-valid-P87-ibm87n01.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n01.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x02FF occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n01.xml)")
end

it "ibm-valid-P87-ibm87n02.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n02.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0346 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n02.xml)")
end

it "ibm-valid-P87-ibm87n03.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n03.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0362 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n03.xml)")
end

it "ibm-valid-P87-ibm87n04.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n04.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0487 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n04.xml)")
end

it "ibm-valid-P87-ibm87n05.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n05.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x05A2 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n05.xml)")
end

it "ibm-valid-P87-ibm87n06.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n06.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x05BA occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n06.xml)")
end

it "ibm-valid-P87-ibm87n07.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n07.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x05BE occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n07.xml)")
end

it "ibm-valid-P87-ibm87n08.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n08.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x05C0 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n08.xml)")
end

it "ibm-valid-P87-ibm87n09.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n09.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x05C3 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n09.xml)")
end

it "ibm-valid-P87-ibm87n10.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n10.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0653 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n10.xml)")
end

it "ibm-valid-P87-ibm87n11.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n11.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x06B8 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n11.xml)")
end

it "ibm-valid-P87-ibm87n12.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n12.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x06B9 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n12.xml)")
end

it "ibm-valid-P87-ibm87n13.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n13.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x06E9 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n13.xml)")
end

it "ibm-valid-P87-ibm87n14.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n14.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x06EE occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n14.xml)")
end

it "ibm-valid-P87-ibm87n15.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n15.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0904 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n15.xml)")
end

it "ibm-valid-P87-ibm87n16.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n16.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x093B occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n16.xml)")
end

it "ibm-valid-P87-ibm87n17.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n17.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x094E occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n17.xml)")
end

it "ibm-valid-P87-ibm87n18.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n18.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0955 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n18.xml)")
end

it "ibm-valid-P87-ibm87n19.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n19.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0964 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n19.xml)")
end

it "ibm-valid-P87-ibm87n20.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n20.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0984 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n20.xml)")
end

it "ibm-valid-P87-ibm87n21.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n21.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x09C5 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n21.xml)")
end

it "ibm-valid-P87-ibm87n22.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n22.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x09C9 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n22.xml)")
end

it "ibm-valid-P87-ibm87n23.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n23.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x09CE occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n23.xml)")
end

it "ibm-valid-P87-ibm87n24.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n24.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x09D8 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n24.xml)")
end

it "ibm-valid-P87-ibm87n25.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n25.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x09E4 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n25.xml)")
end

it "ibm-valid-P87-ibm87n26.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n26.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0A03 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n26.xml)")
end

it "ibm-valid-P87-ibm87n27.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n27.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0A3D occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n27.xml)")
end

it "ibm-valid-P87-ibm87n28.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n28.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0A46 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n28.xml)")
end

it "ibm-valid-P87-ibm87n29.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n29.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0A49 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n29.xml)")
end

it "ibm-valid-P87-ibm87n30.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n30.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0A4E occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n30.xml)")
end

it "ibm-valid-P87-ibm87n31.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n31.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0A80 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n31.xml)")
end

it "ibm-valid-P87-ibm87n32.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n32.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0A84 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n32.xml)")
end

it "ibm-valid-P87-ibm87n33.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n33.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0ABB occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n33.xml)")
end

it "ibm-valid-P87-ibm87n34.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n34.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0AC6 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n34.xml)")
end

it "ibm-valid-P87-ibm87n35.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n35.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0ACA occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n35.xml)")
end

it "ibm-valid-P87-ibm87n36.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n36.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0ACE occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n36.xml)")
end

it "ibm-valid-P87-ibm87n37.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n37.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0B04 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n37.xml)")
end

it "ibm-valid-P87-ibm87n38.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n38.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0B3B occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n38.xml)")
end

it "ibm-valid-P87-ibm87n39.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n39.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0B44 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n39.xml)")
end

it "ibm-valid-P87-ibm87n40.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n40.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0B4A occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n40.xml)")
end

it "ibm-valid-P87-ibm87n41.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n41.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0B4E occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n41.xml)")
end

it "ibm-valid-P87-ibm87n42.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n42.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0B58 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n42.xml)")
end

it "ibm-valid-P87-ibm87n43.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n43.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0B84 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n43.xml)")
end

it "ibm-valid-P87-ibm87n44.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n44.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0BC3 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n44.xml)")
end

it "ibm-valid-P87-ibm87n45.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n45.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0BC9 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n45.xml)")
end

it "ibm-valid-P87-ibm87n46.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n46.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0BD6 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n46.xml)")
end

it "ibm-valid-P87-ibm87n47.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n47.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0C0D occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n47.xml)")
end

it "ibm-valid-P87-ibm87n48.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n48.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0C45 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n48.xml)")
end

it "ibm-valid-P87-ibm87n49.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n49.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0C49 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n49.xml)")
end

it "ibm-valid-P87-ibm87n50.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n50.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0C54 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n50.xml)")
end

it "ibm-valid-P87-ibm87n51.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n51.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0C81 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n51.xml)")
end

it "ibm-valid-P87-ibm87n52.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n52.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0C84 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n52.xml)")
end

it "ibm-valid-P87-ibm87n53.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n53.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0CC5 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n53.xml)")
end

it "ibm-valid-P87-ibm87n54.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n54.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0CC9 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n54.xml)")
end

it "ibm-valid-P87-ibm87n55.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n55.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0CD4 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n55.xml)")
end

it "ibm-valid-P87-ibm87n56.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n56.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0CD7 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n56.xml)")
end

it "ibm-valid-P87-ibm87n57.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n57.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0D04 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n57.xml)")
end

it "ibm-valid-P87-ibm87n58.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n58.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0D45 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n58.xml)")
end

it "ibm-valid-P87-ibm87n59.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n59.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0D49 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n59.xml)")
end

it "ibm-valid-P87-ibm87n60.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n60.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0D4E occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n60.xml)")
end

it "ibm-valid-P87-ibm87n61.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n61.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0D58 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n61.xml)")
end

it "ibm-valid-P87-ibm87n62.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n62.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0E3F occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n62.xml)")
end

it "ibm-valid-P87-ibm87n63.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n63.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0E3B occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n63.xml)")
end

it "ibm-valid-P87-ibm87n64.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n64.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0E4F occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n64.xml)")
end

it "ibm-valid-P87-ibm87n66.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n66.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0EBA occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n66.xml)")
end

it "ibm-valid-P87-ibm87n67.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n67.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0EBE occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n67.xml)")
end

it "ibm-valid-P87-ibm87n68.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n68.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0ECE occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n68.xml)")
end

it "ibm-valid-P87-ibm87n69.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n69.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0F1A occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n69.xml)")
end

it "ibm-valid-P87-ibm87n70.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n70.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0F36 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n70.xml)")
end

it "ibm-valid-P87-ibm87n71.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n71.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0F38 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n71.xml)")
end

it "ibm-valid-P87-ibm87n72.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n72.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0F3B occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n72.xml)")
end

it "ibm-valid-P87-ibm87n73.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n73.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0F3A occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n73.xml)")
end

it "ibm-valid-P87-ibm87n74.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n74.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0F70 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n74.xml)")
end

it "ibm-valid-P87-ibm87n75.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n75.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0F85 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n75.xml)")
end

it "ibm-valid-P87-ibm87n76.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n76.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0F8C occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n76.xml)")
end

it "ibm-valid-P87-ibm87n77.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n77.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0F96 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n77.xml)")
end

it "ibm-valid-P87-ibm87n78.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n78.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0F98 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n78.xml)")
end

it "ibm-valid-P87-ibm87n79.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n79.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0FB0 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n79.xml)")
end

it "ibm-valid-P87-ibm87n80.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n80.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0FB8 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n80.xml)")
end

it "ibm-valid-P87-ibm87n81.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n81.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x0FBA occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n81.xml)")
end

it "ibm-valid-P87-ibm87n82.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n82.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x20DD occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n82.xml)")
end

it "ibm-valid-P87-ibm87n83.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n83.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x20E2 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n83.xml)")
end

it "ibm-valid-P87-ibm87n84.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n84.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x3030 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n84.xml)")
end

it "ibm-valid-P87-ibm87n85.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm87n85.xml", nil, " Tests CombiningChar with an only legal per 5th edition character. The character #x309B occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm87n85.xml)")
end

it "ibm-valid-P88-ibm88n03.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm88n03.xml", nil, " Tests Digit with an only legal per 5th edition character. The character #x066A occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm88n03.xml)")
end

it "ibm-valid-P88-ibm88n04.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm88n04.xml", nil, " Tests Digit with an only legal per 5th edition character. The character #x06FA occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm88n04.xml)")
end

it "ibm-valid-P88-ibm88n05.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm88n05.xml", nil, " Tests Digit with an only legal per 5th edition character. The character #x0970 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm88n05.xml)")
end

it "ibm-valid-P88-ibm88n06.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm88n06.xml", nil, " Tests Digit with an only legal per 5th edition character. The character #x09F2 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm88n06.xml)")
end

it "ibm-valid-P88-ibm88n08.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm88n08.xml", nil, " Tests Digit with an only legal per 5th edition character. The character #x0AF0 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm88n08.xml)")
end

it "ibm-valid-P88-ibm88n09.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm88n09.xml", nil, " Tests Digit with an only legal per 5th edition character. The character #x0B70 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm88n09.xml)")
end

it "ibm-valid-P88-ibm88n10.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm88n10.xml", nil, " Tests Digit with an only legal per 5th edition character. The character #x0C65 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm88n10.xml)")
end

it "ibm-valid-P88-ibm88n11.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm88n11.xml", nil, " Tests Digit with an only legal per 5th edition character. The character #x0CE5 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm88n11.xml)")
end

it "ibm-valid-P88-ibm88n12.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm88n12.xml", nil, " Tests Digit with an only legal per 5th edition character. The character #x0CF0 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm88n12.xml)")
end

it "ibm-valid-P88-ibm88n13.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm88n13.xml", nil, " Tests Digit with an only legal per 5th edition character. The character #x0D70 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm88n13.xml)")
end

it "ibm-valid-P88-ibm88n14.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm88n14.xml", nil, " Tests Digit with an only legal per 5th edition character. The character #x0E5A occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm88n14.xml)")
end

it "ibm-valid-P88-ibm88n15.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm88n15.xml", nil, " Tests Digit with an only legal per 5th edition character. The character #x0EDA occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm88n15.xml)")
end

it "ibm-valid-P88-ibm88n16.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm88n16.xml", nil, " Tests Digit with an only legal per 5th edition character. The character #x0F2A occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm88n16.xml)")
end

it "ibm-valid-P89-ibm89n03.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm89n03.xml", nil, " Tests Extender with an only legal per 5th edition character. The character #x02D2 occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm89n03.xml)")
end

it "ibm-valid-P89-ibm89n04.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm89n04.xml", nil, " Tests Extender with an only legal per 5th edition character. The character #x03FE occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm89n04.xml)")
end

it "ibm-valid-P89-ibm89n05.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm89n05.xml", nil, " Tests Extender with an only legal per 5th edition character. The character #x065F occurs as the second character in the PITarget in the PI in the DTD.  (xmlconf/eduni/errata-4e/ibm89n05.xml)")
end

it "ibm-invalid-P89-ibm89n06.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm89n06.xml", nil, " Tests Extender with an only legal per 5th edition character. The character #x0EC7 occurs as the second character in the PITarget in the PI in the prolog, and in an element name.  (xmlconf/eduni/errata-4e/ibm89n06.xml)")
end

it "ibm-invalid-P89-ibm89n07.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm89n07.xml", nil, " Tests Extender with an only legal per 5th edition character. The character #x3006 occurs as the second character in the PITarget in the PI in the prolog, and in an element name.  (xmlconf/eduni/errata-4e/ibm89n07.xml)")
end

it "ibm-invalid-P89-ibm89n08.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm89n08.xml", nil, " Tests Extender with an only legal per 5th edition character. The character #x3030 occurs as the second character in the PITarget in the PI in the prolog, and in an element name.  (xmlconf/eduni/errata-4e/ibm89n08.xml)")
end

it "ibm-invalid-P89-ibm89n09.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm89n09.xml", nil, " Tests Extender with an only legal per 5th edition character. The character #x3036 occurs as the second character in the PITarget in the PI in the prolog, and in an element name.  (xmlconf/eduni/errata-4e/ibm89n09.xml)")
end

it "ibm-invalid-P89-ibm89n10.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm89n10.xml", nil, " Tests Extender with an only legal per 5th edition character. The character #x309C occurs as the second character in the PITarget in the PI in the prolog, and in an element name.  (xmlconf/eduni/errata-4e/ibm89n10.xml)")
end

it "ibm-invalid-P89-ibm89n11.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm89n11.xml", nil, " Tests Extender with an only legal per 5th edition character. The character #x309F occurs as the second character in the PITarget in the PI in the prolog, and in an element name.  (xmlconf/eduni/errata-4e/ibm89n11.xml)")
end

it "ibm-invalid-P89-ibm89n12.xml (Section B.)" do
  assert_parses("xmlconf/eduni/errata-4e/ibm89n12.xml", nil, " Tests Extender with an only legal per 5th edition character. The character #x30FF occurs as the second character in the PITarget in the PI in the prolog, and in an element name.  (xmlconf/eduni/errata-4e/ibm89n12.xml)")
end

end

end

describe "eduni/namespaces/errata-1e/" do
describe "Richard Tobin's XML Namespaces 1.0/1.1 2nd edition test suite 1 June 2006" do
it "rmt-ns-e1.0-13a (Section NE13)" do
  assert_raises(XML::Error, " The xml namespace must not be declared as the default namespace.  (xmlconf/eduni/namespaces/errata-1e/NE13a.xml)") do
    File.open("xmlconf/eduni/namespaces/errata-1e/NE13a.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "rmt-ns-e1.0-13b (Section NE13)" do
  assert_raises(XML::Error, " The xmlns namespace must not be declared as the default namespace.  (xmlconf/eduni/namespaces/errata-1e/NE13b.xml)") do
    File.open("xmlconf/eduni/namespaces/errata-1e/NE13b.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "rmt-ns-e1.0-13c (Section NE13)" do
  assert_raises(XML::Error, " Elements must not have the prefix xmlns.  (xmlconf/eduni/namespaces/errata-1e/NE13c.xml)") do
    File.open("xmlconf/eduni/namespaces/errata-1e/NE13c.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

end

describe "eduni/misc/" do
describe "Bjoern Hoehrmann via HST 2013-09-18" do
it "hst-bh-001 (Section 2.2 [2], 4.1 [66])" do
  assert_raises(XML::Error, " decimal charref > 10FFFF, indeed > max 32 bit integer, checking for recovery from possible overflow  (xmlconf/eduni/misc/001.xml)") do
    File.open("xmlconf/eduni/misc/001.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "hst-bh-002 (Section 2.2 [2], 4.1 [66])" do
  assert_raises(XML::Error, " hex charref > 10FFFF, indeed > max 32 bit integer, checking for recovery from possible overflow  (xmlconf/eduni/misc/002.xml)") do
    File.open("xmlconf/eduni/misc/002.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "hst-bh-003 (Section 2.2 [2], 4.1 [66])" do
  assert_raises(XML::Error, " decimal charref > 10FFFF, indeed > max 64 bit integer, checking for recovery from possible overflow  (xmlconf/eduni/misc/003.xml)") do
    File.open("xmlconf/eduni/misc/003.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "hst-bh-004 (Section 2.2 [2], 4.1 [66])" do
  assert_raises(XML::Error, " hex charref > 10FFFF, indeed > max 64 bit integer, checking for recovery from possible overflow  (xmlconf/eduni/misc/004.xml)") do
    File.open("xmlconf/eduni/misc/004.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "hst-bh-005 (Section 3.1 [41])" do
  assert_parses("xmlconf/eduni/misc/005.xml", nil, " xmlns:xml is an attribute as far as validation is concerned and must be declared  (xmlconf/eduni/misc/005.xml)")
end

it "hst-bh-006 (Section 3.1 [41])" do
  assert_parses("xmlconf/eduni/misc/006.xml", nil, " xmlns:foo is an attribute as far as validation is concerned and must be declared  (xmlconf/eduni/misc/006.xml)")
end

it "hst-lhs-007 (Section 4.3.3)" do
  assert_raises(XML::Error, " UTF-8 BOM plus xml decl of iso-8859-1 incompatible  (xmlconf/eduni/misc/007.xml)") do
    File.open("xmlconf/eduni/misc/007.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "hst-lhs-008 (Section 4.3.3)" do
  assert_raises(XML::Error, " UTF-16 BOM plus xml decl of utf-8 (using UTF-16 coding) incompatible  (xmlconf/eduni/misc/008.xml)") do
    File.open("xmlconf/eduni/misc/008.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

it "hst-lhs-009 (Section 4.3.3)" do
  assert_raises(XML::Error, " UTF-16 BOM plus xml decl of utf-8 (using UTF-8 coding) incompatible  (xmlconf/eduni/misc/009.xml)") do
    File.open("xmlconf/eduni/misc/009.xml") do |file|
      XML::DOM.parse(file)
    end
  end
end

end

end

end
