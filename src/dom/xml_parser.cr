require "../dom"
require "../lexer"

module CRXML::DOM
  struct XMLParser
    getter document : XMLDocument

    def initialize(@lexer : Lexer)
      @document = XMLDocument.new

      # Prolog
      token = @lexer.next_token?(skip_s: @lexer.@options.well_formed?)

      if parse_xmldecl?(token)
        token = @lexer.next_token?(skip_s: true)
      end

      loop do
        case token
        when Lexer::Doctype
          parse_doctype(token)
        when Lexer::STag
          # reached root element
          document.root = parse_element(token)
          token = @lexer.next_token?(skip_s: true)
          break
        when Lexer::Comment
          @document.append(Comment.new(token.data, @document))
        when Lexer::PI
          @document.append(ProcessingInstruction.new(token.name, token.data, @document))
        when nil
          return
        else
          raise ParserError.new("Unexpected #{token.class.name} in Misc", token.start_location)
        end

        token = @lexer.next_token?(skip_s: true)
      end

      # Misc*
      loop do
        case token
        when Lexer::Comment
          @document.append(Comment.new(token.data, @document))
        when Lexer::PI
          @document.append(ProcessingInstruction.new(token.name, token.data, @document))
        when nil
          return
        else
          raise ParserError.new("Unexpected #{token.class.name} in Misc", token.start_location)
        end

        token = @lexer.next_token?(skip_s: true)
      end
    end

    # TODO: well-formed: the attributes are ordered: version [encoding] [standalone]
    private def parse_xmldecl?(token : Lexer::XMLDecl)
      while attr = @lexer.next_xmldecl_token?
        case attr.name
        when "version"
          @document.version = attr.value
        when "encoding"
          @document.encoding = attr.value
          @lexer.set_encoding(attr.value)
        when "standalone"
          @document.standalone = attr.value
        else
          raise ParserError.new("Unexpected attribute #{attr.name} in XMLDecl", attr.start_location)
        end
      end
      true
    end

    private def parse_xmldecl?(token : Lexer::Token?)
      false
    end

    private def parse_doctype(token : Lexer::Doctype)
      raise ParserError.new("Multiple doctype declaration", token.start_location) if @document.doctype?
      doctype = DocumentType.new(token.name, token.public_id, token.system_id, @document)
      @document.doctype = doctype

      if @lexer.doctype_intsubset?
        while token = @lexer.next_dtd_token?
          case token
          when Lexer::AttlistDecl
            attlistdecl = AttlistDecl.new(token.name, token.defs, @document)
            doctype.append(attlistdecl)
          when Lexer::ElementDecl
            doctype.append(ElementDecl.new(token.name, token.content, @document))
          when Lexer::EntityDecl
            entitydecl = EntityDecl.new(token.parameter, token.name, token.value, token.public_id, token.system_id, token.notation_id, @document)
            doctype.append(entitydecl)
          when Lexer::NotationDecl
            notationdecl = NotationDecl.new(token.name, token.public_id, token.system_id, @document)
            doctype.append(notationdecl)
          when Lexer::Comment
            doctype.append(Comment.new(token.data, @document))
          when Lexer::PI
            doctype.append(ProcessingInstruction.new(token.name, token.data, @document))
          when Lexer::PEReference
            # TODO: process PEReference
          else
            raise ParserError.new("Unexpected #{token.class.name} in DOCTYPE", token.start_location)
          end
        end
      end
    end

    private def parse_element(token : Lexer::STag) : Element
      element = Element.new(token.name, @document)

      while token = @lexer.next_attribute?(element.name)
        case token
        when Lexer::Attribute
          element.attributes[token.name] = token.value
        when Lexer::ETag
          # empty tag
          return element
        end
      end

      # TODO: unroll the loop and keep a list of nested elements, so we can
      # try to recover from mismatched elements
      while token = @lexer.next_token?(skip_s: false)
        case token
        when Lexer::STag
          element.append(parse_element(token))
        when Lexer::CDATA
          element.append(CDataSection.new(token.data, @document))
        when Lexer::Text
          element.append(Text.new(token.data, @document))
        when Lexer::EntityRef
          # TODO: process EntityRef
        when Lexer::Comment
          element.append(Comment.new(token.data, @document))
        when Lexer::PI
          element.append(ProcessingInstruction.new(token.name, token.data, @document))
        when Lexer::ETag
          unless token.name == element.name
            raise ParserError.new("Element mismatch", token.start_location)
          end
          break
        else
          raise ParserError.new("Unexpected #{token.class.name} in content", token.start_location)
        end
      end

      element
    end
  end
end
