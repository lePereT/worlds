-- Same hostile-lab Development pairing, but with strict positive Theory.
local W=require('worlds')
local Q=require('worlds.query')
local Construction=require('worlds.construction')
local Theory=require('speculation.relay.theory.lifecycle_and_correspondence.historical.positive_theory')
local D={}
local State={}
State.__index=State
local Rule={}
Rule.__index=Rule
function D.state(g,facts,schemas)
  assert(W.boundary(g)==g,'live state must be boundary-normal Geometry')
  return setmetatable({geometry=g,theory=Theory.state(g,facts,schemas)},State)
end
function D.rule(g,spec) return setmetatable({geometry=g,theory=Theory.rule(g,spec)},Rule) end
function State:facts() return self.theory:all() end
function State:count(p) return self.theory:count(p) end
function State:select(p) return self.theory:select(p) end
local function decide(q) local e=Q.solve(q)
while true do local k,x=e:step(math.huge)
  if k=='yes' or k=='no' then return k,x end
  if k=='done' then return 'no',x end end end
function D.prepare(state,rule,seeds)
  local kind,eqs=decide(Q.match(state.geometry,rule.geometry,{seeds=seeds or {}}))
  if kind~='yes' then return nil,'no-worlds-match' end
  local src={}
  for _,e in ipairs(eqs) do src[#src+1]=e.from end
  return {rule=rule,equations=eqs,sources=src}
end
local function current(g,s) return g:owns_strand(s) and g:consumer(s)==nil end
function D.commit(state,p)
  for _,s in ipairs(p.sources) do if W.kind(s)=='strand' and not current(state.geometry,s) then
    return nil,'stale-exact-authority' end end
  local ok,c=pcall(Construction.join,{state.geometry,p.rule.geometry},p.equations)
  if not ok then return nil,'invalid-worlds-construction' end
  local th,detail=Theory.apply(state.theory,p.rule.theory,c)
  if not th then return nil,detail end
  return setmetatable({geometry=th.geometry,theory=th},State),{construction=c,theory=detail}
end
function D.apply(state,rule,seeds) local p,w=D.prepare(state,rule,seeds)
if not p then return nil,w end
  return D.commit(state,p) end
return D
