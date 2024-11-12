require "./location"

module CRXML
  class Lexer
    abstract struct Token
      getter start_location : Location
      getter end_location : Location

      private def initialize(@start_location, @end_location)
      end
    end

    struct Text < Token
      getter content : String

      def initialize(@content, @start_location, @end_location)
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

    struct SDoctype < Token
      getter name : String
      getter public_id : String?
      getter system_id : String?

      def initialize(@name, @public_id, @system_id, @start_location, @end_location)
      end
    end

    struct EDoctype < Token
      def initialize(@start_location, @end_location)
      end
    end

    struct Attribute < Token
      getter name : String
      getter value : String

      def initialize(@name, @value, @start_location, @end_location)
      end
    end

    struct Comment < Token
      getter content : String

      def initialize(@content, @start_location, @end_location)
      end
    end

    struct CDATA < Token
      getter content : String

      def initialize(@content, @start_location, @end_location)
      end
    end

    struct XmlDecl < Token
      def initialize(@start_location, @end_location)
      end
    end

    struct PI < Token
      getter name : String
      getter content : String

      def initialize(@name, @content, @start_location, @end_location)
      end
    end
  end
end
