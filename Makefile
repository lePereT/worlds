LUA ?= lua
LUAC ?= luac

DIRECTED = tests/api.lua tests/compat.lua tests/attachment.lua tests/attachment_query.lua tests/regression.lua tests/harden.lua tests/certified.lua tests/separate.lua tests/frontier.lua
STRESS = tests/stress_attachment.lua

.PHONY: all test stress syntax lua51 luajit

all: test stress syntax

test:
	@set -e; for f in $(DIRECTED); do echo "=== $$f ==="; $(LUA) $$f; done

stress:
	@set -e; for f in $(STRESS); do echo "=== $$f ==="; $(LUA) $$f; done

syntax:
	@set -e; find src tests -name '*.lua' -type f | sort | while read f; do $(LUAC) -p "$$f"; done

lua51:
	@command -v lua5.1 >/dev/null 2>&1 || { echo 'lua5.1 not found'; exit 2; }
	@$(MAKE) all LUA=lua5.1 LUAC=luac5.1

luajit:
	@command -v luajit >/dev/null 2>&1 || { echo 'luajit not found'; exit 2; }
	@$(MAKE) test stress LUA=luajit
