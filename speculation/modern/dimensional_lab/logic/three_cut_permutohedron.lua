package.path='./src/?.lua;./src/?/init.lua;./speculation/modern/dimensional_lab/?.lua;'..package.path
local W=require('worlds'); local D=require('common')
local ok,eq,count=D.counter()

local function arrow(label,a,b)
  local x=W.builder(); local m=x:membrane(nil,label); local pa=x:point(m,a); local pb=x:point(m,b)
  local i=x:strand(m,{pa},a); local o=x:strand(m,{pb},b); x:face(m,{i},{o},label); return {g=x:finish(),i=i,o=o}
end
local roles={{'A','B','C'},{'D','E','F'},{'G','H','I'}}
local function lane(prefix,r)
  local f=arrow(prefix..'.1',r[1],r[2]); local g=arrow(prefix..'.2',r[2],r[3])
  return W.join({f.g,g.g},{{from=f.o,to=g.i}})
end
local function surface(order)
  local lanes={lane(order..'.L1',roles[1]),lane(order..'.L2',roles[2]),lane(order..'.L3',roles[3])}
  local parts={}; for i=1,3 do parts[i]=lanes[tonumber(order:sub(i,i))] end
  return D.surface(order,W.join(parts,{}))
end
local names={'123','213','231','321','312','132'}; local S={}
for _,name in ipairs(names) do S[name]=surface(name) end

print('1. six orders of three independent cuts give one logical boundary and six exact histories')
local sig=D.boundary_signature(S['123'].g)
for _,name in ipairs(names) do eq(D.boundary_signature(S[name].g),sig,'sequent invariant under cut order'); eq(#S[name].g:faces(),6) end
for i=1,#names do for j=i+1,#names do ok(S[names[i]].g~=S[names[j]].g,'exact construction histories remain distinct') end end

print('2. adjacent cut permutations form the S3 permutohedron as face-free higher incidence')
local edges={}
for i=1,#names do edges[#edges+1]={S[names[i]],S[names[i%#names+1]]} end
local atlas=D.deformation_atlas({S['123'],S['213'],S['231'],S['321'],S['312'],S['132']},edges,'three-cut permutohedron')
eq(#atlas.world:points(),6); eq(#atlas.world:strands(),6); eq(#atlas.world:faces(),0)
-- Every higher vertex has degree two in this hexagonal coherence loop.
local deg={}; for _,s in ipairs(atlas.world:strands()) do for _,p in ipairs(W.points(s)) do deg[p]=(deg[p] or 0)+1 end end
for _,p in ipairs(atlas.world:points()) do eq(deg[p],2,'permutohedron vertex degree') end

print('3. the two braid routes s1 s2 s1 and s2 s1 s2 are exact-distinct higher histories with one higher boundary')
local routeA={D.higher_rewrite(S['123'],S['213'],'s1'),D.higher_rewrite(S['213'],S['231'],'s2'),D.higher_rewrite(S['231'],S['321'],'s1')}
local routeB={D.higher_rewrite(S['123'],S['132'],'s2'),D.higher_rewrite(S['132'],S['312'],'s1'),D.higher_rewrite(S['312'],S['321'],'s2')}
local A=D.path_rewrites(routeA); local B=D.path_rewrites(routeB)
eq(#A:faces(),3); eq(#B:faces(),3); eq(D.boundary_signature(A),D.boundary_signature(B),'braid routes have same higher source/target proof surfaces')
ok(A~=B,'braid coherence relates rather than identifies higher histories')

print('PASS three-cut permutohedron coherence',count(),'assertions')
