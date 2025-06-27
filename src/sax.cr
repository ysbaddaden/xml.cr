require "string_pool"
require "./char_reader"
require "./chars"
require "./element_decl"
require "./entity_decl"

class IO::Memory
  def bytesize=(@bytesize)
  end
end

module XML
  # Simple API for XML.
  class SAX
    include Chars

    def initialize(io : IO, @handlers : Handlers)
      @reader = CharReader.new(io)
      @buffer = IO::Memory.new
      @name_buffer = IO::Memory.new
      @string_pool = StringPool.new
      @entities = {} of String => EntityDecl
    end

    def parse : Nil
      @reader.autodetect_encoding!

      if @reader.consume?('<', '?', 'x', 'm', 'l')
        expect_whitespace
        parse_xml_decl
      end

      while @reader.current?
        skip_whitespace

        if @reader.consume?('<', '?')
          parse_processing_instruction
        elsif @reader.consume?('<', '!', 'D', 'O', 'C', 'T', 'Y', 'P', 'E')
          parse_doctype_decl
        elsif @reader.consume?('<', '!', '-', '-')
          parse_comment
        else
          break
        end
      end

      parse_content
    end

    def parse_xml_decl : Nil
      version, encoding, standalone = "1.0", "", true

      loop do
        if @reader.current? == '?'
          @reader.consume
          expect '>'
          break
        end

        attr_name = parse_name
        skip_whitespace
        expect '='
        skip_whitespace

        case attr_name
        when "version"
          # WF: value can only b "1.0", '1.0', "1.1" or '1.1'
          version = parse_attr_value
        when "encoding"
          encoding = parse_encoding
        when "standalone"
          # WF: expect "yes", 'yes', "no" or 'no'
          standalone = parse_attr_value.compare("yes", case_insensitive: true) == 0
        else
          recoverable_error("XMLDECL: unexpected attribute #{attr_name.inspect}")
        end

        skip_whitespace
      end

      @reader.set_encoding(encoding) unless encoding.blank?
      @reader.normalize_eol = :always if version == "1.1"

      @handlers.xml_decl(version, encoding, standalone)
    end

    def parse_doctype_decl : Nil
      intsubset = false

      expect_whitespace
      name = parse_name

      # expect_whitespace unless @reader.current? == '>'
      skip_whitespace
      public_id, system_id = parse_external_id
      skip_whitespace

      if @reader.current? == '['
        @reader.consume
        intsubset = true
      end

      @handlers.start_doctype_decl(name, system_id, public_id, intsubset)

      parse_intsubset if intsubset

      skip_whitespace
      expect '>'

      @handlers.end_doctype_decl
    end

    def parse_external_id(loose_system_id = false) : {String?, String?}
      if @reader.consume?('P', 'U', 'B', 'L', 'I', 'C')
        expect_whitespace
        public_id = parse_pubid_literal

        if loose_system_id
          skip_whitespace
          if @reader.current? == '"' || @reader.current? == '\''
            system_id = parse_system_literal
          end
        else
          expect_whitespace
          system_id = parse_system_literal
        end
      elsif @reader.consume?('S', 'Y', 'S', 'T', 'E', 'M')
        expect_whitespace
        system_id = parse_system_literal
      end
      {public_id, system_id}
    end

    def parse_system_literal : String
      quote = expect '"', '\''
      value = consume_until { |char| char == quote }
      expect quote
      value
    end

    def parse_pubid_literal : String
      quote = expect '"', '\''
      value = consume_until do |char|
        # WF: error unless pubid?(char)
        char == quote
      end
      expect quote
      value
    end

    def parse_intsubset : Nil
      loop do
        skip_whitespace

        case char = @reader.current?
        when '<'
          if @reader.consume?('<', '!', 'A', 'T', 'T', 'L', 'I', 'S', 'T')
            parse_attlist_decl
          elsif @reader.consume?('<', '!', 'E', 'L', 'E', 'M', 'E', 'N', 'T')
            parse_element_decl
          elsif @reader.consume?('<', '!', 'E', 'N', 'T', 'I', 'T', 'Y')
            parse_entity_decl
          elsif @reader.consume?('<', '!', 'N', 'O', 'T', 'A', 'T', 'I', 'O', 'N')
            parse_notation_decl
          elsif @reader.consume?('<', '?')
            parse_processing_instruction
          elsif @reader.consume?('<', '!', '-', '-')
            parse_comment
          end
        when '%'
          @reader.consume
          name = parse_name
          expect ';'
          # @handlers.entity_ref(name, parameter: true)
        when ']'
          @reader.consume
          break
        end
      end
    end

    def parse_attlist_decl : Nil
      expect_whitespace
      element_name = parse_name
      skip_whitespace

      until @reader.current? == '>'
        name = parse_name
        expect_whitespace
        type = parse_att_type
        expect_whitespace
        default = parse_default_decl
        @handlers.attlist_decl(element_name, name, type, default)
        skip_whitespace
      end
      expect '>'
    end

    def parse_att_type : Symbol | {Symbol, Array(String)}
      if @reader.consume?('C', 'D', 'A', 'T', 'A')
        :CDATA
      elsif @reader.consume?('I', 'D', 'R', 'E', 'F', 'S')
        :IDREF
      elsif @reader.consume?('I', 'D', 'R', 'E', 'F')
        :IDREF
      elsif @reader.consume?('I', 'D')
        :ID
      elsif @reader.consume?('E', 'N', 'T', 'I', 'T', 'I', 'E', 'S')
        :ENTITIES
      elsif @reader.consume?('E', 'N', 'T', 'I', 'T', 'Y')
        :ENTITY
      elsif @reader.consume?('N', 'M', 'T', 'O', 'K', 'E', 'N', 'S')
        :NMTOKENS
      elsif @reader.consume?('N', 'M', 'T', 'O', 'K', 'E', 'N')
        :NMTOKEN
      elsif @reader.consume?('N', 'O', 'T', 'A', 'T', 'I', 'O', 'N')
        expect_whitespace
        names = parse_list { parse_name }
        {:NOTATION, names}
      else
        nmtokens = parse_list { parse_nmtoken }
        {:ENUMERATION, nmtokens}
      end
    end

    private def parse_list(&) : Array(String)
      list = [] of String

      expect '('
      loop do
        skip_whitespace
        list << yield
        skip_whitespace
        break if expect(')', '|') == ')'
      end

      list
    end

    def parse_default_decl : Symbol | String
      if @reader.consume?('#', 'R', 'E', 'Q', 'U', 'I', 'R', 'E', 'D')
        return :REQUIRED
      end

      if @reader.consume?('#', 'I', 'M', 'P', 'L', 'I', 'E', 'D')
        return :IMPLIED
      end

      if @reader.consume?('#', 'F', 'I', 'X', 'E', 'D')
        expect_whitespace
      end
      parse_attr_value
    end

    def parse_element_decl : Nil
      expect_whitespace
      name = parse_name
      expect_whitespace
      model = parse_content_spec
      skip_whitespace
      expect '>'
      @handlers.element_decl(name, model)
    end

    def parse_content_spec
      if @reader.consume?('E', 'M', 'P', 'T', 'Y')
        return ElementDecl::Empty.new
      end

      if @reader.consume?('A', 'N', 'Y')
        return ElementDecl::Any.new
      end

      expect '('
      skip_whitespace

      if @reader.consume?('#', 'P', 'C', 'D', 'A', 'T', 'A')
        names = [] of String
        loop do
          skip_whitespace
          break if expect(')', '|') == ')'
          skip_whitespace
          names << parse_name
        end
        @reader.consume if @reader.current? == '*'
        ElementDecl::Mixed.new(names)
      else
        parse_children
      end
    end

    private def parse_children : ElementDecl::Children
      klass = nil
      children = [] of ElementDecl::Children

      loop do
        case @reader.current?
        when '('
          @reader.consume
          skip_whitespace
          child = parse_children
          child.quantifier = parse_quantifier
          children << child
          skip_whitespace
        else
          name = parse_name
          quantifier = parse_quantifier
          children << ElementDecl::Name.new(quantifier, name)
          skip_whitespace
        end

        case @reader.current?
        when ')'
          @reader.consume
          break
        when '|'
          fatal_error("Expected ',' but got '|'") if klass == ElementDecl::Seq
          @reader.consume
          klass = ElementDecl::Choice
        when ','
          @reader.consume
          fatal_error("Expected '|' but got ','") if klass == ElementDecl::Choice
          klass = ElementDecl::Seq
        end

        skip_whitespace
      end

      quantifier = parse_quantifier

      if klass == ElementDecl::Choice
        ElementDecl::Choice.new(quantifier, children)
      else
        ElementDecl::Seq.new(quantifier, children)
      end
    end

    private def parse_quantifier
      case @reader.current?
      when '?'
        @reader.consume
        ElementDecl::Quantifier::OPTIONAL
      when '*'
        @reader.consume
        ElementDecl::Quantifier::REPEATED
      when '+'
        @reader.consume
        ElementDecl::Quantifier::PLUS
      else
        ElementDecl::Quantifier::NONE
      end
    end

    def parse_entity_decl
      expect_whitespace

      if @reader.current? == '%'
        @reader.consume
        expect_whitespace
        parameter = true
      else
        parameter = false
      end
      name = parse_name
      expect_whitespace

      case @reader.current?
      when '"', '\''
        value = parse_entity_value(quote: @reader.consume)
      when 'P', 'S'
        public_id, system_id = parse_external_id
        skip_whitespace
        if @reader.consume?('N', 'D', 'A', 'T', 'A')
          expect_whitespace
          notation_id = parse_name
        end
      end

      skip_whitespace
      expect '>'

      entity =
        if value
          EntityDecl::Internal.new(name, parameter, value)
        elsif notation_id
          EntityDecl::Unparsed.new(name, public_id, system_id, notation_id)
        else
          EntityDecl::External.new(name, parameter, public_id, system_id)
        end

      @entities[name] = entity
      @handlers.entity_decl(entity)
    end

    def parse_entity_value(quote : Char) : String
      while char = @reader.current?
        case char
        when quote
          @reader.consume
          break
        when '&'
          if @reader.peek == '#'
            parse_character_reference
          else
            # do not process entity ref
            @reader.consume
            @buffer << char
          end
        when '%'
          @reader.consume
          name = parse_name
          expect ';'
          if (entity = @entities[name]?) && entity.is_a?(EntityDecl::Internal) && entity.parameter?
            @buffer << entity.value
          else
            @buffer << '%' << name << ';'
          end
        else
          @buffer << char
          @reader.consume
        end
      end
      value = @buffer.to_s
      @buffer.clear
      value
    end

    def parse_notation_decl
      expect_whitespace
      name = parse_name
      expect_whitespace
      public_id, system_id = parse_external_id(loose_system_id: true)
      skip_whitespace
      expect '>'
      @handlers.notation_decl(name, public_id, system_id)
    end

    def parse_processing_instruction : Nil
      target = parse_name
      if target.compare("xml", case_insensitive: true) == 0
        recoverable_error "PI: reserved prefix #{target.inspect}"
      end

      # expect_whitespace unless @reader.current == '?'
      skip_whitespace

      data = consume_until do |char|
        char == '?' && @reader.peek == '>'
      end
      @reader.consume # ?
      @reader.consume # >

      @handlers.processing_instruction(target, data)
    end

    def parse_comment : Nil
      # WF: double hyphens (--) isn't allowed within comments
      # WF: grammar doesn't allow ---> to end comment
      data = consume_until do |char|
        @reader.consume?('-', '-', '>')
      end
      @handlers.comment(data)
    end

    def parse_content : Nil
      while char = @reader.current?
        if char == '<'
          if @reader.consume?('<', '!', '-', '-')
            parse_comment
          elsif @reader.consume?('<', '!', '[', 'C', 'D', 'A', 'T', 'A', '[')
            parse_cdata
          elsif @reader.consume?('<', '?')
            parse_processing_instruction
          elsif @reader.consume?('<', '/')
            name = parse_name
            skip_whitespace
            expect '>'
            @handlers.end_element(name)
          else
            @reader.consume # '<'
            name = parse_name
            attributes = parse_attributes
            if @reader.consume?('/', '>')
              @handlers.empty_element(name, attributes)
            else
              expect '>'
              @handlers.start_element(name, attributes)
            end
          end
        else
          parse_character_data
        end
      end
    end

    def parse_character_data : Nil
      while char = @reader.current?
        case char
        when '<'
          break
        when '&'
          if @reader.peek == '#'
            parse_character_reference
          else
            parse_entity_reference do |name|
              data = @buffer.to_s
              @buffer.clear
              @handlers.character_data(data)
              @handlers.entity_reference(name)
            end
          end
        else
          @buffer << char
          @reader.consume
        end
      end

      data = @buffer.to_s
      @buffer.clear

      @handlers.character_data(data)
    end

    def parse_character_reference : Nil
      # keep current buffer pos so we can "rewind" on invalid syntax
      pos = @buffer.pos
      bytesize = @buffer.bytesize
      value = 0

      @buffer << @reader.consume # '&'
      @buffer << @reader.consume # '#'

      if @reader.current? == 'x'
        @buffer << @reader.consume

        while char = @reader.consume
          @buffer << char

          case char
          when '0'..'9'
            value = value * 16 + (char.ord - '0'.ord)
          when 'a'..'f'
            value = value * 16 + (char.ord - 'a'.ord + 10)
          when 'A'..'F'
            value = value * 16 + (char.ord - 'A'.ord + 10)
          when ';'
            @buffer.pos = pos
            @buffer.bytesize = bytesize
            @buffer << value.chr
            return
          else
            break
          end
        end
      else
        while char = @reader.consume
          @buffer << char

          case char
          when '0'..'9'
            value = value * 10 + (char.ord - '0'.ord)
          when ';'
            @buffer.pos = pos
            @buffer.bytesize = bytesize
            @buffer << value.chr
            return
          else
            break
          end
        end
      end

      recoverable_error "Invalid character reference"
    end

    def parse_entity_reference(&) : Nil
      @reader.consume # '&'

      name = parse_name

      if @reader.current? == ';'
        @reader.consume

        case name
        when "lt" then @buffer << '<'
        when "gt" then @buffer << '>'
        when "amp" then @buffer << '&'
        when "apos" then @buffer << '\''
        when "quot" then @buffer << '"'
        else
          if (entity = @entities[name]?) && entity.is_a?(EntityDecl::Internal)
            # TODO: parse entity value as self contained XML
            @buffer << entity.value
          else
            yield name
          end
        end
      else
        @buffer << '&'
        @buffer << name
        recoverable_error "Invalid entity reference"
      end
    end

    def parse_cdata : Nil
      data = consume_until { @reader.consume?(']', ']', '>') }
      @handlers.cdata_section(data)
    end

    def parse_name : String
      char = @reader.current
      fatal_error("Invalid name start char #{char.inspect}") unless name_start?(char)

      @name_buffer << char
      @reader.consume

      while (char = @reader.current?) && name?(char)
        @name_buffer << char
        @reader.consume
      end

      @string_pool.get(@name_buffer.to_slice)
    ensure
      @name_buffer.clear
    end

    def parse_nmtoken : String
      while (char = @reader.current?) && name?(char)
        @name_buffer << char
        @reader.consume
      end
      @string_pool.get(@name_buffer.to_slice)
    ensure
      @name_buffer.clear
    end

    def parse_attributes : Array({String, String})
      attributes = [] of {String, String}

      loop do
        skip_whitespace

        case @reader.current?
        when '>'
          break
        when '/'
          break if @reader.peek == '>'
        end

        name = parse_name
        skip_whitespace
        expect '='
        skip_whitespace
        value = parse_attr_value
        attributes << {name, value}
      end

      attributes
    end

    def parse_attr_value : String
      quote = expect '"', '\''

      while char = @reader.current?
        case char
        when quote
          break
        when '&'
          if @reader.peek == '#'
            parse_character_reference
          else
            parse_entity_reference do |name|
              @buffer << '&'
              @buffer << name
              @buffer << ';'
            end
          end
        else
          @buffer << char
          @reader.consume
        end
      end

      value = consume_until { |char| char == quote }
      @reader.consume # quote
      value
    ensure
      @buffer.clear
    end

    def parse_encoding : String
      quote = expect '"', '\''
      # WF: must start with `encname_start?` and continue with `encname?`
      value = consume_until { |char| char == quote }
      @reader.consume # quote
      value
    end

    def skip_whitespace : Nil
      while (char = @reader.current?) && s?(char)
        @reader.consume
      end
    end

    def expect_whitespace : Nil
      if s?(@reader.current)
        while (char = @reader.current?) && s?(char)
          @reader.consume
        end
      else
        fatal_error("Expected whitespace but got #{@reader.current.inspect}")
      end
    end

    private def expect(*chars : Char) : Char
      if chars.includes?(@reader.current)
        @reader.consume
      else
        fatal_error("Expected any of #{chars.inspect} but got #{@reader.current.inspect}")
      end
    end

    private def consume_until(& : Char -> Bool) : String
      until yield(char = @reader.current)
        @buffer << char
        @reader.consume
      end
      @buffer.to_s
    ensure
      @buffer.clear
    end

    private def recoverable_error(message : String)
      @handlers.error(message, @reader.location)
    end

    private def fatal_error(message : String)
      raise Error.new(message, @reader.location)
    end

    def location : Location
      @reader.location
    end

    class Handlers
      def xml_decl(version : String, encoding : String, standalone : Bool) : Nil
      end

      def start_doctype_decl(name : String, system_id : String?, public_id : String?, intsubset : Bool)
      end

      def end_doctype_decl : Nil
      end

      def attlist_decl(element_name : String, attribute_name : String, type : Symbol | {Symbol, Array(String)}, default : Symbol | String) : Nil
      end

      def element_decl(name : String, content : ElementDecl) : Nil
      end

      def entity_decl(entity : EntityDecl) : Nil
      end

      def notation_decl(name : String, public_id : String?, system_id : String?) : Nil
      end

      def processing_instruction(target : String, data : String) : Nil
      end

      def start_element(name : String, attributes : Array({String, String})) : Nil
      end

      def end_element(name : String) : Nil
      end

      def empty_element(name : String, attributes : Array({String, String})) : Nil
        start_element(name, attributes)
        end_element(name)
      end

      def character_data(data : String) : Nil
      end

      def entity_reference(name : String) : Nil
      end

      def comment(data : String) : Nil
      end

      def cdata_section(data : String) : Nil
      end

      def error(message : String, location : Location)
        raise Error.new(message, location)
      end
    end
  end
end
