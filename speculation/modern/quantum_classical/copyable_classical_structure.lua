local HERE='./speculation/modern/quantum_classical'; package.path='./src/?.lua;./src/?/init.lua;'..HERE..'/?.lua;'..package.path
local W=require('worlds'); local T=require('common'); T.reset()
local ok,eq=T.ok,T.eq

-- Worlds permits copying only as an explicit causal act: one exact authority in,
-- two fresh exact authorities out, all carrying the same persistent Point.
local b=W.builder(); local m=b:membrane(nil,'copy'); local q=b:point(m,'q'); local i=b:strand(m,{q},'in'); local o1=b:strand(m,{q},'out1'); local o2=b:strand(m,{q},'out2'); b:face(m,{i},{o1,o2},'explicit copy candidate'); local g=b:finish()
eq(#g:ingress(),1); eq(#g:egress(),2); ok(o1~=o2); eq(W.points(o1)[1],q); eq(W.points(o2)[1],q)

-- Quantum Theory can interpret that shape by the standard classical copying map
-- Delta|0>=|00>, Delta|1>=|11>. It is not the universal quantum cloner.
local Delta={{1,0},{0,0},{0,0},{0,1}} -- 4x2
local eps={{1,1}}                    -- 1x2 algebraic delete/counit
local I={{1,0},{0,1}}
local left=T.mm(T.kron(Delta,I),Delta)
local right=T.mm(T.kron(I,Delta),Delta)
ok(T.meq(left,right),'copy map is coassociative')
local swap={{1,0,0,0},{0,0,1,0},{0,1,0,0},{0,0,0,1}}
ok(T.meq(T.mm(swap,Delta),Delta),'copy map is cocommutative')
ok(T.meq(T.mm(T.kron(eps,I),Delta),I),'left deletion is a counit')
ok(T.meq(T.mm(T.kron(I,eps),Delta),I),'right deletion is a counit')
ok(T.meq(T.mm(T.transpose(Delta),Delta),I),'copying is special/isometric on the classical basis')

local z0={1,0}; local z1={0,1}; local s=1/math.sqrt(2); local plus={s,s}
ok(T.veq(T.mv(Delta,z0),{1,0,0,0}) and T.veq(T.mv(Delta,z1),{0,0,0,1}),'basis states are copied exactly')
ok(not T.veq(T.mv(Delta,plus),T.kron({plus},{plus})[1] or {}),'generic superposition is not cloned')
-- Explicit comparison without relying on vector kron helper.
local copied_plus=T.mv(Delta,plus); local cloned_plus={0.5,0.5,0.5,0.5}
ok(not T.veq(copied_plus,cloned_plus),'|+> becomes an entangled correlation rather than |+>|+>')

print('copyable classical structure: '..T.count()..' assertions passed')
print('  the explicit Worlds split shape supports a commutative copying algebra whose copyable states are classical basis data, not arbitrary quantum states')
