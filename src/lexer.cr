require "io/memory"
require "string_pool"
require "./lexer/error"
require "./lexer/ast"
# require "./lexer/entities"

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
      "lt"   => "<",
      "gt"   => ">",
      "amp"  => "&",
      "apos" => "'",
      "quot" => "\"",
    }

    def self.new(string : String, **args)
      new(IO::Memory.new(string), **args)
    end

    @io : IO
    @replacement_texts : Array({IO, String, Char?})
    @current_char : Char?
    @peek_char : Char?
    @peek_peek_char : Char?
    getter options : Options
    getter location : Location

    # TODO: option to skip over comments (don't allocate as strings)
    def initialize(@io : IO, @options : Options = :none)
      @buf = IO::Memory.new
      @pool = StringPool.new
      @location = Location.new(1, 0)
      @replacement_texts = Array({IO, String, Char?}).new
      autodetect_encoding!
      next_char
    end

    def set_encoding(encoding : String) : Nil
      @io.set_encoding(encoding)
    end

    # Attempts to autodetect the file encoding using the Byte Order Mark (BOM)
    # for unicode (UTF-8, UCS-4LE, UCS-4BE, UTF-16) or using the first few
    # bytes. Sets the encoding on the IO when an encoding is detected.
    #
    # WARNING: requires the IO to support `#seek`!
    private def autodetect_encoding! : Nil
      bytes = uninitialized UInt8[4]
      @io.read_fully?(bytes.to_slice)

      # Byte Order Mark (BOM)

      case bytes
      when UInt8.static_array(0x00, 0x00, 0xFE, 0xFF)
        @io.set_encoding("UCS-4BE")
        return
      when UInt8.static_array(0xFF, 0xFE, 0x00, 0x00)
        @io.set_encoding("UCS-4LE")
        return
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
      when UInt8.static_array(0x00, 0x3C, 0x00, 0x3F)
        @io.set_encoding("UTF-16BE")
      when UInt8.static_array(0x3C, 0x00, 0x3F, 0x00)
        @io.set_encoding("UTF-16LE")
      when UInt8.static_array(0x3C, 0x3F, 0x78, 0x6D)
        # ASCII, ISO 646, UTF-8: we can keep reading with the default UTF-8
      end

      @io.seek(0, IO::Seek::Set)
    end

    def tokenize(& : Token ->) : Nil
      while token = next_token?
        yield token

        case token
        when XMLDecl
          while tok = next_xmldecl_token?
            yield tok
          end
          skip_s
        when Doctype
          while tok = next_dtd_token?
            yield tok
          end
        when STag
          while tok = next_attribute?(token.name)
            yield tok
            break if tok.is_a?(ETag)
          end
        end
      end
    end

    def next_token?(skip_s = false) : Token?
      self.skip_s if skip_s
      start_location = @location

      case @current_char
      when '<'
        case next_char
        when '/'
          next_char
          name = lex_name
          self.skip_s
          expect('>')
          ETag.new(name, start_location, @location)
        when '?'
          next_char
          name = lex_name
          if name == "xml"
            XMLDecl.new(start_location, @location)
          else
            # todo: well-formed: name !~ /xml/i
            data = lex_pi
            PI.new(name, data, start_location, @location)
          end
        when '!'
          case next_char
          when '['
            next_char
            expect("CDATA")
            expect('[')
            data = lex_cdata
            CDATA.new(data, start_location, @location)
          when '-'
            next_char
            expect('-')
            data = lex_comment
            Comment.new(data, start_location, @location)
          else
            expect("DOCTYPE")
            expect_s
            lex_doctype(start_location)
          end
        else
          name = lex_name
          STag.new(name, start_location, @location)
        end
      when '&'
        if peek_char == '#'
          data = lex_text
          Text.new(data, start_location, @location)
        else
          next_char
          name = lex_name
          expect(';') # TODO: recoverable
          EntityRef.new(name, start_location, @location)
        end
      #when '%'
      #  next_char
      #  name = lex_name
      #  expect(';') # TODO: recoverable
      #  PEReference.new(name, start_location, @location)
      when nil
        # reached EOF
      else
        data = lex_text
        Text.new(data, start_location, @location)
      end
    end

    def next_xmldecl_token? : Token?
      skip_s

      if current_char == '?'
        next_char
        expect('>')
        nil
      else
        start_location = @location
        name, value = lex_attribute
        Attribute.new(name, value, start_location, @location)
      end
    end

    def doctype_intsubset? : Bool
      skip_s

      if current_char == '['
        next_char
        true
      else
        expect('>')
        false
      end
    end

    def next_dtd_token? : Token?
      skip_s
      start_location = @location

      case expect('<', ';', '%', ']')
      when '<'
        case expect('!', '?')
        when '!'
          if current_char == '-'
            expect('-')
            data = lex_comment
            Comment.new(data, start_location, @location)
          else
            case expect("ATTLIST", "ELEMENT", "ENTITY", "NOTATION")
            when "ATTLIST"
              expect_s
              lex_attlistdecl(start_location)
            when "ELEMENT"
              expect_s
              lex_elementdecl(start_location)
            when "ENTITY"
              expect_s
              lex_entitydecl(start_location)
            when "NOTATION"
              expect_s
              lex_notationdecl(start_location)
            end
          end
        when '?'
          name = lex_name
          # todo: well-formed: name !~ /xml/i
          data = lex_pi
          PI.new(name, data, start_location, @location)
        end
      when '%'
        name = lex_name
        expect(';')
        PEReference.new(name, start_location, @location)
      when ']'
        # done
        skip_s
        expect('>')
        nil
      end
    end

    private def lex_doctype(start_location)
      name = lex_name
      skip_s
      unless current_char == '[' || current_char == '>'
        public_id, system_id = lex_external_id
        skip_s
      end
      Doctype.new(name, public_id, system_id, start_location, @location)
    end

    # TODO: AttDef is optional (as per the grammar)
    private def lex_attlistdecl(start_location) : AttlistDecl
      dtname = lex_name
      defs = [] of DOM::AttDef

      loop do
        expect_s if s?(current_char)
        break if current_char == '>'

        name = lex_name
        expect_s

        case current_char
        when '('
          type = "ENUMERATION"
          enumeration = lex_enumeratedtype { lex_nmtoken }
        when '>'
          break
        else
          case type = expect("CDATA", "ID", "ENTITY", "ENTITIES", "NMTOKEN", "NOTATION")
          when "ID"
            if current_char == 'R'
              expect("REF")
              if current_char == 'S'
                next_char
                type = "IDREFS"
              else
                type = "IDREF"
              end
            end
          when "NMTOKEN"
            if current_char == 'S'
              expect('S')
              type = "NMTOKENS"
            end
          when "NOTATION"
            expect_s
            enumeration = lex_enumeratedtype { lex_name }
          end
        end

        expect_s

        if current_char == '#'
          next_char
          case default = expect("REQUIRED", "IMPLIED", "FIXED")
          when "FIXED"
            expect_s
            value = lex_attvalue
          end
        else
          value = lex_attvalue
        end

        defs << DOM::AttDef.new(name, type, enumeration, default, value)
      end

      skip_s
      expect '>'
      AttlistDecl.new(dtname, defs, start_location, @location)
    end

    private def lex_enumeratedtype(& : -> String) : Array(String)
      expect('(')
      skip_s

      enumeration = [] of String
      loop do
        skip_s
        enumeration << yield
        skip_s

        case expect('|', ')')
        when '|'
          next
        when ')'
          break
        end
      end
      enumeration
    end

    private def lex_elementdecl(start_location) : ElementDecl
      name = lex_name
      expect_s

      content = String.build do |str|
        until (char = current_char) == '>'
          str << char
          next_char
        end
      end.strip
      next_char # >

      ElementDecl.new(name, content, start_location, @location)
    end

    private def lex_entitydecl(start_location) : EntityDecl
      if parameter = (current_char == '%')
        next_char
        expect_s
      end

      name = lex_name
      expect_s

      if quote?(current_char)
        value = lex_entity_value
      else
        public_id, system_id = lex_external_id
        expect_s unless current_char == '>'

        unless current_char == '>'
          expect("NDATA")
          expect_s
          notation_id = lex_name
        end
      end

      skip_s
      expect('>')
      EntityDecl.new(parameter, name, value, public_id, system_id, notation_id, start_location, @location)
    end

    private def lex_notationdecl(start_location) : NotationDecl
      name = lex_name
      expect_s

      case expect("PUBLIC", "SYSTEM")
      when "PUBLIC"
        expect_s
        public_id = lex_pubid_literal
        expect_s if s?(current_char)
        system_id = lex_system_literal if quote?(current_char)
      when "SYSTEM"
        expect_s
        system_id = lex_system_literal
      end

      skip_s
      expect('>')
      NotationDecl.new(name, public_id, system_id, start_location, @location)
    end

    def next_attribute?(name : String) : Token?
      skip_s

      case current_char
      when '>'
        next_char
        nil
      when '/'
        start_location = @location
        next_char
        expect('>')
        ETag.new(name, start_location, @location)
      else
        start_location = @location
        name, value = lex_attribute
        Attribute.new(name, value, start_location, @location)
      end
    end

    # OPTIMIZE: fast-mode: accept anything but whitespace, '>', '"', '\'' or ';'
    def lex_name : String
      if (char = @current_char) && name_start_char?(char)
        @buf << char
        next_char
      else
        raise SyntaxError.new("Expected NameStartChar", @location)
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
    def lex_nmtoken : String
      while (char = @current_char) && name_char?(char)
        @buf << char
        next_char
      end
      @pool.get(@buf.to_slice)
    ensure
      @buf.clear
    end

    def lex_attribute : {String, String?}
      name = lex_name
      skip_s

      if current_char == '='
        next_char
        skip_s

        # TODO: recover: allow missing quotes (end attvalue at whitespace, '>',
        # '/>', '?>', '"' or '\'')
        quote = expect('"', '\'')
        value = lex_attvalue(quote)
      elsif @options.well_formed?
        expect('=')
      end

      {name, value}
    end

    private def lex_attvalue
      lex_attvalue(expect('"', '\''))
    end

    # TODO: yield on EntityRef
    # TODO: option to skip trailing/ending S (NMTOKENS)
    # TODO: option to merge S (NMTOKENS)
    private def lex_attvalue(quote)
      String.build do |str|
        loop do
          case char = current_char
          when quote
            next_char
            break
          when '<'
            if @options.well_formed?
              next_char
              raise SyntaxError.new("Attribute value cannot contain a literal '<'", @location)
            end
          when '&'
            if peek_char == '#'
              normalize_char_ref(str)
            else
              # TODO: process EntityRef
              str << '&'
              next_char
            end
          else
            # normalize space
            str << (s?(char) ? ' ' : char)
            next_char
          end
        end
      end
    end

    # TODO: yield on PEReference
    def lex_entity_value : String
      quote = expect('"', '\'')

      String.build do |str|
        loop do
          case char = current_char
          when quote
            next_char
            break
          when '&'
            if peek_char == '#'
              normalize_char_ref(str)
            else
              str << '&'
              next_char
            end
          when '%'
            # TODO: process PEReference
            str << '%'
            next_char
          else
            # normalize space
            str << (s?(char) ? ' ' : char)
            next_char
          end
        end
      end
    end

    def lex_external_id : {String?, String?}
      case expect("SYSTEM", "PUBLIC")
      when "PUBLIC"
        expect_s
        public_id = lex_pubid_literal
        expect_s
        system_id = lex_system_literal
      when "SYSTEM"
        expect_s
        system_id = lex_system_literal
      end
      {public_id, system_id}
    end

    def lex_system_literal : String
      quote = expect('"', '\'')

      String.build do |str|
        until (char = current_char) == quote
          str << char
          next_char
        end
        next_char
      end
    end

    def lex_pubid_literal : String
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

    def lex_pi : String
      skip_s
      String.build do |str|
        loop do
          if current_char == '?'
            if next_char == '>'
              next_char
              break
            end
            str << '?'
          else
            if @options.well_formed? && restricted_char?(current_char)
              raise SyntaxError.new("Invalid Char", @location)
            end
            str << current_char
            next_char
          end
        end
      end
    end

    def skip_text : Nil
      consume_text { }
    end

    def lex_text : String
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

            if restricted_char?(char)
              raise SyntaxError.new("Invalid Char in data", @location)
            end
          end

          if char == '&'
            if peek_char == '#'
              normalize_char_ref(str)
              next
            else
              # entityref: abort
              break
            end
          end

          str << char
          next_char
        end
      end
    end

    def skip_comment : Nil
      consume_comment { }
    end

    def lex_comment : String
      String.build do |str|
        consume_comment { |char| str << char }
      end
    end

    private def consume_comment(&)
      loop do
        char = current_char

        if char == '-'
          if next_char == '-'
            if peek_char == '>'
              next_char # -
              next_char # >
              break
            elsif @options.well_formed?
              raise ValidationError.new("Double hyphen within comment", @location.adjust(column: -2))
            end
          end

          yield '-'
          next
        end

        if @options.well_formed? && restricted_char?(char)
          raise ValidationError.new("Invalid char in comment", @location)
        end

        yield char
        next_char
      end
    end

    def lex_cdata : String
      String.build do |str|
        loop do
          char = current_char

          if char == ']'
            if next_char == ']'
              if peek_char == '>'
                next_char # ]
                next_char # >
                break
              end
            end

            str << ']'
            next
          end

          if @options.well_formed? && !char?(char)
            raise ValidationError.new("Invalid char in cdata", @location)
          end

          str << char
          next_char
        end
      end
    end

    def expect_s : Nil
      unless s?(@current_char)
        raise SyntaxError.new("Expected space", @location)
      end
      skip_s
    end

    def skip_s : Nil
      while (char = @current_char) && s?(char)
        next_char
      end
    end

    private def expect(*names : String) : String?
      location = @location
      min = names.min_by(&.size).size
      max = names.max_by(&.size).size

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

      raise SyntaxError.new("Expected #{names.join(", ")}", location)
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
        raise SyntaxError.new("Expected #{chars.map(&.inspect).join(", ")} but reached EOF", @location)
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
    #private def normalize_to(str, char, include_pe = false, include_entity = false, normalize_s = false, merge_s = false, &)
    #  if char == '&'
    #    if next_char == '#'
    #      if next_char == 'x'
    #        next_char
    #        normalize_hexadecimal_char_ref(str)
    #      else
    #        normalize_decimal_char_ref(str)
    #      end
    #    else
    #      normalize_entity_ref(str) { |entity_ref| yield entity_ref }
    #    end
    #  elsif include_pe && char == '%'
    #    normalize_pe_reference(str)
    #  elsif s?(char)
    #    skip_s if merge_s
    #    str << (normalize_s ? ' ' : char)
    #    next_char
    #  else
    #    str << char
    #    next_char
    #  end
    #end

    private def normalize_char_ref(str)
      expect('&')
      expect('#')

      if current_char == 'x'
        next_char
        normalize_hexadecimal_char_ref(str)
      else
        normalize_decimal_char_ref(str)
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

    # NOTE: DEPRECATED
    private def normalize_entity_ref(str, & : EntityRef ->)
      start_location = @location.adjust(column: -1)
      name = lex_name

      if current_char == ';'
        next_char

        if value = PREDEFINED_ENTITIES[name]?
          str << value
          return
        else
          yield EntityRef.new(name, start_location, @location)
        end

        # if @options.well_formed?
        #   raise ValidationError.new("Unknown entity", @location.adjust(column: -1 - name.size))
        # end
      elsif @options.well_formed?
        expect(';')
      else
        str << '&' << name
      end
    end

    # NOTE: DEPRECATED
    private def normalize_pe_reference(str)
      name = lex_name

      if current_char == ';'
        next_char

        # if value = @parameter_entities.try(&.fetch(name) { nil })
        #   str << value
        #   return
        # end

        # if @options.well_formed?
        #   raise ValidationError.new("Unknown parameter entity", @location.adjust(column: -2 - name.size))
        # end

        str << '%' << name << ';'
      elsif @options.well_formed?
        expect(';')
      else
        str << '%' << name
      end
    end

    private def peek_char : Char?
      if char = @peek_char
        char
      elsif char = @peek_peek_char
        @peek_peek_char = nil
        @peek_char = char
      elsif char = @io.read_char
        char, @peek_peek_char = normalize_line_endings(char)
        @peek_char = char
      else
        raise SyntaxError.new("Reached EOF", @location)
      end
    end

    private def current_char : Char
      @current_char || raise SyntaxError.new("Reached EOF", @location)
    end

    private def next_char : Char?
      if char = @peek_char
        @peek_char, @peek_peek_char = @peek_peek_char, nil
      else
        char = @io.read_char
      end

      char, @peek_char = normalize_line_endings(char)
      @location.update(char) if char

      @current_char = char
    end

    # https://www.w3.org/TR/xml11/#sec-line-ends
    private def normalize_line_endings(current_char)
      if current_char == '\r'
        peek_char = @io.read_char
        peek_char = nil if StaticArray['\n', '\u0085'].includes?(peek_char)
        current_char = '\n'
      elsif StaticArray['\u0085', '\u2028'].includes?(current_char)
        current_char = '\n'
      end
      {current_char, peek_char}
    end

    # https://www.w3.org/TR/xml11/#NT-S
    private def s?(char)
      StaticArray[' ', '\t', '\n', '\r'].includes?(char)
    end

    private def quote?(char)
      char == '"' || char == '\''
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
        '\u0086'..'\u009F',
        '\u000E'..'\u001F',
        '\u007F'..'\u0084',
      ].any? { |c| c === char }
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
