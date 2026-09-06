local S=require('tests.support')
local G,A,Same=S.G,S.A,S.Worlds.same

-- Alpha-isomorphic symmetric geometries built in opposite branch order.
local function forest(reverse, partition)
  local b=G.builder(); local R=b:membrane(nil,'root')
  local points={}
  for i=1,#partition do points[i]=b:point(R,'Joint','j'..i) end
  local order={1,2,3,4}; if reverse then order={4,3,2,1} end
  for _,i in ipairs(order) do
    local m=b:membrane(R,'slot','m'..i)
    local p=points[partition[i]]
    b:strand(m,'R',{p},'r'..i)
  end
  return b:finish()
end
local parts={
  {1,1,1,1},       -- 4
  {1,1,1,2},       -- 3+1
  {1,1,2,2},       -- 2+2
  {1,1,2,3},       -- 2+1+1
  {1,2,3,4},       -- 1+1+1+1
}
for i,p in ipairs(parts) do
  S.ok(Same(forest(false,p),forest(true,{p[4],p[3],p[2],p[1]})),'alpha symmetry failed partition '..i)
end
for i=1,#parts do for j=i+1,#parts do S.no(Same(forest(false,parts[i]),forest(false,parts[j])),'distinct sharing partitions collapsed') end end

-- Exact equality anchors already-existing occurrences. Two symmetric actions on
-- different existing Strand occurrences are distinct states.
local b=G.builder(); local K=b:membrane(nil,'p'); local X=b:point(K,'X'); local a=b:strand(K,'R',{X},'a'); local c=b:strand(K,'R',{X},'c'); local base=b:finish()
local p=G.builder(); local D=p:membrane(nil,'p'); local Q=p:point(D,'X'); local i=p:strand(D,'R',{Q}); local o=p:strand(D,'Done',{Q}); p:face(D,'step',{i},{o}); local step=p:finish()
local ws=A.all(base,{K},step); S.eq(#ws,2)
local g1=A.glue(ws[1]); local g2=A.glue(ws[2])
S.no(Same(g1,g2),'consuming different existing authority must remain distinct')

-- Two independent steps on both exact occurrences commute despite execution order.
local function choose_for(g,sid)
  for _,w in ipairs(A.all(g,{K},step)) do if w:strand(i)==sid then return w end end
end
local wA,wC=choose_for(base,a),choose_for(base,c); S.ok(wA); S.ok(wC)
local ga=A.glue(wA); local wC2=choose_for(ga,c); S.ok(wC2); local gac=A.glue(wC2)
local gc=A.glue(wC); local wA2=choose_for(gc,a); S.ok(wA2); local gca=A.glue(wA2)
S.ok(Same(gac,gca),'exact independent occurrences failed to commute')

print('ok 22_exact_isomorphism')
