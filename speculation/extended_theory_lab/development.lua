-- Experimental Geometry + occurrence-relative Theory pairing.
-- Worlds remains the sole authority/causality/locality machine.

local W=require('worlds')
local Q=require('worlds.query')
local Construction=require('worlds.construction')
local Theory=require('speculation.extended_theory_lab.theory')

local D={}
local State={}
State.__index=State
local Rule={}
Rule.__index=Rule

function D.state(geometry,facts,schemas)
  assert(W.boundary(geometry)==geometry,'live experimental state must be boundary-normal Geometry')
  return setmetatable({geometry=geometry,theory=Theory.state(geometry,facts,schemas)},State)
end

function D.rule(geometry,spec)
  return setmetatable({geometry=geometry,theory=Theory.rule(geometry,spec)},Rule)
end

function State:facts() return self.theory:all() end
function State:count(pred) return self.theory:count(pred) end
function State:select(pred) return self.theory:select(pred) end

local function decide(q)
  local e=Q.solve(q)
  while true do
    local k,x=e:step(math.huge)
    if k=='yes' or k=='no' then return k,x end
    if k=='done' then return 'no',x end
  end
end

function D.prepare(state,rule,seeds)
  local kind,eqs=decide(Q.match(state.geometry,rule.geometry,{seeds=seeds or {}}))
  if kind~='yes' then return nil,'no-worlds-match' end
  return {rule=rule,equations=eqs,sources=(function()
    local xs={}
    for _,e in ipairs(eqs) do xs[#xs+1]=e.from end
    return xs end)()}
end

local function source_current(g,s)
  return g:owns_strand(s) and g:consumer(s)==nil
end

function D.commit(state,prepared)
  for _,s in ipairs(prepared.sources) do if W.kind(s)=='strand' and not
      source_current(state.geometry,s) then return nil,'stale-exact-authority' end end
  local ok,c=pcall(Construction.join,{state.geometry,prepared.rule.geometry},prepared.equations)
  if not ok then return nil,'invalid-worlds-construction' end
  local theory,detail=Theory.apply(state.theory,prepared.rule.theory,c)
  if not theory then return nil,detail end
  return setmetatable({geometry=theory.geometry,theory=theory},State),{construction=c,theory=detail}
end

function D.apply(state,rule,seeds)
  local p,why=D.prepare(state,rule,seeds)
  if not p then return nil,why end
  return D.commit(state,p)
end

return D
