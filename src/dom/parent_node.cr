module CRXML::DOM::ParentNode
  getter children : Children = Children.new

  def first_element_child : Element
    first_element_child { raise NilAssertionError.new("Expected #first_element_child to not be nil") }
  end

  def first_element_child? : Element?
    first_element_child { nil }
  end

  def first_element_child(&)
    case node = @children.head
    when Element
      node
    when NonDocumentTypeChildNode
      node.next_element_sibling { yield }
    else
      yield
    end
  end

  def last_element_child : Element
    last_element_child { raise NilAssertionError.new("Expected #first_element_child to not be nil") }
  end

  def last_element_child? : Element?
    last_element_child { nil }
  end

  def last_element_child(&)
    case node = @children.tail
    when Element
      node
    when NonDocumentTypeChildNode
      node.previous_element_sibling { yield }
    else
      yield
    end
  end

  # def child_element_count : Int32

  def each_element_child(& : Element ->) : Nil
    if child = first_element_child?
      yield child

      while child = child.next_element_sibling?
        yield child
      end
    end
  end

  # def prepend(*nodes : Node) : Nil
  # def append(*nodes : Node) : Nil
  # def replace_children(*nodes : Node) : Nil
end
