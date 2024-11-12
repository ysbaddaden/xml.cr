module CRXML
  class Element < Node
    include DOM::ParentNode
    include DOM::ChildNode
    include DOM::NonDocumentTypeChildNode

    getter name : String

    def initialize(@name : String, @owner_document : Document)
    end

    def attributes : DOM::Attributes
      @attributes ||= DOM::Attributes.new(self)
    end

    def text_content : String
      String.build { |str| text_content(str) }
    end

    protected def text_content(str : String::Builder) : Nil
      @children.each { |child| child.text_content(str) }
    end

    # def closest(selectors : String) : Element?
    # def matches(selectors : String) : Bool

    # def each_by(**options, & : Node ->)
    # def each_element_by(name : String, & : Element ->) : Nil
    # def each_element_by(class : String, & : Element ->) : Nil

    # def get_elements_by(name : String) : Array(Element)
    # def get_elements_by(class : String) : Array(Element)
  end
end
