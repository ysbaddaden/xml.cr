# Copyright 2025 Julien PORTALIER
# Distributed under the Apache-2.0 LICENSE

require "./node"

module XML::DOM
  class Notation < Node
    getter! public_id : String
    getter! system_id : String

    def initialize(@public_id, @system_id, @owner_document)
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
      io << '\n'
    end

    def clone : self
      dup
    end
  end
end
