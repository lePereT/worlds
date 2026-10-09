local H=require('speculation.relay.computation.concurrency_discovery.common')
local ok,eq,count=H.counter()
-- This is a deliberate falsifier, not the desired Cell law. With no initial cell-state provider,
-- the direct transition encoding can let put/take mutually support one another as a joint SCC.
-- Worlds is correct to admit that geometry; the lesson is that shared persistent state needs a
-- stronger library representation of grounding than a bare rendezvous-like state seam.
local p=H.C.together({H.Cell.put('box',1),H.Cell.take('box')})
eq(#p:family().items,1,'expected direct-state falsifier stopped exposing its grounding ambiguity')
local a=p:alternative(1)
eq(#a.geometry.faces,1,'mutual state cycle did not SCC-normalise to the expected joint Face')
eq(#a.authority.inputs,0,'falsifier unexpectedly acquired an external state ground')
eq(H.value(p,1,1),1,'falsifier lost the cyclically proffered payload')
ok(H.no_runtime_words(p:bytes()))
print('PASS cc 33: direct cell seams expose the persistent-state grounding question ('..count()..')')
