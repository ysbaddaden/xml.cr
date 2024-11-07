require "./node_set"

module CRXML
  class DOMError < Exception
  end

  # TODO: Document(version, charset, doctype, root)
  # TODO: Fragment(children)
  # TODO: CDATA
  # TODO: attributes
  # TODO: namespaces
  abstract class Node
    getter! parent_node : Node
    getter! previous_sibling : Node
    getter! next_sibling : Node

    protected def parent_node=(@parent_node : Node?)
    end

    protected def previous_sibling=(@previous_sibling : Node?)
    end

    protected def next_sibling=(@next_sibling : Node?)
    end

    def parent_element : Element
      @parent_node.as(Element)
    end

    def parent_element? : Element?
      @parent_node.as(Element?)
    end

    def previous_element_sibling : Element?
      previous_element_sibling?.not_nil!
    end

    def previous_element_sibling? : Element?
      node = @previous_sibling
      while node
        return node if node.is_a?(Element)
        node = node.@previous_sibling
      end
    end

    def next_element_sibling : Element?
      next_element_sibling?.not_nil!
    end

    def next_element_sibling? : Element?
      node = @next_sibling
      while node
        return node if node.is_a?(Element)
        node = node.@next_sibling
      end
    end

    def remove : Nil
      relink(nil, nil, nil)
    end

    protected def relink(parent_node, previous_sibling, next_sibling) : Nil
      parent_element?.try(&.unlink_child(self))
      unlink_siblings
      link(parent_node, previous_sibling, next_sibling)
    end

    protected def link(@parent_node, @previous_sibling, @next_sibling) : Nil
    end

    protected def unlink_siblings : Nil
      if node = @previous_sibling
        node.next_sibling = @next_sibling
      end
      if node = @next_sibling
        node.previous_sibling = @previous_sibling
      end
    end

    # Serializes the element and all its child nodes as a XML string.
    def to_xml : String
      String.build { |str| to_xml(str) }
    end

    # Serializes the element and all its child nodes as XML.
    abstract def to_xml(io : IO) : Nil

    protected abstract def content(str : String::Builder) : Nil
  end

  # TODO: append(*nodes)
  # TODO: insert(*nodes, before)
  # TODO: insert(*nodes, after)
  # TODO: before(*nodes)
  # TODO: after(*nodes)
  class Element < Node
    property name : String

    def initialize(@name : String)
      @children = NodeSet.new
    end

    def first_child : Node
      first_child?.not_nil!
    end

    def first_child? : Node?
      @children.head
    end

    def last_child : Node
      last_child?.not_nil!
    end

    def last_child? : Node?
      @children.tail
    end

    def first_element_child : Node
      first_element_child?.not_nil!
    end

    def first_element_child? : Node?
      case node = @children.head
      when Element
        node
      when Node
        node.next_element_sibling?
      end
    end

    def last_element_child : Node
      last_element_child?.not_nil!
    end

    def last_element_child? : Node?
      case node = @children.tail
      when Element
        node
      when Node
        node.previous_element_sibling?
      end
    end

    def content : String
      String.build { |str| content(str) }
    end

    protected def content(str : String::Builder) : Nil
      @children.each { |node| node.content(str) }
    end

    # Removes *node* from any tree it currently is in, then appends it to child
    # nodes.
    def append(node : Node) : Nil
      node.relink(self, @children.tail, nil)

      if tail = @children.tail
        tail.next_sibling = node
        @children.tail = node
      else
        @children.head = node
        @children.tail = node
      end
    end

    # Removes *node* from any child nodes it currently resides in, then inserts
    # it to the child nodes of this element, just before the *before* child
    # node.
    #
    # Raises if *before* isn't in this element child nodes.
    def insert(node : Node, *, before : Node) : Nil
      raise DOMError.new("not a child of node") unless before.parent_node?.try(&.same?(self))

      node.relink(self, before.previous_sibling?, before)

      if n = before.previous_sibling?
        n.next_sibling = node
      else
        @children.head = node
      end
      before.previous_sibling = node
    end

    # Removes *node* from any child nodes it currently resides in, then inserts
    # it to the child nodes of this element, just after the *after* child node.
    #
    # Raises if *after* isn't in this element child nodes.
    def insert(node : Node, *, after : Node?) : Nil
      raise DOMError.new("not a child of node") unless after.parent_node?.try(&.same?(self))

      node.relink(self, after, after.next_sibling?)

      if n = after.next_sibling?
        n.previous_sibling = node
      else
        @children.tail = node
      end
      after.next_sibling = node
    end

    # Removes *node* from child nodes.
    #
    # Raises if *node* isn't in this element child nodes.
    def remove_child(node : Node) : Nil
      raise DOMError.new("not a child of node") unless node.parent_node?.try(&.same?(self))

      unlink_child(node)
      node.unlink_siblings
      node.link(nil, nil, nil)
    end

    protected def unlink_child(node : Node) : Nil
      if @children.head.same?(node)
        @children.head = node.next_sibling?
      end

      if @children.tail.same?(node)
        @children.tail = node.previous_sibling?
      end
    end

    def to_xml(io : IO) : Nil
      io << '<' << @name << '>'
      @children.each { |node| node.to_xml(io) }
      io << '<' << '/' << @name << '>'
    end
  end

  class Text < Node
    property content : String

    def initialize(@content)
    end

    protected def content(str : String::Builder) : Nil
      str << @content
    end

    # FIXME: escape @content
    def to_xml(io : IO) : Nil
      io << @content
    end
  end
end
