module CRXML
  class DocumentFragment < Node
    include DOM::NonElementParentNode
    include DOM::ParentNode

    def initialize(@owner_document : Document)
    end

    def clone : self
      copy = DocumentFragment.new(@owner_document)
      each_child { |child| copy.append(child.clone) }
      copy
    end
  end
end
