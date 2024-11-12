.POSIX:

CRYSTAL = crystal
CRFLAGS = --progress --threads=28
OPTS =

spec: .phony
	$(CRYSTAL) run $(CRFLAGS) spec/*_spec.cr spec/**/*_spec.cr -- $(OPTS)

.phony:
