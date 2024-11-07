require "./spec_helper"

describe CRXML::Element do
  it "creates a dom tree" do
    html = Element.new("html")
    head = Element.new("head")
    body = Element.new("body")

    html.append(head)
    html.append(body)

    title = Element.new("title")
    title.append(Text.new("This is my book"))
    head.append(title)

    assert_equal "<html><head><title>This is my book</title></head><body></body></html>", html.to_xml
  end

  it "#initialize" do
    foo = Element.new("foo")
    assert_equal "foo", foo.name
    assert_nil foo.parent_node?
    assert_nil foo.parent_element?
    assert_nil foo.first_child?
    assert_nil foo.first_element_child?
    assert_nil foo.last_child?
    assert_nil foo.last_element_child?
    assert_nil foo.previous_element_sibling?
    assert_nil foo.next_element_sibling?
    assert_equal "", foo.content
  end

  it "#first_child" do
    foo = Element.new("foo")
    bar = Element.new("bar")
    txt = Text.new("txt")

    assert_nil foo.first_child?

    foo.append(bar)
    assert_same bar, foo.first_child?

    foo.insert(txt, before: bar)
    assert_same txt, foo.first_child?
  end

  it "#last_child" do
    foo = Element.new("foo")
    bar = Element.new("bar")
    txt = Text.new("txt")

    assert_nil foo.last_child?

    foo.append(bar)
    assert_same bar, foo.last_child?

    foo.insert(txt, after: bar)
    assert_same txt, foo.last_child?
  end

  describe "#first_element_child" do
    it "returns first child" do
      foo = Element.new("foo")
      bar = Element.new("bar")
      assert_nil foo.first_element_child?

      foo.append(bar)
      assert_same bar, foo.first_element_child?
    end

    it "skips non element children" do
      foo = Element.new("foo")
      t1 = Text.new("t1")
      t2 = Text.new("t2")
      assert_nil foo.first_element_child?

      bar = Element.new("bar")
      foo.append(t1)
      foo.append(t2)
      assert_nil foo.first_element_child?

      foo.append(bar)
      assert_same bar, foo.first_element_child?
    end

    it "doesn't have element child nodes" do
      foo = Element.new("foo")
      assert_nil foo.first_element_child?

      txt = Text.new("txt")
      foo.append(txt)
      assert_nil foo.first_element_child?
    end
  end

  describe "#last_element_child" do
    it "returns last child" do
      foo = Element.new("foo")
      bar = Element.new("bar")
      assert_nil foo.last_element_child?

      foo.append(bar)
      assert_same bar, foo.last_element_child?
    end

    it "skips non element children" do
      foo = Element.new("foo")
      t1 = Text.new("t1")
      t2 = Text.new("t2")

      assert_nil foo.last_element_child?

      bar = Element.new("bar")
      foo.append(t1)
      foo.append(t2)
      assert_nil foo.last_element_child?

      foo.insert(bar, before: t1)
      assert_same bar, foo.last_element_child?
    end

    it "doesn't have element child nodes" do
      foo = Element.new("foo")
      assert_nil foo.last_element_child?

      txt = Text.new("txt")
      foo.append(txt)
      assert_nil foo.last_element_child?
    end
  end

  describe "#content" do
    it "returns text content" do
      assert_equal "some foo", Text.new("some foo").content
      assert_equal "", Element.new("foo").content
    end

    it "merges the text content from all descendant nodes" do
      foo = Element.new("foo")
      foo.append(Text.new("some content"))
      assert_equal "some content", foo.content

      bar = Element.new("bar")
      bar.append(Text.new("before"))
      bar.append(foo)
      foo.append(Text.new("\n"))
      bar.append(Text.new("after"))
      assert_equal "beforesome content\nafter", bar.content
    end
  end

  describe "#append" do
    it "appends nodes" do
      parent = Element.new("parent")
      assert_nil parent.first_child?
      assert_nil parent.last_child?

      a = Element.new("a")
      parent.append(a)
      assert_same parent, a.parent_node?
      assert_same a, parent.first_child?
      assert_same a, parent.last_child?
      assert_nil a.previous_sibling?
      assert_nil a.next_sibling?

      b = Element.new("b")
      parent.append(b)
      assert_same parent, b.parent_node?
      assert_same a, parent.first_child?
      assert_same b, parent.last_child?
      assert_nil a.previous_sibling?
      assert_same b, a.next_sibling?
      assert_same a, b.previous_sibling?
      assert_nil b.next_sibling?

      c = Text.new("c")
      parent.append(c)
      assert_same parent, c.parent_node?
      assert_same a, parent.first_child?
      assert_same c, parent.last_child?
      assert_nil a.previous_sibling?
      assert_same b, a.next_sibling?
      assert_same a, b.previous_sibling?
      assert_same c, b.next_sibling?
      assert_same b, c.previous_sibling?
      assert_nil c.next_sibling?
    end

    it "moves node to another tree" do
      a = Element.new("a")
      a1 = Element.new("a1")
      a2 = Element.new("a2")
      node = Element.new("node")
      a.append(a1)
      a.append(node)
      a.append(a2)

      b = Element.new("b")
      b.append(node)

      assert_same a1, a.first_child?
      assert_same a2, a.last_child?
      assert_same a2, a1.next_sibling?
      assert_same a1, a2.previous_sibling?

      assert_equal b, node.parent_node?
      assert_same node, b.first_child?
      assert_same node, b.last_child?

      assert_nil node.previous_sibling?
      assert_nil node.next_sibling?
    end
  end

  describe "#insert(before:)" do
    it "inserts before first child" do
      parent = Element.new("parent")
      child = Element.new("child")
      parent.append(child)

      node = Element.new("node")
      parent.insert(node, before: child)

      assert_same node, parent.first_child?
      assert_same node, child.previous_sibling?
      assert_nil child.next_sibling?
      assert_same child, parent.last_child?
    end

    it "inserts within child nodes" do
      parent = Element.new("parent")
      a = Element.new("a")
      b = Element.new("b")
      parent.append(a)
      parent.append(b)

      node = Element.new("node")
      parent.insert(node, before: b)

      assert_same a, parent.first_child?
      assert_same b, parent.last_child?

      assert_nil a.previous_sibling?
      assert_same node, a.next_sibling?
      assert_same node, b.previous_sibling?
      assert_nil b.next_sibling?
    end

    it "moves node to another tree" do
      a = Element.new("a")
      a1 = Element.new("a1")
      a2 = Element.new("a2")
      node = Element.new("node")
      a.append(a1)
      a.append(node)
      a.append(a2)

      b = Element.new("b")
      b1 = Element.new("b1")
      b.append(b1)
      b.insert(node, before: b1)

      assert_same a1, a.first_child?
      assert_same a2, a.last_child?
      assert_same a2, a1.next_sibling?
      assert_same a1, a2.previous_sibling?

      assert_equal b, node.parent_node?
      assert_same node, b.first_child?
      assert_same b1, b.last_child?

      assert_nil node.previous_sibling?
      assert_same b1, node.next_sibling?
      assert_same node, b1.previous_sibling?
      assert_nil b1.next_sibling?
    end

    it "raises when not a child" do
      parent = Element.new("parent")
      node = Element.new("node")
      child = Element.new("child")
      assert_raises(DOMError) { parent.insert(node, before: child) }
    end
  end

  describe "#insert(after:)" do
    it "inserts after last child" do
      parent = Element.new("parent")
      child = Element.new("child")
      parent.append(child)

      node = Element.new("node")
      parent.insert(node, after: child)

      assert_same child, parent.first_child?
      assert_nil child.previous_sibling?
      assert_same node, child.next_sibling?
      assert_same node, parent.last_child?
    end

    it "inserts within child nodes" do
      parent = Element.new("parent")
      a = Element.new("a")
      b = Element.new("b")
      parent.append(a)
      parent.append(b)

      node = Element.new("node")
      parent.insert(node, before: b)

      assert_same a, parent.first_child?
      assert_same b, parent.last_child?

      assert_nil a.previous_sibling?
      assert_same node, a.next_sibling?
      assert_same node, b.previous_sibling?
      assert_nil b.next_sibling?
    end

    it "moves node to another tree" do
      a = Element.new("a")
      a1 = Element.new("a1")
      a2 = Element.new("a2")
      node = Element.new("node")
      a.append(a1)
      a.append(node)
      a.append(a2)

      b = Element.new("b")
      b1 = Element.new("b1")
      b.append(b1)
      b.insert(node, after: b1)

      assert_same a1, a.first_child?
      assert_same a2, a.last_child?
      assert_same a2, a1.next_sibling?
      assert_same a1, a2.previous_sibling?

      assert_equal b, node.parent_node?
      assert_same b1, b.first_child?
      assert_same node, b.last_child?

      assert_nil b1.previous_sibling?
      assert_same node, b1.next_sibling?
      assert_same b1, node.previous_sibling?
      assert_nil node.next_sibling?
    end

    it "raises when not a child" do
      parent = Element.new("parent")
      node = Element.new("node")
      child = Element.new("child")
      assert_raises(DOMError) { parent.insert(node, after: child) }
    end
  end

  describe "#remove_child" do
    it "removes first child node" do
      parent = Element.new("parent")
      a = Element.new("a")
      b = Element.new("b")
      parent.append(a)
      parent.append(b)

      parent.remove_child(a)
      assert_nil a.parent_node?
      assert_nil a.previous_sibling?
      assert_nil a.next_sibling?
      assert_same b, parent.first_child?
      assert_same b, parent.last_child?
      assert_nil b.previous_sibling?
      assert_nil b.next_sibling?
    end

    it "removes last child node" do
      parent = Element.new("parent")
      a = Element.new("a")
      b = Element.new("b")
      parent.append(a)
      parent.append(b)

      parent.remove_child(b)
      assert_nil b.parent_node?
      assert_nil b.previous_sibling?
      assert_nil b.next_sibling?
      assert_same a, parent.first_child?
      assert_same a, parent.last_child?
      assert_nil a.previous_sibling?
      assert_nil a.next_sibling?
    end

    it "removes a child node" do
      parent = Element.new("parent")
      a = Element.new("a")
      b = Element.new("b")
      c = Element.new("b")
      parent.append(a)
      parent.append(b)
      parent.append(c)

      parent.remove_child(b)
      assert_nil b.parent_node?
      assert_nil b.previous_sibling?
      assert_nil b.next_sibling?
      assert_same a, parent.first_child?
      assert_same c, parent.last_child?
      assert_nil a.previous_sibling?
      assert_same c, a.next_sibling?
      assert_same a, c.previous_sibling?
      assert_nil c.next_sibling?
    end

    it "removes last remaining child node" do
      parent = Element.new("parent")
      node = Element.new("node")
      parent.append(node)

      parent.remove_child(node)
      assert_nil node.parent_node?
      assert_nil node.previous_sibling?
      assert_nil node.next_sibling?
    end

    it "raises when not a child" do
      node = Element.new("node")
      child = Element.new("child")
      assert_raises(DOMError) { node.remove_child(child) }
    end
  end
end
