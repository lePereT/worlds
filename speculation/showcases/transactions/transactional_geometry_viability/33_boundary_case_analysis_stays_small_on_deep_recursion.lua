local H=require('speculation.showcases.transactions.transactional_geometry_viability.common')
 local ok,eq,count=H.counter()
local p=H.one_root('f',{H.authority_identity_context(),H.unary_context({definition='f'}),H.unary_context({definition='f'},{suffix=true})})
 local a=H.Analysis.compute(p)
 local r=p:root('f')
 local n=0
for _ in pairs(a.behaviour[r]) do n=n+1 end
ok(n<=3,'finite authority quotient retained recursive history')
 ok(a.rounds<=5,'fixed point followed unfolding depth rather than boundary cases')
print('PASS gv 33: recursive authority viability saturates by boundary cases rather than history depth ('..count()..')')
