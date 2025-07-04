require "./node"

module XML::DOM
  class DocumentFragment < Node
    include NonElementParentNode
    include ParentNode

    def initialize(@owner_document : Document)
    end

    def clone : self
      copy = DocumentFragment.new(@owner_document)
      each_child { |child| copy.append(child.clone) }
      copy
    end
  end
end
