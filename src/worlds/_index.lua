-- Disposable indexes over immutable Geometry.
-- Query compilation and live-boundary maintenance share this cache; deleting it
-- changes performance only.
local Persistent=require('worlds._persistent')
local INSTANCES=setmetatable({}, {__mode='k'})

return function(K)
local old=INSTANCES[K]; if old then return old end
local CACHE=setmetatable({}, {__mode='k'})
local M={}
local function state(g) local x=CACHE[g]; if not x then x={}; CACHE[g]=x end; return x end
local function push(map,k,v) local xs=map[k]; if not xs then xs={}; map[k]=xs end; xs[#xs+1]=v end

-- Query/source views ---------------------------------------------------------
function M.view(g)
  local c=state(g); if c.view then return c.view end
  local s=K.geometry(g)
  c.view={membranes=Persistent.array(s.membranes),points=Persistent.array(s.points),
    strands=Persistent.array(s.strands),faces=Persistent.array(s.faces),
    mset=s.mset,pset=s.pset,sset=s.sset,fset=s.fset,producer=s.producer,consumer=s.consumer,
    ingress=Persistent.array(s.ingress),egress=Persistent.array(s.egress),developable=s.developable}
  return c.view
end
function M.surface(g)
  local c=state(g); if c.surface then return c.surface end
  local rel,groups,of={},{},{}
  for _,s in ipairs(M.view(g).egress) do
    local ps,ar=K.points(s); ar=#ps; local r=rel[ar]
    if not r then r={rows={},by={}}; for i=2,ar+1 do r.by[i]={} end; rel[ar]=r; groups[ar]={} end
    local coords={K.place(s)}; for i,p in ipairs(ps) do coords[i+1]=p end
    local n=groups[ar]
    for _,v in ipairs(coords) do local q=n[v]; if not q then q={}; n[v]=q end; n=q end
    local row=n.group
    if not row then row={coords=coords,occurrences={}}; n.group=row; r.rows[#r.rows+1]=row; for i=2,#coords do push(r.by[i],coords[i],row) end end
    row.occurrences[#row.occurrences+1]=s; of[s]=row
  end
  c.surface={relations=rel,groups=groups,of=of}; return c.surface
end
local function positions(xs) local p={}; for i,x in ipairs(xs) do p[x]=i end; return p end
function M.prepare(g) M.view(g); M.surface(g); return g end
function M.ingress_positions(g) local c=state(g); if not c.ipos then c.ipos=positions(M.view(g).ingress) end; return c.ipos end
function M.egress_positions(g) local c=state(g); if not c.epos then c.epos=positions(M.view(g).egress) end; return c.epos end

-- Boundary order -------------------------------------------------------------
local function h(n) return n and n.h or 0 end
local function z(n) return n and n.n or 0 end
local function recalc(n) n.h=math.max(h(n.l),h(n.r))+1; n.n=z(n.l)+z(n.r)+1; return n end
local function R(y) local x=y.l; y.l=x.r; x.r=recalc(y); return recalc(x) end
local function L(x) local y=x.r; x.r=y.l; y.l=recalc(x); return recalc(y) end
local function balance(n)
  recalc(n); local d=h(n.l)-h(n.r)
  if d>1 then if h(n.l.l)<h(n.l.r) then n.l=L(n.l) end; return R(n) end
  if d < -1 then if h(n.r.r)<h(n.r.l) then n.r=R(n.r) end; return L(n) end
  return n
end
local function insert(n,k) if not n then return {k=k,h=1,n=1} end; if k<n.k then n.l=insert(n.l,k) else n.r=insert(n.r,k) end; return balance(n) end
local function minimum(n) while n.l do n=n.l end; return n end
local function delete(n,k)
  if not n then return nil end
  if k<n.k then n.l=delete(n.l,k) elseif k>n.k then n.r=delete(n.r,k)
  elseif not n.l then return n.r elseif not n.r then return n.l
  else local s=minimum(n.r); n.k=s.k; n.r=delete(n.r,s.k) end
  return balance(n)
end
local function rank(n,k) local r=0; while n do if k<n.k then n=n.l else r=r+z(n.l)+1; if k==n.k then return r end; n=n.r end end end
local function build(keys,a,b) if a>b then return nil end; local m=math.floor((a+b)/2); local n={k=keys[m]}; n.l=build(keys,a,m-1); n.r=build(keys,m+1,b); return recalc(n) end
local function order(xs) local by,keys={},{}; for i,x in ipairs(xs) do by[x]=i; keys[i]=i end; return {root=build(keys,1,#keys),by=by,next=#keys} end
local function pos(o,x) local k=o.by[x]; return k and rank(o.root,k) or nil end
local function remove(o,x) local k=o.by[x]; assert(k,'boundary order lost exact carrier'); o.by[x]=nil; o.root=delete(o.root,k) end
local function append(o,x) o.next=o.next+1; o.by[x]=o.next; o.root=insert(o.root,o.next) end
local function ordinals(o,xs) local out={}; for _,x in ipairs(xs) do out[#out+1]=assert(pos(o,x),'boundary carrier has no current ordinal') end; table.sort(out); return out end

local function contribute(st,s,d,pc,mc)
  local function mem(m) while m and st.mset[m] do mc[m]=(mc[m] or 0)+d; m=K.parent(m) end end
  mem(K.place(s)); for _,p in ipairs(K.points(s)) do if st.pset[p] then pc[p]=(pc[p] or 0)+d; mem(K.place(p)) end end
end
local function bindex(g)
  local c=state(g); if c.boundary then return c.boundary end
  local st=K.geometry(g); assert(st.boundary_normal,'boundary index requires boundary-normal Geometry')
  local pc,mc={},{}; for _,s in Persistent.iter(st.egress) do contribute(st,s,1,pc,mc) end
  c.boundary={point_count=pc,membrane_count=mc,order={strand=order(Persistent.array(st.strands)),point=order(Persistent.array(st.points)),membrane=order(Persistent.array(st.membranes))}}
  return c.boundary
end
function M.has_boundary(g) local c=CACHE[g]; return not not(c and c.boundary) end
function M.prepare_boundary(g) bindex(g); return g end
function M.boundary_position(g,kind,x) return pos(bindex(g).order[kind],x) end

local function delta(frame,result,removed_s,added_s,pd,md)
  local fs,idx=K.geometry(frame),bindex(frame)
  local removed_p,removed_m={},{}
  for p,d in pairs(pd) do if fs.pset[p] and (idx.point_count[p] or 0)+d<=0 then removed_p[#removed_p+1]=p end end
  for m,d in pairs(md) do if fs.mset[m] and (idx.membrane_count[m] or 0)+d<=0 then removed_m[#removed_m+1]=m end end
  local added_p,added_m={},{}
  if result then
    local rs=K.geometry(result)
    for _,p in ipairs(rs.frame_new_points or rs.points) do if not fs.pset[p] and (pd[p] or 0)>0 then added_p[#added_p+1]=p end end
    for _,m in ipairs(rs.frame_new_membranes or rs.membranes) do if not fs.mset[m] and (md[m] or 0)>0 then added_m[#added_m+1]=m end end
  end
  local sr,pr,mr=ordinals(idx.order.strand,removed_s),ordinals(idx.order.point,removed_p),ordinals(idx.order.membrane,removed_m)
  local strands=Persistent.sequence_delta(fs.strands,sr,added_s)
  local points=Persistent.sequence_delta(fs.points,pr,added_p)
  local membranes=Persistent.sequence_delta(fs.membranes,mr,added_m)
  local function removed(xs) local t={}; for _,x in ipairs(xs) do t[x]=true end; return t end
  local nextg=K.make_boundary{membranes=membranes,points=points,strands=strands,
    mset=Persistent.set_delta(fs.mset,removed(removed_m),added_m,membranes),
    pset=Persistent.set_delta(fs.pset,removed(removed_p),added_p,points),
    sset=Persistent.set_delta(fs.sset,removed(removed_s),added_s,strands)}

  CACHE[frame]=nil
  for x,d in pairs(pd) do local n=(idx.point_count[x] or 0)+d; idx.point_count[x]=n>0 and n or nil end
  for x,d in pairs(md) do local n=(idx.membrane_count[x] or 0)+d; idx.membrane_count[x]=n>0 and n or nil end
  for _,x in ipairs(removed_s) do remove(idx.order.strand,x) end; for _,x in ipairs(added_s) do append(idx.order.strand,x) end
  for _,x in ipairs(removed_p) do remove(idx.order.point,x) end; for _,x in ipairs(added_p) do append(idx.order.point,x) end
  for _,x in ipairs(removed_m) do remove(idx.order.membrane,x) end; for _,x in ipairs(added_m) do append(idx.order.membrane,x) end
  state(nextg).boundary=idx
  return nextg
end

function M.boundary_apply(frame,removed_s,added_s)
  removed_s,added_s=removed_s or {},added_s or {}; local fs=K.geometry(frame); local pd,md={},{}
  for _,s in ipairs(removed_s) do contribute(fs,s,-1,pd,md) end
  for _,s in ipairs(added_s) do contribute(fs,s,1,pd,md) end
  return delta(frame,nil,removed_s,added_s,pd,md)
end
function M.boundary_after(frame,result)
  local fs,rs=K.geometry(frame),K.geometry(result); local removed_s,added_s,pd,md={},{},{},{}
  if rs.frame_base==frame then
    for _,s in ipairs(rs.frame_removed_egress or {}) do removed_s[#removed_s+1]=s; contribute(fs,s,-1,pd,md) end
    for _,s in ipairs(rs.frame_added_egress or {}) do added_s[#added_s+1]=s; contribute(rs,s,1,pd,md) end
  else
    for _,s in Persistent.iter(fs.egress) do if rs.consumer[s]~=nil then removed_s[#removed_s+1]=s; contribute(fs,s,-1,pd,md) end end
    for _,s in Persistent.iter(rs.egress) do if not fs.sset[s] then added_s[#added_s+1]=s; contribute(rs,s,1,pd,md) end end
  end
  return delta(frame,result,removed_s,added_s,pd,md)
end

INSTANCES[K]=M
return M
end
