-- Worlds 0.5.0 -- exact scarce boundary wiring.
--
-- Cut is a retained proof/search relation.  It creates nothing and executes
-- nothing.  It maps demanded ingress Strands of one open Geometry injectively
-- to an explicit finite set of exact offered Strands, while solving Point
-- equality and membrane-topology equations induced by that wiring.

local G=require('worlds.geometry')
local M={}
local STATE=setmetatable({}, {__mode='k'})
local CutMT={__newindex=function() error('Worlds Cut values are immutable',2) end,__metatable='Worlds Cut'}; CutMT.__index=CutMT
local QueryMT={__metatable='Worlds Cut.Query'}; QueryMT.__index=QueryMT

local function state(x,kind)
  local s=STATE[x]; assert(s and (not kind or s.kind==kind),'expected Worlds '..(kind or 'Cut value')); return s
end
local function copy(m) local r={} for k,v in pairs(m or {}) do r[k]=v end return r end
local function restore(dst,snap) for k in pairs(dst) do dst[k]=nil end; for k,v in pairs(snap) do dst[k]=v end end

local function map_membrane(mmap,pm,gm)
  while pm do
    if not (G.is_membrane(pm) and G.is_membrane(gm)) then return false end
    local old=mmap[pm]; if old and old~=gm then return false end; mmap[pm]=gm
    pm=G.parent(pm); if pm then gm=G.parent(gm); if not gm then return false end end
  end
  return true
end

local function new_cut(pattern,smap,pmap,mmap)
  local x=setmetatable({},CutMT); STATE[x]={kind='Cut',pattern=pattern,strands=copy(smap),points=copy(pmap),membranes=copy(mmap)}; return x
