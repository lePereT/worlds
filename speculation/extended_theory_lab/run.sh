#!/bin/sh
set -eu
LUA_PATH='./src/?.lua;./src/?/init.lua;./?.lua;;' texlua speculation/extended_theory_lab/run.lua
