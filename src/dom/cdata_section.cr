# Copyright 2025 Julien PORTALIER
# Distributed under the Apache-2.0 LICENSE

require "./character_data"

module XML::DOM
  class CDataSection < CharacterData
    def ==(other : CDataSection) : Bool
      @data == other.data
    end
  end
end
