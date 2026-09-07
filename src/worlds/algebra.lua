-- Worlds 0.5.0 -- open-process algebra.
--
-- tensor(parts)       : juxtaposition, no interaction
-- close(parts, links) : simultaneous scarce boundary wiring + causal normal form
-- admissible(P, cut)  : causal-authority judgement for actual development
--
-- The implementation is intentionally phase-shaped so it mirrors the model.

local G=require('worlds.geometry')
local Cut=require('worlds.cut')
local M={}

local function union_find(items)
  local parent,rank={},{}; for _,x in ipairs(items) do parent[x]=x; rank[x]=0 end
  local function find(x) local p=parent[x]; assert(p,'unknown union-find item'); if p~=x then parent[x]=find(p) end; return parent[x] end
  local function union(a,b) a,b=find(a),find(b); if a==b then return a end; if rank[a]<rank[b] then a,b=b,a end; parent[b]=a; if rank[a]==rank[b] then rank[a]=rank[a]+1 end; return a end
  return find,union
end

local function index_parts(parts)
  local owner={membrane={},point={},strand={},face={}}
  for i,g in ipairs(parts) do
    assert(G.is_geometry(g),'Algebra part must be Geometry')
    for _,x in ipairs(g:membranes()) do assert(not owner.membrane[x]); owner.membrane[x]=i end
    for _,x in ipairs(g:points()) do assert(not owner.point[x]); owner.point[x]=i end
    for _,x in ipairs(g:strands()) do assert(not owner.strand[x]); owner.strand[x]=i end
    for _,x in ipairs(g:faces()) do assert(not owner.face[x]); owner.face[x]=i end
  end
  return owner
end

