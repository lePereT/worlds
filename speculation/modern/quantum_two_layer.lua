-- Worlds 0.6.2 quantum research toy.
--
-- Keep the exact kernel classical. Use one family of Strands for scarce causal
-- subsystem authority and another family over the same Points for amplitude
-- factor scope. A tiny external amplitude calculation decides separability;
-- Worlds only exposes the candidate factorisation shape.

package.path='./src/?.lua;./src/?/init.lua;'..package.path
local W=require('worlds')

local n=0
local function ok(x,msg) n=n+1; assert(x,msg or 'assertion failed') end
local function eq(a,b,msg) n=n+1; assert(a==b,(msg or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end

local wb=W.builder(); local wm=wb:membrane(nil,'quantum-world')
local q=wb:point(wm,'q'); local e=wb:point(wm,'e')
local aq=wb:strand(wm,{q},'authority.q')
local ae=wb:strand(wm,{e},'authority.e')
local fq=wb:strand(wm,{q},'amplitude-factor.q')
local fe=wb:strand(wm,{e},'amplitude-factor.e')
local world=wb:finish()

-- Entangling realisation: causal authorities remain separate exact occurrences,
-- while amplitude factor scope becomes joint over q,e.
local d=W.builder(); local dm=d:membrane(nil,'entangle')
local Q=d:point(dm,'Q'); local E=d:point(dm,'E')
local iaq=d:strand(dm,{Q},'in.authority.q'); local iae=d:strand(dm,{E},'in.authority.e')
local ifq=d:strand(dm,{Q},'in.factor.q'); local ife=d:strand(dm,{E},'in.factor.e')
local oaq=d:strand(dm,{Q},'out.authority.q'); local oae=d:strand(dm,{E},'out.authority.e')
local joint=d:strand(dm,{Q,E},'joint-factor(q,e)')
d:face(dm,{iaq,iae,ifq,ife},{oaq,oae,joint},'entangle')
local dev=d:finish()

local seeds={{from=aq,to=iaq},{from=ae,to=iae},{from=fq,to=ifq},{from=fe,to=ife}}
local solver=W.solve(world,dev,seeds)
local tag,eqs=solver:step(math.huge)
eq(tag,'yes','entangling development should match exact authority/factor inputs')
local live,image=W.advance(world,dev,eqs)
ok(live:owns_strand(image[oaq]) and live:owns_strand(image[oae]),'separate causal authorities remain live')
local jf=image[joint]
ok(live:owns_strand(jf),'joint amplitude-factor occurrence is live')
eq(W.points(jf)[1],q); eq(W.points(jf)[2],e)

-- Candidate geometric split of a joint factor. Worlds can express the shape;
-- domain Theory must decide whether a particular amplitude actually factorises.
local s=W.builder(); local sm=s:membrane(nil,'split')
local SQ=s:point(sm,'Q'); local SE=s:point(sm,'E')
local sin=s:strand(sm,{SQ,SE},'joint')
local sq=s:strand(sm,{SQ},'q-factor'); local se=s:strand(sm,{SE},'e-factor')
s:face(sm,{sin},{sq,se},'candidate-factorisation')
local split=s:finish()
local split_solver=W.solve(live,split,{{from=jf,to=sin}})
local stag,seqs=split_solver:step(math.huge)
eq(stag,'yes','Geometry permits the candidate split shape')

-- For a pure two-qubit state represented as a 2x2 amplitude matrix, rank one
-- (zero determinant) is the simple separability test. These are pre-determined
-- toy amplitudes; no external linear algebra package is used.
local function separable(M)
  return M[1][1]*M[2][2]-M[1][2]*M[2][1]==0
end
local product={{1,2},{3,6}}       -- outer product [1,3]^T [1,2]
local bell={{1,0},{0,1}}          -- unnormalised |00> + |11>
ok(separable(product),'product amplitude is rank one')
ok(not separable(bell),'Bell amplitude is not rank one')

-- Worlds cannot and should not distinguish those two amplitude values from the
-- scope alone. The same exact candidate split geometry exists in both cases.
ok(stag=='yes','structural candidate remains independent of amplitude truth')

-- Scarcity still prevents implicit duplication of exact causal authority: one
-- authority occurrence cannot satisfy two simultaneous target requirements.
local c=W.builder(); local cm=c:membrane(nil,'clone-attack'); local X=c:point(cm,'X')
local c1=c:strand(cm,{X},'need1'); local c2=c:strand(cm,{X},'need2'); local clone_attack=c:finish()
local clone_solver=W.solve(W.boundary(live),clone_attack)
local ctag=clone_solver:step(math.huge)
-- There are other live Strands over q/e, so constrain this observation to the
-- exact q authority by asking a seeded two-use construction directly: join must
-- reject reusing one source egress in two equations.
local ok_join=pcall(function()
  W.join({W.boundary(live),clone_attack},{{from=image[oaq],to=c1},{from=image[oaq],to=c2}})
end)
ok(not ok_join,'one exact authority cannot be spent twice by implicit gluing')

print('modern quantum two-layer: '..n..' assertions passed')
print('  structural factorisation is Geometry; separability remains domain truth')
