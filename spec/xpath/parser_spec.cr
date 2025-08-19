require "minitest/autorun"
require "../../src/xpath/parser"

class XML::XPath::ParserTest < Minitest::Test
  def test_unabbreviated_syntax
    assert_parses %(child::para),
      Path.relative([Step.new(Axis::Child, NodeTest::Name.new("para"))])

    assert_parses %(child::*),
      Path.relative([Step.new(Axis::Child, NodeTest::Any.new)])

    assert_parses %(child::text()),
      Path.relative([Step.new(Axis::Child, NodeTest::Text.new)])

    assert_parses %(child::node()),
      Path.relative([Step.new(Axis::Child, NodeTest::Node.new)])

    assert_parses %(attribute::name),
      Path.relative([Step.new(Axis::Attribute, NodeTest::Name.new("name"))])

    assert_parses %(attribute::*),
      Path.relative([Step.new(Axis::Attribute, NodeTest::Any.new)])

    assert_parses %(descendant::para),
      Path.relative([Step.new(Axis::Descendant, NodeTest::Name.new("para"))])

    assert_parses %(ancestor::div),
      Path.relative([Step.new(Axis::Ancestor, NodeTest::Name.new("div"))])

    assert_parses %(ancestor-or-self::div),
      Path.relative([Step.new(Axis::AncestorOrSelf, NodeTest::Name.new("div"))])

    assert_parses %(descendant-or-self::para),
      Path.relative([Step.new(Axis::DescendantOrSelf, NodeTest::Name.new("para"))])

    assert_parses %(self::para),
      Path.relative([Step.new(Axis::Self, NodeTest::Name.new("para"))])

    assert_parses %(child::chapter/descendant::para),
      Path.relative([
        Step.new(Axis::Child, NodeTest::Name.new("chapter")),
        Step.new(Axis::Descendant, NodeTest::Name.new("para")),
      ])

    assert_parses %(child::*/child::para),
      Path.relative([
        Step.new(Axis::Child, NodeTest::Any.new),
        Step.new(Axis::Child, NodeTest::Name.new("para")),
      ])

    assert_parses %(/),
      Path.absolute

    assert_parses %(/descendant::para),
      Path.absolute([
        Step.new(Axis::Descendant, NodeTest::Name.new("para")),
      ])

    assert_parses %(/descendant::olist/child::item),
      Path.absolute([
        Step.new(Axis::Descendant, NodeTest::Name.new("olist")),
        Step.new(Axis::Child, NodeTest::Name.new("item")),
      ])

    assert_parses %(child::para[position()=1]),
      Path.relative([
        Step.new(Axis::Child, NodeTest::Name.new("para"), [
          BinaryExpr.new(Operator::Equal, FunctionCall.new("position"), Literal.number(1)),
        ] of Expr)
      ])

    assert_parses %(child::para[position()=last()]),
      Path.relative([
        Step.new(Axis::Child, NodeTest::Name.new("para"), [
          BinaryExpr.new(Operator::Equal, FunctionCall.new("position"), FunctionCall.new("last")),
        ] of Expr)
      ])

    assert_parses %(child::para[position()=last()-1]),
      Path.relative([
        Step.new(Axis::Child, NodeTest::Name.new("para"), [
          BinaryExpr.new(
            Operator::Equal,
            FunctionCall.new("position"),
            BinaryExpr.new(Operator::Sub, FunctionCall.new("last"), Literal.number(1)),
          ),
        ] of Expr)
      ])

    assert_parses %(child::para[position()>1]),
      Path.relative([
        Step.new(Axis::Child, NodeTest::Name.new("para"), [
          BinaryExpr.new(Operator::GreaterThan, FunctionCall.new("position"), Literal.number(1)),
        ] of Expr)
      ])

    assert_parses %(following-sibling::chapter[position()=1]),
      Path.relative([
        Step.new(Axis::FollowingSibling, NodeTest::Name.new("chapter"), [
          BinaryExpr.new(Operator::Equal, FunctionCall.new("position"), Literal.number(1)),
        ] of Expr)
      ])

    assert_parses %(preceding-sibling::chapter[position()=1]),
      Path.relative([
        Step.new(Axis::PrecedingSibling, NodeTest::Name.new("chapter"), [
          BinaryExpr.new(Operator::Equal, FunctionCall.new("position"), Literal.number(1)),
        ] of Expr)
      ])

    assert_parses %(/descendant::figure[position()=42]),
      Path.absolute([
        Step.new(Axis::Descendant, NodeTest::Name.new("figure"), [
          BinaryExpr.new(Operator::Equal, FunctionCall.new("position"), Literal.number(42)),
        ] of Expr)
      ])

    assert_parses %(/child::doc/child::chapter[position()=5]/child::section[position()=2]),
      Path.absolute([
        Step.new(Axis::Child, NodeTest::Name.new("doc")),
        Step.new(Axis::Child, NodeTest::Name.new("chapter"), [
          BinaryExpr.new(Operator::Equal, FunctionCall.new("position"), Literal.number(5)),
        ] of Expr),
        Step.new(Axis::Child, NodeTest::Name.new("section"), [
          BinaryExpr.new(Operator::Equal, FunctionCall.new("position"), Literal.number(2)),
        ] of Expr)
      ])

    assert_parses %(child::para[attribute::type="warning"]),
      Path.relative([
        Step.new(Axis::Child, NodeTest::Name.new("para"), [
          BinaryExpr.new(Operator::Equal, Path.relative([Step.new(Axis::Attribute, NodeTest::Name.new("type"))]), Literal.string("warning")),
        ] of Expr)
      ])

    assert_parses %(child::para[attribute::type='warning'][position()=5]),
      Path.relative([
        Step.new(Axis::Child, NodeTest::Name.new("para"), [
          BinaryExpr.new(Operator::Equal, Path.relative([Step.new(Axis::Attribute, NodeTest::Name.new("type"))]), Literal.string("warning")),
          BinaryExpr.new(Operator::Equal, FunctionCall.new("position"), Literal.number(5)),
        ] of Expr)
      ])

    assert_parses %(child::para[position()=5][attribute::type="warning"]),
      Path.relative([
        Step.new(Axis::Child, NodeTest::Name.new("para"), [
          BinaryExpr.new(Operator::Equal, FunctionCall.new("position"), Literal.number(5)),
          BinaryExpr.new(
            Operator::Equal,
            Path.relative([Step.new(Axis::Attribute, NodeTest::Name.new("type"))]),
            Literal.string("warning")
        ),
        ] of Expr)
      ])

    assert_parses %(child::chapter[child::title='Introduction']),
      Path.relative([
        Step.new(Axis::Child, NodeTest::Name.new("chapter"), [
          BinaryExpr.new(
            Operator::Equal,
            Path.relative([Step.new(Axis::Child, NodeTest::Name.new("title"))]),
            Literal.string("Introduction")),
        ] of Expr)
      ])

    assert_parses %(child::chapter[child::title]),
      Path.relative([
        Step.new(Axis::Child, NodeTest::Name.new("chapter"), [
          Path.relative([Step.new(Axis::Child, NodeTest::Name.new("title"))]),
        ] of Expr)
      ])

    assert_parses %(child::*[self::chapter or self::appendix]),
      Path.relative([
        Step.new(Axis::Child, NodeTest::Any.new, [
          BinaryExpr.new(
            Operator::Or,
            Path.relative([Step.new(Axis::Self, NodeTest::Name.new("chapter"))]),
            Path.relative([Step.new(Axis::Self, NodeTest::Name.new("appendix"))])
          )
        ] of Expr)
      ])

    assert_parses %(child::*[self::chapter or self::appendix][position()=last()]),
      Path.relative([
        Step.new(Axis::Child, NodeTest::Any.new, [
          BinaryExpr.new(
            Operator::Or,
            Path.relative([Step.new(Axis::Self, NodeTest::Name.new("chapter"))]),
            Path.relative([Step.new(Axis::Self, NodeTest::Name.new("appendix"))])
          ),
          BinaryExpr.new(Operator::Equal, FunctionCall.new("position"), FunctionCall.new("last")),
        ] of Expr)
      ])
  end

  def test_abbreviated_syntax
    assert_parses %(para),
      Path.relative([Step.new(Axis::Child, NodeTest::Name.new("para"))])

    assert_parses %(*),
      Path.relative([Step.new(Axis::Child, NodeTest::Any.new)])

    assert_parses %(text()),
      Path.relative([Step.new(Axis::Child, NodeTest::Text.new)])

    assert_parses %(@name),
      Path.relative([Step.new(Axis::Attribute, NodeTest::Name.new("name"))])

    assert_parses %(@*),
      Path.relative([Step.new(Axis::Attribute, NodeTest::Any.new)])

    assert_parses %(para[1]),
      Path.relative([
        Step.new(Axis::Child, NodeTest::Name.new("para"), [Literal.number(1)] of Expr)
      ])

    assert_parses %(para[last()]),
      Path.relative([
        Step.new(Axis::Child, NodeTest::Name.new("para"), [FunctionCall.new("last")] of Expr)
      ])

    assert_parses %(*/para),
      Path.relative([
        Step.new(Axis::Child, NodeTest::Any.new),
        Step.new(Axis::Child, NodeTest::Name.new("para")),
      ])

    assert_parses %(/doc/chapter[5]/section[2]),
      Path.absolute([
        Step.new(Axis::Child, NodeTest::Name.new("doc")),
        Step.new(Axis::Child, NodeTest::Name.new("chapter"), [Literal.number(5)] of Expr),
        Step.new(Axis::Child, NodeTest::Name.new("section"), [Literal.number(2)] of Expr),
      ])

    assert_parses %(chapter//para),
      Path.relative([
        Step.new(Axis::Child, NodeTest::Name.new("chapter")),
        Step.abbreviated,
        Step.new(Axis::Child, NodeTest::Name.new("para")),
      ])

    assert_parses %(//para),
      Path.absolute([
        Step.abbreviated,
        Step.new(Axis::Child, NodeTest::Name.new("para")),
      ])

    assert_parses %(//olist/item),
      Path.absolute([
        Step.abbreviated,
        Step.new(Axis::Child, NodeTest::Name.new("olist")),
        Step.new(Axis::Child, NodeTest::Name.new("item")),
      ])

    assert_parses %(.),
      Path.relative([Step.new(Axis::Self, NodeTest::Node.new)])

    assert_parses %(.//para),
      Path.relative([
        Step.new(Axis::Self, NodeTest::Node.new),
        Step.abbreviated,
        Step.new(Axis::Child, NodeTest::Name.new("para")),
      ])

    assert_parses %(..),
      Path.relative([Step.new(Axis::Parent, NodeTest::Node.new)])

    assert_parses %(../@lang),
      Path.relative([
        Step.new(Axis::Parent, NodeTest::Node.new),
        Step.new(Axis::Attribute, NodeTest::Name.new("lang")),
      ])

    assert_parses %(para[@type="warning"]),
      Path.relative([
        Step.new(Axis::Child, NodeTest::Name.new("para"), [
          BinaryExpr.new(
            Operator::Equal,
            Path.relative([Step.new(Axis::Attribute, NodeTest::Name.new("type"))]),
            Literal.string("warning"),
          ),
        ] of Expr),
      ])

    assert_parses %(para[@type="warning"][5]),
      Path.relative([
        Step.new(Axis::Child, NodeTest::Name.new("para"), [
          BinaryExpr.new(
            Operator::Equal,
            Path.relative([Step.new(Axis::Attribute, NodeTest::Name.new("type"))]),
            Literal.string("warning"),
          ),
          Literal.number(5),
        ] of Expr),
      ])

    assert_parses %(para[5][@type="warning"]),
      Path.relative([
        Step.new(Axis::Child, NodeTest::Name.new("para"), [
          Literal.number(5),
          BinaryExpr.new(
            Operator::Equal,
            Path.relative([Step.new(Axis::Attribute, NodeTest::Name.new("type"))]),
            Literal.string("warning"),
          ),
        ] of Expr),
      ])

    assert_parses %(chapter[title="Introduction"]),
      Path.relative([
        Step.new(Axis::Child, NodeTest::Name.new("chapter"), [
          BinaryExpr.new(
            Operator::Equal,
            Path.relative([Step.new(Axis::Child, NodeTest::Name.new("title"))]),
            Literal.string("Introduction"),
          ),
        ] of Expr),
      ])

    assert_parses %(chapter[title]),
      Path.relative([
        Step.new(Axis::Child, NodeTest::Name.new("chapter"), [
          Path.relative([Step.new(Axis::Child, NodeTest::Name.new("title"))]),
        ] of Expr),
      ])

    assert_parses %(employee[@secretary and @assistant]),
      Path.relative([
        Step.new(Axis::Child, NodeTest::Name.new("employee"), [
          BinaryExpr.new(
            Operator::And,
            Path.relative([Step.new(Axis::Attribute, NodeTest::Name.new("secretary"))]),
            Path.relative([Step.new(Axis::Attribute, NodeTest::Name.new("assistant"))]),
          ),
        ] of Expr),
      ])
  end

  def test_expressions
    assert_parses %(@value > 10),
      BinaryExpr.new(
        Operator::GreaterThan,
        Path.relative([Step.new(Axis::Attribute, NodeTest::Name.new("value"))]),
        Literal.number(10)
      )

    assert_parses %($x='foo'),
      BinaryExpr.new(Operator::Equal, VariableReference.new("x"), Literal.string("foo"))

    assert_parses %($x!='foo'),
      BinaryExpr.new(Operator::NotEqual, VariableReference.new("x"), Literal.string("foo"))

    assert_parses %(not($x!='foo')),
      FunctionCall.new("not", [
        BinaryExpr.new(Operator::NotEqual, VariableReference.new("x"), Literal.string("foo"))
      ] of Expr)

    assert_parses %(3 > 2 > 1),
      BinaryExpr.new(
        Operator::GreaterThan,
        BinaryExpr.new(
          Operator::GreaterThan,
          Literal.number(3),
          Literal.number(2),
        ),
        Literal.number(1),
      )

    assert_parses %((3 > 2) > 1),
      BinaryExpr.new(
        Operator::GreaterThan,
        BinaryExpr.new(
          Operator::GreaterThan,
          Literal.number(3),
          Literal.number(2),
        ),
        Literal.number(1),
      )

    assert_parses %(3 > (2 > 1)),
      BinaryExpr.new(
        Operator::GreaterThan,
        Literal.number(3),
        BinaryExpr.new(
          Operator::GreaterThan,
          Literal.number(2),
          Literal.number(1),
        ),
      )
  end

  def test_filter_expressions
    assert_parses %(preceding::foo[1]),
      Path.relative([
        Step.new(Axis::Preceding, NodeTest::Name.new("foo"), [Literal.number(1)] of Expr)
      ])

    assert_parses %(preceding::foo[1][2]),
      Path.relative([
        Step.new(Axis::Preceding, NodeTest::Name.new("foo"), [
          Literal.number(1),
          Literal.number(2),
        ] of Expr)
      ])

    assert_parses %((preceding::foo)[1]),
      FilterExpr.new(
        Path.relative([Step.new(Axis::Preceding, NodeTest::Name.new("foo"))]),
        [Literal.number(1)] of Expr
      )

    assert_parses %((preceding::foo)[1][2]),
      FilterExpr.new(
        Path.relative([Step.new(Axis::Preceding, NodeTest::Name.new("foo"))]),
        [Literal.number(1), Literal.number(2)] of Expr
      )
  end

  def assert_parses(input, expected = nil, message = nil, file = __FILE__, line = __LINE__)
    lexer = Lexer.new(input)
    parser = Parser.new(lexer)
    actual = parser.parse
    assert_equal expected, actual, message, file, line
  end
end
