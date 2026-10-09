local H=require('speculation.relay.computation.geometry_viability.common')
 local ok,eq,count=H.counter()
local preferred=H.authority_identity_context(1)
 local fallback=H.authority_step_context(1)
local p=H.one_root('f',{preferred,fallback},{{1,2}})
 local r=p:root('f')
 local state,sources=H.state_one(1)
local fam=H.Search.family(p,r,1)
 local fallback_row=nil
for _,row in ipairs(fam.items) do if #row.value.geometry.faces==1 then fallback_row=row end end
ok(fallback_row,'fallback discovery missing')
eq(H.Judgement.check(p,r,state,H.empty_knowledge(),sources,fallback_row),'Blocked','viable authority dominator did not block')
print('PASS gv 06: exact compatible authority dominator blocks a discovered fallback ('..count()..')')
