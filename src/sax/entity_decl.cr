# Copyright 2025 Julien PORTALIER
# Distributed under the Apache-2.0 LICENSE

module XML
  class SAX
    abstract class EntityDecl
      class Internal < EntityDecl
        property? parameter : Bool
        property value : String
        property location : Location
        getter? needs_processing : Bool

        def initialize(@name, @parameter, @value, @location)
          @needs_processing =
            @value.includes?('<') ||
            @value.includes?('&') ||
            (@parameter && @value.includes?('%'))
        end
      end

      class External < EntityDecl
        property? parameter : Bool
        property public_id : String?
        property system_id : String?

        def initialize(@name, @parameter, @public_id, @system_id)
        end

        def external? : Bool
          true
        end
      end

      class Unparsed < EntityDecl
        property public_id : String?
        property system_id : String?
        property notation_id : String

        def initialize(@name, @public_id, @system_id, @notation_id)
        end

        def external? : Bool
          true
        end
      end

      property name : String

      private def initialize(@name : String)
      end

      def parameter? : Bool
        false
      end

      def external? : Bool
        false
      end
    end
  end
end
