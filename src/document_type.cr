module CRXML
  class DocumentType < Node
    include DOM::ChildNode

    property name : String
    property public_id : String
    property system_id : String

    getter children : Children = Children.new

    def initialize(@name, @public_id, @system_id, @owner_document)
    end

    def inspect(io : IO, indent = 0) : Nil
      indent.times { io << ' ' }
      io << '#' << self.class.name
      io << " name=" << name
      io << " public_id=" << public_id unless public_id.blank?
      io << " system_id=" << system_id unless system_id.blank?
      io << '\n'
      each_child { |child| child.inspect(io, indent + 2) }
    end
  end
end
