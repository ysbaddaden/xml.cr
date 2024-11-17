require "./spec_helper"

describe CRXML::Lexer do
  describe "#tokenize" do
    it "normalizes end of lines" do
      assert_tokens [{:text, "\n"}], xml: "\r"
      assert_tokens [{:text, "\n"}], xml: "\n"
      assert_tokens [{:text, "\n\n"}], xml: "\n\n"
      assert_tokens [{:text, "\n"}], xml: "\r\n"
      assert_tokens [{:text, "\n"}], xml: "\r\u0085"
      assert_tokens [{:text, "\n"}], xml: "\u0085"
      assert_tokens [{:text, "\n"}], xml: "\u2028"
      assert_tokens [{:text, "\nt"}], xml: "\rt"
      assert_tokens [{:text, "\n\n"}], xml: "\r\r"
      assert_tokens [{:text, "\n\n"}], xml: "\r\u2028"
      assert_tokens [{:text, "\n \n  "}], xml: "\n \r\n  "
    end

    it "tokenizes xml declaration" do
      assert_tokens [{:xmldecl}], xml: "<?xml?>"
      assert_tokens [{:xmldecl}], xml: "<?xml\t \r\n?>"

      assert_tokens [{:xmldecl}, {:attribute, "version", "1.0"}], xml: "<?xml version='1.0'?>"
      assert_tokens [{:xmldecl}, {:attribute, "version", "1.1"}], xml: %(<?xml version="1.1"?>)

      assert_tokens [{:xmldecl}, {:attribute, "encoding", "utf-8"}], xml: "<?xml encoding='utf-8'?>"
      assert_tokens [{:xmldecl}, {:attribute, "encoding", "iso-8859-1"}], xml: %(<?xml encoding="iso-8859-1"?>)

      assert_tokens [{:xmldecl}, {:attribute, "standalone", "yes"}], xml: %(<?xml standalone="yes"?>)
      assert_tokens [{:xmldecl}, {:attribute, "standalone", "no"}], xml: "<?xml standalone='no'?>"

      assert_tokens [
        {:xmldecl},
        {:attribute, "encoding", "UTF-8"},
        {:attribute, "standalone", "no"},
        {:attribute, "version", "1.1"},
      ], xml: %(<?xml \t encoding   = "UTF-8"  standalone =\n'no'  version =\r"1.1"\t ?>)
    end

    it "tokenizes processing instructions" do
      assert_tokens [{:pi, "key", ""}], xml: "<?key?>"
      assert_tokens [{:pi, "key", ""}], xml: "<?key \t?>"
      assert_tokens [{:pi, "key", "value"}], xml: "<?key value?>"
      assert_tokens [{:pi, "key", "value "}], xml: "<?key value ?>"
      assert_tokens [{:pi, "inst", "with some content"}], xml: "<?inst with some content?>"
    end

    it "tokenizes comments" do
      assert_tokens [{:comment, ""}], xml: "<!---->"
      assert_tokens [{:comment, " "}], xml: "<!-- -->"
      assert_tokens [{:comment, " - -- "}], xml: "<!-- - -- -->" # not well-formed
      assert_tokens [{:comment, " a comment ->"}], xml: "<!-- a comment ->-->"
      assert_tokens [{:comment, "a-"}], xml: "<!--a--->" # not well-formed
      assert_tokens [{:comment, "azerty"}], xml: "<!--azerty-->"
      assert_tokens [{:comment, " declarations for <head> & <body> "}], xml: "<!-- declarations for <head> & <body> -->"
      assert_tokens [
        {:comment, "one"},
        {:comment, "two"},
      ], xml: "<!--one--><!--two-->"
    end

    it "tokenizes cdata" do
      assert_tokens [{:cdata, ""}], xml: "<![CDATA[]]>"
      assert_tokens [{:cdata, " "}], xml: "<![CDATA[ ]]>"
      assert_tokens [{:cdata, "chars"}], xml: "<![CDATA[chars]]>"
      assert_tokens [{:cdata, "<greeting>Hello, world!</greeting>"}], xml: "<![CDATA[<greeting>Hello, world!</greeting>]]>"
      assert_tokens [{:cdata, " [] [[]] "}], xml: "<![CDATA[ [] [[]] ]]>"
      assert_tokens [{:cdata, " []] ]>]] ]"}], xml: "<![CDATA[ []] ]>]] ]]]>"
    end

    it "tokenizes elements" do
      assert_tokens [
        {:stag, "root"},
        {:etag, "root"},
      ], xml: "<root></root>"

      assert_tokens [
        {:stag, "root"},
        {:etag, "root"},
      ], xml: "<root \t></root\r >"

      assert_tokens [
        {:stag, "root"},
        {:stag, "foo"},
        {:etag, "foo"},
        {:etag, "root"},
      ], xml: "<root><foo></foo></root>"

      assert_tokens [
        {:stag, "root"},
        {:stag, "foo"},
        {:etag, "foo"},
        {:stag, "bar"},
        {:stag, "baz"},
        {:etag, "baz"},
        {:etag, "bar"},
        {:etag, "root"},
      ], xml: "<root><foo></foo><bar><baz></baz></bar></root>"
    end

    it "tokenizes empty elements" do
      assert_tokens [{:stag, "key"}, {:etag, "key"}], xml: "<key/>"
      assert_tokens [{:stag, "empty"}, {:etag, "empty"}], xml: "<empty \t\n/>"
    end

    it "tokenizes unbalanced elements" do
      assert_tokens [
        {:stag, "root"},
        {:stag, "foo"},
        {:stag, "bar"},
        {:etag, "baz"},
        {:etag, "root"},
      ], xml: "<root><foo><bar></baz></root>"
    end

    describe "attributes" do
      it "tokenizes" do
        assert_tokens [
          {:stag, "root"},
          {:attribute, "id", "start"},
        ], xml: %(<root id="start">)

        assert_tokens [
          {:stag, "root"},
          {:attribute, "id", "start"},
          {:attribute, "class", "name"},
        ], xml: %(<root id="start" class="name">)

        assert_tokens [
          {:stag, "root"},
          {:attribute, "id", "start"},
          {:attribute, "id", "end"},
        ], xml: %(<root id="start" id="end">)
      end

      it "pcdata: normalizes whitespace (including end of lines)" do
        assert_tokens [
          {:stag, "empty"},
          {:attribute, "value", " name1     name2"},
        ], xml: %(<empty value=" name1 \t \r\n name2">)
      end

      it "nmtokens: normalizes whitespace (including end of lines)" do
        skip "not implemented"
      end

      it "replaces decimal char ref" do
        assert_tokens [
          {:stag, "empty"},
          {:attribute, "value", "&"},
        ], xml: %(<empty value="&#38;">)

        assert_tokens [
          {:stag, "empty"},
          {:attribute, "value", "&#38;"},
        ], xml: %(<empty value="&#38;#38;">)
      end

      it "replaces hexadecimal char ref" do
        assert_tokens [
          {:stag, "empty"},
          {:attribute, "value", "&"},
        ], xml: %(<empty value="&#x26;">)
      end

      it "replaces predefined entities" do
        Lexer::PREDEFINED_ENTITIES.each do |name, char|
          assert_tokens [
            {:stag, "empty"},
            {:attribute, "value", char.to_s},
          ], xml: %(<empty value="&#{name};">)
        end
      end

      # it "doesn't recognize unknown entities" do
      #   assert_tokens [
      #     {:stag, "empty"},
      #     {:attribute, "value", "&unknown;"},
      #   ], xml: %(<empty value="&unknown;">)
      # end

      # it "replaces local entities" do
      #   skip "missing test"
      # end

      # it "replaces external entities" do
      #   skip "missing test"
      # end

      it "doesn't recognize parameter entities" do
        assert_tokens [
          {:stag, "empty"},
          {:attribute, "value", "%name;"},
        ], xml: %(<empty value="%name;">)
      end
    end

    describe "text" do
      it "tokenizes" do
        assert_tokens [{:text, "foobar"}], xml: "foobar"
        assert_tokens [{:text, "foo\n bar baz\n "}], xml: "foo\n bar baz\n "
      end

      it "doesn't normalize whitespace (only end of lines)" do
        assert_tokens [{:text, " \t\n"}], xml: " \t\r\n"
      end

      it "replaces decimal char ref" do
        assert_tokens [{:text, "\u0001"}], xml: "&#1;"
        assert_tokens [{:text, "\u007b"}], xml: "&#123;"
        assert_tokens [{:text, "&#38;"}], xml: "&#38;#38;"
        assert_tokens [{:text, "&#60;"}], xml: "&#38;#60;"
      end

      it "replaces hexadecimal char ref" do
        assert_tokens [{:text, "\u0009"}], xml: "&#x9;"
        assert_tokens [{:text, "\u00ad"}], xml: "&#xad;"
        assert_tokens [{:text, "\u{10ffff}"}], xml: "&#x10fFFf;"
      end

      it "tokenizes entity ref" do
        Lexer::PREDEFINED_ENTITIES.each do |name, char|
          assert_tokens [{:entity_ref, name}], xml: "&#{name};"
        end
        assert_tokens [{:entity_ref, "unknown"}], xml: "&unknown;"
      end

      # it "replaces local entities" do
      #   skip "missing test"
      # end

      # it "replaces external entities" do
      #   skip "missing test"
      # end

      it "doesn't recognize parameter entities" do
        assert_tokens [{:text, "%name;"}], xml: "%name;"
      end
    end

    it "tokenizes pretty printed XML" do
      xml = <<-XML
      <?xml version="1.1"?>
      <root>
        <bar>
          <foo></foo>
        </bar>
        <baz>some text</baz>
      </root>
      XML

      assert_tokens [
        {:xmldecl},
        {:attribute, "version", "1.1"},
        {:stag, "root"},
        {:text, "\n  "},
        {:stag, "bar"},
        {:text, "\n    "},
        {:stag, "foo"},
        {:etag, "foo"},
        {:text, "\n  "},
        {:etag, "bar"},
        {:text, "\n  "},
        {:stag, "baz"},
        {:text, "some text"},
        {:etag, "baz"},
        {:text, "\n"},
        {:etag, "root"},
      ], xml
    end
  end

  # lexes the logical structure (elements)
  private def assert_tokens(expected, xml)
    actual = [] of {Symbol} | {Symbol, String} | {Symbol, String, String}
    lexer = Lexer.new(xml)
    lexer.tokenize { |token| actual << transform_token(token) }
    assert_equal expected, actual
  end

  private def transform_token(token)
    case token
    when Lexer::Text
      {:text, token.data}
    when Lexer::STag
      {:stag, token.name}
    when Lexer::ETag
      {:etag, token.name}
    when Lexer::Attribute
      {:attribute, token.name, token.value}
    when Lexer::Comment
      {:comment, token.data}
    when Lexer::CDATA
      {:cdata, token.data}
    when Lexer::XMLDecl
      {:xmldecl}
    when Lexer::Doctype
      {:doctype}
    when Lexer::PI
      {:pi, token.name, token.data}
    when Lexer::EntityRef
      {:entity_ref, token.name}
    when Lexer::PEReference
      {:pe_reference, token.name}
    else
      raise "unknown token: #{token}"
    end
  end
end
