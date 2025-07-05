# Copyright 2025 Julien PORTALIER
# Distributed under the Apache-2.0 LICENSE

require "string_pool"
require "./chars"
require "./sax/attributes"
require "./sax/element_decl"
require "./sax/entities"
require "./sax/handlers"
require "./sax/reader"

class IO::Memory
  def bytesize=(@bytesize)
  end
end

module XML
  # Simple API for XML.
  #
  # Parses XML documents using a push-parser; whenever something is reached, for
  # example an element starts, or a comment is reached, a callback is called
  # with details about the event. Custom handlers can then do anything they want
  # using these informations: stream the document while reacting to certain
  # elements and skipping the rest, or build a complete DOM tree, or a partial
  # tree without declarations, comments or processing instructions.
  #
  # See `Handlers` for the list of methods that will be called during parsing.
  #
  # TODO: options to enable parsing entities, etc.
  class SAX
    include Chars

    def base : String
      @base.not_nil!
    end

    def base? : String?
      @base
    end

    def base=(value : String?)
      @base = value
    end

    def self.new(io : IO, handlers : Handlers)
      new(Reader.new(io), handlers, Entities.new, Hash(String, Attributes).new)
    end

    protected def self.new(io : IO, handlers : Handlers, entities : Entities, elements : Hash(String, Attributes))
      new(Reader.new(io), handlers, entities, elements)
    end

    protected def initialize(@reader : Reader, @handlers : Handlers, @entities : Entities, @elements : Hash(String, Attributes))
      @buffer = IO::Memory.new
      @name_buffer = IO::Memory.new
      @string_pool = StringPool.new
    end

    # Returns the current location.
    def location : Location
      @reader.location
    end

    # Parse IO as a XML document.
    #
    # Raises `Error` on fatal errors.
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
    rescue ex : XML::Error
      raise ex
    rescue ex
      raise XML::Error.new(ex.message || "Internal error", @reader.location, cause: ex)
    end

    # Parse IO as a General Entity (GE).
    protected def parse_external_general_entity : Nil
      @reader.normalize_eol = :always
      @reader.autodetect_encoding!

      if @reader.consume?('<', '?', 'x', 'm', 'l')
        expect_whitespace
        parse_text_decl
      end

      parse_content
    end

    # Parse IO as an external Doctype.
    #
    # NOTE: `@reader` must be an ExtSubsetReader.
    protected def parse_external_dtd : Nil
      @reader.autodetect_encoding!

      if @reader.consume?('<', '?', 'x', 'm', 'l')
        expect_whitespace
        parse_text_decl
      end

      parse_extsubset
    end

    protected def parse_xml_decl : Nil
      version, encoding, standalone = "1.0", nil, nil

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
          version = parse_att_value
        when "encoding"
          encoding = parse_encoding
        when "standalone"
          # WF: expect "yes", 'yes', "no" or 'no'
          standalone = parse_att_value.compare("yes", case_insensitive: true) == 0
        else
          recoverable_error("XMLDECL: unexpected attribute #{attr_name.inspect}")
        end

        skip_whitespace
      end

      @reader.set_encoding(encoding) unless encoding.nil? || encoding.blank?
      if version == "1.1"
        @reader.version = :XML_1_1
        @reader.normalize_eol = :always
      end
      @handlers.xml_decl(version, encoding, standalone)
    end

    protected def parse_text_decl : Nil
      version, encoding = "1.0", nil

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
          version = parse_att_value
        when "encoding"
          encoding = parse_encoding
        else
          recoverable_error("XMLDECL: unexpected attribute #{attr_name.inspect}")
        end

        @reader.version = :XML_1_1 if version == "1.1"

        skip_whitespace
      end

      unless encoding.nil? || encoding.blank?
        # sometimes the specified encoding isn't as explicit as the detected
        # encoding e.g. BOM=UTF-16LE  but encoding="UTF-16"
        unless @reader.@io.encoding.starts_with?(encoding)
          @reader.set_encoding(encoding)
        end
      end

      @handlers.text_decl(version, encoding)
    end

    protected def parse_doctype_decl : Nil
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
      parse_external_doctype(system_id) if system_id

      skip_whitespace
      expect '>'

      @handlers.end_doctype_decl
    end

    private def parse_external_doctype(system_id : String) : Nil
      @handlers.open_external(@base, system_id) do |path, io|
        reader = ExtSubsetReader.new(io, ->pe_callback(String))
        sax = XML::SAX.new(reader, @handlers, @entities, @elements)
        sax.base = File.dirname(path)
        sax.parse_external_dtd
      end
    end

    protected def parse_external_id(loose_system_id = false) : {String?, String?}
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

    protected def parse_system_literal : String
      quote = expect '"', '\''
      value = consume_until { |char| char == quote }
      expect quote
      value
    end

    protected def parse_pubid_literal : String
      quote = expect '"', '\''
      value = consume_until do |char|
        # WF: error unless pubid?(char)
        char == quote
      end
      expect quote
      value
    end

    protected def parse_intsubset : Nil
      parse_subset(ext: false)
    end

    protected def parse_extsubset : Nil
      parse_subset(ext: true)
    end

    protected def parse_subset(ext : Bool) : Nil
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
          elsif @reader.consume?('<', '!', '[')
            recoverable_error "Unexpected conditional section outside of extsubset" unless ext
            parse_conditional_section
          else
            fatal_error "Unknown declaration"
          end
        when '%'
          @reader.consume
          name = parse_name
          expect ';'
          expand_parameter_entity?(name)
        when ']'
          @reader.consume
          break
        when nil
          break
        else
          fatal_error "Unexpected #{char.inspect} in DTD"
        end
      end
    end

    protected def parse_conditional_section : Nil
      @reader.auto_expand_pe_refs = true
      skip_whitespace

      if @reader.consume?('I', 'G', 'N', 'O', 'R', 'E')
        skip_whitespace
        @reader.auto_expand_pe_refs = false
        expect '['

        count = 1
        while count > 0
          if @reader.consume?('<', '!', '[')
            count += 1
          elsif @reader.consume?(']', ']', '>')
            count -= 1
          else
            @reader.consume
          end
        end
      elsif @reader.consume?('I', 'N', 'C', 'L', 'U', 'D', 'E')
        skip_whitespace
        @reader.auto_expand_pe_refs = false
        expect '['

        parse_extsubset

        unless @reader.consume?(']', '>')
          fatal_error "Unexpected ']'"
        end
      else
        fatal_error "Unexpected #{@reader.current?.inspect}"
      end
    end

    protected def expand_parameter_entity?(name : String, literal = false) : Bool
      return false unless entity = valid_entity? { @entities.parameter?(name) }

      expanding?(entity) do
        if entity.external?
          @handlers.open_external(@base, entity.system_id) do |path, io|
            with_reader(ExtSubsetReader.new(io, ->pe_callback(String)), base: File.dirname(path)) do
              if literal
                parse_entity_value(quote: nil)
              else
                parse_external_dtd
              end
            end
            return true
          end
          return false
        end

        with_reader(Reader.new(IO::Memory.new(entity.value), location: entity.location)) do
          # FIXME: depending on where the entity was declared, it might be an
          # intsubset or an extsubset
          if literal
            parse_entity_value(quote: nil)
          else
            parse_extsubset
          end
        end

        true
      end
    end

    private def pe_callback(name : String) : IO?
      return unless entity = valid_entity? { @entities.parameter?(name) }

      expanding?(entity) do
        if entity.internal?
          return IO::Memory.new(entity.value)
        end

        if ret = @handlers.open_external(@base, entity.system_id)
          _, io = ret
          return io
        end
      end

      nil
    end

    protected def expand_general_entity?(name : String, context : Symbol) : Bool
      return false unless entity = valid_entity? { @entities.general?(name) }

      expanding?(entity) do
        if entity.external?
          if context == :att_value
            # WF: No External Entity References
            recoverable_error "Cannot expand external entity in attribute value."
            return false
          end

          @handlers.open_external(@base, entity.system_id) do |path, io|
            sax = XML::SAX.new(io, @handlers, @entities, @elements)
            sax.base = File.dirname(path)
            sax.parse_external_general_entity
            return true
          end

          return false
        end

        with_reader(Reader.new(IO::Memory.new(entity.value), :never, entity.location)) do
          if context == :att_value
            parse_att_value_impl(quote: nil)
          else
            parse_content
          end
        end

        true
      end
    end

    private def valid_entity?(&) : Entity?
      entity = yield

      unless entity
        # WF: Entity Declared.
        recoverable_error "Cannot expand undeclared entity."
        return
      end

      if entity.unparsed?
        # WF: Parsed Entity.
        recoverable_error "Cannot expand unparsed entity."
        return
      end

      entity
    end

    # Remembers that we're expanding this entity for the duration of the
    # *block*. Aborts if we're already expanding said entity to avoid infinite
    # recursion because of a direct or indirect reference.
    private def expanding?(entity : Entity, &) : Bool
      if @entities.expanding?(entity) { yield }
        # WF: No Recursive.
        recoverable_error "Cannot expand recursive reference to parsed entity."
        false
      else
        true
      end
    end

    private def with_reader(reader : Reader, base : String? = nil, &)
      reader_, @reader = @reader, reader
      if base
        base_, @base = @base, base
      end

      begin
        yield
      ensure
        @reader = reader_
        @base = base_ if base
      end
    end

    protected def parse_attlist_decl : Nil
      @reader.auto_expand_pe_refs = true

      expect_whitespace
      element_name = parse_name
      skip_whitespace

      until @reader.current? == '>'
        name = parse_name
        expect_whitespace
        type, names = parse_att_type
        expect_whitespace
        default, value = parse_default_decl

        attrs = @elements[element_name] ||= Attributes.new
        attrs[name] ||= Attribute.new(type, names, default, value)
        @handlers.attlist_decl(element_name, name, type, names, default, value)

        skip_whitespace
      end
      @reader.auto_expand_pe_refs = false

      expect '>'
    end

    protected def parse_att_type : {Symbol, Array(String)?}
      if @reader.consume?('C', 'D', 'A', 'T', 'A')
        {:CDATA, nil}
      elsif @reader.consume?('I', 'D', 'R', 'E', 'F', 'S')
        {:IDREF, nil}
      elsif @reader.consume?('I', 'D', 'R', 'E', 'F')
        {:IDREF, nil}
      elsif @reader.consume?('I', 'D')
        {:ID, nil}
      elsif @reader.consume?('E', 'N', 'T', 'I', 'T', 'I', 'E', 'S')
        {:ENTITIES, nil}
      elsif @reader.consume?('E', 'N', 'T', 'I', 'T', 'Y')
        {:ENTITY, nil}
      elsif @reader.consume?('N', 'M', 'T', 'O', 'K', 'E', 'N', 'S')
        {:NMTOKENS, nil}
      elsif @reader.consume?('N', 'M', 'T', 'O', 'K', 'E', 'N')
        {:NMTOKEN, nil}
      elsif @reader.consume?('N', 'O', 'T', 'A', 'T', 'I', 'O', 'N')
        expect_whitespace
        names = parse_att_list { parse_name }
        {:NOTATION, names}
      else
        nmtokens = parse_att_list { parse_nmtoken }
        {:ENUMERATION, nmtokens}
      end
    end

    private def parse_att_list(&) : Array(String)
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

    protected def parse_default_decl : {Symbol, String?}
      if @reader.consume?('#', 'R', 'E', 'Q', 'U', 'I', 'R', 'E', 'D')
        return {:REQUIRED, nil}
      end

      if @reader.consume?('#', 'I', 'M', 'P', 'L', 'I', 'E', 'D')
        return {:IMPLIED, nil}
      end

      if @reader.consume?('#', 'F', 'I', 'X', 'E', 'D')
        expect_whitespace
      end

      @reader.auto_expand_pe_refs = false
      value = parse_att_value
      @reader.auto_expand_pe_refs = true

      {:FIXED, value}
    end

    protected def parse_element_decl : Nil
      @reader.auto_expand_pe_refs = true

      expect_whitespace
      name = parse_name
      expect_whitespace
      model = parse_content_spec
      skip_whitespace
      expect '>'

      @reader.auto_expand_pe_refs = false
      @handlers.element_decl(name, model)
    end

    protected def parse_content_spec : ElementDecl
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

    private def parse_quantifier : ElementDecl::Quantifier
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

    protected def parse_entity_decl : Nil
      @reader.auto_expand_pe_refs = true

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

      entity =
        case @reader.current?
        when '"', '\''
          quote = @reader.consume
          location = @reader.location
          @reader.auto_expand_pe_refs = false
          value = parse_entity_value(quote)
          @reader.auto_expand_pe_refs = true
          @entities.add(parameter, name, value, nil, nil, nil, location)
        else
          public_id, system_id = parse_external_id
          skip_whitespace
          if @reader.consume?('N', 'D', 'A', 'T', 'A')
            expect_whitespace
            notation_name = parse_name
            @entities.add(parameter, name, nil, public_id, system_id, notation_name, nil)
          else
            @entities.add(parameter, name, nil, public_id, system_id, nil, nil)
          end
        end

      skip_whitespace
      expect '>'

      @reader.auto_expand_pe_refs = false
      @handlers.entity_decl(entity)
    end

    protected def parse_entity_value(quote : Char?) : String
      while char = @reader.current?
        case char
        when quote
          @reader.consume
          break
        when '&'
          if @reader.peek == '#'
            parse_character_reference
          else
            # do not process general entity ref
            @reader.consume
            @buffer << char
          end
        when '%'
          @reader.consume
          name = parse_name
          expect ';'
          unless expand_parameter_entity?(name, literal: true)
            @buffer << '%' << name << ';'
          end
        else
          @buffer << char
          @reader.consume
        end
      end

      # HACK: quote is nil when parsing a PERef in an EntityValue, in that case
      # we keep the buffer intact and don't bother generating a string
      if quote
        @buffer.to_s
      else
        ""
      end
    ensure
      @buffer.clear if quote
    end

    protected def parse_notation_decl : Nil
      @reader.auto_expand_pe_refs = true

      expect_whitespace
      name = parse_name
      expect_whitespace
      public_id, system_id = parse_external_id(loose_system_id: true)
      skip_whitespace
      expect '>'

      @reader.auto_expand_pe_refs = false
      @handlers.notation_decl(name, public_id, system_id)
    end

    protected def parse_processing_instruction : Nil
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

    protected def parse_comment : Nil
      # WF: grammar doesn't allow ---> to end comment
      @reader.allow_restricted_chars = true
      data = consume_until do |char|
        if @reader.consume?('-', '-', '>')
          true
        else
          if @reader.consume?('-', '-')
            # WF: double hyphens (--) isn't allowed within comments
            recoverable_error "Comments cannot contain double-hyphen (--)."
          end
          false
        end
      end
      @reader.allow_restricted_chars = false
      @handlers.comment(data)
    end

    protected def parse_content : Nil
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
            attributes = parse_attributes(name)

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

    protected def parse_character_data : Nil
      while char = @reader.current?
        case char
        when '<'
          break
        when '&'
          if @reader.peek == '#'
            parse_character_reference
          else
            @handlers.character_data(@buffer.to_s) if @buffer.size > 0
            @buffer.clear
            parse_entity_reference(:element) do |name|
              @handlers.entity_reference(name)
            end
          end
        else
          @buffer << char
          @reader.consume
        end
      end
      @handlers.character_data(@buffer.to_s) if @buffer.size > 0
      @buffer.clear
    end

    protected def parse_character_reference : Nil
      # keep current buffer pos so we can "rewind" on valid syntax, and have
      # nothing to do on invalid syntax (we pushed every char to the buffer)
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

    protected def parse_entity_reference(context : Symbol, &) : Nil
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
          unless expand_general_entity?(name, context)
            yield name
          end
        end
      else
        @buffer << '&'
        @buffer << name
        recoverable_error "Invalid entity reference"
      end
    end

    protected def parse_cdata : Nil
      data = consume_until { @reader.consume?(']', ']', '>') }
      @handlers.cdata_section(data)
    end

    protected def parse_name : String
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

    protected def parse_nmtoken : String
      while (char = @reader.current?) && name?(char)
        @name_buffer << char
        @reader.consume
      end
      @string_pool.get(@name_buffer.to_slice)
    ensure
      @name_buffer.clear
    end

    protected def parse_attributes(element_name : String) : Array({String, String})
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
        value = parse_att_value
        attributes << {name, value}
      end

      if attrs = @elements[element_name]?
        # add default attribute values
        attrs.each do |name, attr|
          if (default = attr.default?) && !attributes.any? { |(n, _)| n == name }
            attributes << {name, default}
          end
        end

        # post-normalization: non CDATA attribute values must discard leading
        # and trailing spaces and replace sequences of spaces to a single space
        #
        # OPTIMIZE: normalize as we parse (but beware of entity expansions)
        attributes.each_with_index do |(attr_name, attr_value), i|
          if (attr = attrs[attr_name]?) && (attr.type != :CDATA)
            attributes[i] = {attr_name, attr_value.strip(' ').gsub(/[ ]+/, ' ')}
          end
        end
      end

      attributes
    end

    protected def parse_att_value : String
      quote = expect '"', '\''
      parse_att_value_impl(quote)
    end

    private def parse_att_value_impl(quote : Char?) : String
      while char = @reader.current?
        if quote && char == quote
          @reader.consume
          break
        end

        if char == '&'
          if @reader.peek == '#'
            parse_character_reference
          else
            parse_entity_reference(:att_value) do |name|
              @buffer << '&' << name << ';'
            end
          end
        else
          recoverable_error "Attribute value cannot contain '<'" if char == '<'

          # normalize whitespace <https://www.w3.org/TR/xml11/#AVNormalize>
          @buffer << (s?(char) ? 0x20.chr : char)
          @reader.consume
        end
      end

      # HACK: quote is nil when parsing a GERef in an AttValue, in that case we
      # keep the buffer intact and don't bother generating a string
      quote ? @buffer.to_s : ""
    ensure
      @buffer.clear if quote
    end

    protected def parse_encoding : String
      quote = expect '"', '\''
      # WF: must start with `encname_start?` and continue with `encname?`
      value = consume_until { |char| char == quote }
      @reader.consume # quote
      value
    end

    protected def skip_whitespace : Nil
      while (char = @reader.current?) && s?(char)
        @reader.consume
      end
    end

    protected def expect_whitespace : Nil
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
  end
end
