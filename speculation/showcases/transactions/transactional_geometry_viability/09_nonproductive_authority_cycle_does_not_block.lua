local H=require('speculation.showcases.transactions.transactional_geometry_viability.common')
 local ok,eq,count=H.counter()
local p=H.rec_package({
  {identity='g',alternatives={H.unary_context({definition='g'})}},
  {identity='f',alternatives={H.unary_context({definition='g'}),H.authority_identity_context()},prefers={{1,2}}},
})
local r=p:root('f')
 local a=H.Analysis.compute(p)
 local gr=p:root('g')
eq(next(a.behaviour[gr]),nil,'pure authority cycle acquired a finite boundary case')
local state,sources=H.state_one(1)
 local fam=H.Search.family(p,r,3)
eq(H.Judgement.first_stable(p,r,state,H.empty_knowledge(),sources,fam),'Hit','nonproductive authority dominator blocked grounded fallback')
print('PASS gv 09: a pure authority cycle has empty least finite viability and cannot block ('..count()..')')
