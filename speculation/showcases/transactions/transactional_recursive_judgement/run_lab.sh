#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../../../.." && pwd)
cd "$ROOT"
LUA_BIN=${LUA:-}
if [ -z "$LUA_BIN" ]; then
  for c in luajit lua5.1 lua5.2 lua5.3 lua5.4 lua5.5 texlua lua; do
    if command -v "$c" >/dev/null 2>&1; then LUA_BIN="$c"; break; fi
  done
fi
[ -n "$LUA_BIN" ] || { echo 'no Lua interpreter found' >&2; exit 1; }
export LUA_PATH='./src/?.lua;./src/?/init.lua;./?.lua;./?/init.lua;;'
n=0
for f in speculation/showcases/transactions/transactional_recursive_judgement/[0-9][0-9]_*.lua; do
  "$LUA_BIN" "$f"
  n=$((n+1))
done
printf 'PASS transactional recursive judgement: %s pressures\n' "$n"
