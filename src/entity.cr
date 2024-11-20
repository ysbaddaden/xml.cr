module CRXML
  class EntityRef < Node
    getter name : String
    getter location : Lexer::Location

    def initialize(@name, @owner_document, @location : Lexer::Location)
    end

    def inspect(io : IO, indent = 0) : Nil
      indent.times { io << ' ' }
      io << '#' << self.class.name
      io << ' ' << '%' << ' ' << name
      io << '\n'
    end

    def clone : self
      dup
    end
  end

  class PEReference < Node
    getter name : String
    getter location : Lexer::Location

    def initialize(@name, @owner_document, @location : Lexer::Location)
    end

    def inspect(io : IO, indent = 0) : Nil
      indent.times { io << ' ' }
      io << '#' << self.class.name
      io << ' ' << name
      io << '\n'
    end

    def clone : self
      dup
    end
  end
end
