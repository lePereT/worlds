-- Disposable acceleration for boundary-normal Geometry.
--
-- Programme Geometry remains immutable.  This cache is deliberately mutable:
-- advancing a boundary transfers its acceleration to the successor and removes
-- it from the predecessor.  A predecessor used again simply rebuilds from its
-- exact Geometry.  No acceleration generation therefore retains old live worlds.
local INSTANCES=setmetatable({}, {__mode='k'})
return function(K)
local existing=INSTANCES[K]; if existing then return existing end
local CACHE=setmetatable({}, {__mode='k'})
local M={}
local Persistent=require('worlds._persistent')
local delta_seq,delta_set=Persistent.sequence_delta,Persistent.set_delta

-- Mutable order-statistic AVL ------------------------------------------------
local function h(n) return n and n.h or 0 end
local function z(n) return n and n.n or 0 end
local function recalc(n) n.h=math.max(h(n.l),h(n.r))+1; n.n=z(n.l)+z(n.r)+1; return n end
local function right(y) local x=y.l; y.l=x.r; x.r=recalc(y); return recalc(x) end
local function left(x) local y=x.r; x.r=y.l; y.l=recalc(x); return recalc(y) end
local function balance(n)
  recalc(n); local d=h(n.l)-h(n.r)
  if d>1 then if h(n.l.l)<h(n.l.r) then n.l=left(n.l) end; return right(n) end
  if d<-1 then if h(n.r.r)<h(n.r.l) then n.r=right(n.r) end; return left(n) end
  return n
end
local function insert(n,key)
  if not n then return {k=key,h=1,n=1} end
  if key<n.k then n.l=insert(n.l,key) else n.r=insert(n.r,key) end
  return balance(n)
end
local function minimum(n) while n.l do n=n.l end; return n end
local function delete(n,key)
  if not n then return nil end
  if key<n.k then n.l=delete(n.l,key)
  elseif key>n.k then n.r=delete(n.r,key)
  elseif not n.l then return n.r
  elseif not n.r then return n.l
  else local s=minimum(n.r); n.k=s.k; n.r=delete(n.r,s.k) end
  return balance(n)
end
local function rank(n,key)
  local r=0
  while n do
    if key<n.k then n=n.l
    else r=r+z(n.l)+1; if key==n.k then return r end; n=n.r end
  end
end
local function build(keys,lo,hi)
  if lo>hi then return nil end
  local mid=math.floor((lo+hi)/2); local n={k=keys[mid]}; n.l=build(keys,lo,mid-1); n.r=build(keys,mid+1,hi); return recalc(n)
