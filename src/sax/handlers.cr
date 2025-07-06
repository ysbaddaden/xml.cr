# Copyright 2025 Julien PORTALIER
# Distributed under the Apache-2.0 LICENSE

module XML
  class SAX
    class Handlers
      # Called for XML declarations.
      #
      # - *version* defaults to `"1.0"`.
      # - *encoding* may be nil, in which case the parser assumes UTF-8 or the detected encoding.
      # - *standalone* will be nil when unspecified.
      def xml_decl(version : String, encoding : String?, standalone : Bool?) : Nil
      end

      # Called for text declarations in parsed external entities.
      #
      # - *version* defaults to `"1.0"`.
      # - *encoding* may be nil, in which case the parser assumes UTF-8 or the detected encoding.
      def text_decl(version : String, encoding : String?) : Nil
      end

      # Called at the start of a DOCTYPE declaration.
      #
      # - *name* is the root element name.
      # - *system_id* and *public_id* will be nil when unspecified.
      # - *intsubset* is true when the doctype has an internal subset declaration.
      def start_doctype_decl(name : String, system_id : String?, public_id : String?, intsubset : Bool)
      end

      # Called at the and of a DOCTYPE declaration.
      def end_doctype_decl : Nil
      end

      # Called for attribute declarations in a DTD.
      #
      # Called for every attribute in attlist declaration: if an attlist has
      # multiple attribute declarations, the method will be called for each one.
      #
      # - *element_name* is the element name the attribute is declared for.
      # - *name* is the attribute name.
      # - *type* is the attribute type as a symbol, for example `:CDATA`, `:IDREFS`, `:NOTATION` or `:ENUMERATION`.
      # - *names* an array of names if type is `:NOTATION` or `:ENUMERATION`, nil otherwise.
      # - *default* can be `:REQUIRED`, `:IMPLIED` or `:FIXED`.
      # - *value* is the default value when *default* is `:FIXED`, nil otherwise.
      def attlist_decl(element_name : String, name : String, type : Symbol, names : Array(String)?, default : Symbol, value : String?) : Nil
      end

      # Called for element declarations in a DTD.
      #
      # - *name* is the declared element name.
      # - *content* is the declared element model.
      def element_decl(name : String, content : ElementDecl) : Nil
      end

      # Called for entity declarations in a DTD.
      #
      # - *entity* is the declared entity definition.
      def entity_decl(entity : Entity) : Nil
      end

      # Called for notation declarations in a DTD.
      #
      # - *name* is the declared notation name.
      # - *system_id* and *public_id* will be nil when unspecified.
      def notation_decl(name : String, public_id : String?, system_id : String?) : Nil
      end

      # Called for processing instructions.
      #
      # - *target* is the first word in the processing instruction.
      # - *data* is the rest of the instruction.
      def processing_instruction(target : String, data : String) : Nil
      end

      # Called at the start of an element tag.
      #
      # - *name* is the tag name.
      # - *attributes* is an array of attribute name/value tuples.
      #
      # The attributes array presents the attributes in the order they have been
      # parsed. If an attribute is present twice with the same name, there will
      # be two entries in the array.
      def start_element(name : String, attributes : Array({String, String})) : Nil
      end

      # Called at the end of an element tag.
      def end_element(name : String) : Nil
      end

      # Called for an empty element tag.
      #
      # See `#start_element` for details.
      #
      # Unless overridden, calls `#start_element` then `#end_element` by default.
      def empty_element(name : String, attributes : Array({String, String})) : Nil
        start_element(name, attributes)
        end_element(name)
      end

      # Called for text.
      #
      # It might be called multiple times for a single contiguous text in a XML
      # document (for example because we processed an entity). You might have to
      # concatenate *data* when searching for some pattern in text, or to build
      # a single text node in a DOM tree.
      def character_data(data : String) : Nil
      end

      # Called when trying to open an external entity or doctype.
      #
      # The IO should be closed after the block has returned.
      def open_external(base : String?, uri : String, & : (String, IO) ->) : Nil
      end

      def open_external(base : String?, uri : String) : {String, IO}?
      end

      # Called when trying to expand an undeclared or invalid entity within
      # character data.
      def entity_reference(name : String)
      end

      # Called for comments.
      #
      # - *data* is all the text inside the comment.
      def comment(data : String) : Nil
      end

      # Called for CDATA sections.
      #
      # - *data* is all the text inside the data section.
      def cdata_section(data : String) : Nil
      end

      # Called when a recoverable error happens.
      #
      # - *message* details the error.
      # - *location* is the line/column where the parser reached the error.
      #
      # Unless overridden, raises an `Error` by default.
      def error(message : String, location : Location)
        raise Error.new(message, location)
      end
    end
  end
end
