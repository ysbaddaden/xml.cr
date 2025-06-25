require "./error"
require "./location"

module XML
  struct CharReader
    enum NormalizeEOL
      Never   # General Entity (GE)
      Partial # XML 1.0
      Always  # XML 1.1 or external Parameter Entity (PE)
    end

    getter location : Location
    property normalize_eol : NormalizeEOL
    @current : Char?
    @buffer : Deque(Char)

    def initialize(@io : IO, @normalize_eol : NormalizeEOL = :partial)
      @buffer = Deque(Char).new(12)
      @location = Location.new(1, 0)
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

    private def io_read_char
      {% if flag?(:DEBUG) %}
        p @io.read_char
      {% else %}
        @io.read_char
      {% end %}
    end
  end
end
