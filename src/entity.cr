module CRXML
  class EntityRef < Node
    getter name : String

    def initialize(@name, @owner_document)
    end

    def inspect(io : IO, indent = 0) : Nil
      indent.times { io << ' ' }
      io << '#' << self.class.name
      io << ' ' << '%' << ' ' << name
      io << '\n'
    end
  end

  class PEReference < Node
    getter name : String

    def initialize(@name, @owner_document)
    end

    def inspect(io : IO, indent = 0) : Nil
      indent.times { io << ' ' }
      io << '#' << self.class.name
      io << ' ' << name
      io << '\n'
    end
  end
end
