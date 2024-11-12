module CRXML
  class XMLDocument < Document
    property version : String
    property encoding : String
    property standalone : String?

    def initialize(@version = "1.0", @encoding = "UTF-8", @standalone = nil)
      super()
    end
  end
end
