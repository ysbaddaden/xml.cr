# Copyright 2025 Julien PORTALIER
# Distributed under the Apache-2.0 LICENSE

require "../error"
require "../location"

module XML
  class SAX
    enum NormalizeEOL
      Never   # General Entity (GE)
      Partial # XML 1.0
      Always  # XML 1.1 or external Parameter Entity (PE)
    end

    # :nodoc:
    class Reader
      getter location : Location
      property normalize_eol : NormalizeEOL
      @current : Char?
      @buffer : Deque(Char)

      def initialize(@io : IO, @normalize_eol : NormalizeEOL = :partial, @location : Location = Location.new(1, 0))
        @buffer = Deque(Char).new(12)
      end

      # Returns the current char. Raises if EOF was reached. End-of-lines have been normalized.
      def current : Char
        current? || raise Error.new("EOF", @location)
      end

      # Returns the current char or nil if EOF was reached. End-of-lines have been
      # normalized.
      def current? : Char?
        if char = @current
          char
        elsif char = (@buffer.shift? || io_read_char)
          char = normalize_line_endings(char)
          @location.update(char)
          @current = char
        end
      end

      # Moves to the next char, replacing the current char. End-of-lines have
      # been normalized.
      def next : Char
        @current = nil
        current
      end

      def next? : Char?
        @current = nil
        current?
      end

      # Peeks one char forward. End-of-lines aren't normalized.
      def peek : Char?
        if char = @buffer.first?
          char
        elsif char = io_read_char
          @buffer << char
          char
        end
      end

      # Peeks *n* chars forward. End-of-lines aren't normalized.
      def peek(n : Int32) : Char?
        # debug_assert! n > 0

        if char = @buffer[n - 1]?
          return char
        end

        i = @buffer.size
        while i < n
          if char = io_read_char
            @buffer << char
            i += 1
          else
            break
          end
        end

        @buffer[n - 1]?
      end

      # Consumes the current char.
      def consume? : Char?
        if char = (@current || next?)
          @current = nil
          char
        end
      end

      def consume : Char
        consume? || raise Error.new("EOF", @location)
      end

      # If *chars* match the current and following chars, then consumes all the
      # chars (aka moves to the end of all the chars) and returns true, otherwise
      # doesn't move and returns false.
      def consume?(*chars : Char) : Bool
        char, *rest = chars

        # search for the word
        unless current? == char
          return false
        end
        rest.each_with_index do |chr, i|
          return false unless peek(i + 1) == chr
        end

        # consume the chars
        rest.each do |chr|
          @buffer.shift?
          location.update(chr)
        end
        @current = nil

        # success
        true
      end

      # As per <https://www.w3.org/TR/xml11/#sec-line-ends>.
      def normalize_line_endings(char)
        unless @normalize_eol.never?
          case char
          when '\r'
            case peek
            when '\n'
              @buffer.shift?
              char = '\n'
            when '\u0085'
              @buffer.shift? if @normalize_eol.always?
              char = '\n'
            when '\u2028'
              char = '\n'
            else
              char = '\n' if @normalize_eol.always?
            end
          when '\u0085', '\u2028'
            char = '\n' if @normalize_eol.always?
          end
        end

        char
      end

      # FIXME: changing the encoding while we already have read a `@current_char`
      # may lead to invalid reads afterwards.
      def set_encoding(encoding : String) : Nil
        @io.set_encoding(encoding)
      end

      # ameba:disable Metrics/CyclomaticComplexity
      def autodetect_encoding! : Nil
        bytes = StaticArray(UInt8, 4).new(0x01_u8)
        @io.read_fully?(bytes.to_slice)

        # Byte Order Mark (BOM)

        case bytes
        when UInt8.static_array(0x00, 0x00, 0xFE, 0xFF)
          set_encoding("UCS-4BE")
          return
        when UInt8.static_array(0xFF, 0xFE, 0x00, 0x00)
          set_encoding("UCS-4LE")
          return
        end

        case bytes.to_slice[0, 2]
        when UInt8.static_array(0xFE, 0xFF).to_slice
          @io.seek(2, IO::Seek::Set)
          set_encoding("UTF-16BE")
          return
        when UInt8.static_array(0xFF, 0xFE).to_slice
          @io.seek(2, IO::Seek::Set)
          set_encoding("UTF-16LE")
          return
        end

        if bytes.to_slice[0, 3] == UInt8.static_array(0xEF, 0xBB, 0xBF).to_slice
          @io.seek(3, IO::Seek::Set)
          set_encoding("UTF-8")
          return
        end

        # autodetect

        case bytes
        when UInt8.static_array(0x00, 0x00, 0x00, 0x3C)
          set_encoding("UCS-4BE")
        when UInt8.static_array(0x3C, 0x00, 0x00, 0x00)
          set_encoding("UCS-4LE")
        when UInt8.static_array(0x00, 0x3C, 0x00, 0x3F)
          set_encoding("UTF-16BE")
        when UInt8.static_array(0x3C, 0x00, 0x3F, 0x00)
          set_encoding("UTF-16LE")
        when UInt8.static_array(0x3C, 0x3F, 0x78, 0x6D)
          # ASCII, ISO 646, UTF-8: we can keep reading with the default UTF-8
        end

        @io.seek(0, IO::Seek::Set)
      end

      private def io_read_char : Char?
        io_read_char_impl
      end

      private def io_read_char_impl : Char?
        {% if flag?(:DEBUG) %}
          p @io.read_char
        {% else %}
          @io.read_char
        {% end %}
      end

      protected def auto_expand_pe_refs=(value : Bool) : Bool
        value
      end
    end

    # :nodoc:
    #
    # Alternative Reader that detects the presence of parameter entities in the
    # IO and immediately processes its replacement text instead of the IO, with
    # a leading and trailing space around the entity.
    #
    # HACK: this isn't the prettiest solution, but it kinda works. The SAX
    # parser only enables the detection and expansion of entities where they are
    # expected to be, which allows us to have PE references within markupdecl.
    # It's probably not very well-formed, though.
    class ExtSubsetReader < Reader
      @io_peek_char : Char?

      def initialize(io : IO, @pe_callback : String -> IO?)
        super io, :always
        @replaced = [] of IO
      end

      protected def auto_expand_pe_refs=(value : Bool) : Bool
        @auto_expand_pe_refs = value
      end

      private def io_read_char : Char?
        if char = @io_peek_char
          @io_peek_char = nil
        else
          char = super
        end

        if char.nil? && (io = @replaced.pop?)
          # finished PE replacement text
          @io.close
          @io = io
          return 0x20.chr # inject trailing space
        end

        if @auto_expand_pe_refs && (char == '%') && (peek_char = super)
          if Chars.name_start?(peek_char)
            name = io_parse_name(peek_char)

            if io = @pe_callback.call(name)
              @replaced << @io
              @io = io
              autodetect_encoding!
              io_parse_text_decl
              return 0x20.chr # inject leading space
            end
          else
            @io_peek_char = peek_char
          end
        end

        char
      end

      private def io_parse_name(char : Char) : String
        String.build do |str|
          str << char
          until (char = io_read_char_impl) == ';'
            raise Error.new("Reached EOF", @location) unless char
            str << char
          end
        end
      end

      private def io_parse_text_decl : Nil
        pos = @io.pos

        {'<', '?', 'x', 'm', 'l'}.each do |char|
          unless io_read_char_impl == char
            @io.seek(pos, IO::Seek::Set)
            return
          end
        end

        if (char = io_read_char_impl) && Chars.s?(char)
          @io.seek(pos, IO::Seek::Set)
          return
        end

        until io_read_char_impl == '>'
          # skip
          # todo: parse version and encoding attributes
        end
      end
    end
  end
end
