module XML::DOM
  module NonDocumentTypeChildNode
    def previous_element_sibling : Element
      previous_element_sibling { raise NilAssertionError.new("Expected #previous_element_sibling to not be nil") }
    end

    def previous_element_sibling? : Element?
      previous_element_sibling { nil }
    end

    def previous_element_sibling(&)
      node = @previous_sibling

      while node
        return node if node.is_a?(Element)
        node = node.@previous_sibling
      end

      yield
    end

    def next_element_sibling : Element
      next_element_sibling { raise NilAssertionError.new("Expected #next_element_sibling to not be nil") }
    end

    def next_element_sibling? : Element?
      next_element_sibling { nil }
    end

    def next_element_sibling(&)
      node = @next_sibling

      while node
        return node if node.is_a?(Element)
        node = node.@next_sibling
      end

      yield
    end
  end
end
