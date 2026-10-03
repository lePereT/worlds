local H=require('speculation.showcases.transactions.transactional_recurrence_calculus.common')
local ok,eq,count=H.counter()
local p=H.rec_package('loop',{H.authority_identity_context(),H.unary_context({definition='loop'})})
local n=#p:bytes()
 local root=p:root('loop')
for d=1,8 do eq(#p:bytes(),n,'cyclic Package grew while inspecting deeper approximant') end
ok(#H.Unfold.package(p,root,8):bytes()>n,'finite expanded meaning unexpectedly smaller than cyclic presentation')
print('PASS tr 22: recurrence is finite sharing, not retained unfolding history ('..count()..')')
