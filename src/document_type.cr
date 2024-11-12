module CRXML
  class DocumentType < Node
    include DOM::ChildNode

    property name : String
    property public_id : String
    property system_id : String

    def initialize(@name, @public_id, @system_id, @owner_document)
    end
  end
end
