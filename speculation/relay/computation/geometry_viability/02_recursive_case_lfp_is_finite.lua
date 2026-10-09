local H=require('speculation.relay.computation.geometry_viability.common')
 local ok,eq,count=H.counter()
local p=H.one_root('f',{H.authority_identity_context(),H.unary_context({definition='f'})})
local a=H.Analysis.compute(p)
 local r=p:root('f')
 local n=0
 for _ in pairs(a.behaviour[r]) do n=n+1 end
eq(n,2,'recursive authority chain should collapse to identity and causal-transition boundary cases')
ok(a.rounds<8,'boundary-case fixed point took unexpected rounds')
ok(a.collisions>0,'deeper recursive histories never collided in the boundary quotient')
print('PASS gv 02: recursive Geometry+Theory viability reaches a finite boundary-case fixed point ('..count()..')')
