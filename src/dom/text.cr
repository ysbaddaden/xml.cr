require "./character_data"

module XML::DOM
  class Text < CharacterData
    def ==(other : Text) : Bool
      @data == other.data
    end
  end
end
