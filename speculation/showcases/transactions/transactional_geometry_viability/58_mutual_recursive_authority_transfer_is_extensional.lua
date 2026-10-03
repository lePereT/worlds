local H=require('speculation.showcases.transactions.transactional_geometry_viability.common')
 local ok,eq,count=H.counter()
local p=H.rec_package({
  {identity='a',alternatives={H.unary_context({definition='b'}),H.authority_identity_context()}},
  {identity='b',alternatives={H.unary_context({definition='a'},{suffix=true}),H.authority_identity_context()}},
})
local ar,br=p:root('a'),p:root('b')
 local a=H.Analysis.compute(p)
ok(#H.Analysis.list(a.behaviour[ar])>=1 and #H.Analysis.list(a.behaviour[br])>=1,'mutual authority SCC produced no finite viability')
-- Deep finite transfer through a->b->a must collapse to the same causal boundary
-- case once a causal step has occurred; root identity must not accumulate history.
local af=H.Search.family(p,ar,7)
 local keys={}
for _,row in ipairs(af.items) do keys[H.Case.key(row.value)]=true end
local n=0
 for _ in pairs(keys) do n=n+1 end
eq(n,#H.Analysis.list(a.behaviour[ar]),'mutual recursive search histories did not collapse to fixed-point boundary cases')
local state,sources=H.state_one(1)
eq(#H.Analysis.list(a.behaviour[ar]),2,'mutual authority SCC should saturate to identity and causal boundary cases')
eq(H.Judgement.first_stable(p,ar,state,H.empty_knowledge(),sources,af,a),'Hit','mutual exact authority transfer did not admit a stable finite witness')
print('PASS gv 58: mutually recursive authority transfer collapses by boundary Development case ('..count()..')')
