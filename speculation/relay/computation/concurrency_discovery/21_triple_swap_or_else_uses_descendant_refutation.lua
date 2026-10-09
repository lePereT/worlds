local H=require('speculation.relay.computation.concurrency_discovery.common')
local Triple=require('speculation.relay.computation.concurrency_discovery.triple_swap')
local ok,eq,count=H.counter()
local first=H.C.or_else(
  Triple.swap('preferred','p1',1),
  Triple.swap('fallback','f1',1))
local p=H.C.together({first,Triple.swap('fallback','f2',2),Triple.swap('fallback','f3',3)})
eq(#p:family().items,6,'refuted preferred triple swap prevented lawful fallback')
eq(#p:family().edges,0,'dead triple-swap preference survived descendant refutation')
ok(not p:bytes():find('preferred',1,true),'refuted preferred protocol leaked into result')
print('PASS cc 21: or_else remains stable around a composable three-party rendezvous ('..count()..')')
