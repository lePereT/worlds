local H=require('speculation.relay.computation.recurrence_calculus.common')
local ok,eq,count=H.counter()
local p=H.rec_package('diverge',{H.unary_context({definition='diverge'})})
local root=p:root('diverge')
ok(#p:bytes()>0,'nonproductive cyclic meaning vanished from Package')
for d=0,10 do eq(#H.Unfold.package(p,root,d):family().items,0,'unguarded cycle gained finite witness') end
print('PASS tr 07: pure cyclic self-reference has empty least finite meaning ('..count()..')')
