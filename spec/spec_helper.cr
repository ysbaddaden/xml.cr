require "minitest/autorun"
require "minitest/spec"
require "../src/dom/parser"

class XML::DOM::Parser < XML::SAX::Handlers
  ROOT_PATH = Path.new(Dir.current).expand

  def open_external(base : String?, uri : String, & : (String, IO) ->) : Nil
    resolve_external(base, uri) do |path, relative_path|
      File.open(path, "r") { |file| yield relative_path, file }
    end
  end

  def open_external(base : String?, uri : String) : {String, IO}?
    resolve_external(base, uri) do |path, relative_path|
      return relative_path, File.new(path, "r")
    end
  end

  # Only opens the file at *uri* if its a local file under the current
  # directory.
  private def resolve_external(base, uri, &)
    if uri =~ %r{^(w+)://(.*)$}
      return unless $1 == "file"
      uri = $2
    end

    path = ROOT_PATH.join(base, uri).expand

    if (path <=> ROOT_PATH).positive?
      yield path, path.relative_to(ROOT_PATH).to_s
    end
  end
end

class Minitest::Test
  def assert_parses(input, output, message, file = __FILE__, line = __LINE__)
    document = File.open(input) do |file|
      XML::DOM.parse(file, base: File.dirname(input))
    end

    if output
      document.root.canonicalize

      canon = File.open(output) { |file| XML::DOM.parse(file) }
      canon.root.canonicalize # NOTE: it's expected to already be canon...

      assert_equal canon.root.inspect, document.root.inspect, message, file, line
    end
  end

  def refute_parses(input, message, file = __FILE__, line = __LINE__)
    assert_raises(XML::SAX::Error, message) do
      File.open(input) do |file|
        XML::DOM.parse(file, base: File.dirname(input))
      end
    end
  end
end
