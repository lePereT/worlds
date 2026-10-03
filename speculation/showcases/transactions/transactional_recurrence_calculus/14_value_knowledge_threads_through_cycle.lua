local H=require('speculation.showcases.transactions.transactional_recurrence_calculus.common')
local ok,eq,count=H.counter()
local p=H.rec_package('value',{H.authority_value_identity_context(),
  H.unary_context({definition='value'},{values=true})})
local f=H.Unfold.package(p,p:root('value'),5)
local s=H.C.specialize(f,{[1]='hello'})
eq(#s:family().items,5)
for _,a in ipairs(s:family().items) do
  eq(H.T.value(a.theory,a.values.outputs[1]),'hello','recursive value relation lost positive knowledge')
end
ok(true)
print('PASS tr 14: recurrence threads Theory knowledge without a recursive evaluator ('..count()..')')
