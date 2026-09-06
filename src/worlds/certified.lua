-- Immutable certified observation of a World model.
--
-- Certification is deliberately a boundary, not another semantic ontology.
-- It validates actual geometry and every attachable detached patch, then copies
-- only primitive World/Point/Strand/Face facts into an immutable Reader view.
-- Downstream Relay code cannot mutate the Model through this capability.

local Audit=require('worlds.audit')
local Model=require('worlds.harden')
local Internal=require('worlds.internal')
local Topology=require('worlds.topology')
local topology_patches=assert(Topology.patches)

-- Pin the Lua trust surface once. This is implementation hardening supplied
-- by `harden.lua`; the semantic certification logic below remains geometric.
local audit_check_certified=assert(Audit.check_certified)
local audit_check_stage=assert(Audit.check_stage)
local model_is_model=assert(Model.is_model)
local model_pristine=assert(Internal.pristine)
local trust_guard=assert(Internal.guard)({Model=Model,Audit=Audit,Topology=Topology})

local C={SCHEMA='worlds.certified/1'}
local View={}; View.__index=View; View.__metatable=false; View.__newindex=function() error('certified World view is immutable',2) end
local Reader={}; Reader.__index=Reader; Reader.__metatable=false; Reader.__newindex=function() error('certified World Reader is immutable',2) end
local views=setmetatable({}, {__mode='k'})
local readers=setmetatable({}, {__mode='k'})

local function fail(msg) error(msg,0) end
local function copy_array(xs)
  local o={}; for i=1,#(xs or {}) do o[i]=xs[i] end; return o
end
local function detached(x,seen)
  if type(x)~='table' then return x end
  seen=seen or {}; if seen[x] then return seen[x] end
  local out={}; seen[x]=out
  for k,v in pairs(x) do out[detached(k,seen)]=detached(v,seen) end
  return out
end

local function component_id(m,p,points)
  local best=p.serial
  for _,q in ipairs(points) do
    if q.dim==0 and m:same_point(p,q) and q.serial<best then best=q.serial end
  end
  return best
end

local function validate_stages(m)
  for _,patch in ipairs(topology_patches(m)) do
    local ok,why=audit_check_stage(m,patch.inputs[1])
    if not ok then return false,why end
  end
  return true
end

local function certify_model(m)
  local ok,why=audit_check_certified(m)
  if not ok then return false,why end
  ok,why=m:check_actual_subcomplex()
  if not ok then return false,why end
  ok,why=validate_stages(m)
  if not ok then return false,why end
  return true
end

