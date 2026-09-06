local S=require('tests.support')
local G,A=S.G,S.A

-- Two exposed membranes have same-sort identities. A pattern Point located in
-- the source membrane must not be identified with an identity located in the
-- target membrane merely because both are visible.
local b=G.builder()
local S0=b:membrane(nil,'place','S')
local T0=b:membrane(nil,'place','T')
local ps=b:point(S0,'X','source-x')
local pt=b:point(T0,'Y','target-y')
local gate=b:strand(S0,'Gate',{ps},'gate')
local base=b:finish()

local p=G.builder()
local D=p:membrane(nil,'place','D')
local qgate=p:point(D,'X','qgate')
local qy=p:point(D,'Y','qy')
local gi=p:strand(D,'Gate',{qgate},'in')
local out=p:strand(D,'Out',{qy},'out')
p:face(D,'step',{gi},{out})
local pat=p:finish()

-- Y exists only in T, whereas qy belongs to D which gate attachment binds to S.
-- A genuine incidence-preserving gluing therefore has no attachment.
local ws=A.all(base,{S0,T0},pat)
S.eq(#ws,0,'Point location must be preserved by attachment')

print('ok 16_point_locality')
