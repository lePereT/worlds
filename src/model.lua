-- worlds/model.lua
--
-- Opaque executable reference kernel.
--
-- Primitive ontology:
--   World   -- locality / actuality by containment
--   Point   -- semantic identity
--   Strand  -- an individual occurrence of authority
--   Face    -- causal transformation
--
-- Objects and Model state are held in private weak maps.  Returned handles are
-- read-only observations: callers can inspect primitive incidence but cannot
-- rewrite kernel topology by assigning Lua fields or mutating incidence arrays.
--
-- Source authority is explicit.  admit(...) creates an actual Strand together
-- with its zero-input provenance Face.  Ordinary face(...) cannot mint authority.

local M={}
local Obj={}
local model_state=setmetatable({}, {__mode='k'})
local object_state=setmetatable({}, {__mode='k'})
local INTERNAL={}

local function assertf(ok,fmt,...)
  if not ok then error(string.format(fmt,...),3) end
end
local function copy_array(xs)
  local o={}; for i=1,#(xs or {}) do o[i]=xs[i] end; return o
end
local function copy_map(t)
  local o={}; for k,v in pairs(t or {}) do o[k]=v end; return o
end
local function ms(m)
  local s=model_state[m]; if not s then error('expected World Model',3) end; return s
end
local function os(o)
  local s=object_state[o]; if not s then error('expected opaque World object',3) end; return s
end
local function maybe_os(o) return type(o)=='table' and object_state[o] or nil end

local ARRAY_FIELDS={points=true,inputs=true,outputs=true}
Obj.__index=function(self,key)
  local method=rawget(Obj,key); if method~=nil then return method end
  local s=object_state[self]; if not s then return nil end
  if ARRAY_FIELDS[key] then return copy_array(s[key]) end
  if key=='uf_parent' or key=='uf_rank' or key=='owner' or key=='structural' then return nil end
  return s[key]
end
Obj.__newindex=function() error('World kernel objects are opaque',2) end
Obj.__metatable=false
function Obj:__tostring()
  local s=os(self)
  if s.dim==-1 then return string.format('%s[World]',s.name) end
  return string.format('%s[%d,%s]',s.name,s.dim,s.sort)
end

M.__index=function(self,key)
  local method=rawget(M,key); if method~=nil then return method end
  local s=model_state[self]; if not s then return nil end
  if key=='objects' or key=='worlds' or key=='instances' then return copy_array(s[key]) end
  if key=='actuality' or key=='next_serial' then return s[key] end
  return nil
end
M.__newindex=function() error('World Model state is opaque',2) end
M.__metatable=false

local function new_handle(state)
  local o=setmetatable({},Obj); object_state[o]=state; return o
end

