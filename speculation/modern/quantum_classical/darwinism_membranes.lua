local HERE='./speculation/modern/quantum_classical'; package.path='./src/?.lua;./src/?/init.lua;'..HERE..'/?.lua;'..package.path
local W=require('worlds'); local T=require('common'); T.reset()
local ok,eq,approx=T.ok,T.eq,T.approx
local N=4

-- One system identity and four disjoint environment fragments.
local b=W.builder(); local root=b:membrane(nil,'world'); local q=b:point(root,'pointer-q'); local aq=b:strand(root,{q},'system')
local env={}
for i=1,N do local m=b:membrane(root,'fragment-'..i); local e=b:point(m,'e'..i); local a=b:strand(m,{e},'blank-'..i); env[i]={m=m,e=e,a=a} end
local world=b:finish()

-- A joint interaction creates one exact record occurrence in each independent
-- membrane. Each record is local to its fragment but structurally mentions the
-- same persistent system Point q.
local d=W.builder(); local dr=d:membrane(nil,'interaction'); local Q=d:point(dr,'Q'); local iq=d:strand(dr,{Q},'q.in'); local ins={iq}; local outs={}; local loc={}
for i=1,N do local m=d:membrane(dr,'fragment-'..i); local E=d:point(m,'E'..i); local ii=d:strand(m,{E},'blank.in.'..i); ins[#ins+1]=ii; loc[i]={m=m,E=E,i=ii} end
local oq=d:strand(dr,{Q},'q.out'); outs[#outs+1]=oq
for i=1,N do local r=d:strand(loc[i].m,{Q,loc[i].E},'record.'..i); loc[i].o=r; outs[#outs+1]=r end
d:face(dr,ins,outs,'environment records pointer')
local dev=d:finish(); local seeds={{from=aq,to=iq}}; for i=1,N do seeds[#seeds+1]={from=env[i].a,to=loc[i].i} end
local s=W.solve(world,dev,seeds); local tag,es=s:step(math.huge); eq(tag,'yes')
local live,img=W.advance(world,dev,es); eq(#live:egress(),N+1)
local records={}
for i=1,N do
  local r=img[loc[i].o]; records[i]=r
  eq(W.membrane(r),env[i].m,'record lands in its independent environment membrane')
  eq(W.points(r)[1],q,'every record names the same exact pointer identity')
  eq(W.points(r)[2],env[i].e)
end

-- Quantum Theory: |+>|0000> -> GHZ = (|00000> + |11111>)/sqrt(2).
-- A minus relative phase gives a globally distinct quantum state with identical
-- proper-fragment reductions.
local dim=2^(N+1); local ghz_plus={}; local ghz_minus={}; for i=1,dim do ghz_plus[i]=0; ghz_minus[i]=0 end
local a=1/math.sqrt(2); ghz_plus[1]=a; ghz_plus[dim]=a; ghz_minus[1]=a; ghz_minus[dim]=-a
local system_red=T.reduced_density_real_pure(ghz_plus,N+1,{1})
ok(T.meq(system_red,{{0.5,0},{0,0.5}}),'environmental recording decoheres the system pointer basis')

for i=1,N do
  local pair=T.reduced_density_real_pure(ghz_plus,N+1,{1,i+1})
  local pair_minus=T.reduced_density_real_pure(ghz_minus,N+1,{1,i+1})
  ok(T.meq(pair,pair_minus),'global relative phase is invisible to each proper record fragment')
  local probs=T.diagprob(pair)
  approx(probs[1],0.5); approx(probs[2],0); approx(probs[3],0); approx(probs[4],0.5)
  local Hs=1; local He=1; local Hjoint=T.entropy_probs(probs)
  approx(Hs+He-Hjoint,1,'each fragment carries one full classical bit about the pointer value')
end

-- The phase is genuinely present globally: plus and minus vectors differ and have
-- opposite overlap on the |11111> branch.
ok(not T.veq(ghz_plus,ghz_minus),'global quantum states remain distinct')
approx(ghz_plus[dim]*ghz_minus[dim],-0.5)

-- Reading/using one exact record need not consume the other redundant records.
local rb=W.builder(); local rm=rb:membrane(nil,'read-fragment'); local X=rb:point(rm,'X')
local ri=rb:strand(rm,{q,X},'record.in'); local ro=rb:strand(rm,{q,X},'record.out'); rb:face(rm,{ri},{ro},'read'); local rd=rb:finish()
local rs=W.solve(live,rd,{{from=records[1],to=ri}}); local rtag,res=rs:step(math.huge); eq(rtag,'yes')
local after,rimg=W.advance(live,rd,res)
ok(after:owns_strand(rimg[ro]),'read record remains available as explicit reissued authority')
for i=2,N do ok(after:owns_strand(records[i]),'other environment records survive literally') end

print('Darwinism/membrane redundancy: '..T.count()..' assertions passed')
print('  one quantum pointer observable becomes many independent exact records; each local fragment is classical while global phase remains nonlocal')
