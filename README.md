# XML

An exploratory shard to handle XML ~~(and later HTML)~~ in pure Crystal.

## XML::SAX (parser)

The foundation parser is a _Simple API for XML_ parser, aka SAX. It's inspired
by [The Expat XML parser API
document](https://libexpat.github.io/doc/api/latest/) (not its code) with
adjustements for an Object Oriented languages, like a distinct
`XML::SAX::Handlers` class for example.

The choice for a SAX parser is because of its relative simplicity along with its
extensible flexibility. The parser deals with the syntax, which you shouldn't
care about, while the handlers let you build whatever you need, and discard the
rest. You may generate a full blown DOM tree, decide to recover from errors, or
validate the XML document, or stream a XML document while skipping over anything
you don't care about.

So far, the non validating DOM parser is 95% conpliant with the _XML Conformance
Test Suites_.

References:

- <https://www.w3.org/TR/xml11/>
- <https://www.w3.org/TR/xml/>
- <https://www.w3.org/XML/Test/xmlconf-20080827.html>
- <https://libexpat.github.io/doc/api/latest/>

## XML::DOM

The initial draft for a DOM in Crystal. Follows the DOM spec, adapted for crystal
(snake_case instead of lowerCamelCase names), but keeps the clunky namings. We
might consider normalizing the API to be much less verbose (maybe).

References:

- <https://dom.spec.whatwg.org/>
- <https://www.w3.org/TR/DOM-Level-3-Core/>

## XPATH 1.0

... TODO ...

References:

- <https://www.w3.org/TR/xpath-10/>

## LICENSE

Distributed under the Apache-2.0 LICENSE.

## AUTHOR

Julien PORTALIER