function M.new(root_name)
  local self=setmetatable({},M)
  local s={objects={},worlds={},instances={},next_serial=1}
  model_state[self]=s
  local root=new_handle({
    owner=self,serial=s.next_serial,name=root_name or 'Actuality',dim=-1,sort='world',parent=nil,
    is_actuality=true,
  })
  s.next_serial=s.next_serial+1
  local rs=os(root); rs.id=rs.name..'#'..rs.serial
  s.objects[#s.objects+1]=root; s.worlds[#s.worlds+1]=root; s.actuality=root
  return self
end

function M:_serial(token)
  assertf(token==INTERNAL,'internal Model mutation is not a public capability')
  local s=ms(self); local n=s.next_serial; s.next_serial=n+1; return n
end
function M:_register(o,token)
  assertf(token==INTERNAL,'internal Model mutation is not a public capability')
  local s=ms(self); local x=os(o)
  assertf(x.owner==self,'cannot register foreign World object')
  s.objects[#s.objects+1]=o
  if x.dim==-1 then s.worlds[#s.worlds+1]=o end
  return o
end
function M:_owned(o,dim)
  local s=maybe_os(o)
  return s and s.owner==self and (dim==nil or s.dim==dim)
end

-- Transactional construction boundary.  Reference implementation snapshots
-- Point equivalence as well as collection lengths so failed operations cannot
-- leave partial identity commitments.
function M:atomic(fn)
  assertf(type(fn)=='function','atomic expects function')
  local s=ms(self)
  local snap={objects=#s.objects,worlds=#s.worlds,instances=#s.instances,next_serial=s.next_serial,uf={}}
  for o,st in pairs(object_state) do
    if st.dim==0 then snap.uf[o]={parent=st.uf_parent,rank=st.uf_rank} end
  end
  local ok,a,b,c,d=pcall(fn)
  if ok then return a,b,c,d end
  while #s.objects>snap.objects do s.objects[#s.objects]=nil end
  while #s.worlds>snap.worlds do s.worlds[#s.worlds]=nil end
  while #s.instances>snap.instances do s.instances[#s.instances]=nil end
  s.next_serial=snap.next_serial
  for o,u in pairs(snap.uf) do local st=object_state[o]; if st then st.uf_parent=u.parent; st.uf_rank=u.rank end end
  error(a,2)
end

-- parent=nil creates a detached World root (an archetype component).
function M:world(name,parent)
  if parent~=nil then assertf(self:_owned(parent,-1),'world parent must be a World of this Model') end
  local serial=self:_serial(INTERNAL)
  local o=new_handle({owner=self,serial=serial,name=name,dim=-1,sort='world',parent=parent})
  os(o).id=tostring(name)..'#'..serial
  return self:_register(o,INTERNAL)
end

function M:_root(w)
  while w do local s=os(w); if not s.parent then return w end; w=s.parent end
  return nil
end
function M:is_realised(x)
  local sx=maybe_os(x); if not sx then return false end
  local w=(sx.dim==-1) and x or sx.world
  local r=self:_root(w); if not r then return false end
  local rs=os(r)
  -- Realised identity Points may be shared literally across carrier custody.
  if sx.dim==0 then return rs.is_actuality==true end
  return r==ms(self).actuality
end
function M:is_suspended(x) return not self:is_realised(x) end
function M:_susp_root(w)
  local r=self:_root(w); if r==ms(self).actuality then return nil end; return r
end
function M:_descends(w,a)
  while w do if w==a then return true end; w=os(w).parent end
  return false
end
function M:_children(w)
  local out={}
  for _,x in ipairs(ms(self).worlds) do if os(x).parent==w then out[#out+1]=x end end
  table.sort(out,function(a,b)return os(a).serial<os(b).serial end)
  return out
end

function M:_cell(spec,token)
  assertf(token==INTERNAL,'internal Model mutation is not a public capability')
  assertf(self:_owned(spec.world,-1),'cell requires World of this Model')
  assertf(spec.dim>=0 and spec.dim<=2,'bad dimension')
  local serial=self:_serial(INTERNAL)
  local o=new_handle({
    owner=self,serial=serial,name=spec.name,dim=spec.dim,sort=spec.sort,world=spec.world,
    points=copy_array(spec.points),inputs=copy_array(spec.inputs),outputs=copy_array(spec.outputs),
    structural=spec.structural,
  })
  os(o).id=tostring(spec.name)..'#'..serial
  return self:_register(o,INTERNAL)
end

function M:point(name,w,sort)
  local p=self:_cell({name=name,dim=0,sort=sort or 'point',world=w},INTERNAL)
  local s=os(p); s.uf_parent=p; s.uf_rank=0
  return p
end

local function point_find(p)
  local ps=os(p); local r=p
  while true do local rs=os(r); if not rs.uf_parent or rs.uf_parent==r then break end; r=rs.uf_parent end
  -- No path compression: Point equality itself remains observation-only.  Union
  -- is the sole identity mutation, which keeps transaction rollback simple.
  return r
end
function M:same_point(a,b)
  local sa,sb=maybe_os(a),maybe_os(b)
  return sa and sb and sa.dim==0 and sb.dim==0 and point_find(a)==point_find(b) or false
end
function M:glue_points(a,b)
  local sa,sb=maybe_os(a),maybe_os(b)
  assertf(sa and sb and sa.dim==0 and sb.dim==0,'point gluing requires Points')
  assertf(sa.sort==sb.sort,'point gluing sort mismatch %s vs %s',sa.sort,sb.sort)
  assertf(self:is_realised(a) and self:is_realised(b),'point gluing currently requires realised Points')
  local ra,rb=point_find(a),point_find(b); if ra==rb then return ra end
  local rsa,rsb=os(ra),os(rb)
  if (rsa.uf_rank or 0)<(rsb.uf_rank or 0) then ra,rb=rb,ra; rsa,rsb=rsb,rsa end
  rsb.uf_parent=ra
  if (rsa.uf_rank or 0)==(rsb.uf_rank or 0) then rsa.uf_rank=(rsa.uf_rank or 0)+1 end
  return ra
end

local function deps(c)
  local s=os(c)
  if s.dim==0 then return {} end
  if s.dim==1 then return copy_array(s.points) end
  local x={}; for _,v in ipairs(s.inputs) do x[#x+1]=v end; for _,v in ipairs(s.outputs) do x[#x+1]=v end; return x
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
  for i,p in ipairs(points or {}) do
    local sp=maybe_os(p); assertf(sp and sp.dim==0,'strand %s point %d not Point',name,i)
  end
  self:_check_actual_boundary(w,points,'strand '..tostring(name))
  return self:_cell({name=name,dim=1,sort=sort or 'strand',world=w,points=points},INTERNAL)
end

function M:_face(name,w,inputs,outputs,sort,structural,token)
  assertf(token==INTERNAL,'internal Model mutation is not a public capability')
  assertf(self:_owned(w,-1),'face requires World of this Model')
  for _,x in ipairs(inputs or {}) do assertf(self:_owned(x,1),'face input must be Strand of this Model') end
  for _,x in ipairs(outputs or {}) do assertf(self:_owned(x,1),'face output must be Strand of this Model') end
  local all={}; for _,x in ipairs(inputs or {}) do all[#all+1]=x end; for _,x in ipairs(outputs or {}) do all[#all+1]=x end
  self:_check_actual_boundary(w,all,'face '..tostring(name))
  if self:is_suspended(w) then
    for _,x in ipairs(all) do assertf(self:is_suspended(x),'suspended Face %s cannot depend directly on realised Strand %s',name,tostring(x)) end
  end
  return self:_cell({name=name,dim=2,sort=sort or 'face',world=w,inputs=inputs,outputs=outputs,structural=structural},INTERNAL)
end
function M:face(name,w,inputs,outputs,sort)
  assertf(#(inputs or {})>0 or #(outputs or {})==0,'ordinary Face cannot mint authority; use admit')
  return self:_face(name,w,inputs,outputs,sort,nil,INTERNAL)
end

-- Explicit structural copying.  Face.sort remains uninterpreted; certification
-- trusts this construction fact, not any particular label string.
function M:copy(name,w,input,outputs,sort)
  assertf(self:_owned(input,1),'copy requires input Strand of this Model')
  assertf(#(outputs or {})>=2,'copy requires at least two output Strands')
  local si=os(input)
  for _,o in ipairs(outputs) do
    assertf(self:_owned(o,1),'copy output must be Strand of this Model')
    local so=os(o); assertf(so.sort==si.sort and #so.points==#si.points,'copy output boundary shape mismatch')
    for i,p in ipairs(si.points) do assertf(self:same_point(p,so.points[i]),'copy output identity boundary mismatch') end
  end
  return self:_face(name,w,{input},outputs,sort or si.sort,'copy',INTERNAL)
end

-- Explicit structural discard.
function M:discard(name,w,input,sort)
  assertf(self:_owned(input,1),'discard requires input Strand of this Model')
  return self:_face(name,w,{input},{},sort or os(input).sort,'discard',INTERNAL)
end

-- Explicit source authority.  Admission is kernel structure, not a semantic
-- label: certification recognises the private admission provenance bit, not the
-- Face name or sort supplied by the caller.
function M:admit(name,w,points,sort)
  assertf(self:_owned(w,-1) and self:is_realised(w),'admission requires an actual World')
  return self:atomic(function()
    local s=self:strand(name,w,points,sort)
    local f=self:_face(tostring(name)..'.admit',w,{}, {s},sort or 'strand','admission',INTERNAL)
    return s,f
  end)
end
function M:structural_kind(f)
  local s=maybe_os(f); if not (s and s.owner==self and s.dim==2) then return nil end; return s.structural
end
function M:is_admission(f) return self:structural_kind(f)=='admission' end

function M:_parents(c)
  local out={}
  for _,p in ipairs(ms(self).objects) do
    local sp=os(p)
    if sp.dim==1 or sp.dim==2 then
      for _,d in ipairs(deps(p)) do if d==c then out[#out+1]=p; break end end
    end
  end
  return out
end

local function shape(a,b)
  local sa,sb=maybe_os(a),maybe_os(b)
  if not sa or not sb or sa.dim~=sb.dim or sa.sort~=sb.sort then return false end
  if sa.dim==1 then return #sa.points==#sb.points end
  if sa.dim==2 then return #sa.inputs==#sb.inputs and #sa.outputs==#sb.outputs end
  return true
end

function M:_match(expected,offered,demand_roots,bindings,seen)
  bindings=bindings or {}; seen=seen or {}
  if not shape(expected,offered) then return false,'shape mismatch' end
  if not self:is_realised(offered) then return false,'offer is not realised' end
  local se,so=os(expected),os(offered)
  local prior=bindings[expected]
  if prior then
    local sp=os(prior)
    if se.dim==0 and sp.dim==0 and so.dim==0 then
      if not self:same_point(prior,offered) then return false,'inconsistent Point binding' end
      offered=prior; so=sp
    elseif prior~=offered then return false,'inconsistent binding' end
  else bindings[expected]=offered end
  local key=se.serial..':'..so.serial; if seen[key] then return true end; seen[key]=true
  local ee,oo=deps(expected),deps(offered); if #ee~=#oo then return false,'incidence arity mismatch' end
  for i=1,#ee do
    local e,o=ee[i],oo[i]; local es,oo_s=os(e),os(o)
    if self:is_realised(e) then
      if es.dim==0 and oo_s.dim==0 then
        if not self:same_point(e,o) then return false,'incidence anchor mismatch' end
      elseif e~=o then return false,'incidence anchor mismatch' end
    else
      local r=self:_susp_root(es.world)
      if not (r and demand_roots[r]) then return false,'suspended incidence is not on demanded frontier' end
      local ok,why=self:_match(e,o,demand_roots,bindings,seen); if not ok then return false,why end
    end
  end
  return true
end

function M:_stage_component(seed)
  local seen,root_seen,q={}, {}, {}
  local function add_root(r)
    if not r or r==ms(self).actuality or root_seen[r] then return end
    root_seen[r]=true
    for _,c in ipairs(ms(self).objects) do
      local sc=os(c)
      if sc.dim>=0 and self:is_suspended(c) and self:_susp_root(sc.world)==r and not seen[c] then seen[c]=true; q[#q+1]=c end
    end
  end
  local function add(c)
    local sc=maybe_os(c); if sc and sc.dim>=0 and self:is_suspended(c) then add_root(self:_susp_root(sc.world)) end
  end
  add(seed)
  local i=1
  while i<=#q do
    local c=q[i]; i=i+1
    for _,d in ipairs(deps(c)) do add(d) end
    for _,p in ipairs(self:_parents(c)) do add(p) end
  end
  return seen
end

function M:_is_open_input(c,component)
  local sc=maybe_os(c)
  if not (sc and sc.dim==1 and self:is_suspended(c) and component[c]) then return false end
  local cr=self:_susp_root(sc.world); local crosses=false; local producer=false
  for _,p in ipairs(self:_parents(c)) do
    local sp=os(p)
    if sp.dim==2 and self:is_suspended(p) and component[p] then
      local pr=self:_susp_root(sp.world)
      if pr~=cr then for _,x in ipairs(sp.inputs) do if x==c then crosses=true; break end end end
      for _,x in ipairs(sp.outputs) do if x==c then producer=true; break end end
    end
  end
  return crosses and not producer
end

function M:_orient_stage(component)
  local demand_roots={}
  for c,_ in pairs(component) do if self:_is_open_input(c,component) then local r=self:_susp_root(os(c).world); if r then demand_roots[r]=true end end end
  local gen_roots={}
  for c,_ in pairs(component) do local r=self:_susp_root(os(c).world); if r and not demand_roots[r] then gen_roots[r]=true end end
  return demand_roots,gen_roots
end

-- A suspended Strand in a demand root may also be the *outgoing* boundary of
-- generated geometry.  It is not authority available to development: it has a
-- producer in a generated root and no consumer inside the suspended stage.
-- During development such an egress is materialised back in the trigger World,
-- with the cloned producer Face as its unique provenance.  This is the dual of
-- an open incoming frontier and gives development a causal result path without
-- introducing a call/return primitive into the kernel.
function M:_is_open_output(c,component,demand_roots,gen_roots)
  local sc=maybe_os(c)
  if not (sc and sc.dim==1 and self:is_suspended(c) and component[c]) then return false end
  local cr=self:_susp_root(sc.world)
  if not (cr and demand_roots[cr]) then return false end
  local produced=false
  for _,p in ipairs(self:_parents(c)) do
    local sp=os(p)
    if sp.dim==2 and self:is_suspended(p) and component[p] then
      local pr=self:_susp_root(sp.world)
      for _,x in ipairs(sp.outputs) do
        if x==c and pr and gen_roots[pr] then produced=true end
      end
      for _,x in ipairs(sp.inputs) do
        if x==c then return false end
      end
    end
  end
  return produced
end

function M:_entry_gate(trigger)
  local candidates={}; local st=os(trigger)
  local function shared_schema_anchor(gate)
    local sg=os(gate); if #sg.points~=#st.points then return false end
    for i,p in ipairs(sg.points) do if self:is_realised(p) and self:same_point(p,st.points[i]) then return true end end
    return false
  end
  for _,c in ipairs(ms(self).objects) do
    local sc=os(c)
    if sc.dim==1 and self:is_suspended(c) and sc.sort==st.sort and shared_schema_anchor(c) then
      local component=self:_stage_component(c)
      if self:_is_open_input(c,component) then
        local dr,gr=self:_orient_stage(component); local r=self:_susp_root(sc.world)
        if dr[r] then local b={}; local ok=self:_match(c,trigger,dr,b,{}); if ok then candidates[#candidates+1]={cell=c,component=component,demand_roots=dr,gen_roots=gr,bindings=b} end end
      end
    end
  end
  if #candidates==0 then return nil end
  assertf(#candidates==1,'trigger %s matches %d suspended entry gates; development ambiguous',st.id,#candidates)
  return candidates[1]
end

function M:_uses(s)
  local n=0
  for _,f in ipairs(ms(self).objects) do
    local sf=os(f)
    if sf.dim==2 and self:is_realised(f) then for _,x in ipairs(sf.inputs) do if x==s then n=n+1 end end end
  end
  return n
end
M._realised_uses=M._uses

function M:_offer_pool(trigger)
  local pool,seen={},{}
  local function add(c) local sc=maybe_os(c); if sc and sc.dim>=0 and self:is_realised(c) and not seen[c] then seen[c]=true; pool[#pool+1]=c end end
  local function add_strand(s)
    local ss=os(s)
    if s==trigger or self:_uses(s)==0 then add(s); for _,p in ipairs(ss.points) do add(p) end end
  end
  add_strand(trigger); local tw=os(trigger).world
  for _,c in ipairs(ms(self).objects) do
    local sc=os(c)
    if sc.dim>=0 and self:is_realised(c) and sc.world==tw then
      if sc.dim==0 then add(c) elseif sc.dim==1 then add_strand(c) end
    end
  end
  return pool
end

function M:_infer(trigger,entry)
  local bindings=copy_map(entry.bindings); local pool=self:_offer_pool(trigger); local demands={}
  for c,_ in pairs(entry.component) do
    local sc=os(c); local r=self:_susp_root(sc.world)
    if r and entry.demand_roots[r] and not self:_is_open_output(c,entry.component,entry.demand_roots,entry.gen_roots) then
      demands[#demands+1]=c
    end
  end
  table.sort(demands,function(a,b) local sa,sb=os(a),os(b); if sa.dim~=sb.dim then return sa.dim>sb.dim end return sa.serial<sb.serial end)
  for _,d in ipairs(demands) do
    if not bindings[d] then
      local success={}; local sd=os(d)
      for _,o in ipairs(pool) do
        local so=os(o)
        if o~=d and so.dim==sd.dim and so.sort==sd.sort then
          local t=copy_map(bindings); local ok=self:_match(d,o,entry.demand_roots,t,{})
          if ok then
            local duplicate=false
            if sd.dim==0 then for _,candidate in ipairs(success) do if self:same_point(candidate.o,o) then duplicate=true; break end end end
            if not duplicate then success[#success+1]={o=o,b=t} end
          end
        end
      end
      assertf(#success>0,'no local realised supply for demanded cell %s',sd.id)
      assertf(#success==1,'ambiguous local supply for demanded cell %s (%d candidates)',sd.id,#success)
      bindings=success[1].b
    end
  end
  return bindings
end

-- Count old realised authority use-sites which the resolved generated Faces
-- would acquire after substituting the demanded frontier. This is deliberately
-- positional: the same Strand appearing twice in one Face is two uses.
function M:_prospective_uses(entry,bindings)
  local counts={}
  for c,_ in pairs(entry.component) do
    local sc=os(c); local r=self:_susp_root(sc.world)
    if sc.dim==2 and r and entry.gen_roots[r] then
      for _,d in ipairs(sc.inputs) do
        local offered=bindings[d]
        local so=offered and maybe_os(offered) or nil
        if so and so.dim==1 and self:is_realised(offered) then counts[offered]=(counts[offered] or 0)+1 end
      end
    end
  end
  return counts
end

function M:_check_prospective_uses(trigger,entry,bindings)
  for s,n in pairs(self:_prospective_uses(entry,bindings)) do
    local total=self:_uses(s)+n
    assertf(total<=1,'development of %s would use realised Strand %s %d times',os(trigger).id,os(s).id,total)
  end
  return true
end

function M:_clone_generated(roots,trigger,bindings,map,egress,token)
  assertf(token==INTERNAL,'internal Model mutation is not a public capability')
  local wm,created,instance_worlds={},{},{}; local rootset={}; for _,r in ipairs(roots) do rootset[r]=true end
  local function cw(w,parent)
    local sw=os(w); local nw=self:world(sw.name..'@'..os(trigger).id,parent); os(nw).origin=w; wm[w]=nw; map[w]=nw; created[#created+1]=nw
    for _,ch in ipairs(self:_children(w)) do cw(ch,nw) end
    return nw
  end
  for _,r in ipairs(roots) do instance_worlds[#instance_worlds+1]=cw(r,os(trigger).world) end
  local function in_roots(w) while w do if rootset[w] then return true end; w=os(w).parent end; return false end
  local cells={}; for _,c in ipairs(ms(self).objects) do local sc=os(c); if sc.dim>=0 and in_roots(sc.world) then cells[#cells+1]=c end end
  table.sort(cells,function(a,b) local sa,sb=os(a),os(b); if sa.dim~=sb.dim then return sa.dim<sb.dim end return sa.serial<sb.serial end)
  local function md(d)
    if bindings[d] then return map[bindings[d]] or bindings[d] end
    if map[d] then return map[d] end
    if self:is_realised(d) then return d end
    error('unmapped suspended dependency '..tostring(d),2)
  end

  -- Points in generated Worlds must exist before outgoing frontier Strands can
  -- be placed back at the trigger locality: an egress may expose fresh identity
  -- generated by the stage.
  for _,c in ipairs(cells) do
    local sc=os(c)
    if sc.dim==0 then
      local w=wm[sc.world]
      local nc=self:point(sc.name..'@'..os(trigger).id,w,sc.sort)
      os(nc).origin=c; map[c]=nc; created[#created+1]=nc
    end
  end

  local actual_egress={}
  table.sort(egress,function(a,b)return os(a).serial<os(b).serial end)
  for _,c in ipairs(egress) do
    local sc=os(c); local ps={}; for i,p in ipairs(sc.points) do ps[i]=md(p) end
    local nc=self:strand(sc.name..'@'..os(trigger).id,os(trigger).world,ps,sc.sort)
    os(nc).origin=c; map[c]=nc; created[#created+1]=nc; actual_egress[#actual_egress+1]=nc
  end

  for _,c in ipairs(cells) do
    local sc=os(c); local w=wm[sc.world]; local nc
    if sc.dim==0 then nc=map[c]
    elseif sc.dim==1 then local ps={}; for i,p in ipairs(sc.points) do ps[i]=md(p) end; nc=self:strand(sc.name..'@'..os(trigger).id,w,ps,sc.sort)
    else
      local ins,outs={},{}; for i,s in ipairs(sc.inputs) do ins[i]=md(s) end; for i,s in ipairs(sc.outputs) do outs[i]=md(s) end
      if sc.structural=='copy' then nc=self:copy(sc.name..'@'..os(trigger).id,w,ins[1],outs,sc.sort)
      elseif sc.structural=='discard' then nc=self:discard(sc.name..'@'..os(trigger).id,w,ins[1],sc.sort)
      else nc=self:face(sc.name..'@'..os(trigger).id,w,ins,outs,sc.sort) end
    end
    if sc.dim~=0 then os(nc).origin=c; map[c]=nc; created[#created+1]=nc end
  end
  return instance_worlds,created,actual_egress
end

function M:develop(trigger)
  local st=maybe_os(trigger)
  assertf(st and st.dim==1 and self:_owned(trigger,1) and self:is_realised(trigger),'development trigger must be realised Strand of this Model')
  assertf(self:_uses(trigger)==0,'trigger occurrence %s has already been consumed',st.id)
  return self:atomic(function()
    local e=self:_entry_gate(trigger); assertf(e,'trigger %s has no suspended development stage',st.id)
    local bindings=self:_infer(trigger,e)
    -- Resolve all old-authority use sites before any fresh World is grafted.
    -- Late aliasing remains visible in the match, but an inadmissible match
    -- cannot enter actuality even transiently.
    self:_check_prospective_uses(trigger,e,bindings)
    local roots={}; for r,_ in pairs(e.gen_roots) do roots[#roots+1]=r end
    table.sort(roots,function(a,b)return os(a).serial<os(b).serial end); assertf(#roots>0,'development %s has no generated World',st.id)
    local egress={}
    for c,_ in pairs(e.component) do if self:_is_open_output(c,e.component,e.demand_roots,e.gen_roots) then egress[#egress+1]=c end end
    local map=copy_map(bindings); local worlds,created,actual_egress=self:_clone_generated(roots,trigger,bindings,map,egress,INTERNAL)
    for d,o in pairs(bindings) do map[d]=map[o] or o end
    local witness,seen={},{}
    for a,x in pairs(map) do
      local sa,sx=maybe_os(a),maybe_os(x)
      if sa and sx and sa.dim==2 and sx.dim==2 and self:is_realised(x) then
        for _,s in ipairs(sx.inputs) do if s==trigger and not seen[x] then witness[#witness+1]=x; seen[x]=true end end
      end
    end
    assertf(#witness==1,'development of %s must yield exactly one realised Face consuming trigger; found %d',st.id,#witness)
    local inst={trigger=trigger,map=map,created=created,event=witness[1],worlds=worlds,egress=actual_egress}; local s=ms(self); s.instances[#s.instances+1]=inst
    return inst
  end)
end

function M:check_scarcity()
  for _,s in ipairs(ms(self).objects) do local ss=os(s); if ss.dim==1 and self:is_realised(s) then local n=self:_uses(s); if n>1 then return false,string.format('scarcity: realised strand %s has %d uses',ss.id,n) end end end
  return true
end
function M:check_actual_subcomplex()
  for _,c in ipairs(ms(self).objects) do local sc=os(c); if sc.dim>=1 and self:is_realised(c) then for _,d in ipairs(deps(c)) do if not self:is_realised(d) then return false,'actual geometry depends on suspended geometry' end end end end
  return true
end
function M:world_path(w)
  local x={}; while w do table.insert(x,1,w); w=os(w).parent end; return x
end
function M.is_model(x) return model_state[x]~=nil end

-- Certification guard for the Lua bootstrap.  Handles deliberately carry no raw
-- fields: all semantic state lives in the private weak maps above.  rawset()
-- bypasses __newindex, so certification rejects any handle that has acquired a
-- shadow field rather than trusting what public observation would report.
function M.pristine(x)
  local s=model_state[x]
  if not s then return false,'expected World Model' end
  if next(x)~=nil then return false,'Model handle contains raw shadow state' end
  for _,o in ipairs(s.objects) do
    if next(o)~=nil then
      local st=object_state[o]
      return false,string.format('%s handle contains raw shadow state',st and st.id or 'World object')
    end
  end
  return true
end

function M:find_actual_point(name,sort)
  local found={}; for _,c in ipairs(ms(self).objects) do local sc=os(c); if sc.dim==0 and self:is_realised(c) and sc.name==name and sc.sort==sort then found[#found+1]=c end end
  if #found==1 then return found[1] end; return nil,#found
end

return M
