local H=require('speculation.relay.computation.development_calculus.common')
local ok,eq,count=H.counter()
 local C=H.C
local a=C.always(true)
 local id=C.identity_value()
 local b=C.bind(a,id)
eq(b:root(),a:root())
 eq(H.out_value(b,1),true)
print('PASS td 04: pure bind collapses to relational Development composition ('..count()..')')
