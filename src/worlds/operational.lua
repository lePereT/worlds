-- Worlds 0.5.0 -- derived operational boundary projection.
--
-- Semantic equation:
--   next = egress(close(history ⊗ process, complete admissible cuts))
--
-- Boundary stores only exact live egress Strand occurrences.  Step specialises
-- the equation without constructing or retaining closed causal history.

local G=require('worlds.geometry')
local Cut=require('worlds.cut')
local Algebra=require('worlds.algebra')
local M={}
local STATE=setmetatable({}, {__mode='k'})
local BoundaryMT={__newindex=function() error('Worlds Boundary has no public mutable fields',2) end,__metatable='Worlds Operational.Boundary'}; BoundaryMT.__index=BoundaryMT
local QueryMT={__metatable='Worlds Operational.Query'}; QueryMT.__index=QueryMT
local WitnessMT={__newindex=function() error('Worlds operational witness is immutable',2) end,__metatable='Worlds Operational.Witness'}; WitnessMT.__index=WitnessMT

local function state(x,kind) local s=STATE[x]; assert(s and s.kind==kind,'expected Worlds Operational '..kind); return s end
local function boundary_new()
  local x=setmetatable({},BoundaryMT); STATE[x]={kind='Boundary',live={},n=0}; return x
end
function M.from_geometry(g)
  assert(G.is_geometry(g),'Operational.from_geometry expects Geometry'); local b=boundary_new(); local s=STATE[b]
  for _,x in ipairs(g:egress()) do if not s.live[x] then s.live[x]=true; s.n=s.n+1 end end; return b
