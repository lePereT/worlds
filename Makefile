TEXLUA ?= texlua
TEXLUAC ?= texluac

DIRECTED = tests/api.lua tests/core.lua tests/certified.lua tests/separate.lua tests/frontier.lua tests/hostile.lua tests/extreme.lua tests/properties.lua
STRESS = tests/stress_core.lua tests/stress_separate.lua tests/stress_hostile.lua tests/stress_extreme.lua tests/stress_choice.lua

.PHONY: all test stress syntax

all: test stress syntax

test:
	@set -e; for f in $(DIRECTED); do echo "=== $$f ==="; $(TEXLUA) $$f; done

stress:
	@set -e; for f in $(STRESS); do echo "=== $$f ==="; $(TEXLUA) $$f; done

syntax:
	@set -e; for f in src/*.lua tests/*.lua; do $(TEXLUAC) -p $$f; done
