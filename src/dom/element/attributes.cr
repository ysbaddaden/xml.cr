# Copyright 2025 Julien PORTALIER
# Distributed under the Apache-2.0 LICENSE

module XML::DOM
  class Element < Node
    class Attributes
      protected property head : Attribute?
      protected property tail : Attribute?

      def initialize(@owner_element : Element)
      end

      def each(& : Attribute ->) : Nil
        node = @head
        while node
          yield node.as(Attribute)
          node = node.next_sibling?
        end
      end

      def each_with_index(& : Attribute, Int32 ->) : Nil
        index = -1
        each { |attr| yield attr, index += 1 }
      end

      def [](index : Int32) : Attribute
        each_with_index do |attr, i|
          return attr if i == index
        end
      end

      def [](name : String) : Attribute
        self[name]? || raise KeyError.new "Missing attribute: #{name.inspect}"
      end

      def []?(name : String) : Attribute?
        each do |attr|
          return attr if attr.name == name
        end
      end

      def []=(name : String, value : V) : V forall V
        each do |attr|
          if attr.name == name
            attr.value = value.to_s
            return value
          end
        end

        attr = Attribute.new(name, value.to_s, @owner_element)

        if tail = @tail
          attr.previous_sibling = tail
          tail.next_sibling = attr
          @tail = attr
        else
          @head = @tail = attr
        end

        value
      end

      def delete(name : String) : String?
        each do |attr|
          if attr.name == name
            attr.unlink_siblings
            attr.relink(nil, nil, nil)
            return attr.value
          end
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
