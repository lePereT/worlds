local H=require('speculation.relay.computation.development_calculus.common')
local ok,eq,count=H.counter()
 local C=H.C
ok(C.fix==nil,'finite laboratory accidentally smuggled recurrence machinery')
local p=C.always('finite')
 eq(#p:family().items,1)
print('PASS td 26: recurrence remains the explicit unresolved extra principle ('..count()..')')