end
function BoundaryMT:contains(x) local s=state(self,'Boundary'); return not not s.live[x] end
function BoundaryMT:size() return state(self,'Boundary').n end
function BoundaryMT:offers() local r={} for x in pairs(state(self,'Boundary').live) do r[#r+1]=x end return r end

local function context(boundary,process,ctx)
  ctx=ctx or {}; local exact,offers={},{}
  for ps,gs in pairs(ctx.strands or {}) do
    assert(process:is_input(ps),'exact Strand key must be process ingress'); assert(G.is_strand(gs),'exact Strand value must be Strand')
    if not boundary:contains(gs) then return nil,'stale strand anchor' end; exact[ps]=gs
  end
  local seen={}; for _,s in ipairs(ctx.offers or {}) do assert(G.is_strand(s),'offer must be Strand'); if not boundary:contains(s) then return nil,'stale offered Strand' end; if not seen[s] then seen[s]=true; offers[#offers+1]=s end end
  return {strands=exact,offers=offers}
end

local function new_witness(boundary,process,cut)
  local x=setmetatable({},WitnessMT); STATE[x]={kind='Witness',boundary=boundary,process=process,cut=cut}; return x
end
function WitnessMT:boundary() return state(self,'Witness').boundary end
function WitnessMT:process() return state(self,'Witness').process end
function WitnessMT:cut() return state(self,'Witness').cut end
function WitnessMT:strand(s) return Cut._state(state(self,'Witness').cut).strands[s] end
function WitnessMT:point(p) return Cut._state(state(self,'Witness').cut).points[p] end
function WitnessMT:membrane(m) return Cut._state(state(self,'Witness').cut).membranes[m] end

function M.query(boundary,process,ctx)
  state(boundary,'Boundary'); assert(G.is_geometry(process),'Operational.query expects Geometry process')
  local q=setmetatable({},QueryMT)
  if not process:grounded() then STATE[q]={kind='Query',done=true,reason='ungrounded',hits=0}; return q end
  local c,reason=context(boundary,process,ctx); if not c then STATE[q]={kind='Query',done=true,reason=reason,hits=0}; return q end
  STATE[q]={kind='Query',boundary=boundary,process=process,cutq=Cut.query(process,c),done=false,hits=0}; return q
end
function QueryMT:step(budget)
  local s=state(self,'Query'); if s.done then return 'Retry',nil,s.reason end
  budget=budget or 1000; local start=s.cutq:stats().steps
  while true do
    local used=s.cutq:stats().steps-start; local left=budget-used; if left<=0 then return 'Unknown' end
    local k,c=s.cutq:step(left); if k=='Unknown' then return 'Unknown' end
    if k=='Retry' then s.done=true; return 'Retry' end
    if Algebra.admissible(s.process,c) then s.hits=s.hits+1; return 'Hit',new_witness(s.boundary,s.process,c) end
  end
end
function QueryMT:stats()
  local s=state(self,'Query'); if not s.cutq then return {steps=0,hits=s.hits or 0} end
  local c=s.cutq:stats(); return {steps=c.steps,cut_hits=c.hits,hits=s.hits or 0,demands=c.demands,offers=c.offers,pool=c.pool,candidate_matrix_cells=0}
end

local function realise(w)
  local s=state(w,'Witness'); local boundary,process,cs=s.boundary,s.process,Cut._state(s.cut)
  for _,source in pairs(cs.strands) do assert(boundary:contains(source),'stale operational witness') end
  assert(Algebra.admissible(process,s.cut),'operational witness is no longer admissible')
  local image={membranes={},points={},strands={}}
  for k,v in pairs(cs.membranes) do image.membranes[k]=v end; for k,v in pairs(cs.points) do image.points[k]=v end; for k,v in pairs(cs.strands) do image.strands[k]=v end

  local needed={}
  local function mark(m) while m and not image.membranes[m] do needed[m]=true; m=G.parent(m) end end
  for _,ps in ipairs(process:egress()) do
    if process:producer(ps) then mark(G.membrane(ps)); for _,p in ipairs(G._state(ps,'Strand').points) do if process:owns_point(p) and not image.points[p] then mark(G.membrane(p)) end end end
  end
  local function ensure(pm)
    if image.membranes[pm] then return image.membranes[pm] end
    assert(needed[pm],'irrelevant fresh membrane requested'); local parent=G.parent(pm); local gp=parent and ensure(parent) or nil
    assert(gp,'fresh root cannot arise without existing causal locality'); local gm=G._new_membrane(gp,G.name(pm)); image.membranes[pm]=gm; return gm
  end
  for pm in pairs(needed) do ensure(pm) end

  for _,ps in ipairs(process:egress()) do
    for _,p in ipairs(G._state(ps,'Strand').points) do
      if process:owns_point(p) and not image.points[p] then local gm=image.membranes[G.membrane(p)]; assert(gm,'fresh Point has no locality'); image.points[p]=G._new_point(gm,G.name(p)) end
    end
  end

  local bs=state(boundary,'Boundary')
  for ps,source in pairs(cs.strands) do if process:consumer(ps) then assert(bs.live[source]); bs.live[source]=nil; bs.n=bs.n-1 end end
  for _,ps in ipairs(process:egress()) do
    if process:producer(ps) then
      local pts={}; for i,p in ipairs(G._state(ps,'Strand').points) do pts[i]=process:owns_point(p) and image.points[p] or p; assert(pts[i],'egress Point has no image') end
      local gm=image.membranes[G.membrane(ps)]; assert(gm,'egress has no locality image'); local out=G._new_strand(gm,pts,G.name(ps)); image.strands[ps]=out
      if not bs.live[out] then bs.live[out]=true; bs.n=bs.n+1 end
    end
  end
  return boundary,image
end
function M.commit(w) return realise(w) end
function M.one(boundary,process,ctx,budget)
  local q=M.query(boundary,process,ctx); while true do local k,w=q:step(budget or math.huge); if k=='Hit' then return w elseif k=='Retry' then return nil else return nil,'Unknown',q end end
end
function M.all(boundary,process,ctx,budget)
  local q=M.query(boundary,process,ctx); local out={}; while true do local k,w=q:step(budget or math.huge); if k=='Hit' then out[#out+1]=w elseif k=='Retry' then return out else return nil,'Unknown',q end end
end

return M
