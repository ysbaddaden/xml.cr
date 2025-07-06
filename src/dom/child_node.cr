# Copyright 2025 Julien PORTALIER
# Distributed under the Apache-2.0 LICENSE

module XML::DOM
  module ChildNode
    def before(*nodes : Node) : Nil
      before(nodes)
    end

    def before(nodes : Enumerable(Node)) : Nil
      return if nodes.empty?

      nodes.each do |node|
        # unlink node from wherever it may be
        node.parent_node?.try(&.unlink_child(node))
        node.unlink_siblings

        # set new parent
        node.owner_document = owner_document
        node.parent_node = parent_node
      end

      # link the nodes
      nodes.each_cons do |a, b|
        a.next_sibling = b
        b.previous_sibling = a
      end

      # actual insert
      first, last = nodes.first, nodes.last

      self.previous_sibling = last
      last.next_sibling = self

      if n = first.previous_sibling = previous_sibling?
        n.next_sibling = first
        first.previous_sibling = n
      else
        parent_node.as(ParentNode).@children.head = first
      end
    end

    def after(*nodes : Node) : Nil
      after(nodes)
    end

    def after(nodes : Enumerable(Node)) : Nil
      return if nodes.empty?

      nodes.each do |node|
        # unlink node from wherever it may be
        node.parent_node?.try(&.unlink_child(node))
        node.unlink_siblings

        # set new parent
        node.owner_document = owner_document
        node.parent_node = parent_node
      end

      # link the nodes
      nodes.each_cons do |a, b|
        a.next_sibling = b
        b.previous_sibling = a
      end

      # actual insert
      first, last = nodes.first, nodes.last

      self.next_sibling = first
      first.previous_sibling = self

      if n = last.next_sibling = next_sibling?
        n.previous_sibling = last
        last.next_sibling = n
      else
        parent_node.as(ParentNode).@children.tail = last
      end
    end

    # def replace_with(*nodes : Node) : Nil
    # end

    def remove : Nil
      relink(nil, nil, nil)
    end
  end
end
