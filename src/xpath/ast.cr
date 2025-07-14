module XML
  module XPath
    enum Axis
      Ancestor = 1
      AncestorOrSelf
      Attribute
      Child
      Descendant
      DescendantOrSelf
      Following
      FollowingSibling
      Namespace
      Parent
      Preceding
      PrecedingSibling
      Self

      def self.from(name : String) : self
        case name
        when "ancestor"           then Ancestor
        when "ancestor-or-self"   then AncestorOrSelf
        when "attribute"          then Attribute
        when "child"              then Child
        when "descendant"         then Descendant
        when "descendant-or-self" then DescendantOrSelf
        when "following"          then Following
        when "following-sibling"  then FollowingSibling
        when "namespace"          then Namespace
        when "parent"             then Parent
        when "preceding"          then Preceding
        when "preceding-sibling"  then PrecedingSibling
        when "self"               then Self
        else raise "BUG: invalid axis name"
        end
      end
    end

    enum Operator
      Add = 1
      Sub
      Mul
      Div
      Mod
      Or
      And
      Equal
      NotEqual
      LowerThan
      LowerThanOrEqual
      GreaterThan
      GreaterThanOrEqual

      def self.from(value : String) : self
        case value
        when "+"   then Add
        when "-"   then Sub
        when "*"   then Mul
        when "div" then Div
        when "mod" then Mod
        when "or"  then Or
        when "and" then And
        when "="   then Equal
        when "!="  then NotEqual
        when "<"   then LowerThan
        when "<="  then LowerThanOrEqual
        when ">"   then GreaterThan
        when ">="  then GreaterThanOrEqual
        else raise "BUG: invalid operator"
        end
      end
    end

    abstract struct NodeTest
      struct Any < NodeTest
      end

      struct Node < NodeTest
      end

      struct Text < NodeTest
      end

      struct Comment < NodeTest
      end

      struct ProcessingInstruction < NodeTest
        getter? name : String?

        def initialize(@name)
        end

        def_equals @name
      end

      struct Name < NodeTest
        getter name : String

        def initialize(@name)
        end

        def_equals @name
      end
    end

    abstract class Expr
    end

    class BinaryExpr < Expr
      getter operator : Operator
      getter lhs : Expr
      getter rhs : Expr

      def initialize(@operator, @lhs, @rhs)
      end

      def_equals @operator, @lhs, @rhs
    end

    class UnaryExpr < Expr
      getter expr : Expr

      def initialize(@expr)
      end

      def operator : Operator
        Operator::Sub
      end

      def_equals @expr
    end

    class Literal < Expr
      getter value : Float64 | String

      def self.number(value : Int::Signed) : self
        new value.to_f64
      end

      def self.number(value : Float64) : self
        new value
      end

      def self.string(value : String) : self
        new value
      end

      def initialize(@value)
      end

      def_equals @value
    end

    class FunctionCall < Expr
      getter name : String
      getter! arguments : Array(Expr)

      def initialize(@name, @arguments = nil)
      end

      def_equals @name, @arguments
    end

    class VariableReference < Expr
      getter name : String

      def initialize(@name)
      end

      def_equals @name
    end

    class FilterExpr < Expr
      getter expr : Expr
      getter! predicates : Array(Expr)

      def initialize(@expr, @predicates = nil)
      end

      def_equals @expr, @predicates
    end

    class Path < Expr
      enum Kind
        Absolute
        Relative
        Filter
      end

      getter kind : Kind
      getter! filter : Expr
      getter! steps : Array(Step)

      def self.absolute(steps = nil)
        new(:absolute, nil, steps)
      end

      def self.relative(steps)
        new(:relative, nil, steps)
      end

      def self.filter(expr, steps)
        new(:filter, expr, steps)
      end

      def initialize(@kind, @filter, @steps)
      end

      def absolute? : Bool
        @kind.absolute?
      end

      def root? : Bool
        absolute? && @steps.nil?
      end

      def relative? : Bool
        @kind.relative?
      end

      def_equals @kind, @filter, @steps
    end

    class Step < Expr
      def self.abbreviated : self
        new(Axis::DescendantOrSelf, NodeTest::Node.new, nil)
      end

      getter axis : Axis
      getter node_test : NodeTest
      getter! predicates : Array(Expr)

      def initialize(@axis, @node_test, @predicates = nil)
      end

      def_equals @axis, @node_test, @predicates
    end
  end
end
