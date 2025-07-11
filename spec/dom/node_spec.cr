require "../spec_helper"

describe XML::DOM::Node do
  let(:document) { XMLDocument.new }

  it "creates a dom tree" do
    html = Element.new("html", document)
    head = Element.new("head", document)
    body = Element.new("body", document)

    html.append(head)
    html.append(body)

    title = Element.new("title", document)
    title.append(Text.new("This is my book", document))
    head.append(title)

    # assert_equal "<html><head><title>This is my book</title></head><body></body></html>", html.to_xml
  end

  it "#parent_node" do
    foo = Element.new("foo", document)
    a = Element.new("a", document)
    foo.append(a)
    assert_same foo, a.parent_node?
  end

  it "#previous_sibling" do
    foo = Element.new("foo", document)
    a = Element.new("a", document)
    b = Text.new("b", document)
    c = Text.new("c", document)
    d = Element.new("d", document)
    foo.append(a)
    foo.append(b)
    foo.append(c)
    foo.append(d)

    assert_nil a.previous_sibling?
    assert_same a, b.previous_sibling?
    assert_same b, c.previous_sibling?
    assert_same c, d.previous_sibling?
  end

  it "#next_sibling" do
    foo = Element.new("foo", document)
    a = Element.new("a", document)
    b = Text.new("b", document)
    c = Text.new("c", document)
    d = Element.new("d", document)
    foo.append(a)
    foo.append(b)
    foo.append(c)
    foo.append(d)

    assert_same b, a.next_sibling?
    assert_same c, b.next_sibling?
    assert_same d, c.next_sibling?
    assert_nil d.next_sibling?
  end

  it "#parent_element" do
    skip
  end

  it "#previous_element_sibling" do
    foo = Element.new("foo", document)
    a = Element.new("a", document)
    b = Text.new("b", document)
    c = Text.new("c", document)
    d = Element.new("d", document)
    foo.append(a)
    foo.append(b)
    foo.append(c)
    foo.append(d)

    assert_nil a.previous_element_sibling?
    assert_same a, b.previous_element_sibling?
    assert_same a, c.previous_element_sibling?
    assert_same a, d.previous_element_sibling?
  end

  it "#next_element_sibling" do
    foo = Element.new("foo", document)
    a = Element.new("a", document)
    b = Text.new("b", document)
    c = Text.new("c", document)
    d = Element.new("d", document)
    foo.append(a)
    foo.append(b)
    foo.append(c)
    foo.append(d)

    assert_same d, a.next_element_sibling?
    assert_same d, b.next_element_sibling?
    assert_same d, c.next_element_sibling?
    assert_nil d.next_element_sibling?
  end

  describe "#remove" do
    it "does nothing when no parent" do
      foo = Element.new("foo", document)
      foo.remove
      assert_nil foo.parent_node?
      assert_nil foo.previous_sibling?
      assert_nil foo.next_sibling?
    end

    it "removes the last remaining child node" do
      foo = Element.new("foo", document)
      bar = Element.new("bar", document)
      foo.append(bar)
      bar.remove
      assert_nil foo.first_child?
      assert_nil foo.last_child?
      assert_nil bar.parent_node?
      assert_nil bar.previous_sibling?
      assert_nil bar.next_sibling?
    end

    it "removes a child node" do
      foo = Element.new("foo", document)
      a = Element.new("a", document)
      b = Element.new("b", document)
      c = Element.new("c", document)
      foo.append(a)
      foo.append(b)
      foo.append(c)

      b.remove
      assert_same a, foo.first_child?
      assert_same c, foo.last_child?
      assert_same c, a.next_sibling?
      assert_same a, c.previous_sibling?
      assert_nil b.parent_node?
      assert_nil b.previous_sibling?
      assert_nil b.next_sibling?
    end

    it "removes a first child node" do
      foo = Element.new("foo", document)
      a = Element.new("a", document)
      b = Element.new("b", document)
      c = Element.new("c", document)
      foo.append(a)
      foo.append(b)
      foo.append(c)

      a.remove
      assert_same b, foo.first_child?
      assert_same c, foo.last_child?
      assert_nil b.previous_sibling?
      assert_nil a.parent_node?
      assert_nil a.previous_sibling?
      assert_nil a.next_sibling?
    end

    it "removes a last child node" do
      foo = Element.new("foo", document)
      a = Element.new("a", document)
      b = Element.new("b", document)
      c = Element.new("c", document)
      foo.append(a)
      foo.append(b)
      foo.append(c)

      c.remove
      assert_same a, foo.first_child?
      assert_same b, foo.last_child?
      assert_nil b.next_sibling?
      assert_nil c.parent_node?
      assert_nil c.previous_sibling?
      assert_nil c.next_sibling?
    end
  end
end