end
function CutMT:pattern() return state(self,'Cut').pattern end
function CutMT:strand(s) return state(self,'Cut').strands[s] end
function CutMT:point(p) return state(self,'Cut').points[p] end
function CutMT:membrane(m) return state(self,'Cut').membranes[m] end
function CutMT:closed_inputs() local r={} for s in pairs(state(self,'Cut').strands) do r[#r+1]=s end return r end

local function demands_of(pattern,ctx)
  if ctx.demands==nil then return pattern:ingress() end
  local out,seen={},{}
  for _,s in ipairs(ctx.demands) do
    assert(pattern:is_input(s),'Cut demand must be an ingress Strand of the pattern')
    assert(not seen[s],'Cut demand listed more than once'); seen[s]=true; out[#out+1]=s
  end
  return out
end

local function prepare(pattern,ctx,stats)
  ctx=ctx or {}
  local demands=demands_of(pattern,ctx); stats.demands=#demands
  local demanded={}; for _,s in ipairs(demands) do demanded[s]=true end
  local exact=copy(ctx.strands)
  for ps,gs in pairs(exact) do
    assert(demanded[ps],'exact Strand key must be a demanded ingress Strand')
    assert(G.is_strand(gs),'exact Strand value must be a Strand')
  end

  -- Fail first using only intrinsic shape; no demand×offer matrix is built.
  local function rigid_count(s)
    local n=0; for _,p in ipairs(G._state(s,'Strand').points) do if not pattern:owns_point(p) then n=n+1 end end; return n
  end
  table.sort(demands,function(a,b)
    local ae,be=exact[a]~=nil,exact[b]~=nil; if ae~=be then return ae end
    local ar,br=rigid_count(a),rigid_count(b); if ar~=br then return ar>br end
    return #G._state(a,'Strand').points > #G._state(b,'Strand').points
  end)

  -- Build the scarce pool after demand ordering. Exact anchors come first in
  -- exact-demand order so the common direct-authority path is immediately local.
  local pool,seen={},{}
  for _,ps in ipairs(demands) do local gs=exact[ps]; if gs and not seen[gs] then seen[gs]=true; pool[#pool+1]=gs end end
  local explicit_offers,offer_seen=0,{}
  for _,gs in ipairs(ctx.offers or {}) do
    assert(G.is_strand(gs),'Cut offer must be a Strand')
    if not offer_seen[gs] then offer_seen[gs]=true; explicit_offers=explicit_offers+1 end
    if not seen[gs] then seen[gs]=true; pool[#pool+1]=gs end
  end
  stats.offers=explicit_offers; stats.pool=#pool

  local available,pos_of={},{}
  for i,gs in ipairs(pool) do available[i]=gs; pos_of[gs]=i end
  local available_n=#available
  local smap,pmap,mmap={},{},{}
  local function compatible(ps,gs)
    if exact[ps] and exact[ps]~=gs then return false end
    local a,b=G._state(ps,'Strand').points,G._state(gs,'Strand').points
    if #a~=#b then return false end
    for i,p in ipairs(a) do if not pattern:owns_point(p) and p~=b[i] then return false end end
    return true
  end

  local co=coroutine.create(function()
    local function tick() coroutine.yield('candidate') end
    local function bind_point(pp,gp)
      local old=pmap[pp]; if old then return old==gp end
      if not map_membrane(mmap,G.membrane(pp),G.membrane(gp)) then return false end
      pmap[pp]=gp; return true
    end

    -- Search is deliberately iterative. A valid first witness can be as deep as
    -- the number of demanded Strands (10,000+ in ordinary structural tests);
    -- semantic search depth must not consume the Lua/C call stack. Each frame is
    -- one demanded Strand plus its local candidate cursor. An active binding is
    -- undone when its child frame is exhausted or after a leaf Hit resumes.
    local frames={}
    local depth=1

    local function frame_for(i)
      local ps=demands[i]
      local anchored=exact[ps]
      local f={ps=ps,wanted=G._state(ps,'Strand').points,anchored=anchored}
      if anchored then f.pos=pos_of[anchored]; f.used=false
      else f.next_pos=1; f.limit=available_n end
      return f
    end

    local function next_pos(f)
      if f.anchored then
        if f.used then return nil end
        f.used=true
        local pos=f.pos
        if pos and pos<=available_n and available[pos]==f.anchored then return pos end
        return nil
      end
      if f.next_pos>f.limit then return nil end
      local pos=f.next_pos; f.next_pos=pos+1; return pos
    end

    local function undo(f)
      local a=f.active; if not a then return end
      smap[f.ps]=nil
      available_n=available_n+1
      available[a.pos]=a.gs; pos_of[a.gs]=a.pos
      available[available_n]=a.last; pos_of[a.last]=available_n
      restore(pmap,a.oldp); restore(mmap,a.oldm)
      f.active=nil
    end

    if #demands==0 then
      stats.hits=stats.hits+1
      coroutine.yield('hit',new_cut(pattern,smap,pmap,mmap))
      return
    end

    frames[1]=frame_for(1)
    while depth>=1 do
      local f=frames[depth]
      local pos=next_pos(f)
      if not pos then
        frames[depth]=nil
        depth=depth-1
        if depth>=1 then undo(frames[depth]) end
      else
        local gs=available[pos]
        tick() -- every examined offer is work, including an incompatible one
        if compatible(f.ps,gs) then
          local oldp,oldm=copy(pmap),copy(mmap)
          local ok=map_membrane(mmap,G.membrane(f.ps),G.membrane(gs))
          if ok then
            local got=G._state(gs,'Strand').points
            for j,pp in ipairs(f.wanted) do
              if pattern:owns_point(pp) then if not bind_point(pp,got[j]) then ok=false; break end
              elseif pp~=got[j] then ok=false; break end
            end
          end
          if ok then
            local last=available[available_n]
            available[pos]=last; pos_of[last]=pos
            available[available_n]=gs; pos_of[gs]=available_n
            available_n=available_n-1
            smap[f.ps]=gs
            f.active={gs=gs,pos=pos,last=last,oldp=oldp,oldm=oldm}
            if depth==#demands then
              stats.hits=stats.hits+1
              coroutine.yield('hit',new_cut(pattern,smap,pmap,mmap))
              undo(f)
            else
              depth=depth+1
              frames[depth]=frame_for(depth)
            end
          else
            restore(pmap,oldp); restore(mmap,oldm)
          end
        end
      end
    end
  end)
  return co
end

function M.query(pattern,ctx)
  assert(G.is_geometry(pattern),'Cut.query expects Geometry')
  local stats={steps=0,hits=0,demands=0,offers=0,pool=0,candidate_matrix_cells=0}
  local q=setmetatable({},QueryMT); STATE[q]={kind='Query',co=prepare(pattern,ctx or {},stats),stats=stats,done=false,pending_candidate=false}; return q
end
function QueryMT:step(budget)
  local s=state(self,'Query'); if s.done then return 'Retry' end
  budget=budget or 1000; local spent=0
  while true do
    if s.pending_candidate then
      if spent>=budget then return 'Unknown' end
      s.pending_candidate=false; spent=spent+1; s.stats.steps=s.stats.steps+1
    end
    local ok,tag,value=coroutine.resume(s.co); if not ok then error(tag,2) end
    if coroutine.status(s.co)=='dead' then s.done=true; return 'Retry' end
    if tag=='candidate' then
      s.pending_candidate=true
    elseif tag=='hit' then
      return 'Hit',value
    end
  end
end
function QueryMT:stats() local s=state(self,'Query').stats; return {steps=s.steps,hits=s.hits,demands=s.demands,offers=s.offers,pool=s.pool,candidate_matrix_cells=0} end

function M.one(pattern,ctx,budget)
  local q=M.query(pattern,ctx); while true do local k,w=q:step(budget or math.huge); if k=='Hit' then return w elseif k=='Retry' then return nil else return nil,'Unknown',q end end
end
function M.all(pattern,ctx,budget)
  local q=M.query(pattern,ctx); local out={}; while true do local k,w=q:step(budget or math.huge); if k=='Hit' then out[#out+1]=w elseif k=='Retry' then return out else return nil,'Unknown',q end end
end

M._state=function(x) return state(x,'Cut') end
M._map_membrane=map_membrane
return M
