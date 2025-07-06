# Copyright 2025 Julien PORTALIER
# Distributed under the Apache-2.0 LICENSE

module XML::DOM
  class EntityReference < Node
    include ChildNode
    include NonDocumentTypeChildNode

    getter name : String

    def initialize(@name : String, @owner_document : Document)
    end

    def ==(other : self) : Bool
      @name == other.name
    end

    protected def text_content(str : String::Builder) : Nil
      str << '&' << @name << ';'
    end

    # :nodoc;
    def inspect(io : IO, indent = 0) : Nil
      indent.times { io << ' ' }
      io << '#' << self.class.name << " name=" << name << '\n'
    end

    def clone : self
      dup
    end

    def normalize : Nil
    end

    def canonicalize : Nil
    end
  end
end
