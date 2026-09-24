package.path='./src/?.lua;./src/?/init.lua;./?.lua;'..package.path
local W=require('worlds')
local n=0
local function ok(x,m) n=n+1; assert(x,m or 'assertion failed') end
local function eq(a,b,m) n=n+1; assert(a==b,(m or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end
local KINDS={'membranes','points','strands','faces'}
local function all(g)local o={};for _,k in ipairs(KINDS) do for _,x in ipairs(g[k](g)) do o[#o+1]=x end end;return o end
local function stage(name)
  local b=W.builder();local m=b:membrane(nil,name);local p=b:point(m,name..'.p')
  local i=b:strand(m,{p},name..'.i');local o=b:strand(m,{p},name..'.o');local f=b:face(m,{i},{o},name..'.f')
  return b:finish(),{m=m,p=p,i=i,o=o,f=f}
end

local X,x=stage('X');local Y,y=stage('Y');local C,c=stage('C');local D,d=stage('D')
local G0,i0=W.join({X,Y,C,D},{})
local E={
  {from=i0[x.o],to=i0[y.i]},
  {from=i0[y.o],to=i0[x.i]}, -- together E1/E2 make a causal SCC
  {from=i0[c.o],to=i0[d.i]}, -- independent acyclic seam
}
local src=all(G0)
local function run(order)
  local g=G0;local img={};for _,z in ipairs(src) do img[z]=z end
  for _,ei in ipairs(order) do
    local e=E[ei];ok(img[e.from]~=nil and img[e.to]~=nil,'pending equation endpoint must survive until used')
    local ng,step=W.join({g},{{from=img[e.from],to=img[e.to]}})
    for _,z in ipairs(src) do img[z]=img[z] and step[img[z]] or nil end
    g=ng
  end
  return {g=g,img=img,label=table.concat(order,'')}
end
local perms={{1,2,3},{1,3,2},{2,1,3},{2,3,1},{3,1,2},{3,2,1}}
local eps={};for _,p in ipairs(perms) do eps[#eps+1]=run(p) end
local dg,di=W.join({G0},E);eps[#eps+1]={g=dg,img=di,label='all'}

print('1. parallel construction paths through a causal SCC retain one final structural outcome')
for _,ep in ipairs(eps) do
  eq(#ep.g:faces(),3,'X/Y SCC contracts while C/D remain two Faces')
  eq(ep.img[i0[x.f]],ep.img[i0[y.f]],'two SCC source Faces map many-to-one to joint Face')
  ok(ep.img[i0[x.o]]==nil and ep.img[i0[x.i]]==nil and ep.img[i0[y.o]]==nil and ep.img[i0[y.i]]==nil,'cyclic Strand authority is annihilated')
end

local function corr(A,B)
  local map,rev={},{}
  for _,z in ipairs(src) do
    local a,b=A.img[z],B.img[z];eq(a==nil,b==nil,'survival/annihilation must be path independent')
    if a then
      if map[a] then eq(map[a],b,'many-to-one source class must agree across paths') else map[a]=b end
      if rev[b] then eq(rev[b],a,'reverse source class must agree') else rev[b]=a end
    end
  end
  for _,k in ipairs(KINDS) do
    local xs,ys=A.g[k](A.g),B.g[k](B.g);eq(#xs,#ys)
    for _,z in ipairs(xs) do ok(map[z]~=nil,'surviving endpoint carrier lacks source-relative image') end
    for _,z in ipairs(ys) do ok(rev[z]~=nil,'reverse endpoint carrier lacks source-relative image') end
  end
  for _,p in ipairs(A.g:points()) do eq(W.membrane(map[p]),map[W.membrane(p)]) end
  for _,s in ipairs(A.g:strands()) do
    local ap,bp=W.points(s),W.points(map[s]);eq(#ap,#bp);for i=1,#ap do eq(bp[i],map[ap[i]]) end
    local pr,co=A.g:producer(s),A.g:consumer(s)
    eq(B.g:producer(map[s]),pr and map[pr] or nil);eq(B.g:consumer(map[s]),co and map[co] or nil)
  end
  for _,f in ipairs(A.g:faces()) do eq(W.membrane(map[f]),map[W.membrane(f)]) end
  for _,m in ipairs(A.g:membranes()) do eq(W.parent(map[m]),W.parent(m) and map[W.parent(m)] or nil) end
  return map
end

print('2. source-relative endpoint correspondences survive many-to-one causal normalisation')
local maps={};for i=1,#eps do maps[i]={};for j=1,#eps do maps[i][j]=corr(eps[i],eps[j]) end end
print('3. SCC correspondences retain exact coherence under all path triples')
for i=1,#eps do for j=1,#eps do for k=1,#eps do
  for _,z in ipairs(all(eps[i].g)) do eq(maps[j][k][maps[i][j][z]],maps[i][k][z],'SCC endpoint coherence') end
end end end
print('PASS causal-SCC construction outcomes form the same source-relative between-Worlds groupoid',n,'assertions')
