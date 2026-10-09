-- Immutable witness of one exact Worlds join materialisation.
--
-- Construction does not introduce a second composition semantics:
-- Construction.join(parts,equations) performs the ordinary Worlds join and
-- retains immutable access to its parts, normalised equations, result Geometry,
-- exact carrier image and optional construction-relative quotient correspondence.

local W=require('worlds')
local Kernel=require('worlds._kernel')
local Query=require('worlds._query')
local DENSE=require('worlds._array')
local K=Kernel.private
local Q,QP=Query.public,Query.private
local Construction={}
local STATE=setmetatable({}, {__mode='k'})
local CSTATE=setmetatable({}, {__mode='k'})
local function immutable() error('Worlds values are immutable',2) end
local MT={__newindex=immutable,__metatable='Worlds Construction'}
local CMT={__newindex=immutable,__metatable='Worlds Construction correspondence'}
local CLASS_MT={__newindex=immutable,__metatable='Worlds Construction class'}
MT.__index=MT
CMT.__index=CMT

local KINDS={'membranes','points','strands','faces'}
local function state(x) return type(x)=='table' and STATE[x] or nil end
local function cstate(x) return type(x)=='table' and CSTATE[x] or nil end

local function normal_equations(es)
  local out={}
  for i,e in ipairs(es) do
    assert(type(e)=='table','Construction equation entries must be exact equations')
    out[i]={from=e.from or e[1],to=e.to or e[2]}
  end
  return out
end

