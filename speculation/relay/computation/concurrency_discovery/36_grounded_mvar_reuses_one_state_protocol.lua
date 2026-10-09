local H=require('speculation.relay.computation.concurrency_discovery.common')
local ok,eq,count=H.counter()
local C=H.C
eq(#C.together({H.MVar.put('box',1),H.MVar.take('box')}):family().items,0,
  'MVar requests self-grounded without persistent state authority')
local state=H.MVar.empty('box')
state=H.MVar.step(state,H.MVar.put('box',7))
eq(H.value(state,1,1),'full')
eq(H.value(state,1,2),7)
local taken=H.MVar.step(state,H.MVar.take('box'))
eq(H.value(taken,1,1),'empty')
eq(H.value(taken,1,3),7,'take lost MVar payload')
local again=H.MVar.step(taken,H.MVar.put('box',8))
eq(H.value(again,1,1),'full')
eq(H.value(again,1,2),8)
ok(#again:alternative(1).geometry.faces>#state:alternative(1).geometry.faces,
  'reused MVar protocol did not preserve causal state recurrence')
ok(H.no_runtime_words(again:bytes()))
print('PASS cc 36: MVar reuses one grounded Empty/Full protocol without self-support ('..count()..')')