function C.certify(m)
  if not model_is_model(m) then fail('certify expects World Model') end
  local ok,why=trust_guard(); if not ok then fail('World certification trust surface changed: '..why) end
  ok,why=model_pristine(m); if not ok then fail('World certification rejected non-opaque handle: '..why) end
  local im=Internal.model(m)
  ok,why=certify_model(im)
  if not ok then fail('World certification failed: '..tostring(why)) end

  local points={}; for _,o in ipairs(im.objects) do if o.dim==0 then points[#points+1]=o end end
  local worlds,ps,ss,fs={},{},{},{}
  local producers,consumers={},{}

  for _,o in ipairs(im.objects) do
    if o.dim==-1 then
      worlds[o.serial]={
        id=o.serial,name=o.name,parent=o.parent and o.parent.serial or nil,
        realised=im:is_realised(o),actuality=(o==im.actuality),origin=o.origin and o.origin.serial or nil,
      }
    elseif o.dim==0 then
      ps[o.serial]={
        id=o.serial,name=o.name,sort=o.sort,world=o.world.serial,
        realised=im:is_realised(o),component=component_id(im,o,points),origin=o.origin and o.origin.serial or nil,
      }
    elseif o.dim==1 then
      local ids={}; for i,p in ipairs(o.points or {}) do ids[i]=p.serial end
      ss[o.serial]={
        id=o.serial,name=o.name,sort=o.sort,world=o.world.serial,points=ids,
        realised=im:is_realised(o),origin=o.origin and o.origin.serial or nil,
      }
    elseif o.dim==2 then
      local ins,outs={},{}
      for i,s in ipairs(o.inputs or {}) do ins[i]=s.serial end
      for i,s in ipairs(o.outputs or {}) do outs[i]=s.serial end
      fs[o.serial]={
        id=o.serial,name=o.name,sort=o.sort,world=o.world.serial,inputs=ins,outputs=outs,
        realised=im:is_realised(o),structural=im:structural_kind(o),origin=o.origin and o.origin.serial or nil,
      }
      if im:is_realised(o) then
        for _,sid in ipairs(ins) do
          local xs=consumers[sid] or {}; consumers[sid]=xs; xs[#xs+1]=o.serial
        end
        for _,sid in ipairs(outs) do
          local xs=producers[sid] or {}; producers[sid]=xs; xs[#xs+1]=o.serial
        end
      end
    end
  end

  local state={
    schema=C.SCHEMA,root=im.actuality.serial,
    worlds=worlds,points=ps,strands=ss,faces=fs,
    producers=producers,consumers=consumers,
  }
  local v=setmetatable({},View); views[v]=state
  return v
end

function C.is_view(v) return views[v]~=nil end
function C.schema(v) local s=views[v]; return s and s.schema or nil end

function C.read(v)
  local state=views[v]; if not state then fail('expected certified World view') end
  local r=setmetatable({},Reader); readers[r]=state; return r
end
function C.is_reader(r) return readers[r]~=nil end

local function state(self)
  local s=readers[self]; if not s then fail('expected certified World Reader') end; return s
end
local function get(t,id,kind)
  local x=t[id]; if not x then fail('unknown certified '..kind..' '..tostring(id)) end; return detached(x)
end
local function sorted_ids(t,predicate)
  local out={}; for id,x in pairs(t) do if not predicate or predicate(x) then out[#out+1]=id end end
  table.sort(out); return out
end

function Reader:schema() return state(self).schema end
function Reader:root() return state(self).root end
function Reader:world(id) local s=state(self); return get(s.worlds,id,'World') end
function Reader:point(id) local s=state(self); return get(s.points,id,'Point') end
function Reader:strand(id) local s=state(self); return get(s.strands,id,'Strand') end
function Reader:face(id) local s=state(self); return get(s.faces,id,'Face') end
function Reader:worlds(parent,realised)
  local s=state(self)
  return sorted_ids(s.worlds,function(x)
    return (parent==nil or x.parent==parent) and (realised==nil or x.realised==realised)
  end)
end
function Reader:points(world,sort,realised)
  local s=state(self)
  return sorted_ids(s.points,function(x)
    return (world==nil or x.world==world) and (sort==nil or x.sort==sort) and (realised==nil or x.realised==realised)
  end)
end
function Reader:strands(world,sort,realised)
  local s=state(self)
  return sorted_ids(s.strands,function(x)
    return (world==nil or x.world==world) and (sort==nil or x.sort==sort) and (realised==nil or x.realised==realised)
  end)
end
function Reader:faces(world,sort,realised)
  local s=state(self)
  return sorted_ids(s.faces,function(x)
    return (world==nil or x.world==world) and (sort==nil or x.sort==sort) and (realised==nil or x.realised==realised)
  end)
end
function Reader:same_point(a,b)
  local s=state(self); local x=s.points[a]; local y=s.points[b]
  if not x or not y then fail('same_point expects certified Point ids') end
  return x.component==y.component
end
function Reader:producer(strand)
  local xs=state(self).producers[strand] or {}
  if #xs>1 then fail('certified Strand has multiple producers') end
  return xs[1]
end
function Reader:consumers(strand) return copy_array(state(self).consumers[strand] or {}) end

function C.snapshot(v)
  local r=C.read(v); local s=state(r)
  return detached({schema=s.schema,root=s.root,worlds=s.worlds,points=s.points,strands=s.strands,faces=s.faces})
end

return C
