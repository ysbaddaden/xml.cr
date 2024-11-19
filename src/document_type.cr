module CRXML
  class DocumentType < Node
    include DOM::ChildNode

    property name : String
    property! public_id : String
    property! system_id : String

    def initialize(@name, @public_id, @system_id, @owner_document)
    end

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
      each_child { |child| child.inspect(io, indent + 2) }
    end

    def clone : self
      copy = DocumentType.new(@name, @public_id, @system_id, @owner_document)
      each_child { |child| copy.append(child.clone) }
      copy
    end
  end

  class AttlistDecl < Node
    getter name : String
    getter defs : Array(DOM::AttDef)
    protected setter defs : Array(DOM::AttDef)

    def initialize(@name, @defs, @owner_document)
    end

    def inspect(io : IO, indent = 0) : Nil
      indent.times { io << ' ' }
      io << '#' << self.class.name
      io << ' ' << @name
      defs.each(&.inspect(io, indent))
      io << '\n'
    end

    def clone : self
      copy = dup
      copy.defs = @defs.map(&.clone)
      copy
    end
  end

  class ElementDecl < Node
    getter name : String
    getter content : String

    def initialize(@name, @content, @owner_document)
    end

    # TODO: parse contentspec <https://www.w3.org/TR/xml11/#elemdecls>
    def spec
      raise NotImplementedError.new("{{@type}}#spec")
    end

    def inspect(io : IO, indent = 0) : Nil
      indent.times { io << ' ' }
      io << '#' << self.class.name
      io << ' ' << @name
      io << ' ' << @content
      io << '\n'
    end

    def clone : self
      dup
    end
  end

  class EntityDecl < Node
    getter? parameter : Bool
    getter name : String
    getter! value : String
    getter! public_id : String
    getter! system_id : String
    getter! notation_id : String

    def initialize(@parameter, @name, @value, @public_id, @system_id, @notation_id, @owner_document)
    end

    def internal? : Bool
      !@value.nil?
    end

    def external? : Bool
      @value.nil?
    end

    def parsed? : Bool
      @notation_id.nil?
    end

    def unparsed? : Bool
      !@notation_id.nil?
    end

    def inspect(io : IO, indent = 0) : Nil
      indent.times { io << ' ' }
      io << '#' << self.class.name
      io << " % " if parameter?
      io << ' ' << @name
      if internal?
        io << ' '
        value.inspect(io)
      else
        if s = public_id?
          io << " PUBLIC "
          s.inspect(io)
        end
        if s = system_id?
          io << " SYSTEM "
          s.inspect(io)
        end
        if s = notation_id?
          io << " NDATA "
          s.inspect(io)
        end
      end
      io << '\n'
    end

    def clone : self
      copy = dup
      copy.@children.clear
      each_child { |child| copy.append(child.clone) }
      copy
    end
  end

  class NotationDecl < Node
    getter name : String
    getter! public_id : String?
    getter! system_id : String?

    def initialize(@name, @public_id, @system_id, @owner_document)
    end

    def inspect(io : IO, indent = 0) : Nil
      indent.times { io << ' ' }
      io << '#' << self.class.name
      io << ' ' << @name
      if s = public_id?
        io << " PUBLIC "
        s.inspect(io)
      end
      if s = system_id?
        io << " SYSTEM "
        s.inspect(io)
      end
      io << '\n'
    end

    def clone : self
      dup
    end
  end
end
