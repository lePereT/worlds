-- Worlds 0.5.0 -- exact finite open geometry.
--
-- Semantic carriers are exactly Membrane, Point, Strand and Face.  Carriers
-- are immutable opaque Lua objects; object identity is exact identity.  Names
-- are correspondence/debug data only.  There are no semantic sorts or IDs.

local M={}

local STATE=setmetatable({}, {__mode='k'})
local function immutable() error('Worlds values are immutable',2) end
local CarrierMT={__newindex=immutable,__metatable='Worlds carrier'}
local GeometryMT={__newindex=immutable,__metatable='Worlds Geometry'}; GeometryMT.__index=GeometryMT
local BuilderMT={}; BuilderMT.__index=BuilderMT

local function new(kind,data,mt)
  local x=setmetatable({},mt or CarrierMT); data.kind=kind; STATE[x]=data; return x
end
local function state(x,kind)
  local s=STATE[x]; if kind then assert(s and s.kind==kind,'expected Worlds '..kind) end; return s
end
local function array(xs) local r={} for i=1,#(xs or {}) do r[i]=xs[i] end return r end
local function setcopy(xs) local r={} for k,v in pairs(xs or {}) do if v then r[k]=true end end return r end

local function membrane(parent,name)
  assert(parent==nil or state(parent,'Membrane'),'Membrane parent must be a Membrane or nil')
  return new('Membrane',{parent=parent,name=name})
end
local function point(mem,name)
  assert(state(mem,'Membrane'),'Point membrane must be a Membrane')
  return new('Point',{membrane=mem,name=name})
end
local function strand(mem,points,name)
  assert(state(mem,'Membrane'),'Strand membrane must be a Membrane')
  for _,p in ipairs(points or {}) do assert(state(p,'Point'),'Strand incidence must contain Points') end
  return new('Strand',{membrane=mem,points=array(points),name=name})
end
local function face(mem,inputs,outputs,name)
  assert(state(mem,'Membrane'),'Face membrane must be a Membrane')
  local seen={}
  for _,s in ipairs(inputs or {}) do
    assert(state(s,'Strand'),'Face inputs must be Strands')
    assert(not seen[s],'Face consumes the same Strand twice'); seen[s]=true
  end
  seen={}
  for _,s in ipairs(outputs or {}) do
    assert(state(s,'Strand'),'Face outputs must be Strands')
    assert(not seen[s],'Face produces the same Strand twice'); seen[s]=true
  end
  -- Arrays are the compact physical enumeration.  Their order is not semantic.
  return new('Face',{membrane=mem,inputs=array(inputs),outputs=array(outputs),name=name})
end

function M.kind(x) local s=STATE[x]; return s and string.lower(s.kind) or nil end
function M.is_membrane(x) local s=STATE[x]; return not not (s and s.kind=='Membrane') end
function M.is_point(x) local s=STATE[x]; return not not (s and s.kind=='Point') end
function M.is_strand(x) local s=STATE[x]; return not not (s and s.kind=='Strand') end
function M.is_face(x) local s=STATE[x]; return not not (s and s.kind=='Face') end
function M.is_geometry(x) local s=STATE[x]; return not not (s and s.kind=='Geometry') end
function M.name(x) local s=STATE[x]; return s and s.name or nil end
function M.parent(x) return state(x,'Membrane').parent end
function M.membrane(x) local s=STATE[x]; assert(s and (s.kind=='Point' or s.kind=='Strand' or s.kind=='Face'),'expected Point/Strand/Face'); return s.membrane end
function M.points(x) return array(state(x,'Strand').points) end
-- Face incidence is a finite set semantically.  These compact arrays are only
-- enumerations; callers must not attach meaning to their order.
function M.inputs(x) return array(state(x,'Face').inputs) end
function M.outputs(x) return array(state(x,'Face').outputs) end

function M.builder()
  return setmetatable({
    membranes={},points={},strands={},faces={},
    mset={},pset={},sset={},fset={},finished=false,
  },BuilderMT)
