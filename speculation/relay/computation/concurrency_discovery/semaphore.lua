-- Counting semaphore as a pool of ordinary scarce token occurrences.
-- Capacity is topology: N available token Strands.  Acquire transfers one token to held state;
-- release transforms the same exact token back to an available open occurrence.
local C=require('speculation.relay.computation.development_calculus.calculus')
local T=C.Equality()
local G=C.Geometry()
local M={}

local function token(state,identity)
  return {protocol='relay.semaphore.token',semaphore=T.var('sem'),state=state}
end

function M.seed(identity,n)
  assert(type(n)=='number' and n%1==0 and n>=0,'semaphore capacity required')
  if n==0 then return C.atom({geometry=G.empty(),theory={variables={'sem'},equalities={T.eq(T.var('sem'),identity)}},
    authority={inputs={},outputs={}},values={inputs={},outputs={}}}) end
  local g,p=G.operation(0,n)
  local support={strands={}}
  local open={outputs={}}
  for i,si in ipairs(p.outputs) do support.strands[si]=token('available',identity); open.outputs[i]=i end
  return C.atom({geometry=g,theory={variables={'sem'},equalities={T.eq(T.var('sem'),identity)}},
    support=support,authority={inputs={},outputs=p.outputs,open=open},values={inputs={},outputs={}}})
end

function M.acquire(identity)
  local g,p=G.operation(1,2)
  return C.atom({geometry=g,theory={variables={'sem'},equalities={T.eq(T.var('sem'),identity)}},
    support={strands={
      [p.inputs[1]]=token('available',identity),
      [p.outputs[1]]=token('held',identity),
    }},authority={inputs=p.inputs,outputs=p.outputs,open={inputs={1}}},values={inputs={},outputs={}}})
end

function M.release(identity)
  local g,p=G.operation(1,1)
  return C.atom({geometry=g,theory={variables={'sem'},equalities={T.eq(T.var('sem'),identity)}},
    support={strands={
      [p.inputs[1]]=token('held',identity),
      [p.outputs[1]]=token('available',identity),
    }},authority={inputs=p.inputs,outputs=p.outputs,open={outputs={1}}},values={inputs={},outputs={}}})
end

function M.held_output(package,alt)
  local a=package:alternative(alt or 1)
  for i,si in ipairs(a.authority.outputs) do
    local r=a.support and a.support.strands and a.support.strands[si]
    if r and r.protocol=='relay.semaphore.token' and r.state=='held' then return i end
  end
  return nil
end

function M.release_held(package,identity,alt)
  local pos=assert(M.held_output(package,alt),'no held semaphore token on package boundary')
  return C.and_then(package,M.release(identity),{value_pairs={},captures={{from=pos,to=1}}})
end
return M
