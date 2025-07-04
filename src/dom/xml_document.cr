module XML::DOM
  class XMLDocument < Document
    property version : String
    property? encoding : String?
    property? standalone : Bool?

    def initialize(@version = "1.0", @encoding = nil, @standalone = nil)
      super()
    end

    protected def reinitialize(@version, @encoding, @standalone)
    end

    # :nodoc:
    def inspect(io : IO, indent = 0) : Nil
      indent.times { io << ' ' }
      io << '#' << self.class.name << " version=" << version
      if e = @encoding
        io << " encoding=" << e
      end
      if s = @standalone
        io << " standalone=" << s
      end
      io << '\n'
      if node = doctype?
        node.inspect(io, indent + 2)
      end
      each_child(&.inspect(io, indent + 2))
      root.inspect(io, indent + 2)
    end
  end
end
