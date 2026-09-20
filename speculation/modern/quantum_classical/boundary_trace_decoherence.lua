local HERE='./speculation/modern/quantum_classical'; package.path='./src/?.lua;./src/?/init.lua;'..HERE..'/?.lua;'..package.path
local W=require('worlds'); local T=require('common'); T.reset()
local ok,eq,approx=T.ok,T.eq,T.approx

-- Geometry: system and one environment authority. The environment can be made
-- internal while system authority survives at the open boundary.
local wb=W.builder(); local root=wb:membrane(nil,'root')
local q=wb:point(root,'q'); local e=wb:point(root,'e')
local aq=wb:strand(root,{q},'system'); local ae=wb:strand(root,{e},'environment')
local initial=wb:finish()

local function cnot_dev(name)
  local b=W.builder(); local m=b:membrane(nil,name); local Q=b:point(m,'Q'); local E=b:point(m,'E')
  local iq=b:strand(m,{Q},'q.in'); local ie=b:strand(m,{E},'e.in')
  local oq=b:strand(m,{Q},'q.out'); local oe=b:strand(m,{E},'e.out')
  b:face(m,{iq,ie},{oq,oe},name)
  return {g=b:finish(),iq=iq,ie=ie,oq=oq,oe=oe}
end
local function apply2(world,qauth,eauth,dev)
  local s=W.solve(world,dev.g,{{from=qauth,to=dev.iq},{from=eauth,to=dev.ie}})
  local tag,es=s:step(math.huge); eq(tag,'yes','two-system gate must match')
  local live,img=W.advance(world,dev.g,es); return live,img[dev.oq],img[dev.oe]
end
local function retire_env(world,eauth)
  local b=W.builder(); local m=b:membrane(nil,'environment-sink'); local E=b:point(m,'E')
  local i=b:strand(m,{E},'env'); b:face(m,{i},{},'hide environment'); local d=b:finish()
  local s=W.solve(world,d,{{from=eauth,to=i}}); local tag,es=s:step(math.huge); eq(tag,'yes')
  local live=W.advance(world,d,es); return live
end

local ent=cnot_dev('entangle')
local ent_live,q1,e1=apply2(initial,aq,ae,ent)
local decoh_live=retire_env(ent_live,e1)
eq(#decoh_live:egress(),1,'only system authority remains open after environment is hidden')
eq(W.points(decoh_live:egress()[1])[1],q,'surviving system keeps exact subsystem identity')

-- Quantum Theory: start |+>|0>, entangle by CNOT, then trace the hidden e.
local s=1/math.sqrt(2)
local plus0={s,0,s,0}
local rho0=T.outer(plus0)
local CNOT={{1,0,0,0},{0,1,0,0},{0,0,0,1},{0,0,1,0}}
local rho_ent=T.apply_unitary(CNOT,rho0)
local rho_q=T.partial_trace_env2(rho_ent)
approx(rho_q[1][1],0.5); approx(rho_q[2][2],0.5)
approx(rho_q[1][2],0); approx(rho_q[2][1],0)
local plus_rho={{0.5,0.5},{0.5,0.5}}
ok(T.meq(rho_q,T.dephase2(plus_rho)),'hiding an entangled environment yields exactly the dephased system state')
ok(T.meq(T.dephase2(rho_q),rho_q),'result is a fixed point of dephasing')

-- If the environment is coherently uncomputed before it becomes internal, the
-- same final causal interface retains the original coherence.
local ent2=cnot_dev('uncompute')
local un_live,q2,e2=apply2(ent_live,q1,e1,ent2)
local restored_live=retire_env(un_live,e2)
eq(#restored_live:egress(),1)
eq(W.points(restored_live:egress()[1])[1],q)
local rho_un=T.apply_unitary(CNOT,rho_ent)
local rho_restored=T.partial_trace_env2(rho_un)
ok(T.meq(rho_restored,plus_rho),'coherent erasure before hiding restores |+> exactly')
approx(rho_restored[1][2],0.5,'off-diagonal coherence survives after uncomputation')

-- The open Worlds shape is the same kind of one-system interface in both cases;
-- the extensional difference is precisely what Theory must retain.
eq(#decoh_live:egress(),#restored_live:egress())
eq(#W.points(decoh_live:egress()[1]),#W.points(restored_live:egress()[1]))
eq(W.points(decoh_live:egress()[1])[1],W.points(restored_live:egress()[1])[1])

print('boundary trace/decoherence: '..T.count()..' assertions passed')
print('  closed environment + Theory partial trace yields a classical fixed point; coherent uncompute restores phase')
