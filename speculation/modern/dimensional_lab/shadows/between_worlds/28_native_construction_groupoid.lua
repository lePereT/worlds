package.path='./src/?.lua;./src/?/init.lua;./?.lua;'..package.path
local W=require('worlds')
local n=0
local function ok(x,m) n=n+1; assert(x,m or 'assertion failed') end
local function eq(a,b,m) n=n+1; assert(a==b,(m or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end

local KINDS={'membranes','points','strands','faces'}
local function carriers(g)
  local out={}
  for _,kind in ipairs(KINDS) do for _,x in ipairs(g[kind](g)) do out[#out+1]=x end end
  return out
end
local function stage(name)
  local b=W.builder(); local m=b:membrane(nil,name); local p=b:point(m,name..'.p')
  local i=b:strand(m,{p},name..'.i'); local o=b:strand(m,{p},name..'.o'); local f=b:face(m,{i},{o},name..'.f')
  return b:finish(),{m=m,p=p,i=i,o=o,f=f}
end

local parts,meta={},{ }
for i,name in ipairs{'A','B','C','D','E','F'} do parts[i],meta[i]=stage(name) end
local G0,i0=W.join(parts,{})
local equations={
  {from=i0[meta[1].o],to=i0[meta[2].i]},
  {from=i0[meta[3].o],to=i0[meta[4].i]},
  {from=i0[meta[5].o],to=i0[meta[6].i]},
}
local source=carriers(G0)

local function run(order)
  local g=G0; local img={}; for _,x in ipairs(source) do img[x]=x end
  for _,ei in ipairs(order) do
    local e=equations[ei]
    local ng,step=W.join({g},{{from=img[e.from],to=img[e.to]}})
    for _,x in ipairs(source) do img[x]=step[img[x]] end
    g=ng
  end
  return {g=g,img=img,label=table.concat(order,'')}
end
local perms={{1,2,3},{1,3,2},{2,1,3},{2,3,1},{3,1,2},{3,2,1}}
local endpoints={}; for _,p in ipairs(perms) do endpoints[#endpoints+1]=run(p) end
local direct,dimg=W.join({G0},equations); endpoints[#endpoints+1]={g=direct,img=dimg,label='all'}

local function exact_tuple(ep,ids,nextid)
  local t={}
  for _,x in ipairs(source) do
    local y=ep.img[x]; local id=ids[y]
    if not id then nextid[1]=nextid[1]+1; id=nextid[1]; ids[y]=id end
    t[#t+1]=id
  end
  return table.concat(t,',')
end

local function correspondence(A,B)
  local map,rev={},{}
  for _,x in ipairs(source) do
    local a,b=A.img[x],B.img[x]
    ok(a~=nil and b~=nil,'source carrier lost in acyclic quotient')
    if map[a] then eq(map[a],b,'source-equivalence must be path independent') else map[a]=b end
    if rev[b] then eq(rev[b],a,'reverse source-equivalence must be path independent') else rev[b]=a end
  end
  for _,kind in ipairs(KINDS) do
    local xs,ys=A.g[kind](A.g),B.g[kind](B.g); eq(#xs,#ys,'parallel endpoints carrier count')
    for _,x in ipairs(xs) do ok(map[x]~=nil,'endpoint carrier not covered by source-relative correspondence') end
    for _,y in ipairs(ys) do ok(rev[y]~=nil,'reverse endpoint carrier not covered') end
  end
  for _,m in ipairs(A.g:membranes()) do eq(W.parent(map[m]),W.parent(m) and map[W.parent(m)] or nil,'Membrane parent preserved') end
  for _,p in ipairs(A.g:points()) do eq(W.membrane(map[p]),map[W.membrane(p)],'Point support preserved') end
  for _,s in ipairs(A.g:strands()) do
    eq(W.membrane(map[s]),map[W.membrane(s)],'Strand support preserved')
    local ap,bp=W.points(s),W.points(map[s]); eq(#ap,#bp,'Strand arity preserved')
    for i=1,#ap do eq(bp[i],map[ap[i]],'ordered Point incidence preserved') end
    local pr,co=A.g:producer(s),A.g:consumer(s)
    eq(B.g:producer(map[s]),pr and map[pr] or nil,'producer preserved')
    eq(B.g:consumer(map[s]),co and map[co] or nil,'consumer preserved')
  end
  for _,f in ipairs(A.g:faces()) do eq(W.membrane(map[f]),map[W.membrane(f)],'Face support preserved') end
  return map
end

print('1. parallel native construction paths end in exact-distinct but structurally corresponding Worlds')
local ids,nextid={}, {0}; local seen={}
for _,ep in ipairs(endpoints) do
  eq(#ep.g:faces(),6); eq(#ep.g:strands(),9); eq(#ep.g:ingress(),3); eq(#ep.g:egress(),3)
  local t=exact_tuple(ep,ids,nextid); ok(not seen[t],'parallel construction path unexpectedly reused exact endpoint tuple'); seen[t]=true
end
eq(#endpoints,7); local sc=0; for _ in pairs(seen) do sc=sc+1 end; eq(sc,7,'six staged orders plus one-shot give seven exact endpoint tuples')

print('2. the common source induces a canonical incidence-preserving correspondence between every pair')
local maps={}
for i=1,#endpoints do maps[i]={}; for j=1,#endpoints do maps[i][j]=correspondence(endpoints[i],endpoints[j]) end end

print('3. those correspondences compose exactly: a thin source-relative groupoid of construction outcomes')
for i=1,#endpoints do for j=1,#endpoints do for k=1,#endpoints do
  local ij,jk,ik=maps[i][j],maps[j][k],maps[i][k]
  for _,x in ipairs(carriers(endpoints[i].g)) do eq(jk[ij[x]],ik[x],'parallel-construction coherence') end
end end end

print('4. construction images are therefore path data, while structural coherence lives between their exact codomains')
for i=1,6 do ok(endpoints[i].g~=endpoints[7].g,'staged endpoint must not be literal one-shot endpoint') end

print('PASS native construction paths generate a coherent between-Worlds groupoid',n,'assertions')
