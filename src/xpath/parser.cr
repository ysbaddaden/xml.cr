require "./ast"
require "./lexer"

module XML
  module XPath
    class Parser
      alias Kind = Lexer::Kind

      def initialize(@lexer : Lexer)
      end

      def parse
        parse_or_expr
      end

      protected def parse_or_expr
        parse_binary_expr("or", proc: ->parse_and_expr)
      end

      protected def parse_and_expr
        parse_binary_expr("and", proc: ->parse_equality_expr)
      end

      protected def parse_equality_expr
        parse_binary_expr("=", "!=", proc: ->parse_relational_expr)
      end

      protected def parse_relational_expr
        parse_binary_expr("<", "<=", ">", ">=", proc: ->parse_additive_expr)
      end

      protected def parse_additive_expr
        parse_binary_expr("+", "-", proc: ->parse_multiplicative_expr)
      end

      protected def parse_multiplicative_expr
        parse_binary_expr("*", "div", "mod", proc: ->parse_unary_expr)
      end

      protected def parse_unary_expr
        if @lexer.operator?("-")
          expr = parse_unary_expr
          UnaryExpr.new(expr)
        else
          parse_union_expr
        end
      end

      protected def parse_union_expr
        parse_binary_expr("|", proc: ->parse_path_expr)
      end

      protected def parse_binary_expr(*operators : String, proc : Proc(Expr))
        expr = proc.call
        while tok = @lexer.operator?(*operators)
          rhs = proc.call
          operator = Operator.from(tok.value)
          expr = BinaryExpr.new(operator, expr, rhs)
        end
        expr
      end

      protected def parse_path_expr
        if path = parse_absolute_location_path?
          return path
        end

        if path = parse_relative_location_path?
          return path
        end

        expr = parse_filter_expr
        path = Path.filter(expr, [] of Step)

        while tok = @lexer.current?
          case tok.kind
          when Kind::Slash
            @lexer.next?
            parse_relative_location_path(path)
          when Kind::SlashSlash
            @lexer.next?
            path.steps << Step.abbreviated
            parse_relative_location_path(path)
          else
            break
          end
        end

        if path.steps.empty?
          expr
        else
          path
        end
      end

      def parse_absolute_location_path?
        case @lexer.current.kind
        when Kind::Slash
          if @lexer.next?
            path = Path.absolute([] of Step)
            parse_relative_location_path(path)
          else
            Path.absolute
          end
        when Kind::SlashSlash
          @lexer.next?
          path = Path.absolute([Step.abbreviated])
          parse_relative_location_path(path)
        end
      end

      def parse_relative_location_path(path = nil)
        parse_relative_location_path?(path) || syntax_error "Expected Path"
      end

      def parse_relative_location_path?(path = nil)
        return path unless step = parse_step?

        path ||= Path.relative([] of Step)
        path.steps << step

        while tok = @lexer.current?
          case tok.kind
          when Kind::Slash
            @lexer.next?
            path.steps << parse_step
          when Kind::SlashSlash
            @lexer.next?
            path.steps << Step.abbreviated
            path.steps << parse_step
          else
            break
          end
        end

        path
      end

      protected def parse_step
        parse_step? || syntax_error "Expected Step"
      end

      protected def parse_step?
        return unless tok = @lexer.current?

        case tok.kind
        when Kind::Dot
          @lexer.next?
          Step.new(Axis::Self, NodeTest::Node.new, nil)
        when Kind::DotDot
          @lexer.next?
          Step.new(Axis::Parent, NodeTest::Node.new, nil)
        when Kind::AxisName
          @lexer.next?
          expect Kind::ColonColon
          node_test = parse_node_test
          predicates = parse_predicates?
          Step.new(Axis.from(tok.value), node_test, predicates)
        when Kind::At
          @lexer.next?
          node_test = parse_node_test
          predicates = parse_predicates?
          Step.new(Axis::Attribute, node_test, predicates)
        else
          if node_test = parse_node_test?
            predicates = parse_predicates?
            Step.new(Axis::Child, node_test, predicates)
          end
        end
      end

      protected def parse_node_test
        parse_node_test? || syntax_error "Expected NodeTest"
      end

      protected def parse_node_test?
        case (tok = @lexer.current).kind
        when Kind::Star
          @lexer.next?
          NodeTest::Any.new
        when Kind::Name
          @lexer.next?
          NodeTest::Name.new(tok.value)
        when Kind::NodeType
          @lexer.next?
          case tok.value
          when "node"
            expect Kind::Lparen
            expect Kind::Rparen
            NodeTest::Node.new
          when "text"
            expect Kind::Lparen
            expect Kind::Rparen
            NodeTest::Text.new
          when "comment"
            expect Kind::Lparen
            expect Kind::Rparen
            NodeTest::Comment.new
          when "processing-instruction"
            expect Kind::Lparen
            tok = @lexer.literal?
            expect Kind::Rparen
            NodeTest::ProcessingInstruction.new(tok.try(&.value))
          else
            raise "BUG: invalid NodeType"
          end
        end
      end

      protected def parse_filter_expr
        expr = parse_primary_expr
        predicates = parse_predicates?

        if predicates
          FilterExpr.new(expr, predicates)
        else
          expr
        end
      end

      protected def parse_predicates
        parse_predicates || syntax_error "Expected Predicate"
      end

      protected def parse_predicates?
        predicates = nil
        while (tok = @lexer.current?) && (tok.kind == Kind::Lsqb)
          predicates ||= [] of Expr
          predicates << parse_predicate
        end
        predicates
      end

      protected def parse_predicate
        @lexer.next?
        expr = parse_or_expr
        expect Kind::Rsqb
        expr
      end

      protected def parse_primary_expr
        case (tok = @lexer.current).kind
        when Kind::Literal
          @lexer.next?
          Literal.string(tok.value)
        when Kind::Number
          @lexer.next?
          Literal.number(tok.value.to_f)
        when Kind::FunctionName
          @lexer.next?
          arguments = parse_arguments
          FunctionCall.new(tok.value, arguments)
        when Kind::Lparen
          @lexer.next?
          expr = parse_or_expr
          expect Kind::Rparen
          expr
        when Kind::VariableReference
          @lexer.next?
          VariableReference.new(tok.value)
        else
          syntax_error "Expected Literal, Number, FunctionCall, VariableReference or '('"
        end
      end

      protected def parse_arguments
        expect Kind::Lparen

        if @lexer.current.kind == Kind::Rparen
          @lexer.next?
          return
        end

        args = [] of Expr

        loop do
          args << parse_or_expr

          case @lexer.current.kind
          when Kind::Rparen
            @lexer.next?
            return args
          when Kind::Comma
            @lexer.next?
          else
            syntax_error "Expected ',' or ')'"
          end
        end
      end

      protected def expect(kind : Kind)
        if (tok = @lexer.current?) && tok.kind == kind
          @lexer.next?
        else
          syntax_error "Expected #{kind} token"
        end
      end

      protected def syntax_error(message = nil)
        raise SyntaxError.new(message, @lexer.start_location)
      end
    end
  end
end
