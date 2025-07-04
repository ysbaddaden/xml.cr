require "./node"

module XML::DOM
  class Entity < Node
    getter! public_id : String
    getter! system_id : String
    getter! notation_name : String

    def initialize(@public_id, @system_id, @notation_name, @owner_document)
    end

    def parsed? : Bool
      @notation_name.nil?
    end

    def unparsed? : Bool
      !@notation_name.nil?
    end

    # :nodoc:
    def inspect(io : IO, indent = 0) : Nil
      indent.times { io << ' ' }
      io << '#' << self.class.name
      if s = public_id?
        io << " public_id="
        s.inspect(io)
      end
      if s = system_id?
        io << " system_id="
        s.inspect(io)
      end
      if s = notation_name?
        io << " notation_name="
        s.inspect(io)
      end
      io << '\n'
    end

    def clone : self
      dup
    end
  end
end
