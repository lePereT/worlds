#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../../../.." && pwd)
cd "$ROOT"
LUA_BIN="${LUA:-}"
if [ -z "$LUA_BIN" ]; then
  for c in luajit lua5.1 lua5.2 lua5.3 lua5.4 lua5.5 texlua lua; do
    if command -v "$c" >/dev/null 2>&1; then LUA_BIN="$c"; break; fi
  done
fi
[ -n "$LUA_BIN" ] || { echo 'no Lua interpreter found' >&2; exit 1; }
export LUA_PATH='./?.lua;./?/init.lua;./src/?.lua;./src/?/init.lua;;'
LAB=speculation/showcases/theory/lifecycle_and_correspondence
run() { printf '== %s\n' "$1"; "$LUA_BIN" "$LAB/$1"; }
run 01_support_lifetime.lua
run run_legacy_48.lua
run 02_correspondence_transport.lua
run 03_groupoid_unification.lua
run 04_fresh_part_composition.lua
run 05_composition_laws.lua
printf '%s\n' 'PASS restrictive Theory lifecycle and correspondence showcase'
