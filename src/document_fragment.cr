module CRXML
  class DocumentFragment < Node
    include DOM::NonElementParentNode
    include DOM::ParentNode

    def initialize(@owner_document : Document)
    end
  end
end
