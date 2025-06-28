# Copyright 2025 Julien PORTALIER
# Distributed under the Apache-2.0 LICENSE

module XML
  module Chars
    def quote?(char : Char?) : Bool
      char == '"' || char == '\''
    end

    # <https://www.w3.org/TR/xml11/#NT-S>
    def s?(char : Char) : Bool
      char.in?(' ', '\t', '\n', '\r')
    end

    # <https://www.w3.org/TR/xml11/#NT-Char>
    def char?(char : Char?) : Bool
      case char
      when '\u0001'..'\uD7FF', '\uE000'..'\uFFFD', '\u{10000}'..'\u{10FFFF}'
        true
      else
        false
      end
    end

    # <https://www.w3.org/TR/xml11/#NT-RestrictedChar>
    def restricted?(char : Char?) : Bool
      case char
      when '\u0001'..'\u0008', '\u000B'..'\u000C', '\u0086'..'\u009F',
        '\u000E'..'\u001F', '\u007F'..'\u0084'
        true
      else
        false
      end
    end

    # <https://www.w3.org/TR/xml11/#NT-NameStartChar>
    def name_start?(char : Char) : Bool
      case char
      when 'A'..'Z', 'a'..'z', ':', '_',
        '\u00C0'..'\u00D6', '\u00D8'..'\u00F6', '\u00F8'..'\u02FF',
        '\u0370'..'\u037D', '\u037F'..'\u1FFF', '\u200C'..'\u200D',
        '\u2070'..'\u218F', '\u2C00'..'\u2FEF', '\u3001'..'\uD7FF',
        '\uF900'..'\uFDCF', '\uFDF0'..'\uFFFD', '\u{10000}'..'\u{EFFFF}'
        true
      else
        false
      end
    end

    # <https://www.w3.org/TR/xml11/#NT-NameChar>
    def name?(char : Char?) : Bool
      case char
      when 'A'..'Z', 'a'..'z', '0'..'9', ':', '-', '.', '_', '\u00B7',
        '\u00C0'..'\u00D6', '\u00D8'..'\u00F6', '\u00F8'..'\u02FF',
        '\u0300'..'\u036F', '\u0370'..'\u037D', '\u037F'..'\u1FFF',
        '\u203F'..'\u2040', '\u200C'..'\u200D', '\u2070'..'\u218F',
        '\u2C00'..'\u2FEF', '\u3001'..'\uD7FF', '\uF900'..'\uFDCF',
        '\uFDF0'..'\uFFFD', '\u{10000}'..'\u{EFFFF}'
        true
      else
        false
      end
    end

    # <https://www.w3.org/TR/xml11/#NT-PubidChar>
    def pubid?(char : Char?) : Bool
      case char
      when 'a'..'z', 'A'..'Z', '0'..'9', '-', '\'', '(', ')', '+', ',', '.', '/',
        ':', '=', '?', ';', '!', '*', '#', '@', '$', '_', '%', ' ', '\r', '\n'
        true
      else
        false
      end
    end

    # <https://www.w3.org/TR/xml11/#NT-EncName>
    def encname_start?(char : Char?) : Bool
      case char
      when 'a'..'z', 'A'..'Z'
        true
      else
        false
      end
    end

    # <https://www.w3.org/TR/xml11/#NT-EncName>
    def encname?(char : Char?) : Bool
      case char
      when 'a'..'z', 'A'..'Z', '0'..'9', '-', '.', '_'
        true
      else
        false
      end
    end
  end
end
