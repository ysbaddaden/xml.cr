class XML::SAX
  # :nodoc:
  class Attribute
    getter type : Symbol
    getter names : Array(String)?
    getter default : Symbol
    getter value : String?

    def initialize(@type : Symbol, @names : Array(String)?, @default : Symbol, @value : String?)
    end

    def cdata? : Bool
      @type == :CDATA
    end

    def required? : Bool
      @default == :REQUIRED
    end

    def implied? : Bool
      @default == :IMPLIED
    end

    def default? : String?
      @value if @default == :FIXED
    end
  end

  # :nodoc:
  alias Attributes = Hash(String, Attribute)
end
