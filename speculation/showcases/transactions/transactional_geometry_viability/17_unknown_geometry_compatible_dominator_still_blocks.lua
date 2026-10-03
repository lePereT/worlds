local H=require('speculation.showcases.transactions.transactional_geometry_viability.common')
 local ok,eq,count=H.counter()
local preferred=H.bool_authority_context(1,true)
 local fallback=H.bool_authority_context(1,nil)
local p=H.one_root('f',{preferred,fallback},{{1,2}})
 local r=p:root('f')
 local state,sources=H.state_one(1)
local fam=H.Search.family(p,r,1)
 local fallback_row=nil
for _,row in ipairs(fam.items) do if H.K.equal(H.Case.public_knowledge(row.value),H.K.top(H.Case.public_knowledge(row.value).ctx)) then fallback_row=row end end
ok(fallback_row,'unconstrained fallback missing')
eq(H.Judgement.check(p,r,state,H.state_bool(nil),sources,fallback_row),'Blocked','Theory-Unknown preferred branch ceased to be viable despite exact Geometry')
eq(H.Judgement.check(p,r,state,H.state_bool(false),sources,fallback_row),'Hit','positively refuted preferred branch did not release fallback')
print('PASS gv 17: Unknown knowledge blocks only when paired exact authority case remains viable ('..count()..')')
