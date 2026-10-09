-- Atomic compare/exchange over the grounded state-owner pattern.
-- Success is positive equality; failure is the ordinary fallback branch selected only when the
-- preferred equality-constrained descendant is refuted.  No disequality or CAS semantic primitive.
local C=require('speculation.relay.computation.development_calculus.calculus')
local T=C.Equality()
local G=C.Geometry()
local S=require('speculation.relay.computation.concurrency_discovery.state_owner')
local M={}

local function state(payload)
  return {protocol='relay.state.owner',cell=T.var('cell'),state='full',payload=payload}
end
local function seam(phase)
  return {protocol='relay.atomic.'..phase,operation='cas',cell=T.var('cell'),
    expected=T.var('expected'),desired=T.var('desired')}
end

local function handler(success)
  local g,p=G.operation(2,3) -- state + request -> next state + reply + owner continuation
  local eqs={T.eq(T.var('state'),'full'),T.eq(T.var('success'),success)}
  if success then
    eqs[#eqs+1]=T.eq(T.var('current'),T.var('expected'))
    eqs[#eqs+1]=T.eq(T.var('next'),T.var('desired'))
  else
    eqs[#eqs+1]=T.eq(T.var('next'),T.var('current'))
  end
  eqs[#eqs+1]=T.eq(T.var('observed'),T.var('current'))
  return C.atom({geometry=g,theory={variables={'cell','state','current','expected','desired','next','observed','success'},equalities=eqs},
    support={strands={
      [p.inputs[1]]=state(T.var('current')),
      [p.inputs[2]]=seam('request'),
      [p.outputs[1]]=state(T.var('next')),
      [p.outputs[2]]=seam('reply'),
    }},authority={inputs=p.inputs,outputs=p.outputs,open={inputs={2},outputs={2}}},
    values={inputs={},outputs={'state','next','success','observed'}}})
end

function M.server()
  return C.or_else(handler(true),handler(false))
end

function M.cell(identity,value) return S.seed_full(identity,value) end

function M.cas(identity,expected,desired)
  local g,p=G.operation(1,2) -- reply -> request + caller continuation
  return C.atom({geometry=g,theory={variables={'cell','expected','desired','success','observed'},equalities={
      T.eq(T.var('cell'),identity),T.eq(T.var('expected'),expected),T.eq(T.var('desired'),desired)}},
    support={strands={
      [p.inputs[1]]=seam('reply'),
      [p.outputs[1]]=seam('request'),
    }},authority={inputs=p.inputs,outputs=p.outputs,open={inputs={1},outputs={1}}},
    values={inputs={},outputs={'success','observed'}}})
end

local function state_output_position(package)
  for _,a in ipairs(package:family().items) do
    for i,si in ipairs(a.authority.outputs) do
      local r=a.support and a.support.strands and a.support.strands[si]
      if r and r.protocol=='relay.state.owner' then return i end
    end
  end
  error('atomic cell state output not found')
end
function M.ground(state_package)
  return C.and_then(state_package,M.server(),{value_pairs={},captures={{from=state_output_position(state_package),to=1}}})
end
function M.step(state_package,cas_package)
  return C.together({M.ground(state_package),cas_package})
end
return M