local function normalise_links(parts,links,owner)
  local out,used_from,used_to={}, {}, {}
  for _,e in ipairs(links or {}) do
    local from=e.from or e.left or e[1]; local to=e.to or e.right or e[2]
    assert(G.is_strand(from) and G.is_strand(to),'close link requires two Strands')
    assert(from~=to,'close link endpoints must be distinct Strand occurrences')
    local fi,ti=owner.strand[from],owner.strand[to]; assert(fi and ti,'close link endpoints must belong to supplied parts')
    assert(parts[fi]:is_terminal(from),'close source must be terminal'); assert(parts[ti]:is_input(to),'close target must be ingress')
    assert(not used_from[from],'terminal cut source is scarce'); assert(not used_to[to],'ingress may be closed only once')
    used_from[from]=true; used_to[to]=true; out[#out+1]={from=from,to=to,from_part=fi,to_part=ti}
  end
  return out
end

local function scc(faces,edges)
  local adj={}; for _,f in ipairs(faces) do adj[f]={} end
  for _,e in ipairs(edges) do adj[e[1]][#adj[e[1]]+1]=e[2] end
  local nexti,stack,on,index,low,groups=0,{},{},{},{},{}
  local function visit(v)
    nexti=nexti+1; index[v]=nexti; low[v]=nexti; stack[#stack+1]=v; on[v]=true
    for _,w in ipairs(adj[v]) do
      if not index[w] then visit(w); if low[w]<low[v] then low[v]=low[w] end
      elseif on[w] and index[w]<low[v] then low[v]=index[w] end
    end
    if low[v]==index[v] then
      local group={}; while true do local w=table.remove(stack); on[w]=nil; group[#group+1]=w; if w==v then break end end; groups[#groups+1]=group
    end
  end
  for _,f in ipairs(faces) do if not index[f] then visit(f) end end
  local group_of,cyclic={},{ }
  for gi,grp in ipairs(groups) do for _,f in ipairs(grp) do group_of[f]=gi end; if #grp>1 then cyclic[gi]=true end end
  for _,e in ipairs(edges) do if e[1]==e[2] then cyclic[group_of[e[1]]]=true end end
  return groups,group_of,cyclic
end

local function lca(reps,exemplar,mfind)
  local function parent(rep) local p=G.parent(exemplar[rep]); return p and mfind(p) or nil end
  local function path(rep) local a={}; while rep do a[#a+1]=rep; rep=parent(rep) end; local r={}; for i=#a,1,-1 do r[#r+1]=a[i] end; return r end
  local paths,max={},0; for _,rep in ipairs(reps) do local p=path(rep); paths[#paths+1]=p; if #p>max then max=#p end end
  local last=nil
  for d=1,max do local x=paths[1][d]; if not x then break end; for i=2,#paths do if paths[i][d]~=x then return last end end; last=x end
  return last
end

function M.close(parts,links)
  assert(type(parts)=='table' and #parts>0,'Algebra.close expects parts')
  local owner=index_parts(parts); local cuts=normalise_links(parts,links or {},owner)

  -- Phase 1: collect carrier universe and induced equivalence equations.
  local all={membrane={},point={},strand={},face={}}
  for _,g in ipairs(parts) do for _,k in ipairs{'membrane','point','strand','face'} do local method=k=='membrane' and 'membranes' or k=='point' and 'points' or k=='strand' and 'strands' or 'faces'; for _,x in ipairs(g[method](g)) do all[k][#all[k]+1]=x end end end
  local mfind,munion=union_find(all.membrane); local pfind,punion=union_find(all.point); local sfind,sunion=union_find(all.strand)

  local function merge_membranes(a,b)
    while a or b do assert(a and b,'cut membrane topology depth mismatch'); munion(a,b); a=G.parent(a); b=G.parent(b) end
  end
  local function bind_points(a,b)
    local ao,bo=owner.point[a],owner.point[b]
    if ao and bo then punion(a,b); merge_membranes(G.membrane(a),G.membrane(b)); return end
    if not ao and not bo then assert(a==b,'rigid imported Point mismatch'); return end
    -- A local variable may not be substituted by an external identity that is
    -- absent from the supplied open geometry.  Such identity must be imported
    -- rigidly or arrive through an exact boundary Cut.
    assert(a==b,'local Point cannot be substituted by unrelated external identity during detached closure')
  end
  for _,e in ipairs(cuts) do
    merge_membranes(G.membrane(e.from),G.membrane(e.to))
    local a,b=G._state(e.from,'Strand').points,G._state(e.to,'Strand').points; assert(#a==#b,'close Strand arity mismatch')
    for i=1,#a do bind_points(a[i],b[i]) end
    sunion(e.from,e.to)
  end

  -- Phase 2: derive the complete cut-induced causal graph and its SCC normal form.
  local producer,consumer={},{}
  for _,g in ipairs(parts) do for _,s in ipairs(g:strands()) do producer[s]=g:producer(s); consumer[s]=g:consumer(s) end end
  for _,e in ipairs(cuts) do local p,c=producer[e.from],consumer[e.to]; if p then producer[e.to]=p end; if c then consumer[e.from]=c end end
  local edges={}
  for _,s in ipairs(all.strand) do local p,c=producer[s],consumer[s]; if p and c then edges[#edges+1]={p,c} end end
  for _,e in ipairs(cuts) do local p,c=producer[e.from],consumer[e.to]; if p and c then edges[#edges+1]={p,c} end end
  local groups,group_of,cyclic=scc(all.face,edges)

  -- Phase 3: materialise one normal-form Geometry.
  local b=G.builder(); local image={}; for i=1,#parts do image[i]={membranes={},points={},strands={},faces={}} end
  local mex,mreps={},{}
  for _,m in ipairs(all.membrane) do local rep=mfind(m); if not mex[rep] then mex[rep]=m; mreps[#mreps+1]=rep end end
  local mout={}
  local function materialise_mem(rep)
    if mout[rep] then return mout[rep] end
    local ex=mex[rep]; local p=G.parent(ex); local parent=p and materialise_mem(mfind(p)) or nil
    local x=b:membrane(parent,G.name(ex)); mout[rep]=x; return x
  end
  for _,rep in ipairs(mreps) do materialise_mem(rep) end
  for i,g in ipairs(parts) do for _,x in ipairs(g:membranes()) do image[i].membranes[x]=mout[mfind(x)] end end

  local pout={}
  local function local_point(p)
    local rep=pfind(p); if not pout[rep] then pout[rep]=b:point(mout[mfind(G.membrane(p))],G.name(p)) end; return pout[rep]
  end
  for i,g in ipairs(parts) do for _,p in ipairs(g:points()) do image[i].points[p]=local_point(p) end end
  local function point_image(p) local i=owner.point[p]; return i and image[i].points[p] or p end

  local members,sreps={},{}
  for _,s in ipairs(all.strand) do local r=sfind(s); local x=members[r]; if not x then x={}; members[r]=x; sreps[#sreps+1]=r end; x[#x+1]=s end
  local sout,internal={},{ }
  for _,rep in ipairs(sreps) do local ms=members[rep]
    local p,c; for _,s in ipairs(ms) do p=p or producer[s]; c=c or consumer[s] end
    if p and c and group_of[p]==group_of[c] and cyclic[group_of[p]] then internal[rep]=true
    else
      local ex=ms[1]; local pts={}; for j,pnt in ipairs(G._state(ex,'Strand').points) do pts[j]=point_image(pnt) end
      sout[rep]=b:strand(mout[mfind(G.membrane(ex))],pts,G.name(ex))
    end
  end
  for i,g in ipairs(parts) do for _,s in ipairs(g:strands()) do image[i].strands[s]=sout[sfind(s)] end end

  local function add_unique(xs,seen,x) if x and not seen[x] then seen[x]=true; xs[#xs+1]=x end end
  for gi,grp in ipairs(groups) do
    if cyclic[gi] then
      local reps={}; for _,f in ipairs(grp) do reps[#reps+1]=mfind(G.membrane(f)) end
      local joint=lca(reps,mex,mfind); assert(joint,'joint occurrence has no common enclosing membrane')
      local ins,outs,si,so={},{},{},{}
      for _,f in ipairs(grp) do
        local fs=G._state(f,'Face')
        for _,s in ipairs(fs.inputs) do add_unique(ins,si,sout[sfind(s)]) end
        for _,s in ipairs(fs.outputs) do add_unique(outs,so,sout[sfind(s)]) end
      end
      local jf=b:face(mout[joint],ins,outs,'joint'); for _,f in ipairs(grp) do image[owner.face[f]].faces[f]=jf end
    else
      local f=grp[1]; local fs=G._state(f,'Face'); local ins,outs={},{}
      for j,s in ipairs(fs.inputs) do ins[j]=sout[sfind(s)]; assert(ins[j],'removed input outside cyclic SCC') end
      for j,s in ipairs(fs.outputs) do outs[j]=sout[sfind(s)]; assert(outs[j],'removed output outside cyclic SCC') end
      image[owner.face[f]].faces[f]=b:face(mout[mfind(G.membrane(f))],ins,outs,G.name(f))
    end
  end
  return b:finish(),image,{links=cuts,groups=groups,group_of=group_of,cyclic=cyclic}
end

function M.tensor(parts) local g,img=M.close(parts,{}); return g,img end

-- Long composition should record parts/cuts and materialise once.
local Builder={__metatable='Worlds Algebra.Builder'}; Builder.__index=Builder
function M.builder() return setmetatable({parts={},links={}},Builder) end
function Builder:add(g) assert(G.is_geometry(g),'Algebra.Builder:add expects Geometry'); self.parts[#self.parts+1]=g; return g end
function Builder:cut(from,to) assert(G.is_strand(from) and G.is_strand(to),'Algebra.Builder:cut expects Strand endpoints'); self.links[#self.links+1]={from=from,to=to}; return self end
function Builder:finish() assert(#self.parts>0,'Algebra.Builder is empty'); return M.close(self.parts,self.links) end

local function terminals(g) return g:egress() end
function M.query(left,right,ctx)
  assert(G.is_geometry(left) and G.is_geometry(right),'Algebra.query expects Geometry values'); ctx=ctx or {}
  local offers=ctx.offers or terminals(left); for _,s in ipairs(offers) do assert(left:is_terminal(s),'Algebra offer must be left egress') end
  for _,s in pairs(ctx.strands or {}) do assert(left:is_terminal(s),'Algebra exact Strand must be left egress') end
  local demands=ctx.close or ctx.demands; assert(demands,'Algebra.query requires close/demands')
  return Cut.query(right,{demands=demands,offers=offers,strands=ctx.strands})
end
local function links_from_cut(left,right,cut)
  local cs=Cut._state(cut); assert(cs.pattern==right,'Cut belongs to another right Geometry'); local links={}
  for rs,ls in pairs(cs.strands) do assert(left:is_terminal(ls)); links[#links+1]={from=ls,to=rs} end
  return links
end
function M.apply(left,right,cut)
  local g,imgs,meta=M.close({left,right},links_from_cut(left,right,cut)); return g,{left=imgs[1],right=imgs[2],cut=cut,meta=meta}
end
function M.one(left,right,ctx,budget)
  local q=M.query(left,right,ctx); while true do local k,c=q:step(budget or math.huge); if k=='Hit' then local g,img=M.apply(left,right,c); return g,img,c elseif k=='Retry' then return nil else return nil,'Unknown',q end end
end
function M.cut(left,right,links)
  local strands,demands={},{}
  if #links>0 then for _,e in ipairs(links) do local ls=e.left or e.from or e[1]; local rs=e.right or e.to or e[2]; strands[rs]=ls; demands[#demands+1]=rs end
  else for rs,ls in pairs(links) do strands[rs]=ls; demands[#demands+1]=rs end end
  local g,img,why=M.one(left,right,{close=demands,strands=strands}); if not g then error('detached cut failed: '..tostring(why or 'no compatible cut'),2) end; return g,img
end

-- Identity substitution is not authority.  Existing localities may change only
-- when consumed exact ingress authority causally supports them.
function M.admissible(process,cut)
  assert(G.is_geometry(process),'Algebra.admissible expects Geometry'); local cs=Cut._state(cut); assert(cs.pattern==process,'Cut belongs to another process')
  local allowed={}
  local function allow(pm) while pm do local gm=cs.membranes[pm]; if gm then allowed[gm]=true end; pm=G.parent(pm) end end
  for ps in pairs(cs.strands) do
    if process:consumer(ps) then
      allow(G.membrane(ps)); for _,p in ipairs(G._state(ps,'Strand').points) do if process:owns_point(p) and cs.points[p] then allow(G.membrane(p)) end end
    end
  end
  local function mapped_ancestor(pm) while pm do local gm=cs.membranes[pm]; if gm then return gm end; pm=G.parent(pm) end end
  local function may_change(pm)
    local gm=cs.membranes[pm]; if gm then return not not allowed[gm] end
    local a=mapped_ancestor(G.parent(pm)); return a and allowed[a] or false
  end
  for _,f in ipairs(process:faces()) do if not may_change(G.membrane(f)) then return false end end
  for _,s in ipairs(process:egress()) do if process:producer(s) and not may_change(G.membrane(s)) then return false end end
  return true
end

return M
