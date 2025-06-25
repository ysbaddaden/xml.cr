require "string_pool"
require "./char_reader"
require "./chars"

module XML
  # Simple API for XML.
  class SAX
    include Chars

    def initialize(io : IO, @handlers : Handlers)
      @chars = CharReader.new(io)
      @buffer = IO::Memory.new
      @string_pool = StringPool.new
    end

    def parse : Nil
      # skip_whitespace

      # TODO: detect encoding

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
      raise NotImplementedError.new("")
    end

    def parse_processing_instruction : Nil
      target = parse_name
      if target.compare("xml", case_insensitive: true)
        recoverable_error "PI: reserved prefix #{target.inspect}"
      end

      expect_whitespace

      data = consume_until do |char|
        char == '?' && @chars.peek == '>'
      end
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
        # TODO: CharRef
        # TODO: EntityRef
        case char
        when '<'
          if @buffer.size > 0
            # OPTIMIZE: use string pool if all whitespace (likely to be repeated)
            @handlers.character_data(@buffer.to_s)
            @buffer.clear
          end

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
          elsif @chars.consume?('<')
            name = parse_name
            attributes = parse_attributes

            if @chars.consume?('/', '>')
              @handlers.empty_element(name, attributes)
            else
              expect '>'
              @handlers.start_element(name, attributes)
            end
          end
        when '&'
        else
          # CharData
          @chars.consume?
          @buffer << char
        end
      end
    end

    def parse_cdata : Nil
      data = consume_until { @chars.consume?(']', ']', '>') }
      @handlers.cdata_section(data)
    end

    def parse_name : String
      build_string(pool: true) do |str|
        char = @chars.current
        unless name_start?(char)
          fatal_error("Invalid name start char #{char.inspect}")
        end
        str << char
        @chars.consume

        while (char = @chars.current?) && name?(char)
          str << char
          @chars.consume
        end
      end
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

    # TODO: CharRef
    # TODO: EntityRef
    def parse_attr_value : String
      quote = expect '"', '\''
      value = consume_until { |char| char == quote }
      @chars.consume # quote
      value
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
      build_string(pool: false) do |str|
        until yield(char = @chars.current)
          str << char
          @chars.consume
        end
      end
    end

    # TODO: use string pool to reduce allocations
    private def build_string(pool, &)
      yield @buffer
      str = pool ? @string_pool.get(@buffer.to_slice) : @buffer.to_s
      @buffer.clear
      str
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

      def start_doctype_decl(name : String, system_id : String, public_id : String, intsubset : Bool)
      end

      def end_doctype_decl : Nil
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
