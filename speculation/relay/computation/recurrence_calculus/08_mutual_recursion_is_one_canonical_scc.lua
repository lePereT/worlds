local H=require('speculation.relay.computation.recurrence_calculus.common')
local ok,eq,count=H.counter()
local p=H.RP.new({definitions={
  {identity='a',alternatives={H.authority_identity_context(),H.unary_context({definition='b'})}},
  {identity='b',alternatives={H.unary_context({definition='a'},{suffix=true})}},
}})
local q=H.RP.new({definitions={
  {identity='y',alternatives={H.unary_context({definition='x'},{suffix=true})}},
  {identity='x',alternatives={H.unary_context({definition='y'}),H.authority_identity_context()}},
}})
ok(p:root('a')~=p:root('b'),'structurally distinct SCC entries collapsed')
eq(p:root('a'),q:root('x'),'mutual SCC entry root changed under alpha-renaming')
eq(p:root('b'),q:root('y'),'mutual SCC peer root changed under alpha-renaming')
eq(p:bytes(),q:bytes(),'mutual SCC bytes changed under definition ordering')
print('PASS tr 08: mutually recursive roots derive from anonymous SCC meaning ('..count()..')')
