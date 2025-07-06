# Copyright 2025 Julien PORTALIER
# Distributed under the Apache-2.0 LICENSE

require "./character_data"

module XML::DOM
  class ProcessingInstruction < CharacterData
    getter target : String

    def initialize(@target : String, @data : String, @owner_document : Document)
    end

    def ==(other : ProcessingInstruction) : Bool
      @target == other.target && @data == other.data
    end

    # :nodoc:
    def inspect(io : IO, indent = 0) : Nil
      indent.times { io << ' ' }
      io << '#' << self.class.name << " target=" << target << " data=" << data.inspect << '\n'
    end
  end
end
