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

      parse_content(parent: element)
    end

    private def parse_content(parent)
      # TODO: unroll the loop and keep a list of nested elements, so we can
      # try to recover from mismatched elements
      while token = @lexer.next_token?(skip_s: false)
        case token
        when Lexer::STag
          parent.append(parse_element(token))
        when Lexer::CDATA
          parent.append(CDataSection.new(token.data, @document))
        when Lexer::Text
          parent.append(Text.new(token.data, @document))
        when Lexer::EntityRef
          process_entity(token, external: true) { |node| parent.append(node) }
        when Lexer::Comment
          parent.append(Comment.new(token.data, @document))
        when Lexer::PI
          parent.append(ProcessingInstruction.new(token.name, token.data, @document))
        when Lexer::ETag
          unless parent.is_a?(Element) && (token.name == parent.name)
            raise ParserError.new("Element mismatch", token.start_location)
          end
          break
        else
          raise ParserError.new("Unexpected #{token.class.name} in content", token.start_location)
        end
      end

      parent
    end

    private def process_entity(token, external = false, &) : Nil
      if text = Lexer::PREDEFINED_ENTITIES[token.name]?
        yield Text.new(text, @document)
      elsif entitydecl = find_entity_declaration(token.name)
        unless entitydecl.first_child?
          if entitydecl.value?
            parse_internal_entity(entitydecl)
          elsif external
            unless parse_external_entity?(entitydecl)
              yield EntityRef.new(token.name, @document)
            end
          else
            raise ParserError.new("Can't reference external entity here", token.start_location)
          end
        end
        entitydecl.each_child { |child| yield child.clone }
      elsif @lexer.@options.well_formed?
        raise ParserError.new("Unknown entity", token.start_location)
      else
        yield EntityRef.new(token.name, @document)
      end
    end

    private def find_entity_declaration(name)
      @document.doctype?.try(&.each_child do |node|
        return node if node.is_a?(EntityDecl) && node.name == name
      end)
    end

    private def parse_internal_entity(entitydecl)
      # TODO: set initial lexer location to entitydecl value position
      lexer = Lexer.new(IO::Memory.new(entitydecl.value), @lexer.@options)

      with_entity_lexer("ge:#{entitydecl.name}", lexer) do
        parse_content(parent: entitydecl)
      end
    end

    # TODO: detect scheme (file://, http://, ...)
    # TODO: download file from the network (if authorized)
    # TODO: authorize access to local file (under an allowed list of paths)
    private def parse_external_entity?(entitydecl)
      return false unless (io = @lexer.@io).responds_to?(:path)

      path = File.expand_path(File.join(File.dirname(io.path), entitydecl.system_id))
      return false unless File.exists?(path)

      File.open(path) do |file|
        lexer = Lexer.new(file, @lexer.@options)

        with_entity_lexer("pe:#{entitydecl.name}", lexer) do
          # TODO: detect and parse TextDecl, set encoding, ...
          parse_content(parent: entitydecl)
        end
      end

      true
    end

    private def entity_recursion_check
      @entity_recursion_check ||= Set(String).new
    end

    private def with_entity_lexer(key, lexer, &)
      unless entity_recursion_check.add?(key)
        raise ParserError.new("Entity directly or indirectly refers to itself", lexer.location)
      end

      original = @lexer
      @lexer = lexer

      begin
        yield
      ensure
        @lexer = original
        entity_recursion_check.delete(key)
      end
    end

    private def dirname : String
    end

    # private def include_path
    #   if path = @include_path
    #     path
    #   elsif (io = @lexer.@io).responds_to?(:path)
    #     @include_path = File.expand_path(File.dirname(io.path))
    #   else
    #     raise RuntimeError.new("Can't parse XML external entity without an include path")
    #   end
    # end
  end
end
