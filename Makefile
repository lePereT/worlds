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

.DEFAULT_GOAL := test

.PHONY: all test check doctor docs tooling architecture laws torture differential whole shape external

all: test

test: check

check: docs tooling architecture laws torture differential whole shape external

doctor:
	@printf 'Lua: %s\n' "$(LUA)"
	@$(LUA) -v

docs:
	cd tests && $(LUA) docs.lua

tooling:
	cd tests && $(LUA) tooling.lua

architecture:
	cd tests && $(LUA) architecture.lua

laws:
	cd tests && $(LUA) run.lua

torture:
	cd tests && $(LUA) torture/inherited.lua

differential:
	cd tests && $(LUA) reference/cut_differential.lua

whole:
	cd tests && $(LUA) torture/whole_model.lua

shape:
	cd tests && $(LUA) shape/structural.lua

external:
	cd external/geometric_products && $(LUA) test.lua
	cd external/relay_source && $(LUA) test.lua
