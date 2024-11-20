require "./location"
require "../dom/att_def"

module CRXML
  class Lexer
    abstract struct Token
      getter start_location : Location
      getter end_location : Location

      private def initialize(@start_location, @end_location)
      end
    end

    struct XMLDecl < Token
      def initialize(@start_location, @end_location)
      end
    end

    struct Doctype < Token
      getter name : String
      getter public_id : String?
      getter system_id : String?

      def initialize(@name, @public_id, @system_id, @start_location, @end_location)
      end
    end

    struct AttlistDecl < Token
      getter name : String
      getter defs : Array(DOM::AttDef)

      def initialize(@name, @defs, @start_location, @end_location)
      end
    end

    struct ElementDecl < Token
      getter name : String
      getter content : String

      def initialize(@name, @content, @start_location, @end_location)
      end
    end

    struct EntityDecl < Token
      getter parameter : Bool
      getter name : String
      getter value : String?
      getter public_id : String?
      getter system_id : String?
      getter notation_id : String?

      def initialize(@parameter, @name, @value, @public_id, @system_id, @notation_id, @start_location, @end_location)
      end

      def general? : Bool
        !@parameter
      end

      def internal? : Bool
        !@value.nil?
      end

      def external? : Bool
        !(@public_id.nil? && @system_id.nil?)
      end

      def unparsed? : Bool
        !@notation_id.nil?
      end
    end

    struct NotationDecl < Token
      getter name : String
      getter public_id : String?
      getter system_id : String?

      def initialize(@name, @public_id, @system_id, @start_location, @end_location)
      end
    end

    struct STag < Token
      getter name : String

      def initialize(@name, @start_location, @end_location)
      end
    end

    struct ETag < Token
      getter name : String

      def initialize(@name, @start_location, @end_location)
      end
    end

    struct Attribute < Token
      getter name : String
      getter! value : String

      def initialize(@name, @value, @start_location, @end_location)
      end
    end

    struct Text < Token
      getter data : String

      def initialize(@data, @start_location, @end_location)
      end
    end

    struct Comment < Token
      getter data : String

      def initialize(@data, @start_location, @end_location)
      end
    end

    struct CDATA < Token
      getter data : String

      def initialize(@data, @start_location, @end_location)
      end
    end

    struct PI < Token
      getter name : String
      getter data : String

      def initialize(@name, @data, @start_location, @end_location)
      end
    end

    struct EntityRef < Token
      getter name : String

      def initialize(@name, @start_location, @end_location)
      end
    end

    struct PEReference < Token
      getter name : String

      def initialize(@name, @start_location, @end_location)
      end
    end
  end
end
