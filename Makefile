.POSIX:

CRYSTAL = crystal
CRFLAGS = --progress
OPTS =

spec: .phony
	$(CRYSTAL) run $(CRFLAGS) spec/*_spec.cr -- $(OPTS)

.phony:
