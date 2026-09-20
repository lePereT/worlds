-- Worlds Query -- finite questions over exact open Geometry.
--
-- This module is not part of the operational ontology.  A Question carries no
-- authority and is not programme state: it asks which exact boundary equations
-- satisfy a declarative matching judgement between two ambient Geometries.
--
-- Mathematical normal form:
--   Q = (A, B, S, T, R, C, E0)
--     A   source/world Geometry
--     B   target/development Geometry
--     S   selected exact egress(A)
--     T   selected exact ingress(B)
--     R   targets which must be matched
--     C   optional finite admissibility restriction, C subset S x T
--     E0  seeded equations
--
-- The execution engine below is disposable machinery implementing that
-- judgement.  The source Geometry is compiled to its exact outgoing section;
-- retained solve state therefore does not retain closed source history.

return function(W,K,Compiled)
assert(type(W)=='table' and type(W.join)=='function' and type(W.boundary)=='function','Worlds Query engine requires exact Worlds kernel')
K=K or require('worlds._kernel').private
Compiled=Compiled or require('worlds._compiled')(K)
local M={}
local EMPTY={}
local relation=require('worlds.query_relation')
local INGRESS=setmetatable({}, {__mode='k'})
local MCACHE=setmetatable({}, {__mode='k'})
local function immutable() error('Worlds Query solve state is immutable',2) end

