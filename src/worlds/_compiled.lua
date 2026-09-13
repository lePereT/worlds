-- Private disposable acceleration for Worlds query machinery.
--
-- The verified centre does not require or register this module.  Everything
-- here is derived lazily from the centre's read-only observation capability and
-- may be discarded without changing Geometry or matching semantics.

local INSTANCES=setmetatable({}, {__mode='k'})

return function(K)
local existing=INSTANCES[K]; if existing then return existing end
assert(type(K)=='table' and type(K.geometry)=='function','compiled Worlds acceleration requires kernel observation capability')
local M={}
local VIEW=setmetatable({}, {__mode='k'})
-- Key complete outgoing sections by their exact egress array.  boundary()
-- deliberately preserves that array, so a projected live Geometry naturally
-- reuses the same acceleration without a callback into the kernel.
local SURFACE=setmetatable({}, {__mode='k'})

local function push(map,key,value)
  local xs=map[key]
  if not xs then xs={}; map[key]=xs end
  xs[#xs+1]=value
end

local function counted_surface(strands)
  local relations,groups,of={},{},{}
  for _,s in ipairs(strands) do
    local ps=K.points(s); local ar=#ps; local rel=relations[ar]
    if not rel then
      rel={rows={},by={}}
      for i=2,ar+1 do rel.by[i]={} end
      relations[ar]=rel; groups[ar]={}
    end
    local coords={K.place(s)}
    for i,p in ipairs(ps) do coords[i+1]=p end
    local n=groups[ar]
    for i=1,#coords do
      local v=coords[i]; local q=n[v]
      if not q then q={}; n[v]=q end
      n=q
    end
    local g=n.group
    if not g then
      g={coords=coords,occurrences={}}; n.group=g; rel.rows[#rel.rows+1]=g
      for i=2,#coords do push(rel.by[i],coords[i],g) end
    end
    g.occurrences[#g.occurrences+1]=s; of[s]=g
  end
  return {relations=relations,of=of}
end

local function positions(xs)
  local p={}; for i,x in ipairs(xs) do p[x]=i end; return p
end

-- Read exact kernel state only on demand.  The returned view contains direct
-- references to immutable kernel arrays/maps for speed; it has no authority to
-- mutate Geometry and is itself disposable.
function M.view(g)
  local v=VIEW[g]; if v then return v end
  local s=K.geometry(g)
  v={
    membranes=s.membranes,points=s.points,strands=s.strands,faces=s.faces,
    mset=s.mset,pset=s.pset,sset=s.sset,fset=s.fset,
    producer=s.producer,consumer=s.consumer,
    ingress=s.ingress,egress=s.egress,
    developable=s.developable,
  }
  VIEW[g]=v
  return v
end

function M.surface(g)
  local v=M.view(g); local key=v.egress
  local x=SURFACE[key]; if x then return x end
  x=counted_surface(key); SURFACE[key]=x; return x
end

function M.prepare(g)
  M.view(g)
  M.surface(g)
  return g
end

function M.ingress_positions(g)
  local v=M.view(g)
  if not v.ipos then v.ipos=positions(v.ingress) end
  return v.ipos
end

function M.egress_positions(g)
  local v=M.view(g)
  if not v.epos then v.epos=positions(v.egress) end
  return v.epos
end

INSTANCES[K]=M
return M
end
