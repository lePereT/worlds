SHELL := /bin/sh

# Preferred interpreter order: LuaJIT, generic Lua, versioned Lua, TexLua.
# Override explicitly with e.g. `make LUA=texlua test`.
LUA_CANDIDATES := luajit lua lua5.4 lua5.3 texlua
LUA ?= $(shell for c in $(LUA_CANDIDATES); do \
    if command -v $$c >/dev/null 2>&1; then printf '%s' $$c; break; fi; \
  done)

ifeq ($(strip $(LUA)),)
$(error No Lua interpreter found. Tried: $(LUA_CANDIDATES))
endif

ROOT := $(CURDIR)
export LUA_PATH := $(ROOT)/src/?.lua;$(ROOT)/src/?/init.lua;;

.PHONY: all doctor check syntax test torture bench clean tree

all: check test

doctor:
	@printf 'Lua:      %s\n' "$(LUA)"
	@$(LUA) tools/lua-info.lua
	@printf 'Worlds:   %s\n' "$$(cat VERSION)"
	@printf 'LUA_PATH: %s\n' "$$LUA_PATH"

check: syntax
	@$(LUA) tests/devcontainer_test.lua

syntax:
	@$(LUA) tests/syntax.lua

test:
	@$(LUA) tools/run-tests.lua tests

# Focused higher-Theory stress cases begin at case 37.
torture:
	@set -e; for t in tests/3[7-9]_*.lua tests/4[0-8]_*.lua; do \
		echo "== $$t =="; $(LUA) "$$t"; \
	done

bench:
	@$(LUA) tools/run-bench.lua bench

clean:
	@rm -rf .cache

tree:
	@find . -path './.git' -prune -o -type f -print | sort

export LUA
