require "io/memory"
require "string_pool"
require "./lexer/error"
require "./lexer/ast"
require "./lexer/entities"

module CRXML
  @[Flags]
  enum Options
    WellFormed
  end

  # Lexes a XML document into tokens.
  #
  # The lexer is closer to a SAX (Simple API for XML) parser than a regular
  # tokenizer in that it directly yields :stag, :attribute or :comment tokens,
  # instead of the smaller `<` or `?>` individual tokens. Most of the XML
  # normalizations (e.g. end of lines, entities) should have already been
  # applied, too.
  #
  # TODO: option to skip comments.
  # TODO: avoid IO#seek (not widely available, trashes buffer).
  #
  # FIXME: (hexa)decimal char refs must be decoded as soon as they are parsed
  # (e.g. in text or entitydecl value), but entity refs shall only be normalized
  # when processed as text.
  class Lexer
    PREDEFINED_ENTITIES = {
      "lt"   => '<',
      "gt"   => '>',
      "amp"  => '&',
      "apos" => '\'',
      "quot" => '"',
    }

    def self.new(string : String, **args)
      new(IO::Memory.new(string), **args)
    end

    @io : IO
    @replacement_texts : Array({IO, Char?, Char?})
    @current_char : Char?
    @peek_char : Char?
    getter options : Options

    # TODO: option to skip over comments (don't allocate as strings)
    def initialize(@io : IO, @options : Options = :none, @include_external_entities = false, @include_path : String? = nil)
      @buf = IO::Memory.new
      @pool = StringPool.new
      @location = Location.new(1, 0)
      @replacement_texts = Array({IO, Char?, Char?}).new
      detect_encoding
      next_char
    end

    private def include_path
      @include_path ||=
        if (io = @io).responds_to?(:path)
          File.expand_path(File.dirname(io.path))
        end
    end

    private def entities
      @entities ||= Hash(String, String).new
    end

    private def external_entities
      @external_entities ||= Hash(String, String).new
    end

    private def parameter_entities
      @parameter_entities ||= Hash(String, String).new
    end

    private def external_parameter_entities
      @external_parameter_entities ||= Hash(String, String).new
    end

    def set_encoding(encoding : String) : Nil
      @io.set_encoding(encoding)
    end

    private def detect_encoding
      bytes = uninitialized UInt8[4]
      @io.read_fully?(bytes.to_slice)

      # detect Byte Order Mark (BOM)

      case bytes
      when UInt8.static_array(0x00, 0x00, 0xFE, 0xFF)
        @io.set_encoding("UCS-4BE")
        return
      when UInt8.static_array(0xFF, 0xFE, 0x00, 0x00)
        @io.set_encoding("UCS-4LE")
        return
        # when UInt8.static_array(0x00, 0x00, 0xFF, 0xFE)
        #  @io.set_encoding("UCS-4" # unusual octet order (2143) unsupported?
        # return
        # when UInt8.static_array(0xFE, 0xFF, 0x00, 0x00)
        #  @io.set_encoding("UCS-4" # unusual octet order (3412) unsupported?
        # return
      end

      case bytes.to_slice[0, 2]
      when UInt8.static_array(0xFE, 0xFF).to_slice
        @io.seek(2, IO::Seek::Set)
        @io.set_encoding("UTF-16BE")
        return
      when UInt8.static_array(0xFF, 0xFE).to_slice
        @io.seek(2, IO::Seek::Set)
        @io.set_encoding("UTF-16LE")
        return
      end

      if bytes.to_slice[0, 3] == UInt8.static_array(0xEF, 0xBB, 0xBF).to_slice
        @io.seek(3, IO::Seek::Set)
        @io.set_encoding("UTF-8")
        return
      end

      # autodetect

      case bytes
      when UInt8.static_array(0x00, 0x00, 0x00, 0x3C)
        @io.set_encoding("UCS-4BE")
      when UInt8.static_array(0x3C, 0x00, 0x00, 0x00)
        @io.set_encoding("UCS-4LE")
        # when UInt8.static_array(0x00, 0x00, 0x3C, 0x00)
        #  @io.set_encoding("UCS-4") # unusual octet order (2143) unsupported?
        # when UInt8.static_array(0x00, 0x3C, 0x00, 0x00)
        #  @io.set_encoding("UCS-4") # unusual octet order (3412) unsupported?
      when UInt8.static_array(0x00, 0x3C, 0x00, 0x3F)
        @io.set_encoding("UTF-16BE")
      when UInt8.static_array(0x3C, 0x00, 0x3F, 0x00)
        @io.set_encoding("UTF-16LE")
      when UInt8.static_array(0x3C, 0x3F, 0x78, 0x6D)
        # ASCII, ISO 646, UTF-8: we can keep reading with the default UTF-8
        # when UInt8.static_array(0x4C, 0x6F, 0xA7, 0x94)
        # EBCDIC: unsupported?
      end

      @io.seek(0, IO::Seek::Set)
    end

    # Expects a XML declaration and yields the individual tokens (`XmlDecl` and
    # `Attribute`). Returns when the XML declaration has been successfully
    # tokenized. Raises `SyntaxError` on errors.
    #
    # TODO: check presence of UTF Byte Order Mark (BOM) and set the IO encoding;
    # See <https://www.w3.org/TR/xml11/#sec-guessing>.
    def tokenize_xmldecl(& : Token ->) : Nil
      skip_s
      start_location = @location

      bytes = uninitialized UInt8[4]
      @io.read_fully?(bytes.to_slice)

      if current_char == '<' && bytes == StaticArray['?'.ord, 'x'.ord, 'm'.ord, 'l'.ord]
        next_char
        @location = @location.adjust(column: +4)
        yield XmlDecl.new(start_location, @location)

        loop do
          skip_s

          if current_char == '?'
            next_char
            expect('>')
            return
          else
            start_location = @location
            name, value = lex_attribute
            yield Attribute.new(name, value, start_location, @location)
          end
        end
      else
        @io.seek(-4, IO::Seek::Current)
      end
    end

    # Yields the individual tokens that make the XML Prolog excluding the XML
    # declaration (see `#tokenize_xmldecl`). Returns when the document root
    # start tag has been parsed (including its attributes). Raises `SyntaxError`
    # on errors.
    def tokenize_prolog(& : Token ->) : Nil
      loop do
        skip_s

        start_location = @location
        char = @current_char

        case char
        when '<'
          next_char

          case current_char
          when '!'
            case next_char
            when '-'
              next_char
              expect('-')
              comment = lex_comment
              yield Comment.new(comment, start_location, @location)
            else
              expect("DOCTYPE")
              skip_s
              name = lex_name
              skip_s
              public_id = nil
              system_id = nil
              if current_char == 'S' || current_char == 'P'
                if expect("SYSTEM", "PUBLIC") == "PUBLIC"
                  skip_s
                  public_id = lex_pubid_literal
                end
                skip_s
                system_id = lex_system_literal
                skip_s
              end
              yield SDoctype.new(name, public_id, system_id, start_location, @location)

              if @current_char == '['
                expect '['

                loop do
                  skip_s
                  start_location = @location

                  case expect(']', '<', '%')
                  when ']'
                    break
                  when '<'
                    case current_char
                    when '?'
                      name, content = lex_pi
                      yield PI.new(name, content, start_location, @location)
                    when '!'
                      case next_char
                      when '-'
                        next_char
                        expect('-')
                        comment = lex_comment
                        yield Comment.new(comment, start_location, @location)
                      else
                        case expect("ELEMENT", "ATTLIST", "ENTITY", "NOTATION")
                        when "ENTITY"
                          skip_s

                          if pe = (current_char == '%')
                            next_char
                            skip_s
                          end

                          name = lex_name
                          skip_s

                          if current_char == 'S' || current_char == 'P'
                            if expect("SYSTEM", "PUBLIC") == "PUBLIC"
                              skip_s
                              public_id = lex_pubid_literal
                            end
                            skip_s
                            system_id = lex_system_literal
                            skip_s
                            if current_char == 'N'
                              expect("NDATA")
                              skip_s
                              notation = lex_name
                            end

                            if pe
                              self.external_parameter_entities[name] ||= system_id if @include_external_entities
                              yield ExternalPE.new(name, public_id, system_id, notation, start_location, @location)
                            else
                              self.external_entities[name] ||= system_id if @include_external_entities
                              yield ExternalEntity.new(name, public_id, system_id, notation, start_location, @location)
                            end
                          else
                            value = lex_entity_value
                            if pe
                              self.parameter_entities[name] ||= value
                              yield PE.new(name, value, start_location, @location)
                            else
                              self.entities[name] ||= value
                              yield Entity.new(name, value, start_location, @location)
                            end
                          end

                          skip_s
                          expect '>'
                        else
                          # todo: elementdecl
                          # todo: AttlistDecl
                          # todo: NotationDecl
                          until next_char == '>'
                            # ignore for now
                          end
                          next_char
                        end
                      end
                    end
                  when '%'
                    name = lex_name
                    expect(';')

                    # FIXME: prevent entity recursion (e1 => e2 => e1 => ...)
                    if pe = @parameter_entities.try(&.fetch(name) { nil })
                      replacement_text IO::Memory.new(pe)
                    end
                    if system_id = @external_parameter_entities.try(&.fetch(name) { nil })
                      if include_path = self.include_path
                        path = File.expand_path(File.join(include_path, system_id))
                        if path.starts_with?(include_path) && File.exists?(path)
                          replacement_text File.new(path)
                          return
                        end
                      end
                    end
                  end
                end

                skip_s
              end

              yield EDoctype.new(start_location, @location)

              expect '>'
            end
          when '?'
            name, content = lex_pi
            yield PI.new(name, content, start_location, @location)
          else
            name = lex_name
            yield STag.new(name, start_location, @location)
            lex_tag_attributes(name) { |attr| yield attr }
            # reached root element: we're done lexing the prolog
            break
          end
        when nil
          # reached EOF
          break
        else
          raise SyntaxError.new("unexpected '#{char}'", @location)
        end
      end
    end

    # todo: option to skip whitespaces
    def tokenize_logical_structures(& : Token ->) : Nil
      loop do
        start_location = @location
        char = @current_char

        case char
        when '<'
          next_char

          case current_char
          when '/'
            next_char
            name = lex_name
            skip_s
            expect '>'
            yield ETag.new(name, start_location, @location)
          when '!'
            case next_char
            when '-'
              next_char
              expect('-')
              comment = lex_comment
              yield Comment.new(comment, start_location, @location)
            when '['
              next_char
              expect("CDATA")
              expect('[')
              cdata = lex_cdata
              yield CDATA.new(cdata, start_location, @location)
            else
              raise SyntaxError.new("unknown <! markup in logical structures", @location)
            end
          when '?'
            name, content = lex_pi
            yield PI.new(name, content, start_location, @location)
          else
            name = lex_name
            yield STag.new(name, start_location, @location)
            lex_tag_attributes(name) { |attr| yield attr }
          end
        when nil
          # reached EOF
          break
        else
          content = lex_text
          yield Text.new(content, start_location, @location)
        end
      end
    end

    private def lex_tag_attributes(tag_name, & : Token ->) : Nil
      loop do
        skip_s
        start_location = @location

        case current_char
        when '>'
          next_char
          break
        when '/'
          next_char
          expect '>'
          yield ETag.new(tag_name, start_location, @location)
          break
        else
          name, value = lex_attribute
          yield Attribute.new(name, value, start_location, @location)
        end
      end
    end

    private def skip_s
      while (char = @current_char) && s?(char)
        next_char
      end
    end

    private def lex_pi
      next_char

      name = lex_name
      # TODO: well-formed: reject name =~ /xml/i
      skip_s

      content = String.build do |str|
        loop do
          if current_char == '?'
            if next_char == '>'
              next_char # >
              break
            end
            str << '?'
          else
            str << current_char
            next_char
          end
        end
      end

      {name, content}
    end

    # OPTIMIZE: fast-mode: accept anything but whitespace, '>', '"', '\'' or ';'
    private def lex_name
      if (char = @current_char) && name_start_char?(char)
        @buf << char
        next_char
      else
        raise SyntaxError.new("Expected NameStartChar but got #{char.inspect}", @location)
      end

      while (char = @current_char) && name_char?(char)
        @buf << char
        next_char
      end

      @pool.get(@buf.to_slice)
    ensure
      @buf.clear
    end

    # OPTIMIZE: fast-mode: accept anything but whitespace, '>', '"', '\'' or ';'
    private def lex_nmtoken
      while (char = @current_char) && name_char?(char)
        @buf << char
        next_char
      end
      @pool.get(@buf.to_slice)
    ensure
      @buf.clear
    end

    private def lex_attribute
      name = lex_name
      skip_s

      # TODO: well-formed: value is required for XML (with override, e.g. HTML)
      if current_char == '='
        next_char
        skip_s

        # TODO: recover: allow missing quotes (end attvalue at whitespace, '>',
        # '/>', '?>', '"' or '\'')
        quote = expect('\'', '"')
        value = lex_attvalue(quote)
      elsif @options.well_formed?
        raise SyntaxError.new("Attribute must have a value", @location)
      end

      {name, value || ""}
    end

    private def lex_entity_value
      quote = expect('"', '\'')

      String.build do |str|
        until (char = current_char) == quote
          normalize_to(str, char, normalize_s: true, include_pe: true)
        end
        next_char
      end
    end

    # TODO: if attribute type is NMTOKENS then merge all whitespaces & skip leading/trailing whitespace
    # TODO: well-formed: reject '<'
    private def lex_attvalue(quote)
      String.build do |str|
        until (char = current_char) == quote
          if char == '<' && @options.well_formed?
            next_char
            raise SyntaxError.new("Attribute value cannot contain a literal '<'", @location)
          end
          normalize_to(str, char, normalize_s: true, include_entity: true)
        end
        next_char
      end
    end

    private def lex_system_literal
      quote = expect('"', '\'')

      String.build do |str|
        until (char = current_char) == quote
          str << char
          next_char
        end
        next_char
      end
    end

    private def lex_pubid_literal
      quote = expect('"', '\'')

      String.build do |str|
        until (char = current_char) == quote
          if !@options.well_formed? || pubid_char?(char)
            str << char
            next_char
          else
            raise ValidationError.new("Unexpected char #{char.inspect} in public id literal", @location)
          end
        end
        next_char
      end
    end

    private def lex_text
      String.build do |str|
        while (char = @current_char) && char != '<'
          if @options.well_formed?
            if char == ']'
              if next_char == ']' && peek_char == '>'
                raise SyntaxError.new("Text content may not contain a literal ']]>' sequence", @location)
              end
              str << ']'
              next
            end
            # if !char?(char) || restricted_char?(char)
            #   raise SyntaxError.new("Invalid Char #{char.inspect}", @location)
            # end
          end
          normalize_to(str, char, include_entity: true, process_entity: true)
        end
      end
    end

    private def lex_comment
      String.build do |str|
        loop do
          if current_char == '-'
            if next_char == '-'
              if peek_char == '>'
                next_char # -
                next_char # >
                break
              elsif @options.well_formed?
                raise ValidationError.new("Double hyphen within comment", @location.adjust(column: -2))
              end
              str << '-'
            end
            str << '-'
          end

          if @options.well_formed? && !char?(current_char)
            raise ValidationError.new("Invalid XML char #{current_char.inspect}", @location)
          end

          str << current_char
          next_char
        end
      end
    end

    private def lex_cdata
      String.build do |str|
        loop do
          if current_char == ']'
            if next_char == ']'
              if peek_char == '>'
                next_char # ]
                next_char # >
                break
              end
            end
            str << ']'
          else
            if @options.well_formed? && !char?(current_char)
              raise ValidationError.new("Invalid XML char #{current_char.inspect}", @location)
            end
            str << current_char
            next_char
          end
        end
      end
    end

    private def expect(*names : String) : String
      min = names.min_by(&.bytesize).bytesize
      max = names.max_by(&.bytesize).bytesize

      min.times do |i|
        @buf << current_char
        next_char

        if name = names.find { |n| @buf.to_slice == n.to_slice }
          return name
        end
      end

      (max - min).times do |i|
        @buf << current_char
        next_char

        if name = names.find { |n| @buf.to_slice == n.to_slice }
          return name
        end
      end

      raise SyntaxError.new("Expected #{names.join(", ")}", @location.adjust(column: -max))
    ensure
      @buf.clear
    end

    private def expect(*chars : Char) : Char
      if char = @current_char
        if chars.includes?(char)
          next_char
          char
        else
          raise SyntaxError.new("Expected #{chars.map(&.inspect).join(", ")} but got #{current_char.inspect}", @location)
        end
      else
        raise SyntaxError.new("Expected #{chars.map(&.inspect).join(", ")} but reached end-of-file", @location)
      end
    end

    # https://www.w3.org/TR/xml11/#AVNormalize
    # https://www.w3.org/TR/xml11/#entproc
    #
    # - +include_pe+: set to true to recognize and include parameter entities (e.g. ENTITY %);
    # - +include_entity+: set to true to recognize and include entities (e.g. ENTITY);
    # - +normalize_s+: set to true to replace whitespaces with a single space (e.g. ATTVALUE);
    # - +merge_s+: set to true to group whitespaces (e.g. NMTOKENS);
    # - +process_entity+: set to true to process the replacement text of entities (e.g. CONTENT).
    #
    private def normalize_to(str, char, include_pe = false, include_entity = false, normalize_s = false, merge_s = false, process_entity = false)
      if char == '&'
        if next_char == '#'
          if next_char == 'x'
            next_char
            normalize_hexadecimal_char_ref(str)
          else
            normalize_decimal_char_ref(str)
          end
        elsif include_entity
          normalize_entity_ref(str, process_entity)
        else
          str << '&'
        end
      elsif include_pe && char == '%'
        normalize_pe_reference(str)
      elsif s?(char)
        skip_s if merge_s # e.g. NMTOKENS
        str << (normalize_s ? ' ' : char)
        next_char
      else
        str << char
        next_char
      end
    end

    private def normalize_hexadecimal_char_ref(str)
      i = 0
      value = 0

      loop do
        case char = current_char
        when ';'
          next_char
          str << value.chr
          return
        when '0'..'9'
          value = value * 16 + (char.ord - '0'.ord)
        when 'a'..'f'
          value = value * 16 + (char.ord - 'a'.ord + 10)
        when 'A'..'F'
          value = value * 16 + (char.ord - 'A'.ord + 10)
        else
          break
        end

        next_char
        @buf << char
      end

      if @options.well_formed?
        raise ValidationError.new("Invalid CharRef", @location.adjust(column: -i - 3))
      end

      str << '&' << '#' << 'x'
      str.write(@buf.to_slice)
    ensure
      @buf.clear
    end

    private def normalize_decimal_char_ref(str)
      i = 0
      value = 0

      loop do
        case char = current_char
        when ';'
          next_char
          str << value.chr
          return
        when '0'..'9'
          value = value * 10 + (char.ord - '0'.ord)
        else
          break
        end

        next_char
        @buf << char
      end

      if @options.well_formed?
        raise ValidationError.new("Invalid CharRef", @location.adjust(column: -i - 2))
      end

      str << '&' << '#'
      str.write(@buf.to_slice)
    ensure
      @buf.clear
    end

    # FIXME: prevent entity recursion (e1 => e2 => e1 => ...)
    # TODO: unknown, well formed, entities should yield an EntityRef token.
    private def normalize_entity_ref(str, process_entity = false)
      name = lex_name

      if current_char == ';'
        next_char

        if value = PREDEFINED_ENTITIES[name]?
          str << value
          return
        end

        if value = @entities.try(&.fetch(name) { nil })
          if process_entity
            replacement_text IO::Memory.new(value)
          else
            str << value
          end
          return
        end

        if process_entity && (system_id = @external_entities.try(&.fetch(name) { nil }))
          if include_path = self.include_path
            path = File.expand_path(File.join(include_path, system_id))
            if path.starts_with?(include_path) && File.exists?(path)
              replacement_text File.new(path)
              return
            end
          end
        end

        if @options.well_formed?
         raise ValidationError.new("Unknown entity", @location.adjust(column: -2 - name.size))
        end

        str << '&' << name << ';'
      elsif @options.well_formed?
        expect(';')
      else
        str << '&' << name
      end
    end

    # FIXME: prevent entity recursion (e1 => e2 => e1 => ...)
    private def normalize_pe_reference(str)
      name = lex_name

      if current_char == ';'
        next_char

        if value = @parameter_entities.try(&.fetch(name) { nil })
          str << value
          return
        end

        # if system_id = @external_parameter_entities.try(&.fetch(name) { nil })
        #   if include_path = self.include_path
        #     path = File.expand_path(File.join(include_path, system_id))
        #     if path.starts_with?(include_path) && File.exists?(path)
        #       replacement_text File.new(path)
        #       return
        #     end
        #   end
        # end

        if @options.well_formed?
          raise ValidationError.new("Unknown parameter entity", @location.adjust(column: -2 - name.size))
        end

        str << '%' << name << ';'
      elsif @options.well_formed?
        expect(';')
      else
        str << '%' << name
      end
    end

    # https://www.w3.org/TR/xml11/#sec-line-ends
    private def normalize_line_endings(current_char)
      if current_char == '\r'
        @io.read_char.tap do |char|
          @peek_char = char unless StaticArray['\n', '\u0085'].includes?(char)
        end
        current_char = '\n'
      elsif StaticArray['\u0085', '\u2028'].includes?(current_char)
        current_char = '\n'
      end
      current_char
    end

    private def peek_char : Char
      peek_char = nil

      while replacement = @replacement_texts.last?
        if peek_char = replacement[0].read_char
          break
        else
          @current_char = replacement[2]
          terminate_replacement(replacement)
        end
      end

      peek_char ||= @io.read_char

      if peek_char
        @peek_char = peek_char
      else
        raise SyntaxError.new("Reached end-of-file", @location)
      end
    end

    private def current_char : Char
      @current_char || raise SyntaxError.new("Reached end-of-file", @location)
    end

    private def next_char : Char?
      current_char = nil

      if current_char = @peek_char
        @peek_char = nil
      else
        while replacement = @replacement_texts.last?
          if current_char = replacement[0].read_char
            break
          else
            current_char = replacement[1]
            @peek_char = replacement[2]
            @replacement_texts.pop
            replacement[0].close if replacement[0].is_a?(File)
          end
        end
      end

      current_char ||= @io.read_char

      if current_char = normalize_line_endings(current_char)
        @location.update(current_char) if @replacement_texts.empty?
      end

      @current_char = current_char
    end

    private def replacement_text(io : IO)
      @replacement_texts << {io, @current_char, @peek_char}
      @peek_char = nil
      @current_char = io.read_char
    end


    # https://www.w3.org/TR/xml11/#NT-Char
    private def char?(char)
      StaticArray[
        '\u0001'..'\uD7FF',
        '\uE000'..'\uFFFD',
        '\u{10000}'..'\u{10FFFF}',
      ].any? { |c| c === char }
    end

    # https://www.w3.org/TR/xml11/#NT-RestrictedChar
    private def restricted_char?(char)
      StaticArray[
        '\u0001'..'\u0008',
        '\u000B'..'\u000C',
        '\u000E'..'\u001F',
        '\u007F'..'\u0084',
        '\u0086'..'\u009F',
      ].any? { |c| c === char }
    end

    # https://www.w3.org/TR/xml11/#NT-S
    private def s?(char)
      StaticArray[' ', '\t', '\n', '\r'].includes?(char)
    end

    # https://www.w3.org/TR/xml11/#NT-NameStartChar
    private def name_start_char?(char)
      StaticArray[
        'A'..'Z',
        'a'..'z',
        ':',
        '_',
        '\u00C0'..'\u00D6',
        '\u00D8'..'\u00F6',
        '\u00F8'..'\u02FF',
        '\u0370'..'\u037D',
        '\u037F'..'\u1FFF',
        '\u200C'..'\u200D',
        '\u2070'..'\u218F',
        '\u2C00'..'\u2FEF',
        '\u3001'..'\uD7FF',
        '\uF900'..'\uFDCF',
        '\uFDF0'..'\uFFFD',
        '\u{10000}'..'\u{EFFFF}',
      ].any? { |c| c === char }
    end

    # https://www.w3.org/TR/xml11/#NT-NameChar
    private def name_char?(char)
      StaticArray[
        'A'..'Z',
        'a'..'z',
        '0'..'9',
        ':',
        '-',
        '.',
        '_',
        '\u00B7',
        '\u00C0'..'\u00D6',
        '\u00D8'..'\u00F6',
        '\u00F8'..'\u02FF',
        '\u0300'..'\u036F',
        '\u0370'..'\u037D',
        '\u037F'..'\u1FFF',
        '\u203F'..'\u2040',
        '\u200C'..'\u200D',
        '\u2070'..'\u218F',
        '\u2C00'..'\u2FEF',
        '\u3001'..'\uD7FF',
        '\uF900'..'\uFDCF',
        '\uFDF0'..'\uFFFD',
        '\u{10000}'..'\u{EFFFF}',
      ].any? { |c| c === char }
    end

    private def pubid_char?(char)
      StaticArray[
        'a'..'z',
        'A'..'Z',
        '0'..'9',
        '-',
        '\'',
        '(',
        ')',
        '+',
        ',',
        '.',
        '/',
        ':',
        '=',
        '?',
        ';',
        '!',
        '*',
        '#',
        '@',
        '$',
        '_',
        '%',
        ' ',
        '\r',
        '\n',
      ].any? { |c| c === char }
    end
  end
end
