local H=require('speculation.showcases.transactions.transactional_geometry_viability.common')
 local ok,eq,count=H.counter()
local t=assert(H.Context.plug(H.authority_identity_context(),{}))
 ok(H.A.complete(t),'base boundary incomplete')
for i=1,8 do t=assert(H.Context.plug(H.unary_context({definition='x'},{suffix=i%2==0}),{t}))
 ok(H.A.complete(t),'recursive plug lost total authority boundary at depth '..i) end
print('PASS gv 39: ordinary recursive composition preserves a complete semantic authority boundary ('..count()..')')
