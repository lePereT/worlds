package.path='./src/?.lua;./src/?/init.lua;./?.lua;'..package.path
local W=require('worlds')
local Construction=require('worlds.construction')
local Oracle=require('speculation.modern.restrictive_theory_followup.correspondence')
local n=0
local function ok(x,m) n=n+1
assert(x,m or 'assertion failed') end
local function eq(a,b,m) n=n+1
assert(a==b,(m or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end
local KINDS={'membranes','points','strands','faces'}
local function all(g)
  local out={}
  for _,k in ipairs(KINDS) do for _,x in ipairs(g[k](g)) do out[#out+1]=x end end
  return out
end
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
  local native,oracle=nil,nil
  for _,z in ipairs(src) do img[z]=z end
  for _,ei in ipairs(order) do
    local e=E[ei]
    local from,to=img[e.from],img[e.to]
    ok(from~=nil and to~=nil,'pending equation endpoint vanished')
    local step=Construction.join({g},{{from=from,to=to}})
    local nc=step:correspondence()
    local oc=Oracle.from_construction(step)
    native=native and native:compose(nc) or nc
    oracle=oracle and Oracle.compose(oracle,oc) or oc
    for _,z in ipairs(src) do img[z]=img[z] and step:image(img[z]) or nil end
    g=step:result()
  end
  return {g=g,img=img,native=native,oracle=oracle,label=table.concat(order,'')}
end
local function verify_map(A,B,map)
  for _,z in ipairs(all(A.g)) do ok(map[z]~=nil,'endpoint carrier lacks correspondence') end
  for _,m in ipairs(A.g:membranes()) do
    eq(W.parent(map[m]),W.parent(m) and map[W.parent(m)] or nil,'Membrane parent not preserved')
  end
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
local function native_map(a,b)
  local out={}
  for _,x in ipairs(all(a.g)) do out[x]=assert(a.native:mate(b.native,x),'native mate missing') end
  return out
end
local function source_partition_agrees(ep)
  local xs={}
  for _,g in ipairs(ep.native:source_parts()) do
    for _,x in ipairs(all(g)) do xs[#xs+1]=x end
  end
  for i=1,#xs do for j=1,#xs do
    eq(ep.native:source_equivalent(xs[i],xs[j]),ep.oracle:source_equivalent(xs[i],xs[j]),
        'native quotient differs from reconstruction oracle')
  end end
end
local function atlas(parts,metas,E,perms,label)
  local product=Construction.join(parts,{})
  local G0=product:result()
  local src=all(G0)
  local mapped={}
  for pi,meta in ipairs(metas) do
    mapped[pi]={}
    for k,v in pairs(meta) do mapped[pi][k]=product:image(v) end
  end
  local ME={}
  for i,e in ipairs(E(mapped)) do ME[i]=e end
  local eps={}
  for _,p in ipairs(perms) do eps[#eps+1]=run(G0,src,ME,p) end
  local dc=Construction.join({G0},ME)
  local di={}
  for _,z in ipairs(src) do di[z]=dc:image(z) end
  eps[#eps+1]={g=dc:result(),img=di,native=dc:correspondence(),
      oracle=Oracle.from_construction(dc),label='all'}

  print(label..': native source quotients agree with reconstruction oracle')
  for _,ep in ipairs(eps) do source_partition_agrees(ep) end
  for _,ep in ipairs(eps) do
    ok(ep.native:same_source_partition(eps[#eps].native),
        label..' native source quotient depends on construction path')
  end

  print(label..': native mates reproduce reconstruction groupoid maps')
  local maps={}
  for i=1,#eps do maps[i]={}
    for j=1,#eps do
      local nm=native_map(eps[i],eps[j])
      local om=Oracle.between(eps[i].oracle,eps[j].oracle)
      maps[i][j]=nm
      verify_map(eps[i],eps[j],nm)
      for _,z in ipairs(all(eps[i].g)) do
        eq(nm[z],om[z],label..' native mate differs from reconstruction oracle')
      end
      for _,z in ipairs(src) do
        local a,b=eps[i].img[z],eps[j].img[z]
        eq(a==nil,b==nil,label..' survival differs by path')
        if a then eq(nm[a],b,label..' native mate disagrees with common-source image') end
      end
    end
  end

  print(label..': native endpoint mates compose exactly')
  for i=1,#eps do for j=1,#eps do for k=1,#eps do
    for _,z in ipairs(all(eps[i].g)) do
      eq(maps[j][k][maps[i][j][z]],maps[i][k][z],label..' native groupoid composition failed')
    end
  end end end
  return eps
end

local perms={{1,2,3},{1,3,2},{2,1,3},{2,3,1},{3,1,2},{3,2,1}}

print('1. acyclic native construction groupoid differential')
do
  local parts,meta={},{}
  for i,name in ipairs{'A','B','C','D','E','F'} do parts[i],meta[i]=stage(name) end
  atlas(parts,meta,function(m) return {
    {from=m[1].o,to=m[2].i},{from=m[3].o,to=m[4].i},{from=m[5].o,to=m[6].i}
  } end,perms,'acyclic')
end

print('2. causal-SCC native construction groupoid differential')
do
  local X,x=stage('X')
  local Y,y=stage('Y')
  local A,a=stage('A')
  local B,b=stage('B')
  local eps=atlas({X,Y,A,B},{x,y,a,b},function(m) return {
    {from=m[1].o,to=m[2].i},{from=m[2].o,to=m[1].i},{from=m[3].o,to=m[4].i}
  } end,perms,'scc')
  for _,ep in ipairs(eps) do eq(#ep.g:faces(),3,'SCC did not contract two Faces to one') end
end

print('PASS native correspondence reproduces both source-relative groupoids',n,'assertions')
