.POSIX:
.PHONY:

CRYSTAL = crystal
CRFLAGS =
OPTS =

-include local.mk

all: bin/parse_xml

bin/parse_xml: parse_xml.cr src/*.cr src/**/*.cr
	@mkdir -p bin
	$(CRYSTAL) build $(CRFLAGS) $< -o $@

# xmlconf/%.xml: xmlconf .PHONY
# 	./bin/parse_xml $@ $(OPTS)

spec: spec/xmlconf_spec.cr .PHONY
	$(CRYSTAL) run $(CRFLAGS) spec/*_spec.cr spec/**/*_spec.cr -- $(OPTS)

spec/xmlconf_spec.cr: bin/gen_xmlconf_spec.cr xmlconf
	$(CRYSTAL) run $(CRFLAGS) $< | $(CRYSTAL) tool format - > $@

xmlconf:
	curl -L https://www.w3.org/XML/Test/xmlts20130923.tar.gz | tar zx
	cd xmlconf && patch -p1 < ../xmlconf.patch

clean: .PHONY
	rm -f bin/parse_xml spec/xmlconf_spec.cr