local function carriers(g)
  local out={}
  for _,k in ipairs(KINDS) do
    for _,x in ipairs(g[k](g)) do out[#out+1]=x end
  end
  return out
end

local function source_carriers(parts)
  local out={}
  for _,g in ipairs(parts) do
    for _,x in ipairs(carriers(g)) do out[#out+1]=x end
  end
  return out
end

local function value(st)
  local x=setmetatable({},MT)
  STATE[x]=st
  return x
end

local function correspondence_value(parts,target,source,target_class)
  local survivor={}
  for y,raw in pairs(target_class) do
    local old=survivor[raw]
    assert(old==nil or old==y,'correspondence class has multiple target carriers')
    survivor[raw]=y
  end
  local x=setmetatable({},CMT)
  CSTATE[x]={source_parts=parts,target=target,source=source,target_class=target_class,
      survivor=survivor,
      public_classes=setmetatable({}, {__mode='k'})}
  return x
end

local function public_class(st,raw)
  if raw==nil then return nil end
  local x=st.public_classes[raw]
  if not x then x=setmetatable({},CLASS_MT)
  st.public_classes[raw]=x end
  return x
end

local function materialise_correspondence(c)
  local st=assert(state(c),'Worlds Construction required')
  if st.correspondence then return st.correspondence end
  local prov=assert(st.provenance,'Construction lacks native quotient provenance')
  local parts,target=c:parts(),c:result()
  local source,target_class={},{}
  for _,x in ipairs(source_carriers(parts)) do
    local raw=assert(prov.source_class(x),'native quotient omitted a source carrier')
    source[x]=raw
    local y=c:image(x)
    if y then
      local old=target_class[y]
      assert(old==nil or old==raw,'native quotient disagrees with exact carrier image')
      target_class[y]=raw
    end
  end
  for _,y in ipairs(carriers(target)) do
    if target_class[y]==nil then target_class[y]={} end
  end
  st.correspondence=correspondence_value(parts,target,source,target_class)
  st.provenance=nil
  return st.correspondence
end

function Construction.join(parts,equations)
  equations=equations or {}
  local r=Q.realisation_for(parts,equations)
  if r then return Construction.from_realisation(r) end
  local result,image,provenance=K.construction_join(parts,equations)
  return value{parts=parts,equations=normal_equations(equations),result=result,image=image,
      provenance=provenance}
end

-- Non-exceptional exact composition judgement. Malformed API use still raises;
-- a well-formed but geometrically unrealizable equation set returns nil,reason.
-- This is the public counterpart of Query's soft realisation check and lets
-- clients distinguish semantic rejection from programming failure directly.
function Construction.try_join(parts,equations)
  equations=equations or {}
  DENSE.length(parts,'join parts')
  DENSE.length(equations,'join equations')
  local normal=normal_equations(equations)
  local r=Q.realisation_for(parts,equations)
  if r then return Construction.from_realisation(r) end
  local result,image_or_why,provenance=K.try_join(parts,normal,true)
  if not result then return nil,image_or_why end
  return value{parts=parts,equations=normal,result=result,image=image_or_why,provenance=provenance}
end

function Construction.from_realisation(realisation)
  assert(Q.is_realisation(realisation),'Construction.from_realisation requires Worlds Realisation')
  return value{realisation=realisation,provenance=QP.realisation_provenance(realisation)}
end

function Construction.is_construction(x)
  return state(x)~=nil
end

function Construction.is_correspondence(x)
  return cstate(x)~=nil
end

function MT:parts()
  local st=assert(state(self),'Worlds Construction required')
  return st.realisation and st.realisation:parts() or st.parts
end

function MT:equations()
  local st=assert(state(self),'Worlds Construction required')
  return st.realisation and st.realisation:equations() or st.equations
end

function MT:result()
  local st=assert(state(self),'Worlds Construction required')
  return st.realisation and st.realisation:result() or st.result
end

function MT:image(carrier)
  local st=assert(state(self),'Worlds Construction required')
  -- A lawful image may be nil when a source carrier is annihilated. Do not use
  -- the Lua `a and b or c` idiom here: nil is a result, not a missing fast path.
  if st.realisation then return st.realisation:image(carrier) end
  return st.image[carrier]
end

function MT:correspondence()
  return materialise_correspondence(self)
end

function CMT:source_parts()
  return assert(cstate(self),'Worlds Construction correspondence required').source_parts
end

function CMT:target()
  return assert(cstate(self),'Worlds Construction correspondence required').target
end

function CMT:source_class(x)
  local st=assert(cstate(self),'Worlds Construction correspondence required')
  return public_class(st,st.source[x])
end

function CMT:target_class(x)
  local st=assert(cstate(self),'Worlds Construction correspondence required')
  return public_class(st,st.target_class[x])
end

-- Return the unique surviving target carrier of a marked source carrier's
-- quotient class, or nil when that class is annihilated (or x is not in the
-- marked source).  This is correspondence evidence rather than exact
-- Construction image and therefore remains meaningful after correspondence
-- composition.
function CMT:survivor(x)
  local st=assert(cstate(self),'Worlds Construction correspondence required')
  local raw=st.source[x]
  return raw and st.survivor[raw] or nil
end

function CMT:source_equivalent(a,b)
  local st=assert(cstate(self),'Worlds Construction correspondence required')
  return st.source[a]~=nil and st.source[a]==st.source[b]
end

function CMT:corresponds(a,b)
  local st=assert(cstate(self),'Worlds Construction correspondence required')
  return st.source[a]~=nil and st.source[a]==st.target_class[b]
end

local function dsu()
  local parent,rank={},{}
  local D={}
  function D:add(x) if parent[x]==nil then parent[x]=x
  rank[x]=0 end end
  function D:find(x)
    self:add(x)
    if parent[x]~=x then parent[x]=self:find(parent[x]) end
    return parent[x]
  end
  function D:union(a,b)
    a,b=self:find(a),self:find(b)
    if a==b then return a end
    if rank[a]<rank[b] then a,b=b,a end
    parent[b]=a
    if rank[a]==rank[b] then rank[a]=rank[a]+1 end
    return a
  end
  return D
end

local function class_members(c)
  local st=assert(cstate(c),'Worlds Construction correspondence required')
  local out={}
  for x,r in pairs(st.source) do
    out[r]=out[r] or {source={},target={}}
    out[r].source[#out[r].source+1]=x
  end
  for x,r in pairs(st.target_class) do
    out[r]=out[r] or {source={},target={}}
    out[r].target[#out[r].target+1]=x
  end
  return out
end

function CMT:compose(next_corr)
  local A=assert(cstate(self),'Worlds Construction correspondence required')
  local B=assert(cstate(next_corr),'Worlds Construction correspondence required')
  local shared=nil
  local extras={}
  for _,g in ipairs(B.source_parts) do
    if g==A.target then
      assert(shared==nil,'intermediate Geometry appears twice in correspondence source')
      shared=g
    else extras[#extras+1]=g end
  end
  assert(shared,'next correspondence does not consume this target Geometry')
  local out_parts={}
  local old={}
  for _,g in ipairs(A.source_parts) do
    out_parts[#out_parts+1]=g
    for _,x in ipairs(carriers(g)) do old[x]=true end
  end
  for _,g in ipairs(extras) do
    for _,x in ipairs(carriers(g)) do
      assert(not old[x],'fresh correspondence part overlaps the marked source')
    end
    out_parts[#out_parts+1]=g
  end

  local D=dsu()
  local visible,mid,final={},{},{}
  for _,g in ipairs(out_parts) do
    for _,x in ipairs(carriers(g)) do visible[x]={}
    D:add(visible[x]) end
  end
  for _,x in ipairs(carriers(A.target)) do mid[x]={}
  D:add(mid[x]) end
  for _,x in ipairs(carriers(B.target)) do final[x]={}
  D:add(final[x]) end

  local function import(c,map_source,map_target)
    for _,cl in pairs(class_members(c)) do
      local first=nil
      for _,x in ipairs(cl.source) do
        local node=assert(map_source(x),'unmapped correspondence source')
        if first then D:union(first,node) else first=node end
      end
      for _,x in ipairs(cl.target) do
        local node=assert(map_target(x),'unmapped correspondence target')
        if first then D:union(first,node) else first=node end
      end
    end
  end
  import(self,function(x) return visible[x] end,function(x) return mid[x] end)
  local extra={}
  for _,g in ipairs(extras) do
    for _,x in ipairs(carriers(g)) do extra[x]=true end
  end
  import(next_corr,function(x) return mid[x] or (extra[x] and visible[x]) end,
      function(x) return final[x] end)

  local source,target_class={},{}
  for x,node in pairs(visible) do source[x]=D:find(node) end
  for x,node in pairs(final) do target_class[x]=D:find(node) end
  return correspondence_value(out_parts,B.target,source,target_class)
end

local function source_order(c)
  local out={}
  for _,g in ipairs(c:source_parts()) do
    for _,x in ipairs(carriers(g)) do out[#out+1]=x end
  end
  return out
end

local function signature(c,raw)
  local st=assert(cstate(c),'Worlds Construction correspondence required')
  local out={}
  for i,x in ipairs(source_order(c)) do
    if st.source[x]==raw then out[#out+1]=tostring(i) end
  end
  return table.concat(out,',')
end

function CMT:same_source_partition(other)
  local A=assert(cstate(self),'Worlds Construction correspondence required')
  local B=assert(cstate(other),'Worlds Construction correspondence required')
  local as,bs=source_order(self),source_order(other)
  if #as~=#bs then return false end
  for i=1,#as do if as[i]~=bs[i] then return false end end
  for i=1,#as do for j=1,#as do
    if (A.source[as[i]]==A.source[as[j]])~=(B.source[as[i]]==B.source[as[j]]) then
      return false
    end
  end end
  return true
end

function CMT:mate(other,x)
  local A=assert(cstate(self),'Worlds Construction correspondence required')
  local B=assert(cstate(other),'Worlds Construction correspondence required')
  local as,bs=source_order(self),source_order(other)
  assert(#as==#bs,'mate requires the same marked source')
  for i=1,#as do assert(as[i]==bs[i],'mate source marking differs') end
  local raw=assert(A.target_class[x],'mate source carrier is outside this target')
  local wanted=W.kind(x)..'|'..signature(self,raw)
  local found=nil
  for y,r in pairs(B.target_class) do
    if W.kind(y)..'|'..signature(other,r)==wanted then
      assert(found==nil,'mate is ambiguous for a source-relative quotient class')
      found=y
    end
  end
  return found
end

return Construction
