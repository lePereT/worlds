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

.PHONY: test query history adversarial work centre differential restricted partial nested branching historical shape check full-check bench stress live

test:
	LUA_PATH='./src/?.lua;;' $(LUA) tests/run.lua

query:
	LUA_PATH='./src/?.lua;./src/?/init.lua;;' $(LUA) tests/query.lua

closure:
	LUA_PATH='./src/?.lua;./src/?/init.lua;;' $(LUA) tests/closure-query.lua

closure-differential:
	LUA_PATH='./src/?.lua;./src/?/init.lua;;' $(LUA) tests/closure-differential.lua

history:
	LUA_PATH='./src/?.lua;./src/?/init.lua;;' $(LUA) tests/history.lua

adversarial:
	LUA_PATH='./src/?.lua;;' $(LUA) tests/adversarial.lua

work:
	LUA_PATH='./src/?.lua;./src/?/init.lua;;' $(LUA) tests/work.lua

centre:
	LUA_PATH='./src/?.lua;./src/?/init.lua;;' $(LUA) tests/centre.lua

differential:
	LUA_PATH='./src/?.lua;./tests/historical/?.lua;;' $(LUA) tests/differential.lua
restricted:
	LUA_PATH='./src/?.lua;;' $(LUA) tests/restricted-differential.lua

partial:
	LUA_PATH='./src/?.lua;;' $(LUA) tests/partial-differential.lua

nested:
	LUA_PATH='./src/?.lua;;' $(LUA) tests/nested-differential.lua

branching:
	LUA_PATH='./src/?.lua;;' $(LUA) tests/branching-differential.lua

historical:
	@set -e; for f in tests/historical/*.lua; do \
	  case "$$f" in *worlds.lua|*support.lua|*prng.lua) continue;; esac; \
	  LUA_PATH='./compat/?.lua;./tests/historical/?.lua;./src/?.lua;./src/?/init.lua;;' WORLDS_SRC='src/worlds.lua' $(LUA) "$$f"; \
	done; echo 'PASS historical algebra 15 files'

shape:
	$(LUA) tools/check-shape.lua

check: test query closure history adversarial work centre shape

full-check: check differential restricted partial nested branching closure-differential historical

bench:
	LUA_PATH='./src/?.lua;;' $(LUA) bench/run.lua

stress:
	LUA_PATH='./src/?.lua;;' $(LUA) bench/stress.lua

live:
	LUA_PATH='./src/?.lua;;' $(LUA) bench/live.lua 10000

.PHONY: speculation-check
speculation-check:
	@set -e; for f in $$(find speculation -name '*.lua' | sort); do \
	  printf 'speculation: %s\n' "$$f"; \
	  LUA_PATH='./src/?.lua;./?.lua;;' $(LUA) "$$f"; \
	done
