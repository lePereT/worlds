local H=require('speculation.relay.computation.recurrence_calculus.common')
local ok,eq,count=H.counter()
local p=H.RP.new({definitions={
  {identity='a',alternatives={H.unary_context({definition='b'})}},
  {identity='b',alternatives={H.unary_context({definition='a'})}},
}})
eq(p:root('a'),p:root('b'),'semantically symmetric recursive entries retained source distinction')
eq(#p:definitions(),1,'symmetric SCC entries did not hash-cons to one semantic root')
for d=0,5 do eq(#H.Unfold.package(p,p:root('a'),d):family().items,0) end
ok(true)
print('PASS tr 31: indistinguishable recursive entries share semantic identity ('..count()..')')
