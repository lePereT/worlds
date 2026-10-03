-- Worlds 0.6.4 verified centre -- exact Geometry, boundary and join.
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
local Persistent=require('worlds._persistent')
local EMPTY={}
local function immutable() error('Worlds values are immutable',2) end
local CarrierMT={__newindex=immutable,__metatable='Worlds carrier'}
local GeometryMT={__newindex=immutable,__metatable='Worlds Geometry'}; GeometryMT.__index=GeometryMT
local IMAGE_STATE=setmetatable({}, {__mode='k'})
local ImageMT={__newindex=immutable,__metatable='Worlds construction image'}
local finish_arrays

local function new(kind,data,mt) local x=setmetatable({},mt or CarrierMT); data.kind=kind; STATE[x]=data; return x end
local function expect(x,kind) local s=STATE[x]; assert(s and s.kind==kind,'expected Worlds '..kind); return s end
local function dsu()
  -- Untouched carriers are implicit singleton classes.  State is allocated only
  -- when an equation actually joins two classes.
  local p,rank={},{}
  local X={}
  function X:find(x)
    local q=p[x]; if not q then return x end
    while q~=p[q] do p[q]=p[p[q]]; q=p[q] end
    local r=q; q=x
    while p[q] and p[q]~=r do local n=p[q]; p[q]=r; q=n end
    return r
  end
  function X:union(a,b)
    a,b=self:find(a),self:find(b); if a==b then return a end
    if not p[a] then p[a]=a; rank[a]=0 end
    if not p[b] then p[b]=b; rank[b]=0 end
    if rank[a]<rank[b] then a,b=b,a end
    p[b]=a; if rank[a]==rank[b] then rank[a]=rank[a]+1 end
    return a
  end
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
function W.points(s) return expect(s,'Strand').points end
function W.inputs(f) return expect(f,'Face').inputs end
function W.outputs(f) return expect(f,'Face').outputs end
function W.is_geometry(x) local s=STATE[x]; return not not(s and s.kind=='Geometry') end

local function image_domain_has(st,x)
  local xs=STATE[x]; if not xs then return false end
  local field=xs.kind=='Membrane' and 'mset' or xs.kind=='Point' and 'pset' or xs.kind=='Strand' and 'sset' or xs.kind=='Face' and 'fset'
  if not field then return false end
  for _,g in ipairs(st.parts) do if STATE[g][field][x] then return true end end
  return false
end
ImageMT.__index=function(self,x)
  local st=IMAGE_STATE[self]; if not st then return nil end
  if st.full then return st.full[x] end
  local y=st.changed[x]; if y~=nil then return y end
  if st.consumed[x] then return nil end
  if image_domain_has(st,x) then return x end
  return nil
end
local function image_value(parts,changed,consumed,full)
  local x=setmetatable({},ImageMT); IMAGE_STATE[x]={parts=parts,changed=changed or {},consumed=consumed or {},full=full}; return x
end
function W.is_image(x) return not not IMAGE_STATE[x] end

