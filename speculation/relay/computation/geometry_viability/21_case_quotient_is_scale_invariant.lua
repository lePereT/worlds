local H=require('speculation.relay.computation.geometry_viability.common')
 local ok,eq,count=H.counter()
local t=assert(H.Context.plug(H.authority_step_context(),{}))
 local key=H.Case.key(t)
for depth=2,12 do t=assert(H.Context.plug(H.unary_context({definition='x'}),{t}))
 eq(H.Case.key(t),key,'causal-chain boundary case changed at scale '..depth) end
print('PASS gv 21: authority boundary Development cases are invariant across compilation scale ('..count()..')')
