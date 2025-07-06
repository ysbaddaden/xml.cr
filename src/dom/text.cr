# Copyright 2025 Julien PORTALIER
# Distributed under the Apache-2.0 LICENSE

require "./character_data"

module XML::DOM
  class Text < CharacterData
    def ==(other : Text) : Bool
      @data == other.data
    end
  end
end
