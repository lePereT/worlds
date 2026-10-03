local H=require('speculation.showcases.transactions.transactional_recurrence_calculus.common')
local ok,eq,count=H.counter()
local p=H.RP.new({definitions={
  {identity='a',alternatives={H.authority_identity_context(),H.unary_context({definition='b'})}},
  {identity='b',alternatives={H.unary_context({definition='a'},{suffix=true})}},
}})
local a,b=p:root('a'),p:root('b')
for d=1,6 do
  local fa,fb=H.Unfold.package(p,a,d),H.Unfold.package(p,b,d)
  ok(#fa:family().items>=1,'productive mutual entry lost base')
  if d==1 then eq(#fb:family().items,0,'peer acquired result before recursive depth') end
end
ok(#H.Unfold.package(p,b,4):family().items>0,'mutual recursion never reached grounded peer')
print('PASS tr 09: mutual recurrence unfolds only through grounded descendants ('..count()..')')
