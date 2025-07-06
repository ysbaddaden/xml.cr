# Copyright 2025 Julien PORTALIER
# Distributed under the Apache-2.0 LICENSE

require "./node"

module XML::DOM
  class DocumentType < Node
    include ChildNode

    property name : String
    property! public_id : String
    property! system_id : String

    def initialize(@name, @public_id, @system_id, @owner_document)
    end

    def entities : Hash(String, Entity)
      @entities ||= Hash(String, Entity).new
    end

    def notations : Hash(String, Notation)
      @notations ||= Hash(String, Notation).new
    end

    # :nodoc:
    def inspect(io : IO, indent = 0) : Nil
      indent.times { io << ' ' }
      io << '#' << self.class.name
      io << ' ' << name

      if s = public_id?
        io << " PUBLIC "
        s.inspect(io)
      end

      if s = system_id?
        io << " SYSTEM "
        s.inspect(io)
      end

      io << '\n'
      each_child(&.inspect(io, indent + 2))
    end

    def clone : self
      copy = DocumentType.new(@name, @public_id, @system_id, @owner_document)
      if entities = @entities
        entities.each { |name, entity| copy.entities[name] = entity.clone }
      end
      if notations = @notations
        notations.each { |name, notation| copy.notations[name] = notation.clone }
      end
      each_child { |child| copy.append(child.clone) }
      copy
    end
  end
end
