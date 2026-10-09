local H=require('speculation.relay.computation.development_calculus.common')
local ok,eq,count=H.counter()
 local C=H.C
local a=C.operation(1,1)
 local inert=C.always('x')
local p=C.together({a,inert},{sources={{part=1,port=1}},targets={{part=1,port=1}}})
eq(#p:family().items,0)
print('PASS td 12: together cannot self-close one part ('..count()..')')
