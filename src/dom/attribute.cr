# Copyright 2025 Julien PORTALIER
# Distributed under the Apache-2.0 LICENSE

require "./node"
require "./element"

module XML::DOM
  # TODO: namespaces
  class Attribute < Node
    property name : String
    property value : String
    property owner_element : Element

    def initialize(@name : String, @value : String, @owner_element : Element)
      @owner_document = @owner_element.owner_document
    end

    # getter namespace_uri : String?
    # getter prefix : String?
    # getter local_name : String

    # def node_value : String
    #   @value
    # end

    # :nodoc:
    def to_s : String
      io << @value
    end

    # :nodoc:
    def to_s(io : IO) : String
      io << @value
    end

    def clone : self
      dup
    end
  end
end