end
local function live_builder(b) assert(getmetatable(b)==BuilderMT and not b.finished,'expected unfinished Geometry.Builder'); return b end
function BuilderMT:membrane(parent,name)
  live_builder(self); if parent then assert(self.mset[parent],'new membrane parent must belong to this Geometry') end
  local x=membrane(parent,name); self.membranes[#self.membranes+1]=x; self.mset[x]=true; return x
end
function BuilderMT:point(mem,name)
  live_builder(self); assert(self.mset[mem],'Point membrane must belong to this Geometry')
  local x=point(mem,name); self.points[#self.points+1]=x; self.pset[x]=true; return x
end
function BuilderMT:strand(mem,pts,name)
  live_builder(self); assert(self.mset[mem],'Strand membrane must belong to this Geometry')
  -- Point incidence may contain imported exact Points owned by another Geometry.
  local x=strand(mem,pts or {},name); self.strands[#self.strands+1]=x; self.sset[x]=true; return x
end
function BuilderMT:face(mem,ins,outs,name)
  live_builder(self); assert(self.mset[mem],'Face membrane must belong to this Geometry')
  for _,s in ipairs(ins or {}) do assert(self.sset[s],'Face input must belong to this Geometry') end
  for _,s in ipairs(outs or {}) do assert(self.sset[s],'Face output must belong to this Geometry') end
  local x=face(mem,ins or {},outs or {},name); self.faces[#self.faces+1]=x; self.fset[x]=true; return x
end

local function validate(b)
  local producer,consumer={},{}
  for _,f in ipairs(b.faces) do
    local fs=state(f,'Face'); local seen={}
    for _,s in ipairs(fs.inputs) do
      assert(not seen[s],'Face consumes the same Strand twice'); seen[s]=true
      assert(not consumer[s],'Strand has more than one consumer'); consumer[s]=f
    end
    seen={}
    for _,s in ipairs(fs.outputs) do
      assert(not seen[s],'Face produces the same Strand twice'); seen[s]=true
      assert(not producer[s],'Strand has more than one producer'); producer[s]=f
    end
  end

  -- Exact causal incidence must be acyclic.  Mutual support is normalised by
  -- Algebra.close before Geometry construction, so cycles never enter Geometry.
  local out,indeg={},{ }
  for _,f in ipairs(b.faces) do out[f]={}; indeg[f]=0 end
  for _,s in ipairs(b.strands) do
    local p,c=producer[s],consumer[s]
    if p and c then out[p][#out[p]+1]=c; indeg[c]=indeg[c]+1 end
  end
  local q={}; for _,f in ipairs(b.faces) do if indeg[f]==0 then q[#q+1]=f end end
  local qi,n=1,0
  while qi<=#q do
    local f=q[qi]; qi=qi+1; n=n+1
    for _,g in ipairs(out[f]) do indeg[g]=indeg[g]-1; if indeg[g]==0 then q[#q+1]=g end end
  end
  assert(n==#b.faces,'causal Face/Strand incidence must be acyclic')

  local ingress,egress={},{ }
  for _,s in ipairs(b.strands) do
    if not producer[s] then ingress[#ingress+1]=s end
    if not consumer[s] then egress[#egress+1]=s end
  end

  -- Every Face of an executable process must lie downstream of an ingress.
  local reached,rq={},{}
  for _,s in ipairs(ingress) do local c=consumer[s]; if c and not reached[c] then reached[c]=true; rq[#rq+1]=c end end
  local ri=1
  while ri<=#rq do
    local f=rq[ri]; ri=ri+1
    for _,s in ipairs(state(f,'Face').outputs) do local c=consumer[s]; if c and not reached[c] then reached[c]=true; rq[#rq+1]=c end end
  end
  local grounded=true
  for _,f in ipairs(b.faces) do if not reached[f] then grounded=false; break end end
  return producer,consumer,ingress,egress,grounded
end

function BuilderMT:finish()
  live_builder(self)
  local producer,consumer,ingress,egress,grounded=validate(self)
  self.finished=true
  return new('Geometry',{
    membranes=array(self.membranes),points=array(self.points),strands=array(self.strands),faces=array(self.faces),
    mset=setcopy(self.mset),pset=setcopy(self.pset),sset=setcopy(self.sset),fset=setcopy(self.fset),
    producer=producer,consumer=consumer,ingress=ingress,egress=egress,grounded=grounded,
  },GeometryMT)
end

local function gs(g) return state(g,'Geometry') end
function GeometryMT:membranes() return array(gs(self).membranes) end
function GeometryMT:points() return array(gs(self).points) end
function GeometryMT:strands() return array(gs(self).strands) end
function GeometryMT:faces() return array(gs(self).faces) end
function GeometryMT:ingress() return array(gs(self).ingress) end
function GeometryMT:egress() return array(gs(self).egress) end
function GeometryMT:owns_membrane(x) return not not gs(self).mset[x] end
function GeometryMT:owns_point(x) return not not gs(self).pset[x] end
function GeometryMT:owns_strand(x) return not not gs(self).sset[x] end
function GeometryMT:owns_face(x) return not not gs(self).fset[x] end
function GeometryMT:producer(s) assert(self:owns_strand(s),'Strand does not belong to Geometry'); return gs(self).producer[s] end
function GeometryMT:consumer(s) assert(self:owns_strand(s),'Strand does not belong to Geometry'); return gs(self).consumer[s] end
function GeometryMT:is_input(s) return self:owns_strand(s) and gs(self).producer[s]==nil end
function GeometryMT:is_terminal(s) return self:owns_strand(s) and gs(self).consumer[s]==nil end
function GeometryMT:grounded() return gs(self).grounded end

-- Private hooks shared by the tiny semantic/operational implementation.
M._state=state
M._new_membrane=membrane
M._new_point=point
M._new_strand=strand
M._new_face=face
return M
