# CRXML

CRXML aims to be a pure-crystal replacement to `XML` in stdlib (that leverages
[libxml2](https://gitlab.gnome.org/GNOME/libxml2/-/wikis/home)). Full conformance
as achieved by libxml2 is obviously a very long-term dream.

Goals:

- Multiple parsers: DOM, SAX, streaming.
- HTML support (with its special quirks);
- Error recoverability (unless asked to validate);
- XPATH queries.

Non goals (at least not immediate):

- CSS queries (maybe through a CSS to XPATH transformer).
- DTD validations;
- XML schemas;
- XSLT transformations.

## References

- <http://www.w3.org/TR/REC-xml/>
- <https://www.w3.org/TR/REC-xml11/>
- <https://www.w3.org/TR/xpath>
- <https://www.w3.org/TR/xmlschema-0/>
- <https://dom.spec.whatwg.org/>

## Test suites

- <https://www.w3.org/XML/Test/>
- <https://www.oasis-open.org/specs/conformance.php>
