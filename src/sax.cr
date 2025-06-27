require "string_pool"
require "./char_reader"
require "./chars"

class IO::Memory
  def bytesize=(@bytesize)
  end
end

module XML
  abstract class ElementDecl
    enum Quantifier
      NONE = 0
      OPTIONAL
      REPEATED
      PLUS

      protected def to_char? : Char?
        case self
        when OPTIONAL then '?'
        when REPEATED then '*'
        when PLUS then '+'
        end
      end
    end

    class Empty < ElementDecl
      # :nodoc:
      def inspect(io : IO) : Nil
        io << "EMPTY"
      end
    end

    class Any < ElementDecl
      # :nodoc:
      def inspect(io : IO) : Nil
        io << "ANY"
      end
    end

    class Mixed < ElementDecl
      getter names : Array(String)

      def initialize(@names)
      end

      # :nodoc:
      def inspect(io : IO) : Nil
        io << "MIXED"
        return if @names.empty?

        io << '('
        @names.join(io, '|')
        io << ')'
      end
    end

    abstract class Children < ElementDecl
      property quantifier : Quantifier

      private def initialize(@quantifier)
      end
    end

    class Name < Children
      property name : String

      def initialize(@quantifier, @name)
      end

      # :nodoc:
      def inspect(io : IO) : Nil
        io << @name
        io << @quantifier.to_char?
      end
    end

    class Choice < Children
      getter children : Array(Name | Choice | Seq)

      def initialize(@quantifier, @children)
      end

      # :nodoc:
      def inspect(io : IO) : Nil
        io << "CHOICE("
        @children.each_with_index do |child, index|
          io << ", " unless index == 0
          child.inspect(io)
        end
        io << ')'
        io << @quantifier.to_char?
      end
    end

    class Seq < Children
      getter children : Array(Name | Choice | Seq)

      def initialize(@quantifier, @children)
      end

      # :nodoc:
      def inspect(io : IO) : Nil
        io << "SEQ("
        @children.each_with_index do |child, index|
          io << ", " unless index == 0
          child.inspect(io)
        end
        io << ')'
        io << @quantifier.to_char?
      end
    end
  end

  # Simple API for XML.
  class SAX
    include Chars

    def initialize(io : IO, @handlers : Handlers)
      @chars = CharReader.new(io)
      @buffer = IO::Memory.new
      @name_buffer = IO::Memory.new
      @string_pool = StringPool.new
    end

    def parse : Nil
      @chars.autodetect_encoding!

      if @chars.consume?('<', '?', 'x', 'm', 'l')
        expect_whitespace
        parse_xml_decl
      end

      while @chars.current?
        skip_whitespace

        if @chars.consume?('<', '?')
          parse_processing_instruction
        elsif @chars.consume?('<', '!', 'D', 'O', 'C', 'T', 'Y', 'P', 'E')
          parse_doctype_decl
        elsif @chars.consume?('<', '!', '-', '-')
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
        if @chars.current? == '?'
          @chars.consume
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

      @chars.set_encoding(encoding) unless encoding.blank?
      @chars.normalize_eol = :always if version == "1.1"

      @handlers.xml_decl(version, encoding, standalone)
    end

    def parse_doctype_decl : Nil
      intsubset = false

      expect_whitespace
      name = parse_name

      # expect_whitespace unless @chars.current? == '>'
      skip_whitespace
      public_id, system_id = parse_external_id
      skip_whitespace

      if @chars.current? == '['
        @chars.consume
        intsubset = true
      end

      @handlers.start_doctype_decl(name, system_id, public_id, intsubset)

      parse_intsubset if intsubset

      skip_whitespace
      expect '>'

      @handlers.end_doctype_decl
    end

    def parse_external_id(loose_system_id = false) : {String?, String?}
      if @chars.consume?('P', 'U', 'B', 'L', 'I', 'C')
        expect_whitespace
        public_id = parse_pubid_literal

        if loose_system_id
          skip_whitespace
          if @chars.current? == '"' || @chars.current? == '\''
            system_id = parse_system_literal
          end
        else
          expect_whitespace
          system_id = parse_system_literal
        end
      elsif @chars.consume?('S', 'Y', 'S', 'T', 'E', 'M')
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

        case char = @chars.current?
        when '<'
          if @chars.consume?('<', '!', 'A', 'T', 'T', 'L', 'I', 'S', 'T')
            parse_attlist_decl
          elsif @chars.consume?('<', '!', 'E', 'L', 'E', 'M', 'E', 'N', 'T')
            parse_element_decl
          elsif @chars.consume?('<', '!', 'E', 'N', 'T', 'I', 'T', 'Y')
            parse_entity_decl
          elsif @chars.consume?('<', '!', 'N', 'O', 'T', 'A', 'T', 'I', 'O', 'N')
            parse_notation_decl
          elsif @chars.consume?('<', '?')
            parse_processing_instruction
          elsif @chars.consume?('<', '!', '-', '-')
            parse_comment
          end
        when '%'
          @chars.consume
          name = parse_name
          expect ';'
          # @handlers.entity_ref(name, parameter: true)
        when ']'
          @chars.consume
          break
        end
      end
    end

    def parse_attlist_decl : Nil
      expect_whitespace
      element_name = parse_name
      skip_whitespace

      until @chars.current? == '>'
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
      if @chars.consume?('C', 'D', 'A', 'T', 'A')
        :CDATA
      elsif @chars.consume?('I', 'D', 'R', 'E', 'F', 'S')
        :IDREF
      elsif @chars.consume?('I', 'D', 'R', 'E', 'F')
        :IDREF
      elsif @chars.consume?('I', 'D')
        :ID
      elsif @chars.consume?('E', 'N', 'T', 'I', 'T', 'I', 'E', 'S')
        :ENTITIES
      elsif @chars.consume?('E', 'N', 'T', 'I', 'T', 'Y')
        :ENTITY
      elsif @chars.consume?('N', 'M', 'T', 'O', 'K', 'E', 'N', 'S')
        :NMTOKENS
      elsif @chars.consume?('N', 'M', 'T', 'O', 'K', 'E', 'N')
        :NMTOKEN
      elsif @chars.consume?('N', 'O', 'T', 'A', 'T', 'I', 'O', 'N')
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
      if @chars.consume?('#', 'R', 'E', 'Q', 'U', 'I', 'R', 'E', 'D')
        return :REQUIRED
      end

      if @chars.consume?('#', 'I', 'M', 'P', 'L', 'I', 'E', 'D')
        return :IMPLIED
      end

      if @chars.consume?('#', 'F', 'I', 'X', 'E', 'D')
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
      if @chars.consume?('E', 'M', 'P', 'T', 'Y')
        return ElementDecl::Empty.new
      end

      if @chars.consume?('A', 'N', 'Y')
        return ElementDecl::Any.new
      end

      expect '('
      skip_whitespace

      if @chars.consume?('#', 'P', 'C', 'D', 'A', 'T', 'A')
        names = [] of String
        loop do
          skip_whitespace
          break if expect(')', '|') == ')'
          skip_whitespace
          names << parse_name
        end
        @chars.consume if @chars.current? == '*'
        ElementDecl::Mixed.new(names)
      else
        parse_children
      end
    end

    private def parse_children : ElementDecl::Children
      klass = nil
      children = [] of ElementDecl::Children

      loop do
        case @chars.current?
        when '('
          @chars.consume
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

        case @chars.current?
        when ')'
          @chars.consume
          break
        when '|'
          fatal_error("Expected ',' but got '|'") if klass == ElementDecl::Seq
          @chars.consume
          klass = ElementDecl::Choice
        when ','
          @chars.consume
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
      case @chars.current?
      when '?'
        @chars.consume
        ElementDecl::Quantifier::OPTIONAL
      when '*'
        @chars.consume
        ElementDecl::Quantifier::REPEATED
      when '+'
        @chars.consume
        ElementDecl::Quantifier::PLUS
      else
        ElementDecl::Quantifier::NONE
      end
    end

    def parse_entity_decl
      expect_whitespace

      if @chars.current? == '%'
        @chars.consume
        expect_whitespace
        parameter = true
      else
        parameter = false
      end
      name = parse_name
      expect_whitespace

      case @chars.current?
      when '"', '\''
        quote = @chars.consume
        value = consume_until { |char| char == quote }
        expect quote
      when 'P', 'S'
        public_id, system_id = parse_external_id
        skip_whitespace
        if @chars.consume?('N', 'D', 'A', 'T', 'A')
          expect_whitespace
          ndata = parse_name
        end
      end

      skip_whitespace
      expect '>'

      if value
        @handlers.entity_decl(name, value, parameter)
      elsif ndata
        @handlers.unparsed_entity_decl(name, public_id, system_id, ndata)
      else
        @handlers.external_entity_decl(name, public_id, system_id, parameter)
      end
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

      # expect_whitespace unless @chars.current == '?'
      skip_whitespace

      data = consume_until do |char|
        char == '?' && @chars.peek == '>'
      end
      @chars.consume # ?
      @chars.consume # >

      @handlers.processing_instruction(target, data)
    end

    def parse_comment : Nil
      # WF: double hyphens (--) isn't allowed within comments
      # WF: grammar doesn't allow ---> to end comment
      data = consume_until do |char|
        @chars.consume?('-', '-', '>')
      end
      @handlers.comment(data)
    end

    # TODO: CDATASection
    def parse_content : Nil
      while char = @chars.current?
        if char == '<'
          if @chars.consume?('<', '!', '-', '-')
            parse_comment
          elsif @chars.consume?('<', '!', '[', 'C', 'D', 'A', 'T', 'A', '[')
            parse_cdata
          elsif @chars.consume?('<', '?')
            parse_processing_instruction
          elsif @chars.consume?('<', '/')
            name = parse_name
            skip_whitespace
            expect '>'
            @handlers.end_element(name)
          else
            @chars.consume # '<'
            name = parse_name
            attributes = parse_attributes
            if @chars.consume?('/', '>')
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
      while char = @chars.current?
        case char
        when '<'
          break
        when '&'
          if @chars.peek == '#'
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
          @chars.consume
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

      @buffer << @chars.consume # '&'
      @buffer << @chars.consume # '#'

      if @chars.current? == 'x'
        @buffer << @chars.consume

        while char = @chars.consume
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
        while char = @chars.consume
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
      @chars.consume # '&'

      name = parse_name

      if @chars.current? == ';'
        @chars.consume

        case name
        when "lt" then @buffer << '<'
        when "gt" then @buffer << '>'
        when "amp" then @buffer << '&'
        when "apos" then @buffer << '\''
        when "quot" then @buffer << '"'
        else
          # todo: replace General Entity (local)
          yield name
        end
      else
        @buffer << '&'
        @buffer << name
        recoverable_error "Invalid entity reference"
      end
    end

    def parse_cdata : Nil
      data = consume_until { @chars.consume?(']', ']', '>') }
      @handlers.cdata_section(data)
    end

    def parse_name : String
      char = @chars.current
      fatal_error("Invalid name start char #{char.inspect}") unless name_start?(char)

      @name_buffer << char
      @chars.consume

      while (char = @chars.current?) && name?(char)
        @name_buffer << char
        @chars.consume
      end

      @string_pool.get(@name_buffer.to_slice)
    ensure
      @name_buffer.clear
    end

    def parse_nmtoken : String
      while (char = @chars.current?) && name?(char)
        @name_buffer << char
        @chars.consume
      end
      @string_pool.get(@name_buffer.to_slice)
    ensure
      @name_buffer.clear
    end

    def parse_attributes : Array({String, String})
      attributes = [] of {String, String}

      loop do
        skip_whitespace

        case @chars.current?
        when '>'
          break
        when '/'
          break if @chars.peek == '>'
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

      while char = @chars.current?
        case char
        when quote
          break
        when '&'
          if @chars.peek == '#'
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
          @chars.consume
        end
      end

      value = consume_until { |char| char == quote }
      @chars.consume # quote
      value
    ensure
      @buffer.clear
    end

    def parse_encoding : String
      quote = expect '"', '\''
      # WF: must start with `encname_start?` and continue with `encname?`
      value = consume_until { |char| char == quote }
      @chars.consume # quote
      value
    end

    def skip_whitespace : Nil
      while (char = @chars.current?) && s?(char)
        @chars.consume
      end
    end

    def expect_whitespace : Nil
      if s?(@chars.current)
        while (char = @chars.current?) && s?(char)
          @chars.consume
        end
      else
        fatal_error("Expected whitespace but got #{@chars.current.inspect}")
      end
    end

    private def expect(*chars : Char) : Char
      if chars.includes?(@chars.current)
        @chars.consume
      else
        fatal_error("Expected any of #{chars.inspect} but got #{@chars.current.inspect}")
      end
    end

    private def consume_until(& : Char -> Bool) : String
      until yield(char = @chars.current)
        @buffer << char
        @chars.consume
      end
      @buffer.to_s
    ensure
      @buffer.clear
    end

    private def recoverable_error(message : String)
      @handlers.error(message, @chars.location)
    end

    private def fatal_error(message : String)
      raise Error.new(message, @chars.location)
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

      def entity_decl(name : String, value : String, parameter : Bool) : Nil
      end

      def external_entity_decl(name : String, public_id : String?, system_id : String?, parameter : Bool) : Nil
      end

      def unparsed_entity_decl(name : String, public_id : String?, system_id : String?, ndata : String?) : Nil
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
