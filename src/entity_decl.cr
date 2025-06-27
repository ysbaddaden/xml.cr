module XML
  abstract class EntityDecl
    class Internal < EntityDecl
      property? parameter : Bool
      property value : String

      def initialize(@name, @parameter, @value)
      end
    end

    class External < EntityDecl
      property? parameter : Bool
      property public_id : String?
      property system_id : String?

      def initialize(@name, @parameter, @public_id, @system_id)
      end

      def external?
        true
      end
    end

    class Unparsed < EntityDecl
      property public_id : String?
      property system_id : String?
      property notation_id : String

      def initialize(@name, @public_id, @system_id, @notation_id)
      end

      def external?
        true
      end
    end

    property name : String

    private def initialize(@name : String)
    end

    def parameter?
      false
    end

    def external?
      false
    end
  end
end
