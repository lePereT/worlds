#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../../../.." && pwd)
cd "$ROOT"
LUA=${LUA:-lua}
export LUA_PATH='./src/?.lua;./?.lua;;'
for f in \
  speculation/showcases/theory/knowledge_contract/doctrine_laws.lua \
  speculation/showcases/theory/knowledge_contract/judgement_laws.lua \
  speculation/showcases/theory/knowledge_contract/equivariance_laws.lua \
  speculation/showcases/theory/knowledge_contract/generated_laws.lua \
  speculation/showcases/theory/knowledge_contract/construction_transport.lua \
  speculation/showcases/theory/knowledge_contract/corelation_transport.lua \
  speculation/showcases/theory/knowledge_contract/generated_corelations.lua \
  speculation/showcases/theory/knowledge_contract/closure_laws.lua \
  speculation/showcases/theory/knowledge_contract/observation_laws.lua \
  speculation/showcases/theory/knowledge_contract/exact_vs_abstract.lua
do
  "$LUA" "$f"
done
