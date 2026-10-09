local H=require('speculation.relay.computation.concurrency_discovery.common')
local Triple=require('speculation.relay.computation.concurrency_discovery.triple_swap')
local ok,eq,count=H.counter()
local first=H.C.choice(
  Triple.swap('red','r1',1),
  Triple.swap('blue','b1',1))
local p=H.C.together({first,Triple.swap('red','r2',2),Triple.swap('red','r3',3)})
eq(#p:family().items,6,'ordinary choice did not compose around a three-party rendezvous')
for i=1,#p:family().items do
  local a=p:alternative(i)
  eq(#a.geometry.faces,1,'chosen triple swap did not remain one joint Face')
end
ok(not p:bytes():find('blue',1,true),'refuted outer choice leaked into established swap meaning')
ok(H.no_runtime_words(p:bytes()))
print('PASS cc 20: triple swap is an ordinary event-valued Package usable inside choice ('..count()..')')