local function builder(trusted)
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
    live(); ps=ps or {}
    if not trusted then
      assert(mset[m],'Strand membrane must belong to Geometry'); DENSE.length(ps,'Strand points')
      for _,p in ipairs(ps) do local x=STATE[p]; assert(x and x.kind=='Point','Strand incidence expects Point') end
    end
    local x=strand(m,ps,name); strands_[#strands_+1]=x; sset[x]=true; return x
  end
  function methods:face(m,ins,outs,name)
    live(); ins,outs=ins or {},outs or {}
    if not trusted then
      assert(mset[m],'Face membrane must belong to Geometry'); DENSE.length(ins,'Face inputs'); DENSE.length(outs,'Face outputs')
      for _,s in ipairs(ins) do assert(sset[s],'Face input must belong to Geometry') end
      for _,s in ipairs(outs) do assert(sset[s],'Face output must belong to Geometry') end
    end
    local x=face(m,ins,outs,name); faces_[#faces_+1]=x; return x
  end
  function methods:finish()
    live(); finished=true
    return finish_arrays(membranes,points_,strands_,faces_,true)
  end
  return setmetatable({}, {__index=methods,__newindex=immutable,__metatable='Worlds builder'})
end
function W.builder() return builder(false) end

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

-- Geometry validation is shared by Builder and join.  The private soft path is
-- used only by the Question engine to reject an exact candidate before yes(E).
local function index_geometry(b,validate,soft)
  local function fail(msg)
    if soft then return nil,msg end
    error(msg,3)
  end
  local producer,consumer={},{}
  for _,f in ipairs(b.faces) do
    local seen=validate and {} or nil
    for _,s in ipairs(inputs(f)) do
      if validate then
        if seen[s] then return fail('Face consumes Strand twice') end
        if consumer[s] then return fail('Strand has >1 consumer') end
        seen[s]=true
      end
      consumer[s]=f
    end
    seen=validate and {} or nil
    for _,s in ipairs(outputs(f)) do
      if validate then
        if seen[s] then return fail('Face produces Strand twice') end
        if producer[s] then return fail('Strand has >1 producer') end
        seen[s]=true
      end
      producer[s]=f
    end
  end
  local order
  if validate then
    local out,indeg={},{}; for _,f in ipairs(b.faces) do out[f]={}; indeg[f]=0 end
    for _,s in ipairs(b.strands) do local p,c=producer[s],consumer[s]; if p and c then out[p][#out[p]+1]=c; indeg[c]=indeg[c]+1 end end
    local q={}; for _,f in ipairs(b.faces) do if indeg[f]==0 then q[#q+1]=f end end
    local qi=1; order={}
    while qi<=#q do local f=q[qi]; qi=qi+1; order[#order+1]=f; for _,g in ipairs(out[f]) do indeg[g]=indeg[g]-1; if indeg[g]==0 then q[#q+1]=g end end end
    if #order~=#b.faces then return fail('causal Face/Strand incidence must be acyclic') end
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
        if known[m] then
          if not available[m] then return fail('existing locality used without causal input incidence') end
        else
          local p=parent(m); if not(p and usable[p]) then return fail('fresh locality must descend from causally available locality') end
        end
        usable[m]=true
      end
      for _,p in ipairs(pts) do
        if known[p] then
          if not available[p] then return fail('existing Point used without causal input incidence') end
        elseif not usable[place(p)] then return fail('fresh Point must inhabit causally available/fresh locality') end
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
  for _,x in Persistent.iter(s.egress) do
    keep_membrane(place(x))
    for _,p in ipairs(points(x)) do
      if s.pset[p] and not keepp[p] then keepp[p]=true; keep_membrane(place(p)) end
    end
  end
  return keepm,keepp
end
local function is_boundary_normal(s)
  if #s.faces~=0 or Persistent.length(s.egress)~=Persistent.length(s.strands) then return false end
  local keepm,keepp=boundary_closure(s)
  for _,m in Persistent.iter(s.membranes) do if not keepm[m] then return false end end
  for _,p in Persistent.iter(s.points) do if not keepp[p] then return false end end
  return true
end

finish_arrays=function(membranes,points_,strands_,faces_,validate,soft)
  local b={membranes=membranes,points=points_,strands=strands_,faces=faces_,mset={},pset={},sset={},fset={}}
  for _,x in ipairs(membranes) do b.mset[x]=true end; for _,x in ipairs(points_) do b.pset[x]=true end; for _,x in ipairs(strands_) do b.sset[x]=true end; for _,x in ipairs(faces_) do b.fset[x]=true end
  local idx,why=index_geometry(b,validate,soft)
  if not idx then return nil,why end
  local data={membranes=membranes,points=points_,strands=strands_,faces=faces_,mset=b.mset,pset=b.pset,sset=b.sset,fset=b.fset,producer=idx.producer,consumer=idx.consumer,ingress=idx.ingress,egress=idx.egress,developable=idx.developable,boundary={},single_face_candidate=(#points_==0 and #membranes==1 and #faces_==1)}
  local g=new('Geometry',data,GeometryMT)
  data.boundary_normal=is_boundary_normal(data)
  return g
end
function GeometryMT:membranes() return Persistent.array(STATE[self].membranes) end
function GeometryMT:points() return Persistent.array(STATE[self].points) end
function GeometryMT:strands() return Persistent.array(STATE[self].strands) end
function GeometryMT:faces() return Persistent.array(STATE[self].faces) end
function GeometryMT:ingress() return Persistent.array(STATE[self].ingress) end
function GeometryMT:egress() return Persistent.array(STATE[self].egress) end
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
  for _,m in Persistent.iter(s.membranes) do if keepm[m] then membranes[#membranes+1]=m; mset[m]=true end end
  for _,p in Persistent.iter(s.points) do if keepp[p] then points_[#points_+1]=p; pset[p]=true end end
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

local function prepare_join(parts,equations,soft,trusted_arrays)
  local nparts=trusted_arrays and #parts or DENSE.length(parts,'join parts'); assert(nparts>0,'join expects Geometry parts'); equations=equations or {}; if not trusted_arrays then DENSE.length(equations,'join equations') end
  local owner={membrane={},point={},strand={},face={}}; local all={membrane={},point={},strand={},face={}}; local partstate={}
  for pi,g in ipairs(parts) do
    local st=expect(g,'Geometry'); partstate[pi]=st
    for _,m in Persistent.iter(st.membranes) do assert(not owner.membrane[m],'Geometry parts must be disjoint'); owner.membrane[m]=pi; all.membrane[#all.membrane+1]=m end
    for _,p in Persistent.iter(st.points) do assert(not owner.point[p],'Geometry parts must be disjoint'); owner.point[p]=pi; all.point[#all.point+1]=p end
    for _,s in Persistent.iter(st.strands) do assert(not owner.strand[s],'Geometry parts must be disjoint'); owner.strand[s]=pi; all.strand[#all.strand+1]=s end
    for _,f in ipairs(st.faces) do assert(not owner.face[f],'Geometry parts must be disjoint'); owner.face[f]=pi; all.face[#all.face+1]=f end
  end
  local md,pd,sd=dsu(),dsu(),dsu(); local manchor,panchor={},{}
  local function reject(msg) if soft then return nil,msg end; error(msg,3) end
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
    local so,to=owner.strand[source],owner.strand[target]
    if not(so and to) then return nil,'equation endpoints must belong to joined Geometry' end
    if source==target then return nil,'boundary equation joins distinct open occurrences' end
    if partstate[so].consumer[source]~=nil then return nil,'from must be open egress' end
    if partstate[to].producer[target]~=nil then return nil,'to must be open ingress' end
    sd:union(source,target); if not eq_mem(place(source),place(target)) then return nil,'inconsistent boundary equation' end
    local a,b=points(source),points(target); if #a~=#b then return nil,'inconsistent boundary equation' end
    for i=1,#a do if owner.point[b[i]] then if not eq_point(a[i],b[i]) then return nil,'inconsistent boundary equation' end elseif a[i]~=b[i] then return nil,'inconsistent boundary equation' end end
    return true
  end
  local from_seen,to_seen={},{}
  for _,e in ipairs(equations) do
    local from,to=e.from or e[1],e.to or e[2]
    if from_seen[from] then return reject('open authority is scarce') end
    if to_seen[to] then return reject('open requirement closes once') end
    from_seen[from]=true; to_seen[to]=true
    local ok,why=eq_strand(from,to); if not ok then return reject(why) end
  end
  return {owner=owner,all=all,partstate=partstate,md=md,pd=pd,sd=sd,manchor=manchor,panchor=panchor}
end

local function do_join(parts,equations,soft,trusted_arrays)
  local prepared,why=prepare_join(parts,equations,soft,trusted_arrays)
  if not prepared then return nil,why end
  local owner,all,partstate=prepared.owner,prepared.all,prepared.partstate
  local md,pd,sd=prepared.md,prepared.pd,prepared.sd
  local manchor,panchor=prepared.manchor,prepared.panchor
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
  local sout={}; for _,r in ipairs(sreps) do local x=smeta[r]; local p,c=x.producer,x.consumer; if not(p and c and group_of[p]==group_of[c] and cyclic[group_of[p]]) then
    local base=frame_member(x.members,owner.strand); local can_reuse=base~=nil
    if can_reuse and mout[md:find(place(base))]~=place(base) then can_reuse=false end
    if can_reuse then for _,q in ipairs(points(base)) do if pimage(q)~=q then can_reuse=false; break end end end
    if can_reuse then sout[r]=base else local ex=x.members[1]; local ps={}; for i,q in ipairs(points(ex)) do ps[i]=pimage(q) end; sout[r]=strand(mout[md:find(place(ex))],ps,STATE[ex].name) end
  end end
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
  local geom,why=finish_arrays(rms,rps,rss,rfs,true,soft)
  if not geom then return nil,why end
  -- Small joins are cheaper with an explicit image table.  Large/frame-local
  -- joins retain the sparse identity-by-default image so unchanged authority
  -- does not become O(frame) retained state.
  local carrier_count=#all.membrane+#all.point+#all.strand+#all.face
  if carrier_count<=4096 then
    local full={}
    for _,m in ipairs(all.membrane) do full[m]=mout[md:find(m)] end
    for _,p in ipairs(all.point) do full[p]=pout[pd:find(p)] end
    for _,s in ipairs(all.strand) do full[s]=simage(s) end
    for _,f in ipairs(all.face) do full[f]=fout[f] end
    return geom,image_value(parts,nil,nil,full)
  end
  local changed,consumed={},{}
  local function note(x,y) if y==nil then consumed[x]=true elseif y~=x then changed[x]=y end end
  for _,m in ipairs(all.membrane) do note(m,mout[md:find(m)]) end
  for _,p in ipairs(all.point) do note(p,pout[pd:find(p)]) end
  for _,s in ipairs(all.strand) do note(s,simage(s)) end
  for _,f in ipairs(all.face) do note(f,fout[f]) end
  return geom,image_value(parts,changed,consumed)
end

local function identity_join(parts,equations,trusted_arrays)
  equations=equations or {}
  local nparts=trusted_arrays and #parts or DENSE.length(parts,'join parts')
  local nequations=trusted_arrays and #equations or DENSE.length(equations,'join equations')
  if nparts==1 and nequations==0 then
    local g=parts[1]; expect(g,'Geometry'); return g,image_value(parts)
  end
end

function W.join(parts,equations)
  local g,image=identity_join(parts,equations,false); if g then return g,image end
  return do_join(parts,equations,false,false)
end

-- Private judgement support: test one already-enumerated exact candidate against
-- the same quotient construction and Geometry laws as public join.  This is not
-- a third public semantic operation; the Question judgement uses it before exposing yes(E).
PRIVATE.try_join=function(parts,equations)
  local g,image=identity_join(parts,equations,true); if g then return g,image end
  return do_join(parts,equations,true,true)
end

-- Match against a live boundary has a strong frame law: unrelated open authority
-- cannot be changed by a directional source->development equation.  Quotient the
-- touched source closure with the development, then splice that exact local
-- result back beside the untouched frame.  Generic join remains the reference
-- path and is used whenever the locality preconditions below are not evident.
local function boundary_subset(frame,sources)
  local fs=expect(frame,'Geometry'); local membranes,points_,strands_={},{},{}; local mset,pset,sset={},{},{}
  local function addm(m)
    if not(m and fs.mset[m]) or mset[m] then return end
    addm(parent(m)); mset[m]=true; membranes[#membranes+1]=m
  end
  for _,s in ipairs(sources) do if not sset[s] then
    sset[s]=true; strands_[#strands_+1]=s; addm(place(s))
    for _,p in ipairs(points(s)) do if fs.pset[p] and not pset[p] then pset[p]=true; points_[#points_+1]=p; addm(place(p)) end end
  end end
  local data={membranes=membranes,points=points_,strands=strands_,faces=EMPTY,mset=mset,pset=pset,sset=sset,fset=EMPTY,producer=EMPTY,consumer=EMPTY,ingress=strands_,egress=strands_,developable=true,boundary={},boundary_normal=true}
  return new('Geometry',data,GeometryMT),data
end

local function frame_match_join(source,target,equations,soft,source_position)
  local fs,ts=expect(source,'Geometry'),expect(target,'Geometry')
  if not fs.boundary_normal or Persistent.length(fs.strands)<64 or not source_position then return nil,'fallback' end
  -- Full parts must still be disjoint; checking the small development against
  -- frame membership is sufficient.
  for _,m in Persistent.iter(ts.membranes) do if fs.mset[m] then return nil,'fallback' end end
  for _,p in Persistent.iter(ts.points) do if fs.pset[p] then return nil,'fallback' end end
  for _,s in Persistent.iter(ts.strands) do if fs.sset[s] then return nil,'fallback' end end
  for _,f in ipairs(ts.faces) do if fs.fset[f] then return nil,'fallback' end end

  local sources,source_seen={},{ }
  for _,e in ipairs(equations or EMPTY) do
    local from,to=e.from or e[1],e.to or e[2]
    if not(fs.sset[from] and fs.consumer[from]==nil and ts.sset[to] and ts.producer[to]==nil) then return nil,'fallback' end
    if not source_seen[from] then source_seen[from]=true; sources[#sources+1]=from end
  end
  -- Decide locality before asking the disposable boundary index for ordinals.
  -- Broad matches therefore pay no frame-position work at all.  Positions are
  -- resolved only after the local quotient tells us which matched sources are
  -- actually consumed; pass-through matched authority remains live.
  if #sources>64 or #sources*4>Persistent.length(fs.strands) then return nil,'fallback' end
  local subset,ss=boundary_subset(source,sources)
  -- If the development mentions an exact frame Point outside the touched source
  -- closure, generic validation must see the whole frame to decide causal use.
  for _,s in Persistent.iter(ts.strands) do for _,p in ipairs(points(s)) do if fs.pset[p] and not ss.pset[p] then return nil,'fallback' end end end

  local local_result,local_image_or_why=do_join({subset,target},equations,soft,true)
  if not local_result then return nil,local_image_or_why end
  -- The frame quotient may only splice untouched authority when the quotient
  -- leaves every touched pre-existing structural coordinate exact-self.  If a
  -- source Membrane or Point is identified/consumed, untouched strands sharing
  -- that coordinate would also change and the local subset is insufficient.
  for _,m in ipairs(ss.membranes) do if local_image_or_why[m]~=m then return nil,'fallback' end end
  for _,p in ipairs(ss.points) do if local_image_or_why[p]~=p then return nil,'fallback' end end
  local ls=expect(local_result,'Geometry')
  local new_m,new_p,new_s={},{},{}
  for _,m in Persistent.iter(ls.membranes) do if not fs.mset[m] then new_m[#new_m+1]=m end end
  for _,p in Persistent.iter(ls.points) do if not fs.pset[p] then new_p[#new_p+1]=p end end
  for _,s in Persistent.iter(ls.strands) do if not fs.sset[s] then new_s[#new_s+1]=s end end

  -- The exact joined witness shares the unrelated frame.  Only genuinely new
  -- local carriers are appended; membership is a read-only overlay.
  local membranes=Persistent.sequence_concat(fs.membranes,new_m)
  local points_=Persistent.sequence_concat(fs.points,new_p)
  local strands_=Persistent.sequence_concat(fs.strands,new_s)
  local faces_=ls.faces
  local mset=Persistent.set_delta(fs.mset,{},new_m,membranes)
  local pset=Persistent.set_delta(fs.pset,{},new_p,points_)
  local sset=Persistent.set_delta(fs.sset,{},new_s,strands_)
  local fset=ls.fset

  -- A boundary-normal frame has every existing strand on ingress.  Local output
  -- contributes only newly produced ingress/egress; consumed frame egress is
  -- represented by an ordinal delta rather than a complete frontier rebuild.
  local new_ingress,added_e={},{}
  for _,s in ipairs(new_s) do
    if ls.producer[s]==nil then new_ingress[#new_ingress+1]=s end
    if ls.consumer[s]==nil then added_e[#added_e+1]=s end
  end
  local removed_e,removed_positions={},{}
  for _,s in ipairs(sources) do
    local mapped=local_image_or_why[s]
    if mapped==nil or ls.consumer[mapped]~=nil then
      removed_e[#removed_e+1]=s
      local pos=source_position(s); if not pos then return nil,'fallback' end
      removed_positions[#removed_positions+1]=pos
    end
  end
  table.sort(removed_positions)
  local ingress=Persistent.sequence_concat(fs.ingress,new_ingress)
  local egress=Persistent.sequence_delta(fs.egress,removed_positions,added_e)
  local data={membranes=membranes,points=points_,strands=strands_,faces=faces_,mset=mset,pset=pset,sset=sset,fset=fset,producer=ls.producer,consumer=ls.consumer,ingress=ingress,egress=egress,developable=ls.developable,boundary={},boundary_normal=false,frame_base=source,frame_removed_egress=removed_e,frame_added_egress=added_e,frame_new_membranes=new_m,frame_new_points=new_p}
  local result=new('Geometry',data,GeometryMT)

  local changed,consumed={},{}; local local_image=local_image_or_why
  local function note(x) local y=local_image[x]; if y==nil then consumed[x]=true elseif y~=x then changed[x]=y end end
  for _,m in ipairs(ss.membranes) do note(m) end; for _,p in ipairs(ss.points) do note(p) end; for _,s in ipairs(ss.strands) do note(s) end
  for _,m in Persistent.iter(ts.membranes) do note(m) end; for _,p in Persistent.iter(ts.points) do note(p) end; for _,s in Persistent.iter(ts.strands) do note(s) end; for _,f in ipairs(ts.faces) do note(f) end
  return result,image_value({source,target},changed,consumed)
end

-- Local-only frame join.  This is the same quotient used by Match, but it
-- deliberately preserves the 'fallback' result instead of broadening to a full
-- join.  Operational advance can therefore attempt locality without paying a
-- second whole-frame construction when the locality preconditions are absent.
PRIVATE.try_frame_join=function(source,target,equations,source_position)
  return frame_match_join(source,target,equations,true,source_position)
end

PRIVATE.try_match_join=function(source,target,equations,source_position)
  local g,image_or_why=PRIVATE.try_frame_join(source,target,equations,source_position)
  if g or image_or_why~='fallback' then return g,image_or_why end
  return do_join({source,target},equations,true,true)
end

-- A common live step is already in quotient-normal form except for one exact
-- Face: a boundary supplies its open inputs and the Face replaces them with new
-- open outputs.  When the development owns no Points and all output locality is
-- causally available through those inputs, the strict quotient is explicit.
-- Constructing it directly avoids building and then immediately discarding a
-- historical joined Geometry.  Every uncertain shape falls back to generic join.
local function single_face_delta(frame,target,ts,equations)
  local fs=expect(frame,'Geometry')
  if not fs.boundary_normal or Persistent.length(fs.points)~=0 then return nil,'fallback' end
  local tm,f=ts.membranes[1],ts.faces[1]
  if parent(tm)~=nil or place(f)~=tm then return nil,'fallback' end
  local ins,outs_=inputs(f),outputs(f)
  if #outs_==0 or #equations~=#ins or Persistent.length(ts.strands)~=#ins+#outs_ then return nil,'fallback' end

  local inset,outset,to_source,source_seen={},{},{},{}
  for _,x in ipairs(ins) do inset[x]=true; if ts.producer[x]~=nil or ts.consumer[x]~=f or place(x)~=tm then return nil,'fallback' end end
  for _,x in ipairs(outs_) do outset[x]=true; if ts.producer[x]~=f or ts.consumer[x]~=nil or place(x)~=tm then return nil,'fallback' end end
  for _,x in Persistent.iter(ts.strands) do if not inset[x] and not outset[x] then return nil,'fallback' end end

  local source_membrane,available_points
  available_points={}
  for _,e in ipairs(equations) do
    local from,to=e.from or e[1],e.to or e[2]
    if not(fs.sset[from] and fs.consumer[from]==nil and inset[to]) or source_seen[from] or to_source[to] then return nil,'fallback' end
    local a,b=points(from),points(to); if #a~=#b then return nil,'fallback' end
    for i=1,#a do if a[i]~=b[i] then return nil,'fallback' end end
    local m=place(from); if source_membrane and source_membrane~=m then return nil,'fallback' end; source_membrane=m
    source_seen[from]=true; to_source[to]=from
    for _,q in ipairs(a) do if fs.pset[q] then available_points[q]=true end end
  end
  if not source_membrane then return nil,'fallback' end
  for _,x in ipairs(ins) do if not to_source[x] then return nil,'fallback' end end
  for _,x in ipairs(outs_) do for _,q in ipairs(points(x)) do if fs.pset[q] and not available_points[q] then return nil,'fallback' end end end

  local changed,mapped_out={},{}
  changed[tm]=source_membrane
  local mapped_in={}; for i,x in ipairs(ins) do mapped_in[i]=to_source[x]; changed[x]=mapped_in[i] end
  for i,x in ipairs(outs_) do local y=strand(source_membrane,points(x),STATE[x].name); mapped_out[i]=y; changed[x]=y end
  changed[f]=face(source_membrane,mapped_in,mapped_out,STATE[f].name)

  local removed={}
  for x in pairs(source_seen) do removed[#removed+1]=x end
  return {removed=removed,added=mapped_out,image=image_value({frame,target},changed,{})}
end

local function single_face_advance(frame,target,ts,equations)
  local fs=expect(frame,'Geometry')
  local delta,why=single_face_delta(frame,target,ts,equations)
  if not delta then return nil,why end
  local removed={} for _,x in ipairs(delta.removed) do removed[x]=true end
  local strands_,sset={},{}
  for _,x in Persistent.iter(fs.egress) do if not removed[x] then strands_[#strands_+1]=x; sset[x]=true end end
  for _,x in ipairs(delta.added) do strands_[#strands_+1]=x; sset[x]=true end
  local data={membranes=fs.membranes,points=fs.points,strands=strands_,faces=EMPTY,mset=fs.mset,pset=fs.pset,sset=sset,fset=EMPTY,producer=EMPTY,consumer=EMPTY,ingress=strands_,egress=strands_,developable=true,boundary={},boundary_normal=true}
  return new('Geometry',data,GeometryMT),delta.image
end

-- Operational evolution returns immediately to the boundary fixed point.
-- This is definitionally boundary(join({boundary(world), development}, equations));
-- the single-Face path above is a mechanically specialised implementation of
-- that law; generic join remains the reference for every other shape.
function W.advance(world,development,equations)
  local frame=W.boundary(world); local ts=STATE[development]
  if ts and ts.kind=='Geometry' and ts.single_face_candidate then
    local nextw,image=single_face_advance(frame,development,ts,equations or EMPTY)
    if nextw then return nextw,image end
  end
  local joined,image=W.join({frame,development},equations)
  return W.boundary(joined),image
end

PRIVATE.parent=parent
PRIVATE.place=place
PRIVATE.points=points
PRIVATE.mint_point=function(m,name) expect(m,'Membrane'); return point(m,name) end
PRIVATE.single_face_delta=function(frame,target,equations) local ts=STATE[target]; if not(ts and ts.kind=='Geometry' and ts.single_face_candidate) then return nil,'fallback' end; return single_face_delta(frame,target,ts,equations or EMPTY) end
PRIVATE.development_builder=function() return builder(true) end
PRIVATE.depth=depth
PRIVATE.geometry=function(g) return expect(g,'Geometry') end
PRIVATE.make_boundary=function(data)
  data.faces=EMPTY; data.fset=EMPTY; data.producer=EMPTY; data.consumer=EMPTY
  data.ingress=data.strands; data.egress=data.strands; data.developable=true; data.boundary={}; data.boundary_normal=true
  return new('Geometry',data,GeometryMT)
end

return {public=W,private=PRIVATE}
