-- Worlds semantic carrier.
--
-- This file is intentionally direct. It describes the geometry, not the Lua
-- trust boundary. `harden.lua` wraps this model for public use.
--
--   World   locality / actuality by containment
--   Point   semantic identity
--   Strand  one occurrence of authority
--   Face    causal transformation

local M={}; M.__index=M

local function assertf(ok,fmt,...)
  if not ok then error(string.format(fmt,...),3) end
end
local function copy(xs)
  local out={}; for i=1,#(xs or {}) do out[i]=xs[i] end; return out
end

function M.new(root_name)
  local self=setmetatable({objects={},worlds={},instances={},next_serial=1,_index_epoch=0,_parent_cache={},_child_cache={}},M)
  local root={owner=self,serial=1,name=root_name or 'Actuality',dim=-1,sort='world',parent=nil,is_actuality=true}
  root.id=root.name..'#1'
  self.next_serial=2
  self.actuality=root
  self.objects[1]=root; self.worlds[1]=root
  return self
end

function M:_serial()
  local n=self.next_serial; self.next_serial=n+1; return n
end
function M:_invalidate_indexes() self._index_epoch=(self._index_epoch or 0)+1 end
function M:_register(o)
  assertf(o.owner==self,'cannot register foreign World object')
  self:_invalidate_indexes()
  self.objects[#self.objects+1]=o
  if o.dim==-1 then self.worlds[#self.worlds+1]=o end
  return o
end
function M:_owned(o,dim)
  return type(o)=='table' and o.owner==self and (dim==nil or o.dim==dim)
end

-- parent=nil creates a detached World root (an archetype component).
function M:world(name,parent)
  if parent~=nil then assertf(self:_owned(parent,-1),'world parent must be a World of this Model') end
  local serial=self:_serial()
  return self:_register({owner=self,serial=serial,id=tostring(name)..'#'..serial,name=name,dim=-1,sort='world',parent=parent})
end

function M:_root(w)
  while w do if not w.parent then return w end; w=w.parent end
  return nil
end
function M:is_realised(x)
  if type(x)~='table' or x.dim==nil then return false end
  local w=x.dim==-1 and x or x.world
  local r=self:_root(w); if not r then return false end
  -- Identity may be shared across carrier custody; authority remains relative
  -- to this carrier's actuality root.
  if x.dim==0 then return r.is_actuality==true end
  return r==self.actuality
end
function M:is_suspended(x) return not self:is_realised(x) end
function M:_susp_root(w)
  local r=self:_root(w); if r==self.actuality then return nil end; return r
end
function M:_descends(w,a)
  while w do if w==a then return true end; w=w.parent end
  return false
end
function M:_children(w)
  local c=self._child_cache[w]
  if c and c.epoch==self._index_epoch then return copy(c.items) end
  local out={}
  for _,x in ipairs(self.worlds) do if x.parent==w then out[#out+1]=x end end
  table.sort(out,function(a,b)return a.serial<b.serial end)
  self._child_cache[w]={epoch=self._index_epoch,items=out}
  return copy(out)
end

function M:_cell(spec)
  assertf(self:_owned(spec.world,-1),'cell requires World of this Model')
  assertf(spec.dim>=0 and spec.dim<=2,'bad dimension')
  local serial=self:_serial()
  return self:_register({
    owner=self,serial=serial,id=tostring(spec.name)..'#'..serial,
    name=spec.name,dim=spec.dim,sort=spec.sort,world=spec.world,
    points=copy(spec.points),inputs=copy(spec.inputs),outputs=copy(spec.outputs),
    structural=spec.structural,
  })
end

function M:point(name,w,sort)
  local p=self:_cell({name=name,dim=0,sort=sort or 'point',world=w})
  p.uf_parent=p; p.uf_rank=0
  return p
end
local function point_find(p)
  local r=p
  while r.uf_parent and r.uf_parent~=r do r=r.uf_parent end
  return r
end
function M:same_point(a,b)
  return type(a)=='table' and type(b)=='table' and a.dim==0 and b.dim==0 and point_find(a)==point_find(b) or false
end
function M:glue_points(a,b)
  assertf(type(a)=='table' and type(b)=='table' and a.dim==0 and b.dim==0,'point gluing requires Points')
  assertf(a.sort==b.sort,'point gluing sort mismatch %s vs %s',a.sort,b.sort)
  assertf(self:is_realised(a) and self:is_realised(b),'point gluing currently requires realised Points')
  local ra,rb=point_find(a),point_find(b); if ra==rb then return ra end
  if (ra.uf_rank or 0)<(rb.uf_rank or 0) then ra,rb=rb,ra end
  rb.uf_parent=ra
  if (ra.uf_rank or 0)==(rb.uf_rank or 0) then ra.uf_rank=(ra.uf_rank or 0)+1 end
  return ra
end

local function deps(c)
  if c.dim==0 then return {} end
  if c.dim==1 then return copy(c.points) end
  local out={}
  for _,x in ipairs(c.inputs) do out[#out+1]=x end
  for _,x in ipairs(c.outputs) do out[#out+1]=x end
  return out
end
M.deps=deps

function M:_check_actual_boundary(world,dependencies,what)
  if self:is_realised(world) then
    for _,d in ipairs(dependencies or {}) do
      assertf(self:is_realised(d),'actuality-boundary violation at %s: actual geometry depends on suspended %s',what,tostring(d))
    end
  end
end

function M:strand(name,w,points,sort)
  assertf(self:_owned(w,-1),'strand requires World of this Model')
  for i,p in ipairs(points or {}) do assertf(type(p)=='table' and p.dim==0,'strand %s point %d not Point',name,i) end
  self:_check_actual_boundary(w,points,'strand '..tostring(name))
  return self:_cell({name=name,dim=1,sort=sort or 'strand',world=w,points=points})
end

function M:_face(name,w,inputs,outputs,sort,structural)
  assertf(self:_owned(w,-1),'face requires World of this Model')
  for _,x in ipairs(inputs or {}) do assertf(self:_owned(x,1),'face input must be Strand of this Model') end
  for _,x in ipairs(outputs or {}) do assertf(self:_owned(x,1),'face output must be Strand of this Model') end
  local all={}
  for _,x in ipairs(inputs or {}) do all[#all+1]=x end
  for _,x in ipairs(outputs or {}) do all[#all+1]=x end
  self:_check_actual_boundary(w,all,'face '..tostring(name))
  if self:is_suspended(w) then
    for _,x in ipairs(all) do
      assertf(self:is_suspended(x),'suspended Face %s cannot depend directly on realised Strand %s',name,tostring(x))
    end
  end
  return self:_cell({name=name,dim=2,sort=sort or 'face',world=w,inputs=inputs,outputs=outputs,structural=structural})
end
function M:face(name,w,inputs,outputs,sort)
  assertf(#(inputs or {})>0 or #(outputs or {})==0,'ordinary Face cannot mint authority; use admit')
  return self:_face(name,w,inputs,outputs,sort,nil)
end

-- Structural permission is geometry created by these constructors, not a Face label.
function M:copy(name,w,input,outputs,sort)
  assertf(self:_owned(input,1),'copy requires input Strand of this Model')
  assertf(#(outputs or {})>=2,'copy requires at least two output Strands')
  for _,o in ipairs(outputs) do
    assertf(self:_owned(o,1),'copy output must be Strand of this Model')
    assertf(o.sort==input.sort and #o.points==#input.points,'copy output boundary shape mismatch')
    for i,p in ipairs(input.points) do assertf(self:same_point(p,o.points[i]),'copy output identity boundary mismatch') end
  end
  return self:_face(name,w,{input},outputs,sort or input.sort,'copy')
end
function M:discard(name,w,input,sort)
  assertf(self:_owned(input,1),'discard requires input Strand of this Model')
  return self:_face(name,w,{input},{},sort or input.sort,'discard')
end
function M:admit(name,w,points,sort)
  assertf(self:_owned(w,-1) and self:is_realised(w),'admission requires an actual World')
  local s=self:strand(name,w,points,sort)
  local f=self:_face(tostring(name)..'.admit',w,{}, {s},sort or 'strand','admission')
  return s,f
end
function M:structural_kind(f)
  if not self:_owned(f,2) then return nil end
  return f.structural
end
function M:is_admission(f) return self:structural_kind(f)=='admission' end

function M:_parents(c)
  local cached=self._parent_cache[c]
  if cached and cached.epoch==self._index_epoch then return copy(cached.items) end
  local out={}
  for _,p in ipairs(self.objects) do
    if p.dim==1 or p.dim==2 then
      for _,d in ipairs(deps(p)) do if d==c then out[#out+1]=p; break end end
    end
  end
  self._parent_cache[c]={epoch=self._index_epoch,items=out}
  return copy(out)
end

function M:_uses(s)
  local n=0
  for _,f in ipairs(self.objects) do
    if f.dim==2 and self:is_realised(f) then
      for _,x in ipairs(f.inputs) do if x==s then n=n+1 end end
    end
  end
  return n
end
M._realised_uses=M._uses

function M:check_scarcity()
  for _,s in ipairs(self.objects) do
    if s.dim==1 and self:is_realised(s) then
      local n=self:_realised_uses(s)
      if n>1 then return false,string.format('scarcity: realised strand %s has %d uses',s.id,n) end
    end
  end
  return true
end
function M:check_actual_subcomplex()
  for _,c in ipairs(self.objects) do
    if c.dim>=1 and self:is_realised(c) then
      for _,d in ipairs(deps(c)) do if not self:is_realised(d) then return false,'actual geometry depends on suspended geometry' end end
    end
  end
  return true
end
function M:world_path(w)
  local out={}; while w do table.insert(out,1,w); w=w.parent end; return out
end
function M.is_model(x) return getmetatable(x)==M end
function M:find_actual_point(name,sort)
  local found={}
  for _,c in ipairs(self.objects) do if c.dim==0 and self:is_realised(c) and c.name==name and c.sort==sort then found[#found+1]=c end end
  if #found==1 then return found[1] end
  return nil,#found
end

-- Fresh grafting is kept beside, rather than inside, the carrier.
-- Attachment/search itself is a derived public construction in worlds.att.
require('worlds.graft').install(M)

return M
