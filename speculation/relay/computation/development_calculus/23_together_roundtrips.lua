local H=require('speculation.relay.computation.development_calculus.common')
local ok,eq,count=H.counter()
 local C=H.C
local a,b,c=C.operation(1,1),C.operation(1,1),C.operation(1,1)
local spec={sources={{part=1,port=1},{part=2,port=1}},targets={{part=3,port=1}}}
local x=C.together({a,b,c},spec)
 local y=C.together({H.roundtrip(a),H.roundtrip(b),H.roundtrip(c)},spec)
eq(x:root(),y:root())
 eq(x:bytes(),y:bytes())
print('PASS td 23: together remains canonical across separate compilation ('..count()..')')
