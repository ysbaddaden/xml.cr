# Copyright 2025 Julien PORTALIER
# Distributed under the Apache-2.0 LICENSE

require "./node"
require "./element/attributes"

module XML::DOM
  class Element < Node
    include ParentNode
    include ChildNode
    include NonDocumentTypeChildNode

    getter name : String

    def initialize(@name : String, @owner_document : Document)
    end

    def attributes : Attributes
      @attributes ||= Attributes.new(self)
    end

    def text_content : String
      String.build { |str| text_content(str) }
    end

    protected def text_content(str : String::Builder) : Nil
      @children.each(&.text_content(str))
    end

    # def closest(selectors : String) : Element?
    # def matches(selectors : String) : Bool

    # def each_by(**options, & : Node ->)
    # def each_element_by(name : String, & : Element ->) : Nil
    # def each_element_by(class : String, & : Element ->) : Nil

    # def get_elements_by(name : String) : Array(Element)
    # def get_elements_by(class : String) : Array(Element)

    def ==(other : Element) : Bool
      return true if same?(other)
      return true if @name == other.name

      # compare attributes (move to Attributes#== ?)
      a_count = @attributes.try(&.size) || 0
      b_count = other.@attributes.try(&.size) || 0
      return false unless a_count == b_count

      unless a_count == 0
        attributes.each do |attr|
          return false unless other_attr = other.attributes[attr.name]?
          return false unless attr.value == other_attr.value
        end
      end

      # compare sub-trees
      a_count = @children.size
      b_count = other.@children.size
      return false unless a_count == b_count

      unless a_count == 0
        a = first_child
        b = other.first_child
        return false unless a == b

        while (a = a.next_sibling?) && (b.next_sibling?)
          return false unless a == b
        end
      end

      true
    end

    # :nodoc:
    def inspect(io : IO, indent = 0) : Nil
      indent.times { io << ' ' }
      io << '#' << self.class.name << ' ' << name

      attrs = [] of {String, String}
      attributes.each { |attr| attrs << {attr.name, attr.value} }
      attrs.sort_by!(&.first)

      attrs.each do |(name, value)|
        io << ' ' << name << '='
        value.inspect(io)
      end
      io << '\n'
      each_child(&.inspect(io, indent + 2))
    end

    def clone : self
      copy = Element.new(@name, @owner_document)

      if (attrs = @attributes) && !attrs.empty?
        attrs.each do |attr|
          copy.attributes[attr.name] = attr.value
        end
      end

      each_child do |child|
        copy.append(child.clone)
      end

      copy
    end
  end
end
