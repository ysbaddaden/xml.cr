.POSIX:
.PHONY:

CRYSTAL = crystal

all: bin/parse_xml

bin/parse_xml: parse_xml.cr src/*.cr src/**.cr
	@mkdir -p bin
	$(CRYSTAL) build $< -o $@

test: bin/parse_xml xmlconf/xmltest/valid/sa/*.xml

xmlconf/xmltest/valid/sa/%.xml: .PHONY
	./bin/parse_xml $@

clean: .PHONY
	rm -f bin/parse_xml
