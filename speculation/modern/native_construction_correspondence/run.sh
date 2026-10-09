#!/bin/sh
set -eu
LUA_BIN="${LUA:-}"
if [ -z "$LUA_BIN" ]; then
  for c in luajit lua5.1 lua5.2 lua5.3 lua5.4 lua5.5 texlua; do
    if command -v "$c" >/dev/null 2>&1; then LUA_BIN="$c"; break; fi
  done
fi
export LUA_PATH='./src/?.lua;./src/?/init.lua;./?.lua;;'
LAB=speculation/modern/native_construction_correspondence
for f in 01_native_transport.lua 02_groupoid_differential.lua 03_composition_laws.lua \
    04_realisation_fast_path.lua; do
  echo "== $f"
  "$LUA_BIN" "$LAB/$f"
done
echo 'PASS native Construction correspondence lab'
