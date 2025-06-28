# Copyright 2025 Julien PORTALIER
# Distributed under the Apache-2.0 LICENSE

module XML
  struct Location
    property line : Int32
    property column : Int32

    def initialize(@line, @column)
    end

    def update(char : Char) : Nil
      if char == '\n'
        @line += 1
        @column = 1
      else
        @column += 1
      end
    end

    # :nodoc:
    def inspect(io : IO)
      io << "line #{line} column #{column}"
    end
  end
end
