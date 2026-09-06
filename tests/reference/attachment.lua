-- Exhaustive reference enumerator for Att_K(P).
--
-- Deliberately not exported by worlds.lua.  It exists for differential tests,
-- hostile examples and the next few months of research.  Production code should use Worlds.Att over an exact Frontier rather than
-- materialising the complete space.

local Internal=require('worlds.internal')
local Topology=require('worlds.topology')
local R={}

local function copy_map(t) local o={}; for k,v in pairs(t or {}) do o[k]=v end; return o end
local function shape(a,b)
  if not a or not b or a.dim~=b.dim or a.sort~=b.sort then return false end
  if a.dim==1 then return #a.points==#b.points end
  if a.dim==2 then return #a.inputs==#b.inputs and #a.outputs==#b.outputs end
  return true
end
local function point_rep(m,p)
  local best
  for _,o in ipairs(m.objects) do
    if o.dim==0 and m:is_realised(o) and m:same_point(p,o) and (not best or o.serial<best) then best=o.serial end
  end
  return best or p.serial
end
local function match(m,e,o,p,b,seen)
  if not shape(e,o) or not m:is_realised(o) then return false end
  local prior=b[e]
  if prior then
    if e.dim==0 and prior.dim==0 and o.dim==0 then if not m:same_point(prior,o) then return false end; o=prior
    elseif prior~=o then return false end
  else b[e]=o end
  local k=e.serial..':'..o.serial; if seen[k] then return true end; seen[k]=true
  local ee,oo=m:deps(e),m:deps(o); if #ee~=#oo then return false end
  for i=1,#ee do
    local x,y=ee[i],oo[i]
    if m:is_realised(x) then
      if x.dim==0 and y.dim==0 then if not m:same_point(x,y) then return false end
      elseif x~=y then return false end
    else
      local r=m:_susp_root(x.world); if not (r and p.demand_roots[r]) then return false end
      if not match(m,x,y,p,b,seen) then return false end
    end
  end
  return true
end
local function pool(m,p,w)
  local out,seen={},{}
  local function add(x) if not seen[x] then seen[x]=true; out[#out+1]=x end end
  for _,x in ipairs(m.objects) do
    if x.dim>=0 and m:is_realised(x) and x.world==w then
      if x.dim==0 then add(x)
      elseif x.dim==1 and m:_uses(x)==0 then add(x); for _,q in ipairs(x.points) do add(q) end end
    end
  end
  return out
end
local function injective(b,d,o)
  if o.dim~=1 then return true end
  for x,y in pairs(b) do if x~=d and x.dim==1 and y==o then return false end end
  return true
end
local function prospective(m,p,b)
  local counts={}
  for c in pairs(p.component) do
    local r=m:_susp_root(c.world)
    if c.dim==2 and r and p.generated_roots[r] then
      for _,d in ipairs(c.inputs) do local o=b[d]; if o and o.dim==1 and m:is_realised(o) then counts[o]=(counts[o] or 0)+1 end end
    end
  end
  for s,n in pairs(counts) do if m:_uses(s)+n>1 then return false end end
  return true
end
local function signature(m,p,b)
  local xs={}
  for _,d in ipairs(p.demands) do local o=b[d]; if o then
    xs[#xs+1]=d.serial..'='..(o.dim==0 and ('P'..point_rep(m,o)) or ((o.dim==1 and 'S' or 'C')..o.serial))
  end end
  table.sort(xs); return table.concat(xs,',')
end

function R.matches(public_model,world,seed,fixed)
  local m=Internal.model(public_model); local p=Topology.patch(m,seed); assert(p.attachable,'not attachable')
  local b={}; local demand={}; for _,d in ipairs(p.demands) do demand[d]=true end
  for _,row in ipairs(fixed or {}) do
    assert(demand[row.demand],'fixed demand not on boundary')
    if not injective(b,row.demand,row.supply) then return {} end
    local t=copy_map(b); if not match(m,row.demand,row.supply,p,t,{}) then return {} end; b=t
  end
  local offers=pool(m,p,world); local out,seen={},{ }
  local function rec(i,bindings)
    while i<=#p.demands and bindings[p.demands[i]] do i=i+1 end
    if i>#p.demands then
      if prospective(m,p,bindings) then local s=signature(m,p,bindings); if not seen[s] then seen[s]=true; out[#out+1]={bindings=copy_map(bindings),signature=s} end end
      return
    end
    local d=p.demands[i]; local point_seen={}
    for _,o in ipairs(offers) do
      if o.dim==d.dim and o.sort==d.sort and injective(bindings,d,o) then
        local skip=false
        if d.dim==0 then local r=point_rep(m,o); if point_seen[r] then skip=true else point_seen[r]=true end end
        if not skip then local t=copy_map(bindings); if match(m,d,o,p,t,{}) then rec(i+1,t) end end
      end
    end
  end
  rec(1,b); table.sort(out,function(a,b) return a.signature<b.signature end); return out
end

return R
