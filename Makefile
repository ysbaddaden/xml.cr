.POSIX:

CRYSTAL = crystal
CRFLAGS = --threads=28
OPTS =

spec: .phony spec/xmlconf_spec.cr
	$(CRYSTAL) run --progress $(CRFLAGS) spec/*_spec.cr spec/**/*_spec.cr -- $(OPTS)

spec/xmlconf_spec.cr: bin/gen_xmlconf_spec.cr
	$(CRYSTAL) run $(CRFLAGS) $< | $(CRYSTAL) tool format - > $@

xmlconf:
	curl -L https://www.w3.org/XML/Test/xmlts20130923.tar.gz | tar zx
	cd xmlconf && patch -p1 < ../xmlconf.patch

.phony:
