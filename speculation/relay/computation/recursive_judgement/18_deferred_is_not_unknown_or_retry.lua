local H=require('speculation.relay.computation.recursive_judgement.common')
 local ok,eq,count=H.counter()
local p=H.rec_package('f',{H.base_bool_context(true)},{})
 local r=p:root('f')
 local a=H.Analysis.compute(p)
local empty=H.Search.family(p,r,0)
-- The state true has a semantic witness, but depth-zero discovery has not found it.
eq(H.Judgement.first_stable(p,r,H.state_bool(true),empty,a),'Deferred','solver exhaustion became semantic failure')
-- State false is genuinely incompatible with every finite descendant.
eq(H.Judgement.first_stable(p,r,H.state_bool(false),empty,a),'Retry','semantic impossibility was not distinguished from Deferred')
print('PASS rj 18: computational Deferred is distinct from semantic Unknown and Retry ('..count()..')')
