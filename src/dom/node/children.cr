# Copyright 2025 Julien PORTALIER
# Distributed under the Apache-2.0 LICENSE

module XML::DOM
  abstract class Node
    # :nodoc:
    struct Children
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

      def [](index : Int32) : Node?
        each_with_index do |node, i|
          return node if i == index
        end
      end

      def empty? : Bool
        @head.nil?
      end

      def size : Int32
        count = 0
        each { count += 1 }
        count
      end

      def clear : Nil
        @head = @tail = nil
      end
    end
  end
end
