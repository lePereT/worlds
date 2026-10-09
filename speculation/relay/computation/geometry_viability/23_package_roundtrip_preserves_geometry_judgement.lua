local H=require('speculation.relay.computation.geometry_viability.common')
 local ok,eq,count=H.counter()
local p=H.one_root('f',{H.unary_context({definition='f'}),H.authority_identity_context()},{{1,2}})
 local q=H.RP.decode(p:bytes())
local r=p:root('f')
 local qr=q:definitions()[1].root
 local state,sources=H.state_one(1)
for depth=1,4 do
  local a=H.Judgement.first_stable(p,r,state,H.empty_knowledge(),sources,H.Search.family(p,r,depth))
  local b=H.Judgement.first_stable(q,qr,state,H.empty_knowledge(),sources,H.Search.family(q,qr,depth))
  eq(a,b,'Package roundtrip changed authority-recursive stability at depth '..depth)
end
print('PASS gv 23: stable authority Judgement is canonical Package meaning ('..count()..')')
