local H=require('speculation.relay.computation.development_calculus.common')
local ok,eq,count=H.counter()
 local C=H.C
local p1,p2,c=C.operation(1,1),C.operation(1,1),C.operation(1,1)
local p=C.together({p1,p2,c},{sources={{part=1,port=1},{part=2,port=1}},targets={{part=3,port=1}}})
eq(#p:family().items,2)
 eq(#p:family().edges,0)
for i=1,2 do local a=p:alternative(i)
 eq(#a.geometry.faces,3)
 eq(#a.authority.inputs,2)
 eq(#a.authority.outputs,2) end
print('PASS td 11: whole-sibling Close ambiguity remains semantic alternatives ('..count()..')')
