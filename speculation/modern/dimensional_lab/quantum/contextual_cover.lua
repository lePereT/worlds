package.path='./src/?.lua;./src/?/init.lua;./speculation/modern/dimensional_lab/?.lua;'..package.path
local W=require('worlds'); local D=require('common'); local R=require('speculation.modern.dimensional_lab.reduct')
local ok,eq,count=D.counter()

print('1. contextual compatibility is a lawful intrinsic face-free incidence world')
local b=W.builder(); local m=b:membrane(nil,'context cover'); local P={}
for r=1,3 do P[r]={}; for c=1,3 do P[r][c]=b:point(m,'O'..r..c) end end
local C={}
for r=1,3 do C[#C+1]=b:strand(m,{P[r][1],P[r][2],P[r][3]},'R'..r) end
for c=1,3 do C[#C+1]=b:strand(m,{P[1][c],P[2][c],P[3][c]},'C'..c) end
local cover=b:finish()
eq(#cover:faces(),0); eq(#cover:points(),9); eq(#cover:strands(),6)
local deg={}; for _,s in ipairs(C) do for _,p in ipairs(W.points(s)) do deg[p]=(deg[p] or 0)+1 end end
for r=1,3 do for c=1,3 do eq(deg[P[r][c]],2,'observable crosses exactly row+column') end end

print('2. exact occurrence reduction is richer than the contextual cover, but contains its scope canonically')
local red=R.reduce_full(cover)
eq(#red.world:faces(),0)
-- Each context scope row is [exact occurrence coordinate, observable coordinates...].
-- Dropping only the leading exact-fibre coordinate recovers the intrinsic cover,
-- including shared observable Points and ordered row incidence.
for _,s in ipairs(C) do
  local rs=red.scope_arc[s]; local row=W.points(rs); local src=W.points(s)
  eq(#row,#src+1,'reduct adds exactly one occurrence coordinate')
  eq(row[1],red.carrier_point[s],'leading coordinate is exact scarce occurrence')
  for i,p in ipairs(src) do eq(row[i+1],red.struct_point[p],'contextual scope survives exactly') end
end
-- Shared observables stay shared at the reduced structural level.
for r=1,3 do for c=1,3 do ok(red.struct_point[P[r][c]]~=nil,'observable has one reduced coordinate') end end

print('3. causal thickening adds causal collar structure; it is not the contextual object itself')
local t=W.builder(); local tm=t:membrane(nil,'measurement thickening'); local TP={}
for r=1,3 do TP[r]={}; for c=1,3 do TP[r][c]=t:point(tm,'O'..r..c) end end
for r=1,3 do local i=t:strand(tm,{TP[r][1],TP[r][2],TP[r][3]},'R'..r..'.in'); local o=t:strand(tm,{TP[r][1],TP[r][2],TP[r][3]},'R'..r..'.out'); t:face(tm,{i},{o},'measure R'..r) end
for c=1,3 do local i=t:strand(tm,{TP[1][c],TP[2][c],TP[3][c]},'C'..c..'.in'); local o=t:strand(tm,{TP[1][c],TP[2][c],TP[3][c]},'C'..c..'.out'); t:face(tm,{i},{o},'measure C'..c) end
local thick=t:finish(); local tr=R.reduce(thick)
eq(#thick:faces(),6); ok(#tr.world:points()>#cover:points(),'causal reduct contains port/face coordinates beyond compatibility cover')
eq(#tr.world:faces(),0,'lowered collar is structural')

print('PASS intrinsic contextual W1 pressure',count(),'assertions')