end
local function order_from(xs)
  local by,keys={},{}; for i,x in ipairs(xs) do by[x]=i; keys[i]=i end
  return {root=build(keys,1,#keys),by=by,next=#keys}
end
local function order_position(o,x) local k=o.by[x]; return k and rank(o.root,k) or nil end
local function order_remove(o,x) local k=o.by[x]; assert(k,'boundary order lost exact carrier'); o.by[x]=nil; o.root=delete(o.root,k) end
local function order_append(o,x) o.next=o.next+1; o.by[x]=o.next; o.root=insert(o.root,o.next) end
local function positions(o,xs)
  local out={}; for _,x in ipairs(xs) do out[#out+1]=assert(order_position(o,x),'boundary carrier has no current ordinal') end; table.sort(out); return out
end

-- Incidence counts ------------------------------------------------------------
local function contribute(st,s,delta,pc,mc)
  local function addm(m)
    while m and st.mset[m] do mc[m]=(mc[m] or 0)+delta; m=K.parent(m) end
  end
  addm(K.place(s))
  for _,p in ipairs(K.points(s)) do if st.pset[p] then pc[p]=(pc[p] or 0)+delta; addm(K.place(p)) end end
end
local function prepare(g)
  local x=CACHE[g]; if x then return x end
  local st=K.geometry(g); assert(st.boundary_normal,'boundary acceleration requires boundary-normal Geometry')
  local pc,mc={},{}; for _,s in Persistent.iter(st.egress) do contribute(st,s,1,pc,mc) end
  x={point_count=pc,membrane_count=mc,order={
    strand=order_from(st.strands),point=order_from(st.points),membrane=order_from(st.membranes),
  }}
  CACHE[g]=x; return x
end
function M.has(g) return CACHE[g]~=nil end
function M.prepare(g) return prepare(g) end
function M.position(g,kind,x) return order_position(prepare(g).order[kind],x) end

local function apply_delta(frame,removed_s,added_s)
  local fs=K.geometry(frame); assert(fs.boundary_normal,'boundary delta requires boundary-normal frame')
  local idx=prepare(frame); local pd,md={},{}
  for _,s in ipairs(removed_s) do contribute(fs,s,-1,pd,md) end
  for _,s in ipairs(added_s) do contribute(fs,s,1,pd,md) end

  local removed_p,removed_m={},{}
  for p,d in pairs(pd) do if fs.pset[p] and (idx.point_count[p] or 0)+d<=0 then removed_p[#removed_p+1]=p end end
  for m,d in pairs(md) do if fs.mset[m] and (idx.membrane_count[m] or 0)+d<=0 then removed_m[#removed_m+1]=m end end

  local sr,pr,mr=positions(idx.order.strand,removed_s),positions(idx.order.point,removed_p),positions(idx.order.membrane,removed_m)
  local points=delta_seq(fs.points,pr,{}); local membranes=delta_seq(fs.membranes,mr,{}); local strands=delta_seq(fs.strands,sr,added_s)
  local prem,mrem,srem={},{},{}; for _,x in ipairs(removed_p) do prem[x]=true end; for _,x in ipairs(removed_m) do mrem[x]=true end; for _,x in ipairs(removed_s) do srem[x]=true end
  local pset=delta_set(fs.pset,prem,{},points); local mset=delta_set(fs.mset,mrem,{},membranes); local sset=delta_set(fs.sset,srem,added_s,strands)
  local nextg=K.make_boundary{membranes=membranes,points=points,strands=strands,mset=mset,pset=pset,sset=sset}

  CACHE[frame]=nil
  for x,d in pairs(pd) do local n=(idx.point_count[x] or 0)+d; idx.point_count[x]=n>0 and n or nil end
  for x,d in pairs(md) do local n=(idx.membrane_count[x] or 0)+d; idx.membrane_count[x]=n>0 and n or nil end
  for _,x in ipairs(removed_s) do order_remove(idx.order.strand,x) end; for _,x in ipairs(added_s) do order_append(idx.order.strand,x) end
  for _,x in ipairs(removed_p) do order_remove(idx.order.point,x) end
  for _,x in ipairs(removed_m) do order_remove(idx.order.membrane,x) end
  CACHE[nextg]=idx
  return nextg
end

function M.apply(frame,removed_s,added_s)
  return apply_delta(frame,removed_s or {},added_s or {})
end

function M.after(frame,result)
  local fs,rs=K.geometry(frame),K.geometry(result); assert(fs.boundary_normal,'boundary delta requires boundary-normal frame')
  local idx=prepare(frame); local pd,md={},{}; local removed_s,added_s={},{}
  if rs.frame_base==frame then
    for _,s in ipairs(rs.frame_removed_egress or {}) do removed_s[#removed_s+1]=s; contribute(fs,s,-1,pd,md) end
    for _,s in ipairs(rs.frame_added_egress or {}) do added_s[#added_s+1]=s; contribute(rs,s,1,pd,md) end
  else
    for _,s in Persistent.iter(fs.egress) do if rs.consumer[s]~=nil then removed_s[#removed_s+1]=s; contribute(fs,s,-1,pd,md) end end
    for _,s in Persistent.iter(rs.egress) do if not fs.sset[s] then added_s[#added_s+1]=s; contribute(rs,s,1,pd,md) end end
  end

  local removed_p,removed_m={},{}
  for p,d in pairs(pd) do if fs.pset[p] and (idx.point_count[p] or 0)+d<=0 then removed_p[#removed_p+1]=p end end
  for m,d in pairs(md) do if fs.mset[m] and (idx.membrane_count[m] or 0)+d<=0 then removed_m[#removed_m+1]=m end end
  local added_p,added_m={},{}
  local psource=rs.frame_new_points or Persistent.array(rs.points); for _,p in ipairs(psource) do if not fs.pset[p] and (pd[p] or 0)>0 then added_p[#added_p+1]=p end end
  local msource=rs.frame_new_membranes or Persistent.array(rs.membranes); for _,m in ipairs(msource) do if not fs.mset[m] and (md[m] or 0)>0 then added_m[#added_m+1]=m end end

  local sr,pr,mr=positions(idx.order.strand,removed_s),positions(idx.order.point,removed_p),positions(idx.order.membrane,removed_m)
  local points=delta_seq(fs.points,pr,added_p); local membranes=delta_seq(fs.membranes,mr,added_m); local strands=delta_seq(fs.strands,sr,added_s)
  local prem,mrem,srem={},{},{}; for _,x in ipairs(removed_p) do prem[x]=true end; for _,x in ipairs(removed_m) do mrem[x]=true end; for _,x in ipairs(removed_s) do srem[x]=true end
  local pset=delta_set(fs.pset,prem,added_p,points); local mset=delta_set(fs.mset,mrem,added_m,membranes); local sset=delta_set(fs.sset,srem,added_s,strands)
  local nextg=K.make_boundary{membranes=membranes,points=points,strands=strands,mset=mset,pset=pset,sset=sset}

  -- Transfer the disposable index.  If `frame` is used again it will rebuild
  -- independently from its immutable Geometry, so branching remains exact.
  CACHE[frame]=nil
  for x,d in pairs(pd) do local n=(idx.point_count[x] or 0)+d; idx.point_count[x]=n>0 and n or nil end
  for x,d in pairs(md) do local n=(idx.membrane_count[x] or 0)+d; idx.membrane_count[x]=n>0 and n or nil end
  for _,x in ipairs(removed_s) do order_remove(idx.order.strand,x) end; for _,x in ipairs(added_s) do order_append(idx.order.strand,x) end
  for _,x in ipairs(removed_p) do order_remove(idx.order.point,x) end; for _,x in ipairs(added_p) do order_append(idx.order.point,x) end
  for _,x in ipairs(removed_m) do order_remove(idx.order.membrane,x) end; for _,x in ipairs(added_m) do order_append(idx.order.membrane,x) end
  CACHE[nextg]=idx
  return nextg
end

INSTANCES[K]=M
return M
end
