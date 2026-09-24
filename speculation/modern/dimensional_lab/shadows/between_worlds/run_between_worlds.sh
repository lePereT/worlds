#!/usr/bin/env bash
set -e
ROOT=$(cd "$(dirname "$0")/../../../../.." && pwd)
cd "$ROOT"
export LUA_PATH='./src/?.lua;./src/?/init.lua;;'
texlua speculation/modern/dimensional_lab/shadows/between_worlds/25_between_worlds_moduli.lua
python3 speculation/modern/dimensional_lab/shadows/between_worlds/26_fundamental_group_raag.py
python3 speculation/modern/dimensional_lab/shadows/between_worlds/27_move_calculus_falsifier.py
texlua speculation/modern/dimensional_lab/shadows/between_worlds/28_native_construction_groupoid.lua
texlua speculation/modern/dimensional_lab/shadows/between_worlds/29_scc_construction_groupoid.lua
texlua speculation/modern/dimensional_lab/shadows/between_worlds/30_provenance_and_symmetry.lua
python3 speculation/modern/dimensional_lab/shadows/between_worlds/31_unlabelled_support_isotropy.py
python3 speculation/modern/dimensional_lab/shadows/between_worlds/32_structural_vs_causal_meta_moves.py
