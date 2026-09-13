-- Worlds 0.6.0 verified centre -- exact Geometry, boundary and join.
--
-- This module contains the operational ontology only.  It knows nothing about
-- query acceleration or matching search.  Live state is the exact open
-- boundary; join is the sole geometry-changing operation and advance returns
-- immediately to boundary normal form.  History is optional observation outside
-- this centre.

local W={}
local PRIVATE={}
local STATE=setmetatable({}, {__mode='k'})
local DENSE=require('worlds._array')
local EMPTY={}
local function immutable() error('Worlds values are immutable',2) end
local CarrierMT={__newindex=immutable,__metatable='Worlds carrier'}
local GeometryMT={__newindex=immutable,__metatable='Worlds Geometry'}; GeometryMT.__index=GeometryMT
local finish_arrays

local function array(xs) local r={} for i=1,#xs do r[i]=xs[i] end return r end
local function new(kind,data,mt) local x=setmetatable({},mt or CarrierMT); data.kind=kind; STATE[x]=data; return x end
local function expect(x,kind) local s=STATE[x]; assert(s and s.kind==kind,'expected Worlds '..kind); return s end
local function dsu(items)
  local p,rank={},{}; for _,x in ipairs(items) do p[x]=x; rank[x]=0 end
  local X={}
  function X:find(x) local q=p[x]; while q~=p[q] do p[q]=p[p[q]]; q=p[q] end; local r=q; q=x; while p[q]~=r do local n=p[q]; p[q]=r; q=n end; return r end
  function X:union(a,b) a,b=self:find(a),self:find(b); if a==b then return a end; if rank[a]<rank[b] then a,b=b,a end; p[b]=a; if rank[a]==rank[b] then rank[a]=rank[a]+1 end; return a end
  return X
end

-- Exact carrier identity owns exact spatial ancestry.  Geometry membership can
-- change under boundary projection; parent/depth/level-ancestor cannot.
local function parent(m) return STATE[m].parent end
local function place(x) return STATE[x].membrane end
local function points(s) return STATE[s].points end
local function inputs(f) return STATE[f].inputs end
local function outputs(f) return STATE[f].outputs end
local function depth(m) return STATE[m].depth end

local function membrane(p,name)
  return new('Membrane',{parent=p,depth=p and depth(p)+1 or 1,name=name})
end
local function point(m,name) return new('Point',{membrane=m,name=name}) end
local function strand(m,ps,name) return new('Strand',{membrane=m,points=ps,name=name}) end
local function face(m,ins,outs,name) return new('Face',{membrane=m,inputs=ins,outputs=outs,name=name}) end

function W.kind(x) local s=STATE[x]; return s and string.lower(s.kind) or nil end
function W.name(x) local s=STATE[x]; return s and s.name or nil end
function W.parent(m) return expect(m,'Membrane').parent end
function W.membrane(x) local s=STATE[x]; assert(s and (s.kind=='Point' or s.kind=='Strand' or s.kind=='Face'),'expected Point/Strand/Face'); return s.membrane end
function W.points(s) return array(expect(s,'Strand').points) end
function W.inputs(f) return array(expect(f,'Face').inputs) end
function W.outputs(f) return array(expect(f,'Face').outputs) end
function W.is_geometry(x) local s=STATE[x]; return not not(s and s.kind=='Geometry') end

