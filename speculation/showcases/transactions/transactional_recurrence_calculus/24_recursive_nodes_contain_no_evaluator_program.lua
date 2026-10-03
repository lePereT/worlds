local H=require('speculation.showcases.transactions.transactional_recurrence_calculus.common')
local ok,eq,count=H.counter()
local p=H.rec_package('loop',{H.authority_identity_context(),H.unary_context({definition='loop'},{suffix=true})})
local d=p:definition(p:root('loop'))
for _,a in ipairs(d.family.items) do
  ok(a.template and a.template.geometry and a.template.theory,'recurrence alternative is not Development context')
  ok(a.op==nil and a.instruction==nil and a.callback==nil and a.continuation==nil,'evaluator node leaked into recurrence Package')
end
ok(not p:bytes():find('continuation',1,true))
 ok(not p:bytes():find('instruction',1,true))
print('PASS tr 24: cyclic Package contains no evaluator/call instruction layer ('..count()..')')
