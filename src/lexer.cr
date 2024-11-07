require "io/memory"
require "string_pool"
require "./lexer/error"
require "./lexer/ast"

module CRXML
  @[Flags]
  enum Validation
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
  class Lexer
    PREDEFINED_ENTITIES = {
      "lt" => '<',
      "gt" => '>',
      "amp" => '&',
      "apos" => '\'',
      "quot" => '"',
    }

    def self.new(string : String, **args)
      new(IO::Memory.new(string), **args)
    end

    @io : IO
    # @input : String?
    # @input_index : Int32?
    @current_char : Char?
    @peek_char : Char?
    # @saved_peek_char : Char?
    getter validate : Validation

    def initialize(@io : IO, @validate : Validation = :none)
      @buf = IO::Memory.new
      @pool = StringPool.new
      @location = Location.new(1, 0)
      next_char
    end

    private def entities
      @entities ||= Hash(String, String).new
    end

    private def parameter_entities
      @parameter_entities ||= Hash(String, String).new
    end

    # TODO: DOCTYPE
    # TODO: ATTLIST
    # TODO: ELEMENT
    # TODO: ENTITY
    # TODO: NOTATION
    # TODO: check presence of UTF BOM
    def tokenize(&)
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
              #case expect("ATTLIST", "DOCTYPE", "ENTITY", "ELEMENT", "NOTATION")
              #when "ATTLIST"
              #  raise NotImplementedError.new("Unsupported <!ATTLIST>")
              #when "DOCTYPE"
              #  raise NotImplementedError.new("Unsupported <!DOCTYPE>")
              #when "ENTITY"
              #  raise NotImplementedError.new("Unsupported <!ENTITY>")
              #when "ELEMENT"
              #  raise NotImplementedError.new("Unsupported <!ELEMENT>")
              #when "NOTATION"
              #  raise NotImplementedError.new("Unsupported <!NOTATION>")
              #else
                raise NotImplementedError.new("unsupported <! markup")
              #end
            end
          when '?'
            next_char
            name = lex_name

            if name == "xml"
              yield XmlDecl.new(start_location, @location)

              loop do
                skip_s
                if current_char == '?'
                  next_char
                  expect('>')
                  break
                else
                  name, value = lex_attribute
                  yield Attribute.new(name, value, start_location, @location)
                end
              end
            else
              # TODO: well-formed: reject name =~ /xml/i
              skip_s
              start_location = @location
              content = lex_pi
              yield PI.new(name, content, start_location, @location)
            end
          else
            name = lex_name
            yield STag.new(name, start_location, @location)

            loop do
              skip_s

              case current_char
              when '>'
                next_char
                break
              when '/'
                next_char
                expect '>'
                yield ETag.new(name, start_location, @location)
                break
              else
                name, value = lex_attribute
                yield Attribute.new(name, value, start_location, @location)
              end
            end
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

    private def skip_s
      while (char = @current_char) && s?(char)
        next_char
      end
    end

    private def lex_pi
      String.build do |str|
        loop do
          if current_char == '?'
            if next_char == '>'
              next_char
              break
            end
            str << '<'
          end
          str << current_char
          next_char
        end
      end
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
      end

      {name, value || ""}
    end

    # TODO: if attribute type is NMTOKENS then merge all whitespaces & skip leading/trailing whitespace
    # TODO: well-formed: reject '<'
    private def lex_attvalue(quote)
      String.build do |str|
        until (char = current_char) == quote
          normalize_to(str, char, normalize_s: true)
        end
        next_char
      end
    end

    private def lex_text
      String.build do |str|
        while (char = @current_char) && char != '<'
          normalize_to(str, char, process_entity: true)
        end
      end
    end

    private def lex_comment
      String.build do |str|
        loop do
          if current_char == '-'
            if next_char == '-'
              if next_char == '>'
                next_char
                break
              elsif @validate.well_formed?
                raise ValidationError.new("'--' can't appear inside comments", @location.adjust(column: -2))
              end
              str << '-'
            end
            str << '-'
          end

          if @validate.well_formed? && !char?(current_char)
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
              if next_char == '>'
                next_char
                break
              end
              str << ']'
            end
            str << ']'
          end

          if @validate.well_formed? && !char?(current_char)
            raise ValidationError.new("Invalid XML char #{current_char.inspect}", @location)
          end

          str << current_char
          next_char
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
    # - +include_pe+: set to true to recognize and include parameter entities (e.g. ENTITY);
    # - +normalize_s+: set to true to replace whitespaces with a single space (e.g. ATTVALUE);
    # - +merge_s+: set to true to group whitespaces (e.g. NMTOKENS);
    # - +process_entity+: set to true to process the replacement text of entities (e.g. CONTENT).
    private def normalize_to(str, char, include_pe = false, normalize_s = false, merge_s = false, process_entity = false)
      if char == '&'
        if next_char == '#'
          if next_char == 'x'
            next_char
            normalize_hexadecimal_char_ref(str)
          else
            normalize_decimal_char_ref(str)
          end
        else
          normalize_entity_ref(str, process_entity)
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
      buffer = uninitialized Char[6]
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
        buffer[i] = char
        break if (i += 1) > buffer.size
      end

      if @validate.well_formed?
        raise ValidationError.new("Invalid CharRef", @location.adjust(column: -i - 3))
      end

      str << '&' << '#' << 'x'
      i.times { |j| str << buffer.to_unsafe[j] }
    end

    private def normalize_decimal_char_ref(str)
      buffer = uninitialized Char[7]
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
        buffer[i] = char
        break if (i += 1) > buffer.size
      end

      if @validate.well_formed?
        raise ValidationError.new("Invalid CharRef", @location.adjust(-i - 2))
      end

      str << '&' << '#'
      i.times { |j| str << buffer.to_unsafe[j] }
    end

    # FIXME: the replacement text must be treated as the actual input when
    # +process_entity+ is true!
    private def normalize_entity_ref(str, process_entity = false)
      name = lex_name

      if current_char == ';'
        next_char

        if value = PREDEFINED_ENTITIES[name]?
          str << value
          return
        end

        if value = @entities.try(&.fetch(name) { nil })
          # if process_entity
          #   self.input = value
          # else
            str << value
          # end
          return
        end

        if @validate.well_formed?
          raise ValidationError.new("Unknown entity", @location.adjust(column: -2 - name.size))
        end

        str << '&' << name << ';'
      elsif @validate.well_formed?
        expect(';')
      else
        str << '&' << name
      end
    end

    private def normalize_pe_reference(str)
      name = lex_name

      if current_char == ';'
        next_char

        if value = @parameter_entities.try(&.fetch(name) { nil })
          str << value
          return
        end

        if @validate.well_formed?
          raise ValidationError.new("Unknown parameter entity", @location.adjust(column: -2 - name.size))
        end

        str << '%' << name << ';'
      elsif @validate.well_formed?
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

    private def current_char : Char
      @current_char || raise SyntaxError.new("Reached end-of-file", @location)
    end

    # TODO: process @input when present
    private def next_char : Char?
      current_char =
        if char = @peek_char
          @peek_char = nil
          char
        # elsif input = @input
        #   if (index = @input_index += 1) == @input.size
        #     input, input_index = nil, 0
        #     peek_char, @saved_peek_char = @saved_peek_char, nil
        #     peek_char || @io.read_char
        #   else
        #     input[index]
        #   end
        else
          @io.read_char
        end

      if current_char = normalize_line_endings(current_char)
        @location.update(current_char) # unless @input
      end

      @current_char = current_char
    end

    # private def input=(input : String)
    #   return unless input.empty?
    #   @input = input
    #   @input_index = 0
    #   @current_char = @input[0]
    #   @saved_peek_char = @peek_char
    # end

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
  end
end
