# Copyright 2025 Julien PORTALIER
# Distributed under the Apache-2.0 LICENSE

module XML
  class SAX
    class Entity
      getter? parameter : Bool
      getter name : String
      getter! value : String
      getter! public_id : String
      getter! system_id : String
      getter! notation_name : String
      getter! location : Location

      # :nodoc:
      def initialize(@parameter : Bool, @name : String, @value : String?, @public_id : String?, @system_id : String?, @notation_name : String?, @location : Location?)
      end

      def general? : Bool
        !@parameter
      end

      def internal? : Bool
        !@value.nil?
      end

      def external? : Bool
        !@system_id.nil?
      end

      def parsed? : Bool
        @notation_name.nil?
      end

      def unparsed? : Bool
        !@notation_name.nil?
      end
    end

    class Entities
      def initialize
        @parameters = Hash(String, Entity).new
        @generals = Hash(String, Entity).new
        @expanding = Set(Entity).new
      end

      def add(parameter : Bool, name : String, value : String?, public_id : String?, system_id : String?, notation_name : String?, location : Location?) : Entity
        entity = Entity.new(parameter, name, value, public_id, system_id, notation_name, location)
        hash = parameter ? @parameters : @generals # PE and GE use different namespaces
        hash[name] = entity unless hash[name]?     # only the first declaration encountered is binding
        entity
      end

      def general?(name : String) : Entity?
        @generals[name]?
      end

      def parameter?(name : String) : Entity?
        @parameters[name]?
      end

      def expanding?(entity : Entity, & : ->) : Bool
        if @expanding.includes?(entity)
          true
        else
          @expanding << entity
          begin
            yield
          ensure
            @expanding.delete(entity)
          end
          false
        end
      end
    end
  end
end
