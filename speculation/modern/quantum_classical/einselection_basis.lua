local HERE='./speculation/modern/quantum_classical'; package.path='./src/?.lua;./src/?/init.lua;'..HERE..'/?.lua;'..package.path
local W=require('worlds'); local T=require('common'); T.reset()
local ok,eq=T.ok,T.eq
local s=1/math.sqrt(2); local H={{s,s},{s,-s}}; local I={{1,0},{0,1}}
local CNOT={{1,0,0,0},{0,1,0,0},{0,0,0,1},{0,0,1,0}}
local HI=T.kron(H,I); local UX=T.mm(T.mm(HI,CNOT),HI)
local function env0(rho) return T.kron(rho,{{1,0},{0,0}}) end
local function reduced_channel(U,rho) return T.partial_trace_env2(T.apply_unitary(U,env0(rho))) end
local function DZ(rho) return reduced_channel(CNOT,rho) end
local function DX(rho) return reduced_channel(UX,rho) end

local z0={{1,0},{0,0}}; local z1={{0,0},{0,1}}; local plus={{0.5,0.5},{0.5,0.5}}; local minus={{0.5,-0.5},{-0.5,0.5}}
ok(T.meq(DZ(z0),z0) and T.meq(DZ(z1),z1),'Z-recording leaves Z pointer states fixed')
ok(not T.meq(DZ(plus),plus),'same interaction decoheres a superposition of Z pointer states')
ok(T.meq(DX(plus),plus) and T.meq(DX(minus),minus),'rotated environment coupling selects X pointer states instead')
ok(not T.meq(DX(z0),z0),'X-recording decoheres a Z eigenstate')
ok(T.meq(DZ(DZ(plus)),DZ(plus)),'selected classicalisation channel is idempotent')
ok(T.meq(DX(DX(z0)),DX(z0)),'rotated classicalisation channel is also idempotent')

-- The Worlds process shape need not change with the selected pointer basis.
local b=W.builder(); local m=b:membrane(nil,'system+environment'); local q=b:point(m,'q'); local e=b:point(m,'e')
local iq=b:strand(m,{q},'q.in'); local ie=b:strand(m,{e},'e.in'); local oq=b:strand(m,{q},'q.out'); local oe=b:strand(m,{e},'e.out'); b:face(m,{iq,ie},{oq,oe},'environment interaction')
local g=b:finish(); eq(#g:faces(),1); eq(#g:ingress(),2); eq(#g:egress(),2)

print('einselection/pointer basis: '..T.count()..' assertions passed')
print('  the classical fixed algebra is selected by the quantum interaction semantics, not by adding a classical carrier or hard-wiring a basis into Worlds')
