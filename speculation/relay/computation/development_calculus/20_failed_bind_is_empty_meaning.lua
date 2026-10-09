local H=require('speculation.relay.computation.development_calculus.common')
local ok,eq,count=H.counter()
 local C=H.C
local p=C.bind(C.always(true),H.branch({{false,'never'}}))
eq(#p:family().items,0)
 eq(#p:family().edges,0)
print('PASS td 20: failed continuation means no composite witness, not rollback ('..count()..')')
