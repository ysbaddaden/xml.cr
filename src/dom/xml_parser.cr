require "../dom"
require "../lexer"

module CRXML::DOM
  struct XMLParser
    getter document : XMLDocument

    def initialize(@lexer : Lexer)
      @document = XMLDocument.new

      parse_xmldecl

      if parse_prolog
        parse_logical_structures
      end

      if @lexer.@options.well_formed?
        ensure_nothing_after_root_element
      end
    end

    # Prolog: XMLDecl
    private def parse_xmldecl : Nil
      @lexer.tokenize_xmldecl do |tok|
        case tok
        when Lexer::XmlDecl
          # nothing to do (we only expect it)
        when Lexer::Attribute
          case tok.name
          when "version"
            @document.version = tok.value
          when "encoding"
            @lexer.set_encoding(tok.value)
            @document.encoding = tok.value
          when "standalone"
            @document.standalone = tok.value
          else
            # todo: recover?
            raise SyntaxError.new("unexpected attribute #{tok.name} in XML declaration", tok.start_location)
          end
        else
          raise "BUG: unexpected #{tok}"
        end
      end
    end

    # Prolog: Doctype?, Misc* (PI | Comment)
    private def parse_prolog : Bool
      doctype = nil

      @lexer.tokenize_prolog do |tok|
        case tok
        when Lexer::SDoctype
          doctype = @document.doctype = DocumentType.new(tok.name, tok.public_id || "", tok.system_id || "", @document)
        when Lexer::EDoctype
          doctype = nil
        when Lexer::STag
          @document.root = Element.new(tok.name, @document)
        when Lexer::Attribute
          @document.root.attributes[tok.name] = tok.value
        when Lexer::ETag
          # edge case: the root element is an empty element
          return false
        when Lexer::PI
          if doctype
            doctype.append(ProcessingInstruction.new(tok.name, tok.content, @document))
          else
            @document.append(ProcessingInstruction.new(tok.name, tok.content, @document))
          end
        when Lexer::Comment
          if doctype
            doctype.append(Comment.new(tok.content, @document))
          else
            @document.append(Comment.new(tok.content, @document))
          end
        when Lexer::PE
          doctype.append(Entity.new(true, tok.name, tok.value, nil, nil, nil)) if doctype
        when Lexer::ExternalPE
          doctype.append(Entity.new(true, tok.name, nil, tok.public_id, tok.system_id, tok.notation)) if doctype
        when Lexer::Entity
          doctype.append(Entity.new(false, tok.name, tok.value, nil, nil, nil)) if doctype
        when Lexer::ExternalEntity
          doctype.append(Entity.new(false, tok.name, nil, tok.public_id, tok.system_id, tok.notation)) if doctype
          # when Lexer::AttList
          # when Lexer::Element
          # when Lexer::Notation
        else
          raise "BUG: unexpected #{tok}"
        end
      end

      # done: we reached the root element (not empty)
      true
    end

    # Logical Structures (elements)
    private def parse_logical_structures : Nil
      current_element = @document.root

      state = [] of Element
      state << current_element

      @lexer.tokenize_logical_structures do |tok|
        case tok
        when Lexer::Text
          current_element.append(Text.new(tok.content, @document))
        when Lexer::STag
          element = Element.new(tok.name, @document)
          current_element.append(element)
          current_element = element
          state.push(element)
        when Lexer::Attribute
          current_element.attributes[tok.name] = tok.value
        when Lexer::ETag
          if current_element.name == tok.name
            state.pop?
            current_element = state.last?
            break unless current_element
          else
            # todo: recover (search the state until we find a matching element,
            # ignore etag if not found)
            raise SyntaxError.new("end tag mismatch", tok.start_location)
          end
        when Lexer::Comment
          current_element.append(Comment.new(tok.content, @document))
        when Lexer::CDATA
          current_element.append(CDataSection.new(tok.content, @document))
        when Lexer::PI
          # current_element.append(ProcessingInstruction.new(tok.name, tok.content, @document))
        else
          raise "BUG: unexpected #{tok}"
        end
      end
    end

    private def ensure_nothing_after_root_element
      @lexer.skip_s
      @lexer.tokenize_logical_structures do |tok|
        raise SyntaxError.new("Unexpected content after root element", tok.start_location)
      end
    end
  end
end
