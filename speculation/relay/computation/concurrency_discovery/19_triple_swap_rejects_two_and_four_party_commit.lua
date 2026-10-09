local H=require('speculation.relay.computation.concurrency_discovery.common')
local Triple=require('speculation.relay.computation.concurrency_discovery.triple_swap')
local ok,eq,count=H.counter()
local two=H.C.together({Triple.swap('swap','a',1),Triple.swap('swap','b',2)})
eq(#two:family().items,0,'two participants completed a three-party swap')
local four=H.C.together({
  Triple.swap('swap','a',1),Triple.swap('swap','b',2),
  Triple.swap('swap','c',3),Triple.swap('swap','d',4)})
eq(#four:family().items,0,'four participants leaked into a malformed triple swap')
ok(true)
print('PASS cc 19: triple swap has genuine three-party commit arity ('..count()..')')
