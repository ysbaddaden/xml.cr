module XML
  abstract class ElementDecl
    enum Quantifier
      NONE = 0
      OPTIONAL
      REPEATED
      PLUS

      protected def to_char? : Char?
        case self
        when OPTIONAL then '?'
        when REPEATED then '*'
        when PLUS then '+'
        end
      end
    end

    class Empty < ElementDecl
      # :nodoc:
      def inspect(io : IO) : Nil
        io << "EMPTY"
      end
    end

    class Any < ElementDecl
      # :nodoc:
      def inspect(io : IO) : Nil
        io << "ANY"
      end
    end

    class Mixed < ElementDecl
      getter names : Array(String)

      def initialize(@names)
      end

      # :nodoc:
      def inspect(io : IO) : Nil
        io << "MIXED"
        return if @names.empty?

        io << '('
        @names.join(io, '|')
        io << ')'
      end
    end

    abstract class Children < ElementDecl
      property quantifier : Quantifier

      private def initialize(@quantifier)
      end
    end

    class Name < Children
      property name : String

      def initialize(@quantifier, @name)
      end

      # :nodoc:
      def inspect(io : IO) : Nil
        io << @name
        io << @quantifier.to_char?
      end
    end

    class Choice < Children
      getter children : Array(Name | Choice | Seq)

      def initialize(@quantifier, @children)
      end

      # :nodoc:
      def inspect(io : IO) : Nil
        io << "CHOICE("
        @children.each_with_index do |child, index|
          io << ", " unless index == 0
          child.inspect(io)
        end
        io << ')'
        io << @quantifier.to_char?
      end
    end

    class Seq < Children
      getter children : Array(Name | Choice | Seq)

      def initialize(@quantifier, @children)
      end

      # :nodoc:
      def inspect(io : IO) : Nil
        io << "SEQ("
        @children.each_with_index do |child, index|
          io << ", " unless index == 0
          child.inspect(io)
        end
        io << ')'
        io << @quantifier.to_char?
      end
    end
  end
end
