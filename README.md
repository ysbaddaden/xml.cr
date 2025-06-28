# XML

An explanatory shard to handle XML (and later HTML) in pure Crystal.

## SAX (parser)

The foundation parser is a _Simple API for XML_ parser, aka SAX. It's inspired
by [The Expat XML parser API document]() (not its code) with adjustements for an
Object Oriented languages, like a distinct `XML::SAX::Handlers` class for
example.

The choice for a SAX parser is because of its relative simplicity along with its
extensible flexibility. The parser deals with the syntax, which you shouldn't
care about, while the handler lets you build whatever you need, and discard to
rest. You may generate a full blown DOM tree, decide to recover from errors, or
validate the XML document, or stream a XML document while skipping over anything
you don't care about.

## DOM

... TODO ...

## XPATH 1.0

... TODO ...

## LICENSE

Distributed under the Apache-2.0 LICENSE.

## AUTHOR

Julien PORTALIER