local function array(xs) local r={} for i=1,#(xs or EMPTY) do r[i]=xs[i] end return r end
local function push(map,key,value) local xs=map[key]; if not xs then xs={}; map[key]=xs end; xs[#xs+1]=value end
local function trie(root,vals,create)
  local n=root
  for i=1,#vals do local v=vals[i]; local q=n[v]; if not q then if not create then return nil end; q={}; n[v]=q end; n=q end
  return n
end
local function dsu(items)
  local p,rank={},{}; for _,x in ipairs(items) do p[x]=x; rank[x]=0 end
  local X={}
  function X:find(x) local q=p[x]; while q~=p[q] do p[q]=p[p[q]]; q=p[q] end; local r=q; q=x; while p[q]~=r do local n=p[q]; p[q]=r; q=n end; return r end
  function X:union(a,b) a,b=self:find(a),self:find(b); if a==b then return a end; if rank[a]<rank[b] then a,b=b,a end; p[b]=a; if rank[a]==rank[b] then rank[a]=rank[a]+1 end; return a end
  return X
end
local place,points,parent,exact_depth=K.place,K.points,K.parent,K.depth

-- Query-local exact ancestry acceleration.  Parent identity belongs to Worlds;
-- depth/jump tables here are rebuildable caches and carry no semantic meaning.
local function mstate(m)
  local s=MCACHE[m]; if s then return s end
  s={depth=exact_depth(m),jumps={}}; MCACHE[m]=s; return s
end
local function depth(m) return exact_depth(m) end
local function jump(m,k,work)
  local s=mstate(m); local v=s.jumps[k]
  if v~=nil then return v~=false and v or nil end
  work()
  if k==1 then v=parent(m) else local h=jump(m,k-1,work); v=h and jump(h,k-1,work) or nil end
  s.jumps[k]=v or false; return v
end
local function ancestor(m,up,work)
  local k=1
  while up>0 do if up%2==1 then m=jump(m,k,work); if not m then return nil end end; up=math.floor(up/2); k=k+1 end
  return m
end
local function lca(a,b,work)
  local da,db=depth(a),depth(b)
  if da>db then a=ancestor(a,da-db,work); da=db elseif db>da then b=ancestor(b,db-da,work); db=da end
  if not a or not b or a==b then return a==b and a or nil end
  local span,k=1,1; while span*2<=da-1 do span=span*2; k=k+1 end
  for i=k,1,-1 do local aa,bb=jump(a,i,work),jump(b,i,work); if aa and bb and aa~=bb then a,b=aa,bb end end
  return jump(a,1,work)
end

local function context(g)
  local c=Compiled.view(g)
  assert(c,'Worlds Query requires Geometry compiled by this kernel')
  return c
end

-- Exact outgoing section: structural incidence rows with scarce exact fibres.
local function counted_surface(strands)
  local relations,groups,of,position={},{},{},{}
  for si,s in ipairs(strands) do
    position[s]=si; local ps=points(s); local ar=#ps; local rel=relations[ar]
    if not rel then rel={rows={},by={}}; for i=2,ar+1 do rel.by[i]={} end; relations[ar]=rel; groups[ar]={} end
    local coords={place(s)}; for i,p in ipairs(ps) do coords[i+1]=p end
    local n=groups[ar]
    for i=1,#coords do local v=coords[i]; local q=n[v]; if not q then q={}; n[v]=q end; n=q end
    local g=n.group
    if not g then g={coords=coords,occurrences={}}; n.group=g; rel.rows[#rel.rows+1]=g; for i=2,#coords do push(rel.by[i],coords[i],g) end end
    g.occurrences[#g.occurrences+1]=s; of[s]=g
  end
  return {relations=relations,of=of,position=position}
end
local function full_surface(g)
  return assert(Compiled.surface(g),'missing compiled outgoing Geometry section')
end

-- Development ingress quotient ------------------------------------------------
local function ingress_section(b,ingress,work)
  local items,arrivals,point_nodes,events={},{},{},{}
  local node_demand={}; local nodes=0
  local function add_event(m,xs) if #xs>1 then push(events,m,xs) end end
  for di,d in ipairs(ingress) do
    work(); local item={strand=d,arity=#points(d),rigid={},pchecks={},mgroups={},endpoints={}}
    local point_first,thread_at={},{}
    local function endpoint(coord,m)
      local x=thread_at[m]
      if not x then nodes=nodes+1; x=nodes; thread_at[m]=x; node_demand[x]=di; push(arrivals,m,x) end
      item.endpoints[#item.endpoints+1]={coord=coord,m=m,node=x}; return x
    end
    endpoint(1,place(d))
    for i,p in ipairs(points(d)) do
      work(); local coord=i+1
      if b.pset[p] then
        local old=point_first[p]
        if old then item.pchecks[#item.pchecks+1]={old.coord,coord}
        else local n=endpoint(coord,place(p)); point_first[p]={coord=coord,node=n}; push(point_nodes,p,{node=n,coord=coord}) end
      else item.rigid[coord]=p end
    end
    local grouped,order={},{}
    local function add(m,e)
      local g=grouped[m]
      if not g then g={terms={},termseen={},nodes={},nodeseen={}}; grouped[m]=g; order[#order+1]={m=m,g=g} end
      local up=depth(e.m)-depth(m); local by=g.termseen[e.coord]
      if not by then by={}; g.termseen[e.coord]=by end
      if not by[up] then by[up]=true; g.terms[#g.terms+1]={coord=e.coord,up=up} end
      if not g.nodeseen[e.node] then g.nodeseen[e.node]=true; g.nodes[#g.nodes+1]=e.node end
    end
    for i=1,#item.endpoints do for j=i+1,#item.endpoints do local a,c=item.endpoints[i],item.endpoints[j]; local m=lca(a.m,c.m,work); if m then add(m,a); add(m,c) end end end
    for _,x in ipairs(order) do if #x.g.terms>1 then item.mgroups[#item.mgroups+1]=x.g.terms; add_event(x.m,x.g.nodes) end end
    for _,e in ipairs(item.endpoints) do local up=depth(e.m)-1; if up>0 then item.exists=item.exists or {}; item.exists[#item.exists+1]={coord=e.coord,up=up} end end
    items[di]=item
  end
  local ids={}; for i=1,nodes do ids[i]=i end
  local eq=dsu(ids); local label={}; for i=1,nodes do label[i]=node_demand[i] end
  local function unite(a,bn) local ra,rb=eq:find(a),eq:find(bn); if ra==rb then return ra end; local la,lb=label[ra],label[rb]; local r=eq:union(ra,rb); label[ra]=nil; label[rb]=nil; label[r]=(la==lb) and la or false; return r end
  local function unite_all(xs) local r=xs[1]; for i=2,#xs do r=unite(r,xs[i]) end; return r end
  local point_outputs={}
  for p,xs in pairs(point_nodes) do
    local firstd,multi=nil,false
    for _,x in ipairs(xs) do local d=node_demand[x.node]; if firstd and firstd~=d then multi=true; break end; firstd=firstd or d end
    if multi then
      local ns={}; for _,x in ipairs(xs) do ns[#ns+1]=x.node end; add_event(place(p),ns)
      for _,x in ipairs(xs) do local di=node_demand[x.node]; local o=point_outputs[di]; if not o then o={}; point_outputs[di]=o end; o[p]={point=true,coord=x.coord} end
    end
  end
  local mboundary={}
  for i=#b.membranes,1,-1 do
    local m=b.membranes[i]
    for _,xs in ipairs(events[m] or EMPTY) do work(); unite_all(xs) end
    local roots,seen={},{}; for _,x in ipairs(arrivals[m] or EMPTY) do local r=eq:find(x); if not seen[r] then seen[r]=true; roots[#roots+1]=r end end
    if #roots>0 then
      local first,multiple=nil,false
      for _,r in ipairs(roots) do local d=label[eq:find(r)]; if d==false or (first and first~=d) then multiple=true; break end; first=first or d end
      if multiple and #roots>1 then mboundary[m]=true; roots={eq:find(unite_all(roots))} end
      local p=parent(m); if p and b.mset[p] then for _,r in ipairs(roots) do push(arrivals,p,r) end end
    end
  end
  local nearest,bparent={},{}
  for _,m in ipairs(b.membranes) do local p=parent(m); nearest[m]=mboundary[m] and m or (p and nearest[p] or nil); if mboundary[m] then bparent[m]=p and nearest[p] or nil end end
  local rank,n={},0; for _,m in ipairs(b.membranes) do n=n+1; rank[m]=n end; for _,p in ipairs(b.points) do n=n+1; rank[p]=n end
  for di,item in ipairs(items) do
    local outmap=point_outputs[di] or {}; local seenm={}
    for _,e in ipairs(item.endpoints) do local m=nearest[e.m]; while m do if not seenm[m] then seenm[m]=true; outmap[m]={coord=e.coord,up=depth(e.m)-depth(m)} end; m=bparent[m] end end
    local vars={}; for v in pairs(outmap) do vars[#vars+1]=v end; table.sort(vars,function(a,c) return rank[a]<rank[c] end)
    item.vars=vars; item.pos={}; item.out={}; for i,v in ipairs(vars) do item.pos[v]=i; item.out[i]=outmap[v] end
  end
  local function key(d)
    local k={d.arity}; for i=2,d.arity+1 do local r=d.rigid[i]; k[#k+1]=r and 'r' or '-'; if r then k[#k+1]=r end end
    k[#k+1]='e'; for _,t in ipairs(d.exists or EMPTY) do k[#k+1]=t.coord; k[#k+1]=t.up end
    k[#k+1]='p'; for _,c in ipairs(d.pchecks) do k[#k+1]=c[1]; k[#k+1]=c[2] end
    k[#k+1]='m'; for _,g in ipairs(d.mgroups) do k[#k+1]='g'; k[#k+1]=#g; for _,t in ipairs(g) do k[#k+1]=t.coord; k[#k+1]=t.up end end
    k[#k+1]='o'; for i,v in ipairs(d.vars) do local t=d.out[i]; k[#k+1]=v; k[#k+1]=t.point and 'p' or 'm'; k[#k+1]=t.coord; if not t.point then k[#k+1]=t.up end end
    return k
  end
  local atoms,root={},{}
  for _,item in ipairs(items) do local demand=item.strand; item.strand=nil; item.endpoints=nil; local slot=trie(root,key(item),true); if not slot.atom then slot.atom={desc=item,demands={}}; atoms[#atoms+1]=slot.atom end; slot.atom.demands[#slot.atom.demands+1]=demand end
  return {atoms=atoms}
end

-- Matching engine -----------------------------------------------------------
local function candidate_groups(surface,desc,exact,work)
  if exact then local g=surface.of[exact]; return g and #g.coords==desc.arity+1 and {g} or {} end
  local rel=surface.relations[desc.arity]; if not rel then return {} end
  local best,checks=nil,{}
  for ci,r in pairs(desc.rigid) do checks[#checks+1]={ci,r}; local xs=rel.by[ci][r]; if not xs then return {} end; if not best or #xs<#best then best=xs end end
  if #checks==0 then return rel.rows end; if #checks==1 then return best end
  local out={}; for _,g in ipairs(best) do work(); local good=true; for _,c in ipairs(checks) do if g.coords[c[1]]~=c[2] then good=false; break end end; if good then out[#out+1]=g end end; return out
end
local function mem_value(coords,t,cache,work) local m=cache[t.coord]; if not m then m=t.coord==1 and coords[1] or place(coords[t.coord]); cache[t.coord]=m end; return ancestor(m,t.up,work) end
local function structural_values(desc,g,work)
  local coords=g.coords; local cache={}
  for _,t in ipairs(desc.exists or EMPTY) do if not mem_value(coords,t,cache,work) then return nil end end
  for _,c in ipairs(desc.pchecks) do work(); if coords[c[1]]~=coords[c[2]] then return nil end end
  for _,group in ipairs(desc.mgroups) do local first=mem_value(coords,group[1],cache,work); if not first then return nil end; for i=2,#group do work(); local v=mem_value(coords,group[i],cache,work); if not v or v~=first then return nil end end end
  local vals={}; for i,t in ipairs(desc.out) do local v=t.point and coords[t.coord] or mem_value(coords,t,cache,work); if not v then return nil end; vals[i]=v end; return vals
end
local function compile_relation(surface,desc,exact,work,allowed)
  local rows,root={},{}
  for _,g in ipairs(candidate_groups(surface,desc,exact,work)) do
    work(); local vals=structural_values(desc,g,work)
    if vals then
      local occurrences={}
      if exact then if not allowed or allowed[exact] then occurrences[1]=exact end
      else for _,o in ipairs(g.occurrences) do if not allowed or allowed[o] then occurrences[#occurrences+1]=o end end end
      if #occurrences>0 then local slot=trie(root,vals,true); local row=slot.row; if not row then row={values=vals,occurrences={}}; slot.row=row; rows[#rows+1]=row end; for _,o in ipairs(occurrences) do row.occurrences[#row.occurrences+1]=o end end
    end
  end
  return {vars=desc.vars,pos=desc.pos,rows=rows}
end
local function conjunction(a,b) if not a then return b end; if not b then return a end; return {kind='and',children={a,b}} end
local function add_support(row,s) local a=row._supports; if not a then a={}; row._supports=a end; if s.kind=='or' then for _,x in ipairs(s.alts) do a[#a+1]=x end else a[#a+1]=s end end
local function freeze_supports(rows) for _,r in ipairs(rows) do local a=r._supports; if a then r._supports=nil; r.support=#a==1 and a[1] or {kind='or',alts=a} end end end
local function positions(vars) local p={}; for i,v in ipairs(vars) do p[v]=i end; return p end
local function put(rows,root,values,support) local x=trie(root,values,true); local r=x.row; if not r then r={values=values}; x.row=r; rows[#rows+1]=r end; add_support(r,support) end
local function shared(a,b) local r={}; for _,v in ipairs(a.vars) do if b.pos[v] then r[#r+1]=v end end; return r end
local function join_factors(a,b,work)
  local common=shared(a,b); local vars=array(a.vars); local have={}; for _,v in ipairs(vars) do have[v]=true end; for _,v in ipairs(b.vars) do if not have[v] then have[v]=true; vars[#vars+1]=v end end
  local small,large=a,b; if #small.rows>#large.rows then small,large=large,small end
  local idx={}; for _,r in ipairs(small.rows) do work(); local key={}; for i,v in ipairs(common) do key[i]=r.values[small.pos[v]] end; local x=trie(idx,key,true); x.rows=x.rows or {}; x.rows[#x.rows+1]=r end
  local rows,root={},{}
  for _,lr in ipairs(large.rows) do work(); local key={}; for i,v in ipairs(common) do key[i]=lr.values[large.pos[v]] end; local x=trie(idx,key,false); for _,sr in ipairs(x and x.rows or EMPTY) do work(); local vals={}; for i,v in ipairs(vars) do local p=large.pos[v]; vals[i]=p and lr.values[p] or sr.values[small.pos[v]] end; put(rows,root,vals,conjunction(lr.support,sr.support)) end end
  freeze_supports(rows); return {vars=vars,pos=positions(vars),rows=rows}
end
local function project(f,var,work)
  local vars={}; for _,v in ipairs(f.vars) do if v~=var then vars[#vars+1]=v end end
  local rows,root={},{}; for _,r in ipairs(f.rows) do work(); local vals={}; for i,v in ipairs(vars) do vals[i]=r.values[f.pos[v]] end; put(rows,root,vals,r.support) end
  freeze_supports(rows); return {vars=vars,pos=positions(vars),rows=rows}
end
local function choose_variable(factors,work)
  local inc={}; for i,f in ipairs(factors) do for _,v in ipairs(f.vars) do work(); local x=inc[v]; if not x then x={ids={},rows=0}; inc[v]=x end; x.ids[#x.ids+1]=i; x.rows=x.rows+#f.rows end end
  local best,bx
  for v,x in pairs(inc) do local boundary={}; for _,i in ipairs(x.ids) do for _,u in ipairs(factors[i].vars) do work(); if u~=v then boundary[u]=true end end end; local width=0; for _ in pairs(boundary) do width=width+1 end; x.width=width; if not bx or width<bx.width or (width==bx.width and x.rows<bx.rows) then best,bx=v,x end end
  return best,bx
end
local function common_count(a,b,work) local n=0; for _,v in ipairs(b.vars) do work(); if a.pos[v] then n=n+1 end end; return n end
local function factorise(atoms,work)
  local factors={}; for _,a in ipairs(atoms) do factors[#factors+1]=a.factor end; local roots={}
  while true do
    local var,info=choose_variable(factors,work); if not var then break end
    local chosen,selected={},{}; for _,i in ipairs(info.ids) do chosen[i]=true; selected[#selected+1]=factors[i] end; table.sort(selected,function(a,b) return #a.rows<#b.rows end)
    local f=table.remove(selected,1)
    while #selected>0 do local best,sharedn=1,-1; for i,x in ipairs(selected) do local n=common_count(f,x,work); if n>sharedn or (n==sharedn and #x.rows<#selected[best].rows) then best,sharedn=i,n end end; f=join_factors(f,table.remove(selected,best),work); if #f.rows==0 then return nil,{kind='empty-join',variable=var} end end
    f=project(f,var,work); if #f.rows==0 then return nil,{kind='empty-projection',variable=var} end
    local rest={}; for i,x in ipairs(factors) do if not chosen[i] then rest[#rest+1]=x end end; if #f.vars==0 then roots[#roots+1]=f else rest[#rest+1]=f end; factors=rest
  end
  for _,f in ipairs(factors) do roots[#roots+1]=f end
  local children={}; for _,f in ipairs(roots) do children[#children+1]=f.rows[1].support end
  if #children==0 then return {kind='and',children={}} elseif #children==1 then return children[1] else return {kind='and',children=children} end
end

local NO_EXACT={}
local function compile_query(surface,ps,target,targets,seeds,cache_full,work,allowed_by_to,admissible_all)
  local exact={}
  for _,e in ipairs(seeds) do work(); local from,to=e.from or e[1],e.to or e[2]; assert(ps.sset[to] and ps.producer[to]==nil and surface.of[from],'seed equation must connect Question source to target'); assert(admissible_all or (allowed_by_to[to] and allowed_by_to[to][from]),'seed equation is outside Question admissibility'); assert(not exact[to] or exact[to]==from,'inconsistent seed equations'); exact[to]=from end
  local section
  if cache_full then section=INGRESS[target]; if not section then section=ingress_section(ps,targets,work); INGRESS[target]=section end else section=ingress_section(ps,targets,work) end
  local atoms={}
  for _,class in ipairs(section.atoms) do
    local groups={}
    for _,d in ipairs(class.demands) do
      local key=(not admissible_all) and d or (exact[d] or NO_EXACT)
      local g=groups[key]; if not g then g={exact=exact[d],demands={},allowed=(not admissible_all) and (allowed_by_to[d] or {}) or nil}; groups[key]=g end; g.demands[#g.demands+1]=d
    end
    for _,g in pairs(groups) do
      work(); local rel=compile_relation(surface,class.desc,g.exact,work,g.allowed); if #rel.rows==0 then return nil,nil,nil,{kind='empty-base-relation',demand=g.demands[1]} end
      local atom={relation=rel,demands=g.demands,multiplicity=#g.demands}; local rows={}
      for _,r in ipairs(rel.rows) do work(); if #r.occurrences>=atom.multiplicity then r.support={kind='leaf',atom=atom,row=r}; rows[#rows+1]=r end end
      if #rows==0 then return nil,nil,nil,{kind='fibre-capacity',required=atom.multiplicity,demands=atom.demands} end
      atom.factor={vars=rel.vars,pos=rel.pos,rows=rows}; atoms[#atoms+1]=atom
    end
  end
  local root,no=factorise(atoms,work); if not root then return nil,nil,nil,no end
  return targets,atoms,root
end

local function solve_machine(st,initial_fuel)
  local fuel=initial_fuel or 0
  local function work(n) n=n or 1; while fuel<n do fuel=fuel+(coroutine.yield('more') or 0) end; fuel=fuel-n end
  local function emit(tag,value) fuel=coroutine.yield(tag,value) or 0 end
  local demands,atoms,root,no=compile_query(st.surface,st.pattern,st.target,st.targets,st.seeds,st.cache_full_targets,work,st.allowed_by_to,st.admissible_all); if no then return 'no',no end
  if #demands==0 then emit('yes',{}); return 'done',1 end
  local selected,trail={},{}
  local function add_leaf(a,r) if not selected[a] then selected[a]=r; trail[#trail+1]=a end end
  local function rollback(n) while #trail>n do local a=trail[#trail]; trail[#trail]=nil; selected[a]=nil end end
  local function pools() local p={}; for _,a in ipairs(atoms) do local r=selected[a]; for _,d in ipairs(a.demands) do p[d]=r.occurrences end end; return p end
  local hits=0
  local function allocate(pools_)
    local ok,proof=relation{targets=demands,pools=pools_,required_targets=demands,work=work,emit=function(ass)
      local es={}; for _,x in ipairs(demands) do es[#es+1]={from=ass[x],to=x} end
      hits=hits+1; emit('yes',es)
    end}
    return ok,proof
  end
  local pending={node=root}; local choices={}; local lastproof=nil
  local function backtrack() while #choices>0 do local c=choices[#choices]; rollback(c.trail); pending=c.pending; if c.next<=#c.node.alts then local x=c.node.alts[c.next]; c.next=c.next+1; pending={node=x,next=pending}; return true end; choices[#choices]=nil end; return false end
  while true do if not pending then local ok,proof=allocate(pools()); if not ok then lastproof=proof end; if not backtrack() then break end else local cell=pending; pending=cell.next; local node=cell.node; work(); if node.kind=='leaf' then add_leaf(node.atom,node.row) elseif node.kind=='and' then for i=#node.children,1,-1 do pending={node=node.children[i],next=pending} end else choices[#choices+1]={node=node,next=2,pending=pending,trail=#trail}; pending={node=node.alts[1],next=pending} end end end
  if hits>0 then return 'done',hits end; return 'no',lastproof or {kind='factor-support-exhausted'}
end

local solve_object
local function ordinary_solve(st)
  st.co=coroutine.create(function(fuel) return solve_machine(st,fuel) end)
  return solve_object(st)
end
local function subset_targets(st)
  local out={}; for _,d in ipairs(st.targets) do local ix=st.optional_index and st.optional_index[d] or nil; if st.mandatory[d] or (ix and st.bits[ix]) then out[#out+1]=d end end; return out
end
local function advance_subset(st)
  if #st.bits==0 then if st.started then return false end; st.started=true; return true end
  if not st.started then st.started=true; return true end
  for i=1,#st.bits do if not st.bits[i] then st.bits[i]=true; for j=1,i-1 do st.bits[j]=false end; return true end end
  return false
end
local function child_state(st,targets,seeds)
  return {surface=st.surface,pattern=st.pattern,target=st.target,targets=targets,seeds=seeds,cache_full_targets=false,allowed_by_to=st.allowed_by_to,admissible_all=st.admissible_all,done=false}
end
local function optional_step(self,st,fuel)
  local remaining=fuel
  while remaining>0 do
    if st.stage=='probe' then
      local d=st.targets[st.probe_index]
      if not d then st.bits={}; st.optional_index={}; for i,x in ipairs(st.optional) do st.bits[i]=false; st.optional_index[x]=i end; st.stage='enumerate'; st.sub=nil
      elseif st.mandatory[d] then st.probe_index=st.probe_index+1
      else
        if not st.sub then st.sub=ordinary_solve(child_state(st,{d},{})) end
        local tag=st.sub:step(1); remaining=remaining-1
        if tag=='yes' then st.optional[#st.optional+1]=d; st.sub=nil; st.probe_index=st.probe_index+1
        elseif tag=='no' or tag=='done' then st.sub=nil; st.probe_index=st.probe_index+1
        elseif tag~='more' then error('unexpected Question probe tag '..tostring(tag)) end
      end
    else
      if not st.sub then
        if not advance_subset(st) then st.done=true; if st.hits>0 then st.final_tag,st.final_value='done',st.hits else st.final_tag,st.final_value='no',st.last_no or {kind='question-support-exhausted'} end; return st.final_tag,st.final_value end
        st.sub=ordinary_solve(child_state(st,subset_targets(st),st.seeds))
      end
      local tag,value=st.sub:step(1); remaining=remaining-1
      if tag=='yes' then st.hits=st.hits+1; return tag,value end
      if tag=='no' then st.last_no=value; st.sub=nil elseif tag=='done' then st.sub=nil elseif tag~='more' then error('unexpected Question solve tag '..tostring(tag)) end
    end
  end
  return 'more',self
end
solve_object=function(st)
  local q
  local methods={}
  function methods:step(fuel)
    if st.done then return st.final_tag,st.final_value end
    fuel=fuel or 1000; if fuel<=0 then return 'more',q end
    if st.mode=='optional' then return optional_step(q,st,fuel) end
    local ok,tag,value=coroutine.resume(st.co,fuel); assert(ok,tag)
    if coroutine.status(st.co)=='dead' then st.done=true; st.final_tag,st.final_value=tag,value; return tag,value end
    return tag,value
  end
  q=setmetatable({}, {__index=methods,__newindex=immutable,__metatable='Worlds query state'})
  return q
end

-- Complete coverage uses the same machine with no finite-section policy.
-- Keeping this constructor here avoids rebuilding the general Question control
-- state on the W.solve hot path; compile_query/factorisation/allocation remain
-- exactly the same implementation.
function M.complete(source,target,seeds)
  local tc=context(target); assert(tc.developable,'Question target must be a development connected to open ingress')
  return ordinary_solve{surface=full_surface(source),pattern=tc,target=target,targets=tc.ingress,seeds=seeds or EMPTY,cache_full_targets=true,allowed_by_to=nil,admissible_all=true,done=false}
end

-- `spec` is the compiled mathematical Question supplied by worlds.query.
-- It contains no programme authority; this engine may be replaced wholesale.
function M.solve(spec)
  local tc=context(spec.target); assert(tc.developable,'Question target must be a development connected to open ingress')
  local surface=spec.full_sources and full_surface(spec.source) or counted_surface(spec.sources or EMPTY)
  local targets=spec.full_targets and tc.ingress or (spec.targets or EMPTY)
  if spec.required_all then
    return ordinary_solve{surface=surface,pattern=tc,target=spec.target,targets=targets,seeds=spec.seeds or EMPTY,cache_full_targets=spec.full_targets,allowed_by_to=spec.allowed_by_to,admissible_all=spec.admissible_all,done=false}
  end
  local required=spec.required_targets or EMPTY
  local mandatory={}; for _,d in ipairs(required) do mandatory[d]=true end; for _,e in ipairs(spec.seeds) do mandatory[e.to or e[2]]=true end
  local all_required=true; for _,d in ipairs(targets) do if not mandatory[d] then all_required=false; break end end
  local st={surface=surface,pattern=tc,target=spec.target,targets=targets,seeds=spec.seeds or EMPTY,cache_full_targets=spec.full_targets,allowed_by_to=spec.allowed_by_to,admissible_all=spec.admissible_all,mandatory=mandatory,done=false}
  if all_required then return ordinary_solve(st) end
  st.mode='optional'; st.stage='probe'; st.probe_index=1; st.optional={}; st.bits={}; st.optional_index={}; st.started=false; st.sub=nil; st.hits=0; st.last_no=nil
  return solve_object(st)
end

return M
end
