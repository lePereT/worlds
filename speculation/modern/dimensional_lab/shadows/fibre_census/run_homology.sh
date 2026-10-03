#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../../../../.." && pwd)
cd "$ROOT"
TMP=${TMPDIR:-/tmp}/worlds-fibre-homology-$$
mkdir -p "$TMP"
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
for q in 2 3 4 5 6; do
  LUA_PATH='./src/?.lua;./src/?/init.lua;;' texlua speculation/modern/dimensional_lab/shadows/fibre_census/emit_support_vertices.lua "$q" "$TMP/lawful$q" "$TMP/dev$q"
  python3 speculation/modern/dimensional_lab/shadows/fibre_census/cubical_homology.py developable "$q" "$TMP/dev$q"
done
python3 speculation/modern/dimensional_lab/shadows/fibre_census/cubical_homology.py lawful4 "$TMP/lawful4"
