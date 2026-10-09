local H=require('speculation.relay.computation.concurrency_discovery.common')
local ok,eq,count=H.counter()
local C=H.C
local internal=C.together({H.Channel.send('inside',7),H.Channel.recv('inside')})
eq(#internal:family().items,1,'known internal rendezvous did not establish')
local external=H.Channel.recv('outside')
local staged=C.each({internal,external})
eq(#staged:family().items,1,'open external boundary was mistaken for semantic failure')
local a=staged:alternative(1)
ok(a.authority.open and #a.authority.open.inputs>0 and #a.authority.open.outputs>0,
  'unknown external readiness did not remain explicit open boundary')
local completed=C.together({staged,H.Channel.send('outside',9)})
eq(#completed:family().items,1,'later environment could not close retained external boundary')
local ca=completed:alternative(1)
ok(not ca.authority.open or (#(ca.authority.open.inputs or {})==0 and #(ca.authority.open.outputs or {})==0),
  'completed external interaction left spurious open readiness state')
ok(H.no_runtime_words(staged:bytes()) and H.no_runtime_words(completed:bytes()))
print('PASS cc 48: external uncertainty residualises as an open boundary, not scheduler state ('..count()..')')
