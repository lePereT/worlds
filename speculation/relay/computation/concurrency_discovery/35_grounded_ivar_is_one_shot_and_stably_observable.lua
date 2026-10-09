local H=require('speculation.relay.computation.concurrency_discovery.common')
local ok,eq,count=H.counter()
local empty=H.IVar.empty('promise')
eq(#H.IVar.step(empty,H.IVar.await('promise')):family().items,0,
  'empty IVar unexpectedly satisfied await')
local full=H.IVar.step(empty,H.IVar.put('promise',42))
eq(#full:family().items,1,'IVar put did not ground Empty -> Full')
eq(H.value(full,1,1),'full')
eq(H.value(full,1,2),42)
eq(#H.IVar.step(full,H.IVar.put('promise',43)):family().items,0,
  'one-shot IVar accepted a second put')
local awaited=H.IVar.step(full,H.IVar.await('promise'))
eq(H.value(awaited,1,3),42,'await did not receive fulfilled value')
local views=H.IVar.observe_many(full,3)
eq(H.value(views,1,1),42)
eq(H.value(views,1,2),42)
eq(H.value(views,1,3),42)
eq(#views:alternative(1).authority.outputs,#full:alternative(1).authority.outputs,
  'stable IVar observations duplicated or consumed state authority')
eq(#views:alternative(1).geometry.faces,#full:alternative(1).geometry.faces,
  'stable IVar observation manufactured causal work')
ok(H.no_runtime_words(full:bytes()))
print('PASS cc 35: grounded IVar is one-shot state plus fan-out positive observation ('..count()..')')
