local HERE='./speculation/modern/quantum_classical'; package.path='./src/?.lua;./src/?/init.lua;'..HERE..'/?.lua;'..package.path
local W=require('worlds'); local T=require('common'); T.reset()
local ok,eq,approx=T.ok,T.eq,T.approx

local I={{1,0},{0,1}}; local X={{0,1},{1,0}}
local function bitflip(p) return {T.scale(I,math.sqrt(1-p)),T.scale(X,math.sqrt(p))},{{1-p,p},{p,1-p}} end
local function damping(g)
  return {{{1,0},{0,math.sqrt(1-g)}},{{0,math.sqrt(g)},{0,0}}},{{1,g},{0,1-g}}
end
local K1,P1=bitflip(0.2); local K2,P2=damping(0.3)
local function channel(K,rho) return T.apply_kraus(K,rho) end
local function compose_channel(Kb,Ka,rho) return channel(Kb,channel(Ka,rho)) end

-- Dephasing is an idempotent projection. Its fixed points are exactly diagonal
-- density matrices, identifiable with classical probability vectors.
local rho={{0.7,0.2},{0.2,0.3}}
local D=T.dephase2(rho)
ok(T.meq(T.dephase2(D),D),'dephasing is idempotent')
approx(T.trace(D),1)
local p=T.diagprob(D); approx(p[1]+p[2],1)

-- These quantum channels preserve the classical fixed sector and commute with
-- dephasing. Their restriction is exactly stochastic matrix action.
for idx,K in ipairs{K1,K2} do
  local q=channel(K,rho); local lhs=T.dephase2(q); local rhs=channel(K,D)
  ok(T.meq(lhs,rhs),('channel %d commutes with classicalisation'):format(idx))
  approx(T.trace(q),1)
end
local qcomp=compose_channel(K2,K1,D)
local Pcomp=T.mm(P2,P1); local pcomp=T.matvec_prob(Pcomp,p)
ok(T.veq(T.diagprob(qcomp),pcomp),'restriction of composed quantum channels is composed Markov transition')
approx(pcomp[1]+pcomp[2],1)

-- Conversely the diagonal quantum state contains no more information than the
-- classical distribution: embedding then projecting is identity.
local function embed(v) return {{v[1],0},{0,v[2]}} end
ok(T.meq(T.dephase2(embed(p)),embed(p)))
ok(T.veq(T.diagprob(embed(p)),p))

-- Put the same two operations on an actual Worlds causal chain.
local function gate(name)
  local b=W.builder(); local m=b:membrane(nil,name); local Q=b:point(m,'Q')
  local i=b:strand(m,{Q},name..'.in'); local o=b:strand(m,{Q},name..'.out'); b:face(m,{i},{o},name)
  return {g=b:finish(),i=i,o=o}
end
local a=gate('bitflip'); local b=gate('damping')
local chain=W.join({a.g,b.g},{{from=a.o,to=b.i}})
eq(#chain:faces(),2); eq(#chain:ingress(),1); eq(#chain:egress(),1)
-- Quantum semantics on the chain is channel composition; on the fixed sector it
-- is therefore the ordinary Markov chain P2 P1.
local pin={0.4,0.6}; local rin=embed(pin)
local rout=compose_channel(K2,K1,rin); local pout=T.matvec_prob(Pcomp,pin)
ok(T.veq(T.diagprob(rout),pout))

-- Parallel independent processes similarly restrict from tensor product quantum
-- semantics to product stochastic semantics.
local par=W.join({a.g,gate('second-bitflip').g},{})
eq(#par:faces(),2); eq(#par:ingress(),2); eq(#par:egress(),2)
local PP=T.kron(P1,P1); local joint={0.12,0.28,0.18,0.42}
local jout=T.matvec_prob(PP,joint); approx(jout[1]+jout[2]+jout[3]+jout[4],1)


-- In fact every finite two-state stochastic matrix has a direct quantum
-- realisation K_{j,i}=sqrt(P_{j,i}) |j><i|. This gives a CPTP channel whose
-- restriction to diagonal states is exactly P (and which discards coherence).
local function embed_stochastic(P)
  local Ks={}
  for j=1,2 do for i=1,2 do
    local K={{0,0},{0,0}}; K[j][i]=math.sqrt(P[j][i]); Ks[#Ks+1]=K
  end end
  return Ks
end
for _,Pg in ipairs{
  {{0.9,0.4},{0.1,0.6}},
  {{0.25,0.7},{0.75,0.3}},
  {{1,0.15},{0,0.85}}
} do
  local Kg=embed_stochastic(Pg); local comp={{0,0},{0,0}}
  for _,K in ipairs(Kg) do comp=T.add(comp,T.mm(T.transpose(K),K)) end
  ok(T.meq(comp,I),'generic stochastic embedding is trace preserving')
  local vin={0.37,0.63}; local qr=channel(Kg,embed(vin)); local vr=T.matvec_prob(Pg,vin)
  ok(T.veq(T.diagprob(qr),vr),'generic embedded channel restricts to its stochastic matrix')
  ok(T.meq(qr,T.dephase2(qr)),'generic classical channel lands in the dephased fixed sector')
end

print('classical stochastic fixed sector: '..T.count()..' assertions passed')
print('  diagonal fixed points of quantum dephasing form ordinary probability states; preserving channels restrict to Markov maps')
