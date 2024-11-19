module CRXML::DOM
  class AttDef
    getter name : String
    getter type : String
    getter! enumeration : Array(String)?
    getter! default : String?
    getter! value : String?

    private setter enumeration : Array(String)?

    def initialize(@name, @type, @enumeration, @default, @value)
    end

    def inspect(io : IO, indent = 0) : Nil
      io << ' ' << @name
      io << ' ' << @type unless @type == "ENUMERATION"

      if nms = enumeration?
        io << ' ' << '('
        nms.join(io, " | ")
        io << ')'
      end

      if d = default?
        io << ' ' << '#' << d
      end

      if v = value?
        io << ' '
        v.inspect(io)
      end
    end

    def clone : self
      copy = dup
      copy.enumeration
      copy
    end
  end
end
