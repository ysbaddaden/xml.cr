# Copyright 2025 Julien PORTALIER
# Distributed under the Apache-2.0 LICENSE

require "./node"
require "./node/children"

module XML::DOM
  # TODO: namespaces
  abstract class Node
    getter owner_document : Document
    getter! parent_node : Node
    getter! previous_sibling : Node
    getter! next_sibling : Node
    protected getter children : Children = Children.new

    private def initialize(@owner_document : Document)
    end

    def parent_element : Element
      @parent_node.as(Element)
    end

    def parent_element? : Element?
      @parent_node.try(&.as(Element))
    end

    def root_node : Node
      parent_node.root_node
    end

    def root_node? : Node?
      @parent_node.try(&.root_node?)
    end

    def root_element : Element
      parent_node.root_node.as(Element)
    end

    def root_element? : Element?
      @parent_node.try(&.root_node?.try(&.as(Element)))
    end

    def first_child : Node
      first_child { raise NilAssertionError.new("Expected #first_child to not be nil") }
    end

    def first_child? : Node?
      first_child { nil }
    end

    def first_child(&)
      @children.head || yield
    end

    def last_child : Node
      last_child { raise NilAssertionError.new("Expected #last_child to not be nil") }
    end

    def last_child? : Node?
      last_child { nil }
    end

    def last_child(&)
      @children.tail || yield
    end

    def each_child(& : Node ->) : Nil
      if child = first_child?
        yield child

        while child = child.next_sibling?
          yield child
        end
      end
    end

    # def node_value : String?
    #   nil
    # end

    def text_content : String?
    end

    def text_content(str : String::Builder) : Nil
    end

    # Merges contiguous text nodes into a single node.
    # Applies to the whole subtree.
    def normalize : Nil
      return unless node = @children.head
      text : Text? = nil

      while node
        next_sibling = node.next_sibling?

        if node.is_a?(Text)
          if text
            # merge contiguous text nodes
            text.data += node.data

            # remove now obsolete node
            text.next_sibling = next_sibling
            next_sibling.previous_sibling = node if next_sibling
            node.link(nil, nil, nil)
          else
            text = node
          end
        else
          node.normalize
          text = nil
        end

        node = next_sibling
      end
    end

    # Replaces cdata sections with a text node.
    # Merges contiguous text nodes into a single node.
    # Removes comment nodes.
    # Applies to the whole subtree.
    def canonicalize : Nil
      return unless node = @children.head
      text : Text? = nil

      while node
        next_sibling = node.next_sibling?

        case node
        when Text
          if text
            # merge contiguous text nodes
            text.data += node.data

            # remove now obsolete node
            text.next_sibling = next_sibling
            next_sibling.previous_sibling = node if next_sibling
            node.link(nil, nil, nil)
          else
            text = node
          end
        when CDataSection
          if text
            # merge contiguous text nodes
            text.data += node.data

            # remove now obsolete node
            text.next_sibling = next_sibling
            next_sibling.previous_sibling = node if next_sibling
            node.link(nil, nil, nil)
          else
            text = Text.new(node.data, node.owner_document)
            self.replace_child(node, child: text)
          end
        when Comment
          self.remove_child(node)
        else
          node.canonicalize
          text = nil
        end

        node = next_sibling
      end
    end

    # def clone_node(deep = false) : Node
    #   deep ? clone : dup
    # end

    def ==(other : Node) : Bool
      false
    end

    # @[Flags]
    # enum DocumentPosition
    #   DISCONNECTED = 0x01
    #   PRECEDING = 0x02
    #   FOLLOWING = 0x04
    #   CONTAINS = 0x08
    #   CONTAINED_BY = 0x10
    #   IMPLEMENTATION_SPECIFIC = 0x20
    # end

    # def compare_document_position : DocumentPosition
    # end

    def append(node : Node) : Nil
      node.relink(self, @children.tail, nil)
      node.owner_document = owner_document

      if tail = @children.tail
        tail.next_sibling = node
        @children.tail = node
      else
        @children.head = node
        @children.tail = node
      end
    end

    def insert(node : Node, *, before : Node?) : Nil
      raise Error.new("not a child of node") unless before.parent_node?.try(&.same?(self))

      node.relink(self, before.previous_sibling?, before)
      node.owner_document = owner_document

      if n = before.previous_sibling?
        n.next_sibling = node
      else
        @children.head = node
      end
      before.previous_sibling = node
    end

    def insert(node : Node, *, after : Node?) : Nil
      raise Error.new("not a child of node") unless after.parent_node?.try(&.same?(self))

      node.relink(self, after, after.next_sibling?)
      node.owner_document = owner_document

      if n = after.next_sibling?
        n.previous_sibling = node
      else
        @children.tail = node
      end
      after.next_sibling = node
    end

    def replace_child(node : Node, *, child : Node) : Nil
      raise Error.new("not a child of node") unless node.parent_node?.try(&.same?(self))

      # insert child in place of the node
      child.link(self, node.previous_sibling?, node.next_sibling?)
      @children.head = child unless node.previous_sibling?
      @children.tail = child unless node.next_sibling?

      # unlink replaced node
      node.link(nil, nil, nil)
    end

    def remove_child(node : Node) : Nil
      raise Error.new("not a child of node") unless node.parent_node?.try(&.same?(self))

      unlink_child(node)
      node.unlink_siblings
      node.link(nil, nil, nil)
    end

    protected def owner_document=(@owner_document : Document?)
    end

    protected def parent_node=(@parent_node : Node?)
    end

    protected def previous_sibling=(@previous_sibling : Node?)
    end

    protected def next_sibling=(@next_sibling : Node?)
    end

    protected def relink(parent_node, previous_sibling, next_sibling) : Nil
      parent_node?.try(&.unlink_child(self))
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

    protected def unlink_child(node : Node) : Nil
      if @children.head.same?(node)
        @children.head = node.next_sibling?
      end
      if @children.tail.same?(node)
        @children.tail = node.previous_sibling?
      end
    end

    # :nodoc:
    def inspect(io : IO, indent = 0) : Nil
      indent.times { io << ' ' }
      io << '#' << self.class.name << '\n'
      # each_child { |child| child.inspect(io, indent + 2) }
    end

    abstract def clone : self
  end
end
