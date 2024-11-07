module CRXML
  class Lexer
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

      def adjust(line = 0, column = 0) : self
        self.class.new(@line + line, @column + column)
      end

      def inspect(io : IO)
        io << "at line #{line} column #{column}"
      end
    end
  end
end
