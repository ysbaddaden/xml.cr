require "./node"

module CRXML
  # :nodoc:
  struct NodeSet
    protected property head : Node?
    protected property tail : Node?

    def each(& : Node ->) : Nil
      node = @head
      while node
        yield node
        node = node.next_sibling?
      end
    end

    def each_with_index(& : Node, Int32 ->) : Nil
      index = -1
      each { |node| yield node, index += 1 }
    end

    # def empty? : Bool
    #   @head.nil?
    # end

    # def size : Int32
    #   count = 0
    #   each { count += 1 }
    #   count
    # end
  end
end