function W.builder()
  local membranes,points_,strands_,faces_={},{},{},{}
  local mset,sset={},{}
  local finished=false
  local methods={}
  local function live() assert(not finished,'builder already finished') end
  function methods:membrane(p,name)
    live(); if p then assert(mset[p],'parent must belong to Geometry') end
    local x=membrane(p,name); membranes[#membranes+1]=x; mset[x]=true; return x
  end
  function methods:point(m,name)
    live(); assert(mset[m],'Point membrane must belong to Geometry')
    local x=point(m,name); points_[#points_+1]=x; return x
  end
  function methods:strand(m,ps,name)
    live(); assert(mset[m],'Strand membrane must belong to Geometry'); ps=ps or {}
    local copy=DENSE.copy(ps,'Strand points')
    for _,p in ipairs(copy) do local x=STATE[p]; assert(x and x.kind=='Point','Strand incidence expects Point') end
    local x=strand(m,copy,name); strands_[#strands_+1]=x; sset[x]=true; return x
  end
  function methods:face(m,ins,outs,name)
    live(); assert(mset[m],'Face membrane must belong to Geometry'); ins,outs=ins or {},outs or {}
    local incopy=DENSE.copy(ins,'Face inputs'); local outcopy=DENSE.copy(outs,'Face outputs')
    for _,s in ipairs(incopy) do assert(sset[s],'Face input must belong to Geometry') end
    for _,s in ipairs(outcopy) do assert(sset[s],'Face output must belong to Geometry') end
    local x=face(m,incopy,outcopy,name); faces_[#faces_+1]=x; return x
  end
  function methods:finish()
    live(); finished=true
    return finish_arrays(array(membranes),array(points_),array(strands_),array(faces_),true)
  end
  return setmetatable({}, {__index=methods,__newindex=immutable,__metatable='Worlds builder'})
end

local function local_mem_chain(set,m,into)
  while m and set[m] do if into[m] then return end; into[m]=true; m=parent(m) end
end
local function strand_local_carriers(b,s,into)
  local_mem_chain(b.mset,place(s),into)
  for _,p in ipairs(points(s)) do if b.pset[p] then into[p]=true; local_mem_chain(b.mset,place(p),into) end end
end
local function referenced_by_face(b,f)
  local r={}; local_mem_chain(b.mset,place(f),r)
  for _,s in ipairs(outputs(f)) do strand_local_carriers(b,s,r) end
  return r
end

-- Builder validation proves Geometry laws.  Trusted join output asks only for
-- the derived causal indices.
local function index_geometry(b,validate)
  local producer,consumer={},{}
  for _,f in ipairs(b.faces) do
    local seen=validate and {} or nil
    for _,s in ipairs(inputs(f)) do if validate then assert(not seen[s],'Face consumes Strand twice'); assert(not consumer[s],'Strand has >1 consumer'); seen[s]=true end; consumer[s]=f end
    seen=validate and {} or nil
    for _,s in ipairs(outputs(f)) do if validate then assert(not seen[s],'Face produces Strand twice'); assert(not producer[s],'Strand has >1 producer'); seen[s]=true end; producer[s]=f end
  end
  local order
  if validate then
    local out,indeg={},{}; for _,f in ipairs(b.faces) do out[f]={}; indeg[f]=0 end
    for _,s in ipairs(b.strands) do local p,c=producer[s],consumer[s]; if p and c then out[p][#out[p]+1]=c; indeg[c]=indeg[c]+1 end end
    local q={}; for _,f in ipairs(b.faces) do if indeg[f]==0 then q[#q+1]=f end end
    local qi=1; order={}
    while qi<=#q do local f=q[qi]; qi=qi+1; order[#order+1]=f; for _,g in ipairs(out[f]) do indeg[g]=indeg[g]-1; if indeg[g]==0 then q[#q+1]=g end end end
    assert(#order==#b.faces,'causal Face/Strand incidence must be acyclic')
  end
  local ingress,egress={},{}
  for _,s in ipairs(b.strands) do if not producer[s] then ingress[#ingress+1]=s end; if not consumer[s] then egress[#egress+1]=s end end
  local reached,rq={},{}; for _,s in ipairs(ingress) do local c=consumer[s]; if c and not reached[c] then reached[c]=true; rq[#rq+1]=c end end
  local ri=1; while ri<=#rq do local f=rq[ri]; ri=ri+1; for _,s in ipairs(outputs(f)) do local c=consumer[s]; if c and not reached[c] then reached[c]=true; rq[#rq+1]=c end end end
  local developable=true; for _,f in ipairs(b.faces) do if not reached[f] then developable=false; break end end

  if validate then
    local known={}; for _,s in ipairs(ingress) do strand_local_carriers(b,s,known) end
    for _,f in ipairs(order) do if reached[f] then
      local available={}; for _,s in ipairs(inputs(f)) do strand_local_carriers(b,s,available) end
      local used=referenced_by_face(b,f); local mems,pts={},{}
      for x in pairs(used) do if b.mset[x] then mems[#mems+1]=x elseif b.pset[x] then pts[#pts+1]=x end end
      table.sort(mems,function(a,c) return depth(a)<depth(c) end)
      local usable={}; for x in pairs(available) do if b.mset[x] then usable[x]=true end end
      for _,m in ipairs(mems) do
        if known[m] then assert(available[m],'existing locality used without causal input incidence')
        else local p=parent(m); assert(p and usable[p],'fresh locality must descend from causally available locality') end
        usable[m]=true
      end
      for _,p in ipairs(pts) do
        if known[p] then assert(available[p],'existing Point used without causal input incidence')
        else assert(usable[place(p)],'fresh Point must inhabit causally available/fresh locality') end
      end
      for x in pairs(used) do known[x]=true end
    end end
  end
  return {producer=producer,consumer=consumer,ingress=ingress,egress=egress,developable=developable}
end

-- Boundary normality is a Geometry fact, not a query-index fact.  The centre
-- computes only the locality closure needed by its own boundary law; structural
-- grouping and postings remain disposable acceleration outside this module.
local function boundary_closure(s)
  local keepm,keepp={},{}
  local function keep_membrane(m)
    while m and s.mset[m] and not keepm[m] do keepm[m]=true; m=parent(m) end
  end
  for _,x in ipairs(s.egress) do
    keep_membrane(place(x))
    for _,p in ipairs(points(x)) do
      if s.pset[p] and not keepp[p] then keepp[p]=true; keep_membrane(place(p)) end
    end
  end
  return keepm,keepp
end
local function is_boundary_normal(s)
  if #s.faces~=0 or #s.egress~=#s.strands then return false end
  local keepm,keepp=boundary_closure(s)
  for _,m in ipairs(s.membranes) do if not keepm[m] then return false end end
  for _,p in ipairs(s.points) do if not keepp[p] then return false end end
  return true
end

finish_arrays=function(membranes,points_,strands_,faces_,validate)
  local b={membranes=membranes,points=points_,strands=strands_,faces=faces_,mset={},pset={},sset={},fset={}}
  for _,x in ipairs(membranes) do b.mset[x]=true end; for _,x in ipairs(points_) do b.pset[x]=true end; for _,x in ipairs(strands_) do b.sset[x]=true end; for _,x in ipairs(faces_) do b.fset[x]=true end
  local idx=index_geometry(b,validate)
  local data={membranes=membranes,points=points_,strands=strands_,faces=faces_,mset=b.mset,pset=b.pset,sset=b.sset,fset=b.fset,producer=idx.producer,consumer=idx.consumer,ingress=idx.ingress,egress=idx.egress,developable=idx.developable,boundary={}}
  local g=new('Geometry',data,GeometryMT)
  data.boundary_normal=is_boundary_normal(data)
  return g
end
function GeometryMT:membranes() return array(STATE[self].membranes) end
function GeometryMT:points() return array(STATE[self].points) end
function GeometryMT:strands() return array(STATE[self].strands) end
function GeometryMT:faces() return array(STATE[self].faces) end
function GeometryMT:ingress() return array(STATE[self].ingress) end
function GeometryMT:egress() return array(STATE[self].egress) end
function GeometryMT:is_developable() return not not STATE[self].developable end
function GeometryMT:owns_membrane(x) return not not STATE[self].mset[x] end
function GeometryMT:owns_point(x) return not not STATE[self].pset[x] end
function GeometryMT:owns_strand(x) return not not STATE[self].sset[x] end
function GeometryMT:owns_face(x) return not not STATE[self].fset[x] end
function GeometryMT:producer(s) local g=STATE[self]; assert(g.sset[s],'Strand must belong to Geometry'); return g.producer[s] end
function GeometryMT:consumer(s) local g=STATE[self]; assert(g.sset[s],'Strand must belong to Geometry'); return g.consumer[s] end
function GeometryMT:is_input(s) local g=STATE[self]; return not not g.sset[s] and g.producer[s]==nil end
function GeometryMT:is_terminal(s) local g=STATE[self]; return not not g.sset[s] and g.consumer[s]==nil end

-- The live projection preserves exact outgoing authority and only the owned
-- locality closure needed to interpret it.  No causal history survives.
function W.boundary(g)
  local s=expect(g,'Geometry'); if s.boundary_normal then return g end; if s.live then return s.live end
  local keepm,keepp=boundary_closure(s)
  local membranes,points_={},{}; local mset,pset,sset={},{},{}
  for _,m in ipairs(s.membranes) do if keepm[m] then membranes[#membranes+1]=m; mset[m]=true end end
  for _,p in ipairs(s.points) do if keepp[p] then points_[#points_+1]=p; pset[p]=true end end
  local strands_=s.egress; for _,x in ipairs(strands_) do sset[x]=true end
  local data={membranes=membranes,points=points_,strands=strands_,faces=EMPTY,mset=mset,pset=pset,sset=sset,fset=EMPTY,producer=EMPTY,consumer=EMPTY,ingress=strands_,egress=strands_,developable=true,boundary={},boundary_normal=true}
  local live=new('Geometry',data,GeometryMT)
  s.live=live; return live
end

-- Join ----------------------------------------------------------------------

local function kosaraju(faces_,out,inn)
  local seen,finish={},{}
  for _,root in ipairs(faces_) do if not seen[root] then seen[root]=true; local stack={{v=root,i=1}}
    while #stack>0 do local f=stack[#stack]; if not f.ns then f.ns={}; for n in pairs(out[f.v] or {}) do f.ns[#f.ns+1]=n end end; local n=f.ns[f.i]
      if n then f.i=f.i+1; if not seen[n] then seen[n]=true; stack[#stack+1]={v=n,i=1} end else finish[#finish+1]=f.v; stack[#stack]=nil end
    end
  end end
  local comp,groups={},{}
  for i=#finish,1,-1 do local root=finish[i]; if not comp[root] then local id=#groups+1; local g={}; groups[id]=g; comp[root]=id; local q={root}; local qi=1
    while qi<=#q do local v=q[qi]; qi=qi+1; g[#g+1]=v; for n in pairs(inn[v] or {}) do  if not comp[n] then comp[n]=id; q[#q+1]=n end end end
  end end
  local cyclic={}; for id,g in ipairs(groups) do cyclic[id]=#g>1 or not not((out[g[1]] or {})[g[1]]) end
  return groups,comp,cyclic
end
local function lca_mem(reps,mparent)
  local function path_(x) local a={}; while x do a[#a+1]=x; x=mparent[x] end; local r={}; for i=#a,1,-1 do r[#r+1]=a[i] end; return r end
  local ps,max={},0; for _,r in ipairs(reps) do local p=path_(r); ps[#ps+1]=p; if #p>max then max=#p end end
  local last=nil; for d=1,max do local x=ps[1][d]; if not x then break end; for i=2,#ps do if ps[i][d]~=x then return last end end; last=x end; return last
end

function W.join(parts,equations)
  local nparts=DENSE.length(parts,'join parts'); assert(nparts>0,'join expects Geometry parts'); equations=equations or {}; DENSE.length(equations,'join equations')
  local owner={membrane={},point={},strand={},face={}}; local all={membrane={},point={},strand={},face={}}; local partstate={}
  for pi,g in ipairs(parts) do
    local st=expect(g,'Geometry'); partstate[pi]=st
    for _,m in ipairs(st.membranes) do assert(not owner.membrane[m],'Geometry parts must be disjoint'); owner.membrane[m]=pi; all.membrane[#all.membrane+1]=m end
    for _,p in ipairs(st.points) do assert(not owner.point[p],'Geometry parts must be disjoint'); owner.point[p]=pi; all.point[#all.point+1]=p end
    for _,s in ipairs(st.strands) do assert(not owner.strand[s],'Geometry parts must be disjoint'); owner.strand[s]=pi; all.strand[#all.strand+1]=s end
    for _,f in ipairs(st.faces) do assert(not owner.face[f],'Geometry parts must be disjoint'); owner.face[f]=pi; all.face[#all.face+1]=f end
  end
  local md,pd,sd=dsu(all.membrane),dsu(all.point),dsu(all.strand); local manchor,panchor={},{}
  local function set_anchor(which,D,x,a) local r=D:find(x); local old=which[r]; if old and old~=a then return false end; which[r]=a; return true end
  local function union_anchor(which,D,a,b) local ra,rb=D:find(a),D:find(b); if ra==rb then return ra end; local aa,ab=which[ra],which[rb]; if aa and ab and aa~=ab then return nil end; local r=D:union(ra,rb); which[ra]=nil; which[rb]=nil; which[r]=aa or ab; return r end
  local function eq_mem(source,target)
    while true do local so,to=owner.membrane[source],owner.membrane[target]; if not to then return source==target end
      if so then if not union_anchor(manchor,md,source,target) then return false end else if not set_anchor(manchor,md,target,source) then return false end end
      local tp=parent(target); if not(tp and owner.membrane[tp]) then return true end; source,target=parent(source),tp; if not source then return false end
    end
  end
  local function eq_point(source,target)
    local so,to=owner.point[source],owner.point[target]; if not to then return source==target end
    if so then if not union_anchor(panchor,pd,source,target) then return false end else if not set_anchor(panchor,pd,target,source) then return false end end
    return eq_mem(place(source),place(target))
  end
  local function eq_strand(source,target)
    local so,to=owner.strand[source],owner.strand[target]; assert(so and to,'equation endpoints must belong to joined Geometry'); assert(source~=target,'boundary equation joins distinct open occurrences'); assert(partstate[so].consumer[source]==nil,'from must be open egress'); assert(partstate[to].producer[target]==nil,'to must be open ingress')
    sd:union(source,target); if not eq_mem(place(source),place(target)) then return false end
    local a,b=points(source),points(target); if #a~=#b then return false end; for i=1,#a do if owner.point[b[i]] then if not eq_point(a[i],b[i]) then return false end elseif a[i]~=b[i] then return false end end; return true
  end
  local from_seen,to_seen={},{}
  for _,e in ipairs(equations) do local from,to=e.from or e[1],e.to or e[2]; assert(not from_seen[from],'open authority is scarce'); assert(not to_seen[to],'open requirement closes once'); from_seen[from]=true; to_seen[to]=true; assert(eq_strand(from,to),'inconsistent boundary equation') end

  local smeta={}; for _,s in ipairs(all.strand) do local r=sd:find(s); local x=smeta[r]; if not x then x={members={}}; smeta[r]=x end; x.members[#x.members+1]=s; local g=partstate[owner.strand[s]]; local p,c=g.producer[s],g.consumer[s]; if p then x.producer=p end; if c then x.consumer=c end end
  local out,inn={},{ }; for _,f in ipairs(all.face) do out[f]={}; inn[f]={} end
  for _,x in pairs(smeta) do local p,c=x.producer,x.consumer; if p and c and not out[p][c] then out[p][c]=true; inn[c][p]=true end end
  local groups,group_of,cyclic=kosaraju(all.face,out,inn)

  local mclasses,members={},{}; for _,m in ipairs(all.membrane) do local r=md:find(m); if not members[r] then members[r]={}; mclasses[#mclasses+1]=r end; members[r][#members[r]+1]=m end
  local mparent={}; for _,r in ipairs(mclasses) do local pr=nil; for _,m in ipairs(members[r]) do local p=parent(m); if p and owner.membrane[p] then local rr=md:find(p); if rr~=r then pr=rr end elseif p and not owner.membrane[p] then manchor[r]=manchor[r] or m end end; mparent[r]=pr end
  local mout={}; local function frame_member(xs,own) for _,x in ipairs(xs) do if own[x]==1 then return x end end end
  local function mat_mem(r)
    if mout[r] then return mout[r] end; local stack={}; local cur=r
    while cur and not mout[cur] do local a=manchor[cur]; if a and not owner.membrane[a] then mout[cur]=a; break end; local base=frame_member(members[cur],owner.membrane); if base then mout[cur]=base; break end; stack[#stack+1]=cur; cur=mparent[cur] end
    local p=cur and mout[cur] or nil; for i=#stack,1,-1 do local rr=stack[i]; local ex=members[rr][1]; local x=membrane(p,STATE[ex].name); mout[rr]=x; p=x end; return mout[r]
  end
  for _,r in ipairs(mclasses) do mat_mem(r) end

  local pclasses,pmembers={},{}; for _,p in ipairs(all.point) do local r=pd:find(p); if not pmembers[r] then pmembers[r]={}; pclasses[#pclasses+1]=r end; pmembers[r][#pmembers[r]+1]=p end
  local pout={}; for _,r in ipairs(pclasses) do local a=panchor[r]; if a and not owner.point[a] then pout[r]=a else local base=frame_member(pmembers[r],owner.point); if base then pout[r]=base else local ex=pmembers[r][1]; pout[r]=point(mout[md:find(place(ex))],STATE[ex].name) end end end
  local function pimage(p) return owner.point[p] and pout[pd:find(p)] or p end

  local sreps={}; for r in pairs(smeta) do sreps[#sreps+1]=r end
  local sout={}; for _,r in ipairs(sreps) do local x=smeta[r]; local p,c=x.producer,x.consumer; if not(p and c and group_of[p]==group_of[c] and cyclic[group_of[p]]) then local base=frame_member(x.members,owner.strand); if base then sout[r]=base else local ex=x.members[1]; local ps={}; for i,q in ipairs(points(ex)) do ps[i]=pimage(q) end; sout[r]=strand(mout[md:find(place(ex))],ps,STATE[ex].name) end end end
  local function simage(s) return sout[sd:find(s)] end

  local fout={}; for gi,grp in ipairs(groups) do
    if cyclic[gi] then
      local locs={}; for _,f in ipairs(grp) do locs[#locs+1]=md:find(place(f)) end; local joint=lca_mem(locs,mparent)
      local ins,outs_,si,so={},{},{},{}; local function add(xs,seen,x) if x and not seen[x] then seen[x]=true; xs[#xs+1]=x end end
      for _,f in ipairs(grp) do for _,s in ipairs(inputs(f)) do add(ins,si,simage(s)) end; for _,s in ipairs(outputs(f)) do add(outs_,so,simage(s)) end end
      local jf=face(mout[joint],ins,outs_,'joint'); for _,f in ipairs(grp) do fout[f]=jf end
    else
      local f=grp[1]; local can_reuse=owner.face[f]==1 and mout[md:find(place(f))]==place(f); if can_reuse then for _,s in ipairs(inputs(f)) do if simage(s)~=s then can_reuse=false; break end end end; if can_reuse then for _,s in ipairs(outputs(f)) do if simage(s)~=s then can_reuse=false; break end end end
      if can_reuse then fout[f]=f else local ins,outs_={},{}; for i,s in ipairs(inputs(f)) do ins[i]=simage(s) end; for i,s in ipairs(outputs(f)) do outs_[i]=simage(s) end; fout[f]=face(mout[md:find(place(f))],ins,outs_,STATE[f].name) end
    end
  end

  local rms,rps,rss,rfs={},{},{},{}; local seenm,seenp,seens,seenf={},{},{},{}
  local function addm(m) if not m or seenm[m] then return end; local path_={}; while m and not seenm[m] do path_[#path_+1]=m; m=parent(m) end; for i=#path_,1,-1 do local x=path_[i]; seenm[x]=true; rms[#rms+1]=x end end
  for _,r in ipairs(mclasses) do addm(mout[r]) end
  for _,r in ipairs(pclasses) do local p=pout[r]; if owner.point[p] or panchor[r]==nil then if not seenp[p] then seenp[p]=true; rps[#rps+1]=p; addm(place(p)) end end end
  for _,r in ipairs(sreps) do local s=sout[r]; if s and not seens[s] then seens[s]=true; rss[#rss+1]=s; addm(place(s)) end end
  for _,f in ipairs(all.face) do local x=fout[f]; if x and not seenf[x] then seenf[x]=true; rfs[#rfs+1]=x; addm(place(x)) end end
  local geom=finish_arrays(rms,rps,rss,rfs,false); local image={}
  for _,m in ipairs(all.membrane) do image[m]=mout[md:find(m)] end; for _,p in ipairs(all.point) do image[p]=pout[pd:find(p)] end; for _,s in ipairs(all.strand) do image[s]=simage(s) end; for _,f in ipairs(all.face) do image[f]=fout[f] end
  return geom,image
end

-- Operational evolution returns immediately to the boundary fixed point.
-- This is definitionally boundary(join({boundary(world), development}, equations));
-- it is a convenience for the slim runtime, not a second composition algorithm.
function W.advance(world,development,equations)
  local joined,image=W.join({W.boundary(world),development},equations)
  return W.boundary(joined),image
end

PRIVATE.parent=parent
PRIVATE.place=place
PRIVATE.points=points
PRIVATE.depth=depth
PRIVATE.geometry=function(g) return expect(g,'Geometry') end

return {public=W,private=PRIVATE}
