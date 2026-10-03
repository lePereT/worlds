local H=require('speculation.showcases.transactions.transactional_geometry_viability.common')
 local ok,eq,count=H.counter()
local rec=H.unary_context({definition='f'})
 local base=H.authority_identity_context()
local p=H.one_root('f',{rec,base},{{1,2}})
 local r=p:root('f')
 local state,sources=H.state_one(1)
for depth=1,5 do
  local fam=H.Search.family(p,r,depth)
 local status=H.Judgement.first_stable(p,r,state,H.empty_knowledge(),sources,fam)
  eq(status,'Deferred','moving recursive authority frontier became falsely stable at depth '..depth)
end
print('PASS gv 04: preferred recursive authority chain blocks every finite frontier without becoming a runtime loop ('..count()..')')
