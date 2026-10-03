local H=require('speculation.showcases.transactions.transactional_recurrence_calculus.common')
local ok,eq,count=H.counter()
local p=H.rec_package('loop',{H.authority_identity_context(),H.unary_context({definition='loop'})})
local q=H.roundtrip(p)
eq(q:bytes(),p:bytes(),'recursive Package roundtrip changed bytes')
ok(q:definition(p:root('loop'))~=nil,'decoded Package lost semantic root')
local bad=p:bytes()..'x'
 ok(not pcall(H.RP.decode,bad),'malformed recursive transport accepted')
print('PASS tr 03: recursive Package transport is canonical ('..count()..')')
