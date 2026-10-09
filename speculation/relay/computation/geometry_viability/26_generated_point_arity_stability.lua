local H=require('speculation.relay.computation.geometry_viability.common')
 local ok,eq,count=H.counter()
for state_n=1,3 do for preferred_n=1,3 do
  local preferred=H.authority_step_context(preferred_n)
 local fallback=H.authority_identity_context(state_n)
  local p=H.one_root('f',{preferred,fallback},{{1,2}})
 local r=p:root('f')
 local state,sources=H.state_one(state_n)
 local fam=H.Search.family(p,r,1)
  local fallback_row=nil
 for _,row in ipairs(fam.items) do if #row.value.geometry.faces==0 then fallback_row=row end end
  ok(fallback_row,'generated fallback discovery missing')
  if preferred_n==state_n then eq(H.Judgement.check(p,r,state,H.empty_knowledge(),sources,fallback_row),'Blocked','compatible dominator missed')
  else eq(H.Judgement.check(p,r,state,H.empty_knowledge(),sources,fallback_row),'Hit','incompatible point arity blocked fallback') end
end end
print('PASS gv 26: generated authority arity matrix agrees with exact Worlds closure ('..count()..')')
