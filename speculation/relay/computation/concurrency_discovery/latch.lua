-- One-shot countdown latch as positive token collection.
-- Completion is certified by owning all N arrived tokens; no negative "count == 0" observation.
local C=require('speculation.relay.computation.development_calculus.calculus')
local T=C.Equality()
local G=C.Geometry()
local M={}
local function token(state)
  return {protocol='relay.latch.token',latch=T.var('latch'),state=state}
end
function M.seed(identity,n)
  local g,p=G.operation(0,n)
  local support={strands={}}
  local open={outputs={}}
  for i,si in ipairs(p.outputs) do support.strands[si]=token('available'); open.outputs[i]=i end
  return C.atom({geometry=g,theory={variables={'latch'},equalities={T.eq(T.var('latch'),identity)}},
    support=support,authority={inputs={},outputs=p.outputs,open=open},values={inputs={},outputs={}}})
end
function M.count_down(identity)
  local g,p=G.operation(1,1)
  return C.atom({geometry=g,theory={variables={'latch'},equalities={T.eq(T.var('latch'),identity)}},
    support={strands={[p.inputs[1]]=token('available'),[p.outputs[1]]=token('arrived')}},
    authority={inputs=p.inputs,outputs=p.outputs,open={inputs={1},outputs={1}}},values={inputs={},outputs={}}})
end
function M.await(identity,n)
  local g,p=G.operation(n,1)
  local support={strands={}}
  local open={inputs={}}
  for i,si in ipairs(p.inputs) do support.strands[si]=token('arrived'); open.inputs[i]=i end
  return C.atom({geometry=g,theory={variables={'latch'},equalities={T.eq(T.var('latch'),identity)}},
    support=support,authority={inputs=p.inputs,outputs=p.outputs,open=open},values={inputs={},outputs={}}})
end
return M
