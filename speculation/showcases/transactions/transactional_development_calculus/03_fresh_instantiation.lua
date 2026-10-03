local H=require('speculation.showcases.transactions.transactional_development_calculus.common')
local ok,eq,count=H.counter()
 local C=H.C
local p=C.operation(1,1)
 local a,b=p:instantiate(1),p:instantiate(1)
ok(a.authority.inputs[1]~=b.authority.inputs[1])
 ok(a.authority.outputs[1]~=b.authority.outputs[1])
eq(#a.geometry:faces(),#b.geometry:faces())
print('PASS td 03: Package instantiation mints fresh exact occurrences ('..count()..')')
