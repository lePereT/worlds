package.path='./src/?.lua;./src/?/init.lua;./?.lua;'..package.path
local W=require('worlds')
local Construction=require('worlds.construction')
local C=require('speculation.showcases.theory.lifecycle_and_correspondence.correspondence')
local n=0
local function ok(x,m) n=n+1
assert(x,m or 'assertion failed') end
local function eq(a,b,m) n=n+1
assert(a==b,(m or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end
local KINDS={'membranes','points','strands','faces'}
local function all(g) local o={}
for _,k in ipairs(KINDS) do for _,x in ipairs(g[k](g)) do o[#o+1]=x end end
return o end
local function stage(name)
  local b=W.builder()
  local m=b:membrane(nil,name)
  local p=b:point(m,name..'.p')
  local i=b:strand(m,{p},name..'.i')
  local o=b:strand(m,{p},name..'.o')
  local f=b:face(m,{i},{o},name..'.f')
  return b:finish(),{m=m,p=p,i=i,o=o,f=f}
end

local function run(G0,src,E,order)
  local g=G0
  local img={}
  local corr=nil
  for _,z in ipairs(src) do img[z]=z end
  for _,ei in ipairs(order) do
    local e=E[ei]
    local from,to=img[e.from],img[e.to]
    ok(from~=nil and to~=nil,'pending equation endpoint vanished')
    local step=Construction.join({g},{{from=from,to=to}})
    local rc=C.from_construction(step)
    corr=corr and C.compose(corr,rc) or rc
    for _,z in ipairs(src) do img[z]=img[z] and step:image(img[z]) or nil end
    g=step:result()
  end
  return {g=g,img=img,corr=corr,label=table.concat(order,'')}
end

local function verify_map(A,B,map)
  for _,z in ipairs(all(A.g)) do ok(map[z]~=nil,'endpoint carrier lacks correspondence') end
  for _,m in ipairs(A.g:membranes()) do eq(W.parent(map[m]),W.parent(m) and map[W.parent(m)] or nil,
    'Membrane parent not preserved') end
  for _,p in ipairs(A.g:points()) do
    eq(W.membrane(map[p]),map[W.membrane(p)],'Point support not preserved')
  end
  for _,s in ipairs(A.g:strands()) do
    eq(W.membrane(map[s]),map[W.membrane(s)],'Strand support not preserved')
    local ap,bp=W.points(s),W.points(map[s])
    eq(#ap,#bp,'Strand arity changed')
    for i=1,#ap do eq(bp[i],map[ap[i]],'Point incidence not preserved') end
    local pr,co=A.g:producer(s),A.g:consumer(s)
    eq(B.g:producer(map[s]),pr and map[pr] or nil,'producer not preserved')
    eq(B.g:consumer(map[s]),co and map[co] or nil,'consumer not preserved')
  end
  for _,f in ipairs(A.g:faces()) do
    eq(W.membrane(map[f]),map[W.membrane(f)],'Face support not preserved')
  end
end

local function atlas(parts,metas,E,perms,label)
  local product=Construction.join(parts,{})
  local G0=product:result()
  local src=all(G0)
  local mapped={}
  for pi,meta in ipairs(metas) do mapped[pi]={}
  for k,v in pairs(meta) do mapped[pi][k]=product:image(v) end end
  local ME={}
  for i,e in ipairs(E(mapped)) do ME[i]=e end
  local eps={}
  for _,p in ipairs(perms) do eps[#eps+1]=run(G0,src,ME,p) end
  local dc=Construction.join({G0},ME)
  local di={}
  for _,z in ipairs(src) do di[z]=dc:image(z) end
  eps[#eps+1]={g=dc:result(),img=di,corr=C.from_construction(dc),label='all'}

  print(label..': staged and one-shot correspondences have the same marked source quotient')
  for _,ep in ipairs(eps) do ok(C.same_source_partition(ep.corr,eps[#eps].corr),
    label..' source quotient depends on construction path') end

  print(label..': correspondence-derived maps reproduce the existing source-image groupoid')
  local maps={}
  for i=1,#eps do maps[i]={}
  for j=1,#eps do
    local map=C.between(eps[i].corr,eps[j].corr)
    maps[i][j]=map
    verify_map(eps[i],eps[j],map)
    for _,z in ipairs(src) do
      local a,b=eps[i].img[z],eps[j].img[z]
      eq(a==nil,b==nil,label..' survival differs by path')
      if a then eq(map[a],b,label..' correspondence disagrees with common-source image') end
    end
  end end

  print(label..': endpoint maps compose exactly')
  for i=1,#eps do for j=1,#eps do for k=1,#eps do
    for _,z in ipairs(all(eps[i].g)) do eq(maps[j][k][maps[i][j][z]],maps[i][k][z],
      label..' groupoid composition failed') end
  end end end
  return eps
end

local perms={{1,2,3},{1,3,2},{2,1,3},{2,3,1},{3,1,2},{3,2,1}}

print('1. acyclic native construction groupoid')
do
  local parts,meta={},{}
  for i,name in ipairs{'A','B','C','D','E','F'} do parts[i],meta[i]=stage(name) end
  atlas(parts,meta,function(m) return {
    {from=m[1].o,to=m[2].i},{from=m[3].o,to=m[4].i},{from=m[5].o,to=m[6].i}}
  end,perms,'acyclic')
end

print('2. causal-SCC native construction groupoid with annihilation')
do
  local X,x=stage('X')
  local Y,y=stage('Y')
  local A,a=stage('A')
  local B,b=stage('B')
  local eps=atlas({X,Y,A,B},{x,y,a,b},function(m) return {
    {from=m[1].o,to=m[2].i},{from=m[2].o,to=m[1].i},{from=m[3].o,to=m[4].i}}
  end,perms,'scc')
  for _,ep in ipairs(eps) do
    eq(#ep.g:faces(),3,'SCC did not contract two Faces to one')
  end
end

print('PASS one correspondence object reproduces both native between-Worlds groupoids',
  n,'assertions')
