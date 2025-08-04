require "../chars"
require "../sax/reader"

module XML
  module XPath
    class SyntaxError < Exception
      getter location : Location

      def initialize(message : String, @location : Location)
        super "#{message} at #{location}"
      end
    end

    # :nodoc:
    struct Token
      enum Kind
        Lparen
        Rparen
        Lsqb
        Rsqb
        At
        Comma
        Dot
        DotDot
        Colon
        ColonColon
        Slash
        SlashSlash
        Operator
        Star
        Number
        Literal
        VariableReference
        NodeType
        FunctionName
        AxisName
        Name
      end

      getter kind : Kind
      getter! value : String

      def initialize(@kind : Kind, @value : String? = nil)
      end

      def inspect(io : IO)
        io << '{'
        kind.to_s(io)
        if value = @value
          io << ',' << ' '
          value.inspect(io)
        end
        io << '}'
      end
    end

    # :nodoc:
    class Lexer
      alias Kind = Token::Kind

      def self.new(string : String) : self
        new SAX::Reader.new(IO::Memory.new(string))
      end

      def self.new(io : IO) : self
        new SAX::Reader.new(io)
      end

      getter start_location : Location
      @preceding : Token?

      # :nodoc:
      def initialize(@reader : SAX::Reader)
        @start_location = @reader.location
      end

      def location : Location
        @reader.location
      end

      def next? : Token?
        @reader.skip_s
        @start_location = @reader.location

        @preceding =
          case char = @reader.consume?
          when nil
            # EOF
          when '('
            Token.new(:Lparen)
          when ')'
            Token.new(:Rparen)
          when '['
            Token.new(:Lsqb)
          when ']'
            Token.new(:Rsqb)
          when '@'
            Token.new(:At)
          when ','
            Token.new(:Comma)
          when '.'
            lex_single_or_double(char, :Dot, :DotDot)
          when ':'
            lex_single_or_double(char, :Colon, :ColonColon)
          when '/'
            lex_single_or_double(char, :Slash, :SlashSlash)
          when '|'
            Token.new(:Operator, "|")
          when '*'
            lex_star_and_disambiguate
          when '+'
            Token.new(:Operator, "+")
          when '-'
            Token.new(:Operator, "-")
          when '='
            Token.new(:Operator, "=")
          when '!'
            expect '='
            Token.new(:Operator, "!=")
          when '<'
            lex_than_or_equal("<", "<=")
          when '>'
            lex_than_or_equal(">", ">=")
          when '"', '\''
            lex_literal(char)
          when '0'..'9'
            lex_number(char)
          when '$'
            lex_variable_reference
          else
            lex_name_and_disambiguate(char)
          end
      end

      protected def lex_single_or_double(char, single : Kind, double : Kind)
        if @reader.current? == char
          @reader.consume?
          Token.new(double)
        else
          Token.new(single)
        end
      end

      protected def lex_than_or_equal(than, than_or_equal)
        if @reader.peek == '='
          @reader.consume?
          Token.new(:Operator, than_or_equal)
        else
          Token.new(:Operator, than)
        end
      end

      protected def lex_star_and_disambiguate
        case @preceding.try(&.kind)
        when Kind::At, Kind::ColonColon, Kind::Lparen, Kind::Lsqb, Kind::Comma, Kind::Operator, nil
          Token.new(:Star)
        else
          Token.new(:Operator, "*")
        end
      end

      protected def lex_number(char)
        dot = false

        value = String.build do |str|
          str << char

          while char = @reader.current?
            case char
            when '0'..'9'
              # ok
            when '.'
              syntax_error "Unexpected '.'" if dot
              dot = true
            else
              break
            end
            str << char
            @reader.consume?
          end
        end
        Token.new(:Number, value)
      end

      protected def lex_literal(quote)
        value = String.build do |str|
          while char = @reader.current?
            @reader.consume?
            break if char == quote
            str << char
          end
        end
        Token.new(:Literal, value)
      end

      protected def lex_variable_reference
        value = lex_name(@reader.consume?)
        Token.new(:VariableReference, value)
      end

      protected def lex_name_and_disambiguate(char)
        value = lex_name(char)

        case @preceding.try(&.kind)
        when Kind::At, Kind::ColonColon, Kind::Lparen, Kind::Lsqb, Kind::Comma, Kind::Operator
          # not an OperatorName
        else
          case value
          when "and", "or", "mod", "div"
            return Token.new(:Operator, value)
          end
        end

        @reader.skip_s

        case @reader.current?
        when '('
          case value
          when "comment", "node", "processing-instruction", "text"
            return Token.new(:NodeType, value)
          else
            return Token.new(:FunctionName, value)
          end
        when ':'
          if @reader.peek == ':'
            case value
            when "ancestor", "ancestor-or-self", "attribute", "child", "descendant",
                 "descendant-or-self", "following", "following-sibling", "namespace",
                 "parent", "preceding", "preceding-sibling", "self"
              return Token.new(:AxisName, value)
            else
              syntax_error "Expected AxisName"
            end
          end
        end

        Token.new(:Name, value)
      end

      protected def lex_name(char) : String
        # char = @reader.current
        # syntax_error "Expected NameStartChar" unless Chars.name_start?(char)

        String.build do |str|
          str << char

          while (char = @reader.current?) && Chars.name?(char)
            break if char == ':' && @reader.peek == ':'
            str << char
            @reader.consume?
          end
        end
      end

      protected def expect(char)
        syntax_error "Expected #{char.inspect}" unless @reader.consume? == char
      end

      protected def syntax_error(message, location = @start_location)
        raise SyntaxError.new(message, location)
      end

      # Returns the current token (the last lexed token). Returns `nil` upon
      # reaching EOF.
      def current? : Token?
        @preceding ||= next?
      end

      # Returns the current token (the last lexed token).
      def current : Token
        current? || syntax_error "Expected token"
      end

      # Consumes and returns the current `Token` if the token is a syntactical
      # token (no value), such as `.`, `//` or  `[`.
      def token? : Token?
        if (tok = @preceding) && tok.value.nil?
          next?
          tok
        end
      end

      # Consumes and returns the current `Token` if the token is a literal.
      def literal? : Token?
        if (tok = @preceding) && (tok.kind == Kind::Literal)
          next?
          tok
        end
      end

      # Consumes and returns the current `Token` if the token is an operator and
      # its value is one of *values*.
      def operator?(*values : String) : Token?
        if (tok = @preceding) && (tok.kind == Kind::Operator) && tok.value.in?(values)
          next?
          tok
        end
      end
    end
  end
end
