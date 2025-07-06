require "../dom"
require "../sax"

module XML::DOM
  def self.parse(io : IO, base : String? = nil) : DOM::XMLDocument
    parser = DOM::Parser.new(io)
    parser.base = base
    parser.parse
    parser.document
  end

  class Parser < SAX::Handlers
    getter document : XMLDocument
    @node : Node

    # :nodoc:
    enum State
      XMLDECL
      PROLOG
      DOCTYPE
      CONTENT
      MISC
    end

    def initialize(io : IO)
      @document = XMLDocument.new("1.0", nil, nil)
      @node = @document
      @state = State::XMLDECL
      @sax = uninitialized SAX
      @sax = SAX.new(io, self)
    end

    def base : String?
      @sax.base
    end

    def base=(value : String?)
      @sax.base = value
    end

    def parse : Nil
      @sax.parse

      unless @document.root?
        error "No root element", @sax.location
      end

      unless @node == @document
        error "Missing end element", @sax.location
      end
    end

    def xml_decl(version : String, encoding : String?, standalone : Bool?) : Nil
      expect :XMLDECL
      @document.reinitialize(version, encoding, standalone)
      @state = State::PROLOG
    end

    def start_doctype_decl(name : String, system_id : String?, public_id : String?, intsubset : Bool)
      expect :PROLOG, :XMLDECL

      doctype = DocumentType.new(name, system_id, public_id, @document)
      @document.doctype = doctype

      @node = doctype
      @state = State::DOCTYPE
    end

    def end_doctype_decl : Nil
      # expect :DOCTYPE
      @node = @document
      @state = State::PROLOG
    end

    def entity_decl(entity : SAX::Entity) : Nil
      expect :DOCTYPE
      unless entity.parameter? || entity.internal?
        @document.doctype.entities[entity.name] = Entity.new(entity.public_id?, entity.system_id?, entity.notation_name?, @document)
      end
    end

    def notation_decl(name : String, public_id : String?, system_id : String?) : Nil
      expect :DOCTYPE
      @document.doctype.notations[name] = Notation.new(public_id, system_id, @document)
    end

    def comment(data : String) : Nil
      @node.append(Comment.new(data, @document))
    end

    def processing_instruction(target : String, data : String) : Nil
      @node.append(ProcessingInstruction.new(target, data, @document))
    end

    def start_element(name : String, attributes : Array({String, String})) : Nil
      expect :CONTENT, :PROLOG, :XMLDECL
      @node = start_element_impl(name, attributes)
    end

    protected def start_element_impl(name, attributes)
      element = Element.new(name, @document)

      attributes.each do |(k, v)|
        if element.attributes[k]?
          error "Duplicate attribute name #{k.inspect}", @sax.location
        end
        element.attributes[k] = v
      end

      if @node.is_a?(Document)
        # WF: element.name should eq document.doctype.name (if doctype)
        raise SAX::Error.new("Document can't have multiple root elements", @sax.location) if @document.root?
        @document.root = element
        @state = State::CONTENT
      else
        @node.append(element)
      end

      element
    end

    def end_element(name : String) : Nil
      expect :CONTENT
      if (curr = @node).is_a?(Element) && (curr.name != name)
        raise SAX::Error.new("End tag mismatch: expected #{curr.name.inspect} but got #{name.inspect}", @sax.location)
      end
      if parent = @node.parent_node?
        @node = parent
      else
        @node = @document
        @state = State::MISC
        @sax.ignore_whitespace = true
      end
    end

    def empty_element(name : String, attributes : Array({String, String})) : Nil
      start_element(name, attributes)
      end_element(name)
    end

    def character_data(data : String) : Nil
      expect :CONTENT
      @node.append(Text.new(data, document))
    end

    def entity_reference(name : String) : Nil
      expect :CONTENT
      @node.append(EntityReference.new(name, document))
    end

    def cdata_section(data : String) : Nil
      expect :CONTENT
      @node.append(CDataSection.new(data, document))
    end

    protected def expect(*states : State)
      return if states.any? { |state| @state == state }
      raise SAX::Error.new("Expected #{states.join(" or ")}", @sax.location)
    end
  end
end
