SHELL := /bin/sh

LUA_CANDIDATES := luajit lua5.1 lua5.2 lua5.3 lua5.4 lua5.5 texlua
LUA ?= $(shell for c in $(LUA_CANDIDATES); do \
  if command -v $$c >/dev/null 2>&1; then printf '%s' $$c; break; fi; \
done)

ifeq ($(strip $(LUA)),)
$(error No Lua interpreter found. Tried: $(LUA_CANDIDATES))
endif

.PHONY: style lua51-syntax lua51-runtime-shape test query closure closure-differential
.PHONY: advance-differential construction presentation history trust adversarial
.PHONY: work mechanical-work centre differential restricted partial nested branching
.PHONY: historical shape check full-check bench close-bench stress live trust-bench
.PHONY: speculation-check relay-check

style:
	$(LUA) tools/check-style.lua

lua51-syntax:
	$(LUA) tools/check-lua51-syntax.lua

lua51-runtime-shape:
	LUA_PATH='./src/?.lua;./src/?/init.lua;;' $(LUA) tests/lua51-compat.lua

test:
	LUA_PATH='./src/?.lua;;' $(LUA) tests/run.lua

query:
	LUA_PATH='./src/?.lua;./src/?/init.lua;;' $(LUA) tests/query.lua

closure:
	LUA_PATH='./src/?.lua;./src/?/init.lua;;' $(LUA) tests/closure-query.lua

closure-differential:
	LUA_PATH='./src/?.lua;./src/?/init.lua;;' $(LUA) tests/closure-differential.lua

advance-differential:
	LUA_PATH='./src/?.lua;./src/?/init.lua;;' $(LUA) tests/advance-differential.lua

construction:
	LUA_PATH='./src/?.lua;./src/?/init.lua;;' $(LUA) tests/construction.lua

presentation:
	LUA_PATH='./src/?.lua;./src/?/init.lua;;' $(LUA) tests/presentation.lua

history:
	LUA_PATH='./src/?.lua;./src/?/init.lua;;' $(LUA) tests/history.lua

trust:
	LUA_PATH='./src/?.lua;./src/?/init.lua;;' $(LUA) tests/trust.lua

adversarial:
	LUA_PATH='./src/?.lua;;' $(LUA) tests/adversarial.lua

work:
	LUA_PATH='./src/?.lua;./src/?/init.lua;;' $(LUA) tests/work.lua

mechanical-work:
	LUA_PATH='./src/?.lua;./src/?/init.lua;;' $(LUA) tests/mechanical-work.lua

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
	  LUA_PATH='./compat/?.lua;./tests/historical/?.lua;./src/?.lua;./src/?/init.lua;;' \
	  WORLDS_SRC='src/worlds.lua' $(LUA) "$$f"; \
	done; echo 'PASS historical algebra 15 files'

shape:
	$(LUA) tools/check-shape.lua

check: style lua51-syntax lua51-runtime-shape test query closure construction presentation history trust \
	adversarial work mechanical-work centre shape

full-check: check differential restricted partial nested branching \
	closure-differential advance-differential historical

bench:
	LUA_PATH='./src/?.lua;;' $(LUA) bench/run.lua

close-bench:
	LUA_PATH='./src/?.lua;;' $(LUA) bench/close.lua

stress:
	LUA_PATH='./src/?.lua;;' $(LUA) bench/stress.lua

live:
	LUA_PATH='./src/?.lua;;' $(LUA) bench/live.lua 10000

speculation-check:
	@set -e; for f in $$(find speculation -name '*.lua' ! -path 'speculation/relay/theory/*' ! -path 'speculation/relay/computation/*' | sort); do \
	  printf 'speculation: %s\n' "$$f"; \
	  LUA_PATH='./src/?.lua;./?.lua;;' $(LUA) "$$f"; \
	done



relay-check:
	LUA='$(LUA)' speculation/relay/theory/knowledge_contract/run.sh
	LUA='$(LUA)' speculation/relay/theory/lifecycle_and_correspondence/run.sh
	LUA='$(LUA)' speculation/relay/computation/development_calculus/run_lab.sh
	LUA='$(LUA)' speculation/relay/computation/recurrence_calculus/run_lab.sh
	LUA='$(LUA)' speculation/relay/computation/formed_computation/run_lab.sh
	LUA='$(LUA)' speculation/relay/computation/recursive_judgement/run_lab.sh
	LUA='$(LUA)' speculation/relay/computation/geometry_viability/run_lab.sh
	LUA='$(LUA)' speculation/relay/computation/concurrency_discovery/run_lab.sh

trust-bench:
	LUA_PATH='./src/?.lua;./src/?/init.lua;;' $(LUA) bench/trust.lua
