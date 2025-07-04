require "./node"
require "./element"

module XML::DOM
  class CharacterData < Node
    include ChildNode
    include NonDocumentTypeChildNode

    property data : String

    def initialize(@data : String, @owner_document : Document, @parent_element : Element? = nil)
    end

    # def node_value : String
    #   @data
    # end

    def text_content : String
      @data
    end

    def ==(other : CharacterData) : Bool
      @data == other.data
    end

    protected def text_content(str : String::Builder) : Nil
      str << @data
    end

    # :nodoc:
    def inspect(io : IO, indent = 0) : Nil
      indent.times { io << ' ' }
      io << '#' << self.class.name << " data=" << data.inspect << '\n'
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
