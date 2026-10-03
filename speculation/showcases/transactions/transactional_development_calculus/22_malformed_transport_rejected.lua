local H=require('speculation.showcases.transactions.transactional_development_calculus.common')
local ok,eq,count=H.counter()
 local C,P=H.C,H.P
local p=C.always(1)
 ok(not pcall(function() P.decode(p:bytes()..'x') end))
print('PASS td 22: malformed/noncanonical Package transport is rejected ('..count()..')')
