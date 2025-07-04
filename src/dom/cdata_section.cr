require "./character_data"

module XML::DOM
  class CDataSection < CharacterData
    def ==(other : CDataSection) : Bool
      @data == other.data
    end
  end
end
