# Copyright 2025 Julien PORTALIER
# Distributed under the Apache-2.0 LICENSE

require "./node"

module XML::DOM
  abstract class Document < Node
    include NonElementParentNode
    include ParentNode

    property! doctype : DocumentType
    property! root : Element

    def initialize
      @owner_document = self
    end

    def text_content : String?
      @root.try(&.text_content)
    end

    # def create_element(name : String) : Element
    # def create_element(name : String, namespace : String) : Element
    # def create_document_fragment : DocumentFragment
    # def create_cdata_section(data : String) : CDataSection
    # def create_comment(data : String) : Comment
    # def create_processing_instruction(target : String, data : String) : Comment
    # def create_attribute(name : String) : Attr
    # def create_attribute(name : String, namespace : String) : Attr

    # def import_node(node : Node, *, deep = false) : Node
    # def adopt_node(node : Node) : Node

    # def create_node_iterator(...) : NodeIterator # =>
    # def create_tree_walker(...) : TreeWalker

    # def each_by(**options, & : Node ->)
    # def each_element_by(name : String, & : Element ->) : Nil
    # def each_element_by(class : String, & : Element ->) : Nil

    # def get_elements_by(name : String) : Array(Element)
    # def get_elements_by(class : String) : Array(Element)

    def ==(other : Document) : Bool
      same?(other) || root == other.root
    end

    # :nodoc:
    def inspect(io : IO, indent = 0) : Nil
      indent.times { io << ' ' }
      io << '#' << self.class.name << '\n'
      if node = doctype?
        node.inspect(io, indent + 2)
      end
      each_child(&.inspect(io, indent + 2))
      root.inspect(io, indent + 2)
    end

    def clone : self
      copy = dup

      if doctype = @doctype
        copy.doctype = doctype.clone
      end

      if root = @root
        copy.root = root.clone
      end

      copy.@children.clear
      each_child do |child|
        copy.append(child.clone)
      end

      copy
    end

    def normalize : Nil
      @root.try(&.normalize)
    end

    def canonicalize : Nil
      @root.try(&.canonicalize)
    end
  end
end
