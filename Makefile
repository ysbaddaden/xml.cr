.POSIX:
.PHONY:

CRYSTAL = crystal
CRFLAGS =

all: bin/parse_xml

bin/parse_xml: parse_xml.cr src/*.cr src/**.cr
	@mkdir -p bin
	$(CRYSTAL) build $(CRFLAGS) $< -o $@

test: ibm oasis xmltest

ibm: xmlconf/ibm/valid/*/*.xml
oasis: xmlconf/oasis/*pass*.xml
xmltest: xmlconf/xmltest/valid/*/*.xml
japanese: xmlconf/japanese/*.xml

xmlconf/%.xml: .PHONY
	./bin/parse_xml $@
	@echo

clean: .PHONY
	rm -f bin/parse_xml
