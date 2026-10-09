local H=require('speculation.relay.computation.geometry_viability.common')
 local ok,eq,count=H.counter()
local p=H.rec_package({
  {identity='g',alternatives={H.authority_identity_context(2),H.authority_identity_context(1)},prefers={{1,2}}},
  {identity='f',alternatives={H.unary_context({definition='g'},{points=1,prefix=true})}},
})
local r=p:root('f')
 local state,sources=H.state_one(1)
 local fam=H.Search.family(p,r,3)
ok(#fam.items>0,'nested compatible fallback was not discovered')
local status=H.Judgement.first_stable(p,r,state,H.empty_knowledge(),sources,fam)
eq(status,'Hit','child dominator incompatible with its parent hole blocked globally')
print('PASS gv 08: nested recursive blockers are tested in the whole exact enclosing context ('..count()..')')
