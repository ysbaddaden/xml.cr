# Copyright 2025 Julien PORTALIER
# Distributed under the Apache-2.0 LICENSE

require "./character_data"

module XML::DOM
  class Comment < CharacterData
    def text_content : Nil
    end

    protected def text_content(str : String::Builder) : Nil
      # do nothing
    end

    def ==(other : Comment) : Bool
      @data == other.data
    end
  end
end
