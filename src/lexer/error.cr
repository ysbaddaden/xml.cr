require "./location"

module CRXML
  abstract class Error < Exception
    getter location : Lexer::Location

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
