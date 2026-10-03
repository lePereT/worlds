#!/bin/sh
set -eu
LUA_PATH='./src/?.lua;./src/?/init.lua;./?.lua;;' texlua speculation/theory/occurrence_relative/run.lua
