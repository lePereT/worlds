-- Intrinsic topology derived from the Worlds carrier.
--
-- This module does not mutate a Model and introduces no carrier object.
-- An attachable patch is one connected detached component, oriented entirely
-- from World-root locality and Point/Strand/Face incidence.

local T={}

local function sorted_set(set,cmp)
  local xs={}; for x in pairs(set or {}) do xs[#xs+1]=x end
  table.sort(xs,cmp or function(a,b) return a.serial<b.serial end)
  return xs
end
local function set_count(t) local n=0; for _ in pairs(t or {}) do n=n+1 end; return n end
local function deps(c)
  if c.dim==0 then return {} end
  if c.dim==1 then return c.points or {} end
  local out={}
  for _,x in ipairs(c.inputs or {}) do out[#out+1]=x end
  for _,x in ipairs(c.outputs or {}) do out[#out+1]=x end
  return out
end


-- A detached component contains complete detached World roots. Distinct roots
-- become one component only through ordinary incidence.
function T.component(m,seed)
  assert(seed and seed.dim and seed.dim>=0 and m:is_suspended(seed),'patch seed must be a suspended cell')
  local seen,root_seen,q={},{},{}
  local function add_root(r)
    if not r or r==m.actuality or root_seen[r] then return end
    root_seen[r]=true
    for _,c in ipairs(m.objects) do
      if c.dim>=0 and m:is_suspended(c) and m:_susp_root(c.world)==r and not seen[c] then
        seen[c]=true; q[#q+1]=c
      end
    end
  end
  local function add(c)
    if c and c.dim and c.dim>=0 and m:is_suspended(c) then add_root(m:_susp_root(c.world)) end
  end
  add(seed)
  local i=1
  while i<=#q do
    local c=q[i]; i=i+1
    for _,d in ipairs(deps(c)) do add(d) end
    for _,p in ipairs(m:_parents(c)) do add(p) end
  end
  return seen
end

-- Incoming/outgoing polarity is not stored. It is a fact about incidence across
-- detached World roots.
function T.is_open_input(m,c,component)
  if not (c and c.dim==1 and m:is_suspended(c) and component[c]) then return false end
  local cr=m:_susp_root(c.world); local crosses=false; local producer=false
  for _,p in ipairs(m:_parents(c)) do
    if p.dim==2 and m:is_suspended(p) and component[p] then
      local pr=m:_susp_root(p.world)
      if pr~=cr then
        for _,x in ipairs(p.inputs) do if x==c then crosses=true; break end end
      end
      for _,x in ipairs(p.outputs) do if x==c then producer=true; break end end
    end
  end
  return crosses and not producer
end

function T.orient(m,component)
  local demand_roots={}
  for c in pairs(component) do
    if T.is_open_input(m,c,component) then
      local r=m:_susp_root(c.world); if r then demand_roots[r]=true end
    end
  end
  local generated_roots={}
  for c in pairs(component) do
    local r=m:_susp_root(c.world)
    if r and not demand_roots[r] then generated_roots[r]=true end
  end
  return demand_roots,generated_roots
end

-- Egress is generated authority returned onto a demand root.
function T.is_open_output(m,c,component,demand_roots,generated_roots)
  if not (c and c.dim==1 and m:is_suspended(c) and component[c]) then return false end
  local cr=m:_susp_root(c.world)
  if not (cr and demand_roots[cr]) then return false end
  local produced=false
  for _,p in ipairs(m:_parents(c)) do
    if p.dim==2 and m:is_suspended(p) and component[p] then
      local pr=m:_susp_root(p.world)
      for _,x in ipairs(p.outputs) do
        if x==c and pr and generated_roots[pr] then produced=true end
      end
      for _,x in ipairs(p.inputs) do if x==c then return false end end
    end
  end
  return produced
end

local function minimum_serial(component)
  local n
  for c in pairs(component) do if not n or c.serial<n then n=c.serial end end
  return n
end

-- Return the complete topologically-derived open patch containing seed.
-- `demands` is an implementation traversal only. Its ordering has no semantic
-- force; attachment is defined by the complete simultaneous matching.
function T.patch(m,seed)
  local component=T.component(m,seed)
  local demand_roots,generated_roots=T.orient(m,component)
  local inputs,outputs,demands={},{},{}
  for c in pairs(component) do
    if c.dim==1 and T.is_open_input(m,c,component) then inputs[#inputs+1]=c end
    if T.is_open_output(m,c,component,demand_roots,generated_roots) then outputs[#outputs+1]=c end
    local r=c.dim>=0 and m:_susp_root(c.world) or nil
    if r and demand_roots[r] and not T.is_open_output(m,c,component,demand_roots,generated_roots) then
      demands[#demands+1]=c
    end
  end
  local by_serial=function(a,b) return a.serial<b.serial end
  table.sort(inputs,by_serial); table.sort(outputs,by_serial)
  -- Fail-first search is free to reorder this later; this stable order exists
  -- only to make the reference implementation and diagnostics reproducible.
  table.sort(demands,function(a,b)
    if a.dim~=b.dim then return a.dim>b.dim end
    return a.serial<b.serial
  end)
  return {
    seed=seed,key=minimum_serial(component),component=component,
    demand_roots=demand_roots,generated_roots=generated_roots,
    inputs=inputs,outputs=outputs,demands=demands,
    attachable=(#inputs>0 and set_count(generated_roots)>0),
  }
end

function T.patches(m)
  local visited,out={},{}
  for _,o in ipairs(m.objects) do
    if o.dim>=0 and m:is_suspended(o) and not visited[o] then
      local p=T.patch(m,o)
      -- A patch is a connected detached component, so every carrier cell in it
      -- would derive the same component. Mark the whole component now rather
      -- than rediscovering it once per cell. This is only traversal caching; it
      -- does not alter the topology or patch identity.
      for c in pairs(p.component) do visited[c]=true end
      if p.attachable then out[#out+1]=p end
    end
  end
  table.sort(out,function(a,b) return a.key<b.key end)
  return out
end

function T.generated_roots(patch) return sorted_set(patch.generated_roots) end

-- Stable implementation fingerprint used only to invalidate retained searches
-- if the detached patch itself is extended while a query is suspended.
function T.fingerprint(m,patch)
  local rows={}
  for c in pairs(patch.component) do
    local ds={}; for _,d in ipairs(deps(c)) do ds[#ds+1]=d.serial end
    table.sort(ds)
    rows[#rows+1]=table.concat({c.serial,c.dim,tostring(c.sort),table.concat(ds,',')},':')
  end
  table.sort(rows)
  return table.concat(rows,'|')
end

return T
