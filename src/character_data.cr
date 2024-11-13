module CRXML
  class CharacterData < Node
    include DOM::ChildNode
    include DOM::NonDocumentTypeChildNode

    property data : String

    def initialize(@data : String, @owner_document : Document, @parent_element : Element? = nil)
    end

    # def node_value : String
    #   @data
    # end

    def text_content : String
      @data
    end

    protected def text_content(str : String::Builder) : Nil
      str << @data
    end

    def inspect(io : IO, indent = 0) : Nil
      indent.times { io << ' ' }
      io << '#' << self.class.name << " data=" << data.inspect << '\n'
    end
  end

  class Text < CharacterData
  end

  class CDataSection < CharacterData
  end

  class ProcessingInstruction < CharacterData
    getter name : String

    def initialize(@name : String, @data : String, @owner_document : Document)
    end

    def inspect(io : IO, indent = 0) : Nil
      indent.times { io << ' ' }
      io << '#' << self.class.name << " name=" << name << " data=" << data.inspect << '\n'
    end
  end

  class Comment < CharacterData
    def text_content : Nil
    end

    protected def text_content(str : String::Builder) : Nil
      # do nothing
    end
  end
end
