local H=require('speculation.relay.computation.development_calculus.common')
local ok,eq,count=H.counter()
 local C=H.C
local p=C.bind(C.always(true),H.branch({{true,'ok'},{false,'bad'}}))
local bytes=p:bytes()
for _,word in ipairs({'TransactionContext','OutputRef','OrderedFamily','coroutine','search','perform','Live'}) do ok(not bytes:find(word,1,true),'Package leaked '..word) end
print('PASS td 25: Package contains no live transaction/runtime machinery ('..count()..')')
