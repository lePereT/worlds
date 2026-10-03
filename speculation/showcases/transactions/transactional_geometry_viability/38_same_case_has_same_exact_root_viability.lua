local H=require('speculation.showcases.transactions.transactional_geometry_viability.common')
 local ok,eq,count=H.counter()
local reps={H.authority_step_context(),H.diamond_context()}
 local chain=assert(H.Context.plug(H.authority_step_context(),{}))
for i=1,3 do chain=assert(H.Context.plug(H.unary_context({definition='x'}),{chain}))
 reps[#reps+1]=H.Context.closed(chain) end
local first_key=H.Case.key(assert(H.Context.plug(reps[1],{})))
 for _,c in ipairs(reps) do eq(H.Case.key(assert(H.Context.plug(c,{}))),first_key,'precondition: representatives do not share one case') end
for source_points=1,2 do local state,sources=H.state_one(source_points)
 local expected
  for i,c in ipairs(reps) do local p=H.one_root('f',{c})
 local r=p:root('f')
 local status=H.Judgement.first_stable(p,r,state,H.empty_knowledge(),sources,H.Search.family(p,r,1))
 if expected then eq(status,expected,'equal boundary cases disagreed on exact root viability') else expected=status end end
end
print('PASS gv 38: equal boundary cases are indistinguishable by exact live-root closure ('..count()..')')
