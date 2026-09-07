package.path='../src/?.lua;../src/?/init.lua;./?.lua;'..package.path
local W=require('worlds'); local G=W.Geometry
local N=0; local function ok(x,m) N=N+1; assert(x,m or ('shape assertion '..N)) end; local function eq(a,b,m) N=N+1; assert(a==b,(m or 'shape mismatch')..': '..tostring(a)..' ~= '..tostring(b)) end

local vb=G.builder(); local vm=vb:membrane(nil,'vocab'); local R=vb:point(vm,'R'); local A=vb:point(vm,'A'); local B=vb:point(vm,'B'); vb:finish()

-- S1. Homogeneous scarce matching uses linear query state and linear first-hit work.
local function homogeneous(n)
  local ob=G.builder(); local om=ob:membrane(nil,'offers'); local offers={}; for i=1,n do offers[i]=ob:strand(om,{R}) end; ob:finish()
  local pb=G.builder(); local pm=pb:membrane(nil,'pattern'); for i=1,n do pb:strand(pm,{R}) end; local p=pb:finish()
  local q=W.Cut.query(p,{offers=offers}); local k,c=q:step(n+1); eq(k,'Hit'); local s=q:stats(); eq(s.steps,n,'first witness candidate work'); eq(s.demands,n); eq(s.offers,n); eq(s.pool,n); eq(s.candidate_matrix_cells,0,'no demand x offer matrix')
end
for _,n in ipairs{1,10,100,1000,10000} do homogeneous(n) end; print('shape Cut homogeneous: n=10000 => steps=10000, matrix-cells=0')

-- S2. Budget is structural work: 100 steps means exactly 100 candidate checks.
do
  local n=1000; local ob=G.builder(); local om=ob:membrane(nil,'o'); local offers={}; for i=1,n do offers[i]=ob:strand(om,{R}) end; ob:finish(); local pb=G.builder(); local pm=pb:membrane(nil,'p'); for i=1,n do pb:strand(pm,{R}) end; local p=pb:finish(); local q=W.Cut.query(p,{offers=offers}); eq(q:step(100),'Unknown'); eq(q:stats().steps,100); eq(q:step(1000),'Hit'); eq(q:stats().steps,n)
end


-- S2b. Incompatible offers still consume the declared structural work budget.
do
  local n=1000
  local ob=G.builder(); local om=ob:membrane(nil,'irrelevant'); local offers={}
  for i=1,n do offers[i]=ob:strand(om,{A,B}) end
  ob:finish()
  local pb=G.builder(); local pm=pb:membrane(nil,'wanted'); pb:strand(pm,{R}); local p=pb:finish()
  local q=W.Cut.query(p,{offers=offers})
  eq(q:step(100),'Unknown','incompatible offer scans must not hide outside the budget')
  eq(q:stats().steps,100,'every examined incompatible offer counts as work')
  eq(q:step(1000),'Retry')
  eq(q:stats().steps,n)
end

-- S3. Long-running operational state stays one live Strand while exact history grows.
do
  local function trans(from,to) local p=G.builder(); local m=p:membrane(nil,'t'); local i=p:strand(m,{from}); local o=p:strand(m,{to}); p:face(m,{i},{o}); return p:finish(),i,o end
  local b=G.builder(); local m=b:membrane(nil,'state'); local cur=b:strand(m,{A}); local history=b:finish(); local boundary=W.Operational.from_geometry(history); local ab,abi,abo=trans(A,B); local ba,bai,bao=trans(B,A)
  for i=1,200 do local p,pi,po= i%2==1 and ab or ba, i%2==1 and abi or bai, i%2==1 and abo or bao; local q=W.Operational.query(boundary,p,{strands={[pi]=cur}}); local k,w=q:step(2); eq(k,'Hit'); eq(q:stats().steps,1); local _,opimg=W.Operational.commit(w); local cut=W.Cut.one(p,{strands={[pi]=history:egress()[1]}}); history=select(1,W.Algebra.apply(history,p,cut)); cur=opimg.strands[po]; eq(boundary:size(),1) end
  eq(#history:faces(),200,'exact reference history records every occurrence'); eq(#history:egress(),1); eq(boundary:size(),1,'operational state scales with live boundary'); print('shape state/history: transitions=200, history-faces=200, boundary=1')
end

-- S4. 10,000 unrelated siblings remain exact frame authority; local transition touches none of them semantically.
do
  local b=G.builder(); local root=b:membrane(nil,'root'); local target; local untouched={}
  for i=1,10000 do local m=b:membrane(root,'m'); local s=b:strand(m,{R}); if i==5000 then target=s else untouched[#untouched+1]=s end end
  local boundary=W.Operational.from_geometry(b:finish()); local p=G.builder(); local pm=p:membrane(nil,'t'); local i=p:strand(pm,{R}); local o=p:strand(pm,{R}); p:face(pm,{i},{o}); local proc=p:finish()
  for _=1,100 do local q=W.Operational.query(boundary,proc,{strands={[i]=target}}); local k,w=q:step(2); eq(k,'Hit'); eq(q:stats().steps,1); local _,img=W.Operational.commit(w); target=img.strands[o] end
  eq(boundary:size(),10000); for _,s in ipairs(untouched) do ok(boundary:contains(s),'frame authority must retain exact occurrence') end; print('shape locality: siblings=10000, locally-updated=1, untouched=9999')
end

-- S5. One-shot cut assembly has linear structural size: n parts, n-1 cuts => n Faces, one ingress, one egress.
do
  local n=1000; local parts,ins,outs={},{},{}; local a=W.Algebra.builder()
  for i=1,n do local b=G.builder(); local m=b:membrane(nil,'s'); ins[i]=b:strand(m,{R}); outs[i]=b:strand(m,{R}); b:face(m,{ins[i]},{outs[i]}); parts[i]=b:finish(); a:add(parts[i]); if i>1 then a:cut(outs[i-1],ins[i]) end end
  local g=a:finish(); eq(#g:faces(),n); eq(#g:ingress(),1); eq(#g:egress(),1); print('shape assembly: parts=1000, cuts=999, faces=1000, ingress=1, egress=1')
end

-- S6. Large simultaneous support ring normalises by shape, not by chosen serialisation.
do
  local n=64; local parts,ins,outs={},{},{}; for i=1,n do local b=G.builder(); local root=b:membrane(nil,'root'); local child=b:membrane(root,'child'); ins[i]=b:strand(child,{R}); local ii={ins[i]}; if i==1 then ii[#ii+1]=b:strand(child,{A}) end; outs[i]=b:strand(child,{R}); b:face(child,ii,{outs[i]}); parts[i]=b:finish() end
  local links={}; for i=1,n do links[i]={outs[i],ins[i%n+1]} end; local g=W.Algebra.close(parts,links); eq(#g:faces(),1,'support SCC contracts to one indivisible occurrence'); eq(#g:ingress(),1); eq(#g:egress(),0); print('shape simultaneous: ring-faces=64 => joint-faces=1')
end

print('PASS shape benchmarks',N,'structural assertions')
