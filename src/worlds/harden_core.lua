-- Lua trust boundary for Worlds.
--
-- `model.lua` and the attachment/graft layer are deliberately plain semantic reference code.
-- This module makes that model safe to hand to arbitrary Lua: objects are
-- opaque proxies, incidence arrays are copied, mutations are transactional and
-- failed Point gluing/development rolls back.

local Raw=require('worlds.model')
local H={}
local I={}

local proxy_to_raw=setmetatable({}, {__mode='k'})
-- A live raw carrier object has one stable public identity. Raw keys are weak so
-- dead Models/objects are still collectible; proxy values remain strong while the
-- raw object is alive. Attachment matching relies on this identity stability.
local raw_to_proxy=setmetatable({}, {__mode='k'})
local model_proxy_to_raw=setmetatable({}, {__mode='k'})
local raw_model_to_proxy=setmetatable({}, {__mode='k'})
local known_models=setmetatable({}, {__mode='k'})
local tx_depth=setmetatable({}, {__mode='k'})

local ObjMT={}; ObjMT.__metatable=false
local ModelMT={}; ModelMT.__metatable=false

local function fail(msg,level) error(msg,(level or 1)+1) end
local function pack(...) return {n=select('#',...),...} end
local unpack_values=table.unpack or unpack
assert(type(unpack_values)=='function','Worlds requires table.unpack or unpack')
local function unpackn(t) return unpack_values(t,1,t.n or #t) end
local function raw_object(x)
  local r=proxy_to_raw[x]
  if r then return r end
  return nil
end
local function is_raw_object(x)
  return type(x)=='table' and type(x.dim)=='number' and type(x.owner)=='table' and Raw.is_model(x.owner)
end
local function wrap_object(raw)
  local p=raw_to_proxy[raw]; if p then return p end
  p=setmetatable({},ObjMT); raw_to_proxy[raw]=p; proxy_to_raw[p]=raw
  return p
end
local function wrap_model(raw)
  local p=raw_model_to_proxy[raw]; if p then return p end
  p=setmetatable({},ModelMT); raw_model_to_proxy[raw]=p; model_proxy_to_raw[p]=raw; known_models[raw]=true
  return p
end

local function wrap(v,seen)
  if Raw.is_model(v) then return wrap_model(v) end
  if is_raw_object(v) then return wrap_object(v) end
  if type(v)~='table' then return v end
  seen=seen or {}; if seen[v] then return seen[v] end
  local out={}; seen[v]=out
  for k,x in pairs(v) do out[wrap(k,seen)]=wrap(x,seen) end
  return out
end
local function unwrap(v,seen)
  local r=proxy_to_raw[v] or model_proxy_to_raw[v]
  if r then return r end
  if type(v)~='table' then return v end
  seen=seen or {}; if seen[v] then return seen[v] end
  local out={}; seen[v]=out
  for k,x in pairs(v) do out[unwrap(k,seen)]=unwrap(x,seen) end
  return out
end

local function snapshot(raw,include_equivalence)
  local snap={objects=#raw.objects,worlds=#raw.worlds,instances=#raw.instances,next_serial=raw.next_serial}
  if include_equivalence then
    snap.uf={}
    -- Point equivalence can span carriers, so operations which may change it
    -- snapshot every Point currently known to this public Lua boundary. Ordinary
    -- carrier construction cannot change equivalence and deliberately avoids
    -- this global work.
    for m in pairs(known_models) do
      for _,o in ipairs(m.objects) do if o.dim==0 then snap.uf[o]={parent=o.uf_parent,rank=o.uf_rank} end end
    end
  end
  return snap
end
local function restore(raw,snap)
  while #raw.objects>snap.objects do raw.objects[#raw.objects]=nil end
  while #raw.worlds>snap.worlds do raw.worlds[#raw.worlds]=nil end
  while #raw.instances>snap.instances do raw.instances[#raw.instances]=nil end
  raw.next_serial=snap.next_serial
  for p,u in pairs(snap.uf or {}) do p.uf_parent=u.parent; p.uf_rank=u.rank end
  if raw._invalidate_indexes then raw:_invalidate_indexes() end
end
local function atomic_raw(raw,fn,include_equivalence)
  local depth=tx_depth[raw] or 0
  if depth>0 then return fn() end
  local snap=snapshot(raw,include_equivalence); tx_depth[raw]=depth+1
  local out=pack(pcall(fn)); tx_depth[raw]=depth
  if out[1] then return unpack_values(out,2,out.n) end
  restore(raw,snap)
  error(out[2],2)
end

local ARRAY_FIELDS={points=true,inputs=true,outputs=true}
function ObjMT.__index(self,key)
  local raw=proxy_to_raw[self]; if not raw then return nil end
  if key=='uf_parent' or key=='uf_rank' or key=='owner' or key=='structural' then return nil end
  local v=raw[key]
  if ARRAY_FIELDS[key] then return wrap(v) end
  return wrap(v)
end
ObjMT.__newindex=function() fail('World kernel objects are opaque',2) end
ObjMT.__tostring=function(self)
  local raw=proxy_to_raw[self]
  if not raw then return '<invalid World object>' end
  if raw.dim==-1 then return string.format('%s[World]',raw.name) end
  return string.format('%s[%d,%s]',raw.name,raw.dim,raw.sort)
end

local mutating={world=true,point=true,glue_points='equivalence',strand=true,face=true,copy=true,discard=true,admit=true,_graft_attachment='equivalence'}

-- v0.2 public Model carrier surface. Attachment/grafting lives in Worlds.Attachment.
-- method here is an API decision, not an accidental consequence of Raw gaining
-- another helper.
local PUBLIC_METHODS={
  world=true,
  point=true,
  strand=true,
  face=true,
  glue_points=true,
  admit=true,
  copy=true,
  discard=true,
  same_point=true,
  is_realised=true,
  is_suspended=true,
  find_actual_point=true,
}

local function call_raw(name,self,allow_internal,...)
  local raw=model_proxy_to_raw[self]
  if not raw then fail('expected World Model',2) end
  if not allow_internal and not PUBLIC_METHODS[name] then
    fail('unsupported World Model operation '..tostring(name),2)
  end
  local method=Raw[name]
  if type(method)~='function' then fail('unknown World Model operation '..tostring(name),2) end
  local args=unwrap({...})
  local function run() return method(raw,unpack_values(args)) end
  local values
  local mutation=mutating[name]
  if mutation then values=pack(atomic_raw(raw,run,mutation=='equivalence')) else values=pack(run()) end
  for i=1,values.n do values[i]=wrap(values[i]) end
  return unpackn(values)
end

for _,name in ipairs({
  'world','point','strand','face','glue_points','admit','copy','discard',
  'same_point','is_realised','is_suspended','find_actual_point',
}) do
  H[name]=function(self,...) return call_raw(name,self,false,...) end
end

function H.new(root_name)
  return wrap_model(Raw.new(root_name))
end
function H.is_model(x) return model_proxy_to_raw[x]~=nil end

-- Transaction boundary used by Separate.import_unit and callers which need a
-- larger all-or-nothing construction than one public mutation.
function H.atomic(self,fn)
  local raw=model_proxy_to_raw[self]
  if not raw then fail('expected World Model',2) end
  if type(fn)~='function' then fail('atomic expects function',2) end
  return atomic_raw(raw,fn,true)
end

function ModelMT.__index(self,key)
  local method=rawget(H,key); if method~=nil then return method end
  local raw=model_proxy_to_raw[self]; if not raw then return nil end
  if key=='objects' or key=='worlds' or key=='instances' then return wrap(raw[key]) end
  if key=='actuality' then return wrap(raw.actuality) end
  if key=='next_serial' then return raw.next_serial end
  return nil
end
ModelMT.__newindex=function() fail('World Model state is opaque',2) end

-- Package-internal adapter. It deliberately does not appear on a public Model
-- handle. Worlds modules which need reference-implementation helpers obtain an
-- internal view through `internal.lua`.
local internal_to_public=setmetatable({}, {__mode='k'})
local public_to_internal=setmetatable({}, {__mode='kv'})
local InternalModelMT={}; InternalModelMT.__metatable=false

function I.model(m)
  if internal_to_public[m] then return m end
  local raw=model_proxy_to_raw[m]
  if not raw then fail('internal model view expects World Model',2) end
  local v=public_to_internal[m]
  if v then return v end
  v=setmetatable({},InternalModelMT)
  internal_to_public[v]=m; public_to_internal[m]=v
  return v
end

function InternalModelMT.__index(self,key)
  local public=internal_to_public[self]
  if not public then return nil end
  if key=='atomic' then return function(_,fn) return H.atomic(public,fn) end end
  if key=='deps' then
    return function(_,c)
      local raw=raw_object(c); if not raw then fail('deps expects World object',2) end
      return wrap(Raw.deps(raw))
    end
  end
  local method=Raw[key]
  if type(method)=='function' and key~='new' and key~='is_model' then
    return function(_,...) return call_raw(key,public,true,...) end
  end
  return public[key]
end
InternalModelMT.__newindex=function() fail('internal World Model view is read-only',2) end

function I.is_model(x) return model_proxy_to_raw[x]~=nil end

-- rawset bypasses __newindex. Certification therefore rejects a proxy which has
-- acquired shadow state even though the underlying semantic model is untouched.
function I.pristine(x)
  local raw=model_proxy_to_raw[x]
  if not raw then return false,'expected World Model' end
  if next(x)~=nil then return false,'Model handle contains raw shadow state' end
  for _,o in ipairs(raw.objects) do
    local p=raw_to_proxy[o]
    if p and next(p)~=nil then return false,string.format('%s handle contains raw shadow state',o.id or 'World object') end
  end
  return true
end

-- Pin mutable Lua module tables at a trust boundary. The returned closure is
-- deliberately Lua hardening, not Worlds semantics.
function I.guard(named)
  local baseline={}
  for name,t in pairs(named or {}) do
    local snap={}; for k,v in pairs(t) do snap[k]=v end
    baseline[name]={module=t,entries=snap}
  end
  return function()
    for name,b in pairs(baseline) do
      for k,v in pairs(b.entries) do if rawget(b.module,k)~=v then return false,name..' module entry changed: '..tostring(k) end end
      for k in pairs(b.module) do if b.entries[k]==nil then return false,name..' module entry added: '..tostring(k) end end
    end
    return true
  end
end

return {public=H,internal=I}
