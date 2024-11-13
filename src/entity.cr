module CRXML
  class Entity < Node
    getter? parameter : Bool
    getter name : String
    getter! value : String
    getter public_id : String?
    getter system_id : String?
    getter notation : String?

    def initialize(@parameter, @name, @value, @public_id, @system_id, @notation)
    end

    def internal? : Bool
      !external?
    end

    def external? : Bool
      @value.nil?
    end

    def parsed? : Bool
      @notation.nil?
    end

    def unparsed? : Bool
      !parsed?
    end

    def inspect(io : IO, indent = 0) : Nil
      indent.times { io << ' ' }
      io << '#' << self.class.name
      io << " % " if parameter?
      io << " name=" << name
      if internal?
        io << " value="; value.inspect(io)
      else
        io << " public_id=" << public_id if public_id
        io << " system_id=" << system_id if system_id
        io << " notation=" << notation if notation
      end
      io << '\n'
    end
  end
end
