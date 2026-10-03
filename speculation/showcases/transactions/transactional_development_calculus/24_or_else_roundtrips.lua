local H=require('speculation.showcases.transactions.transactional_development_calculus.common')
local ok,eq,count=H.counter()
 local C=H.C
local a,b=C.always('a'),C.always('b')
 local x=C.or_else(a,b)
 local y=C.or_else(H.roundtrip(a),H.roundtrip(b))
eq(x:root(),y:root())
 eq(x:bytes(),y:bytes())
print('PASS td 24: preference is portable semantic structure, not search state ('..count()..')')
