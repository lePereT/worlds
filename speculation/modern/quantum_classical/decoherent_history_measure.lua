local HERE='./speculation/modern/quantum_classical'; package.path='./src/?.lua;./src/?/init.lua;'..HERE..'/?.lua;'..package.path
local W=require('worlds'); local T=require('common'); T.reset()
local ok,eq,approx=T.ok,T.eq,T.approx

local b=W.builder(); local m=b:membrane(nil,'histories'); local q=b:point(m,'q'); local input=b:strand(m,{q},'input'); local world=b:finish()
local function route(name,marked)
  local d=W.builder(); local dm=d:membrane(nil,name); local Q=d:point(dm,'Q'); local i=d:strand(dm,{Q},'in'); local pts={Q}
  if marked then local M=d:point(dm,marked); pts={Q,M} end
  local o=d:strand(dm,pts,'out'); d:face(dm,{i},{o},name); return {g=d:finish(),i=i,o=o}
end
local function run(r)
  local s=W.solve(world,r.g,{{from=input,to=r.i}}); local tag,es=s:step(math.huge); eq(tag,'yes'); local live,img=W.advance(world,r.g,es); return img[r.o]
end
local h1=run(route('h1',nil)); local h2=run(route('h2',nil)); local h3=run(route('h3','record-3'))
eq(T.row_key(W,h1),T.row_key(W,h2)); ok(T.row_key(W,h1)~=T.row_key(W,h3))

-- A finite decoherence functional D. Event weight is mu(A)=sum_{i,j in A} D_ij.
local function mu(D,set)
  local s=0; for _,i in ipairs(set) do for _,j in ipairs(set) do s=s+D[i][j] end end; return s
end
local a={0.3,0.4,math.sqrt(0.51)}
local coherent={}; for i=1,3 do coherent[i]={}; for j=1,3 do coherent[i][j]=a[i]*a[j] end end
local A={1,2}; local B={3}; local ALL={1,2,3}
ok(math.abs(mu(coherent,ALL)-(mu(coherent,A)+mu(coherent,B)))>0.1,'fully coherent fine histories do not define an additive classical measure on this partition')

-- Make h3 distinguishable/environmentally recorded. Coherence survives inside the
-- structurally indistinguishable class {h1,h2}, but cross-class terms vanish.
local block={{a[1]^2,a[1]*a[2],0},{a[2]*a[1],a[2]^2,0},{0,0,a[3]^2}}
approx(mu(block,A),0.49); approx(mu(block,B),0.51); approx(mu(block,ALL),1)
approx(mu(block,ALL),mu(block,A)+mu(block,B),'the boundary classes now obey ordinary finite additivity')
ok(math.abs(mu(block,A)-(mu(block,{1})+mu(block,{2})))>0.1,'quantum interference may remain inside one classical coarse-grained event')

-- Refine observation enough to distinguish h1 and h2 as well: the decoherence
-- functional becomes diagonal and a full classical distribution over exact
-- histories emerges.
local norm=a[1]^2+a[2]^2+a[3]^2
local diag={{a[1]^2/norm,0,0},{0,a[2]^2/norm,0},{0,0,a[3]^2/norm}}
approx(mu(diag,{1})+mu(diag,{2})+mu(diag,{3}),1)
approx(mu(diag,{1,2}),mu(diag,{1})+mu(diag,{2}))
approx(mu(diag,{1,3}),mu(diag,{1})+mu(diag,{3}))
approx(mu(diag,{2,3}),mu(diag,{2})+mu(diag,{3}))

print('decoherent history measure: '..T.count()..' assertions passed')
print('  classical Kolmogorov additivity appears first on decoherent boundary classes, even while exact histories inside a class remain quantum-coherent')
