local H=require('speculation.showcases.transactions.transactional_recursive_judgement.common')
 local ok,eq,count=H.counter()
local p=H.rec_package('f',{H.unary_bool_context({definition='f'}),H.base_bool_context(nil)},{{1,2}})
 local r=p:root('f')
 local a=H.Analysis.compute(p)
for depth=1,3 do
  local f=H.Search.family(p,r,depth)
 ok(#f.items>0,'search found no finite descendants')
  for _,row in ipairs(f.items) do local s=H.Judgement.check(p,r,H.state_bool(false),row,a)
 eq(s,'Blocked','temporary finite frontier became commit eligible') end
  local s=H.Judgement.first_stable(p,r,H.state_bool(false),f,a)
 eq(s,'Deferred','moving recursive preference should remain semantically unsettled')
end
print('PASS rj 11: recursively preferred moving frontier never becomes stable commit eligibility ('..count()..')')
