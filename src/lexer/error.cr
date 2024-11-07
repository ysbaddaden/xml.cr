require "./location"

module CRXML
  class Lexer
    abstract class Error < Exception
      def initialize(@message : String, @location : Lexer::Location)
      end

      def message : String
        "#{@message} at line #{@location.line} column #{@location.column}"
      end
    end

    class SyntaxError < Error
    end

    class ValidationError < Error
    end
  end
end
