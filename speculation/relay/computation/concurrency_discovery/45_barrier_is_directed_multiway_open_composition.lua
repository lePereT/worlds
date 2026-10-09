local H=require('speculation.relay.computation.concurrency_discovery.common')
local ok,eq,count=H.counter()
local C,B,G=H.C,H.Barrier,H.G
local two=C.together({B.coordinator('phase',3),B.participant('phase',1),B.participant('phase',2)})
eq(#two:family().items,0,'three-way barrier completed with only two participants')
local all=C.together({B.coordinator('phase',3),B.participant('phase',1),B.participant('phase',2),B.participant('phase',3)})
ok(#all:family().items>=1,'three-way barrier did not close')
local a=all:alternative(1)
eq(#a.authority.inputs,0,'closed barrier retained release inputs')
eq(#a.authority.outputs,3,'barrier did not expose one continuation per participant')
-- Arrival faces precede the coordinator, which precedes release/continuation faces: synchronisation
-- need not collapse into one SCC as triple swap does.
local faces=#a.geometry.faces
ok(faces>=7,'barrier geometry unexpectedly collapsed directed phase structure')
local wrong=C.together({B.coordinator('phase',2),B.participant('phase',1),B.participant('other',2)})
eq(#wrong:family().items,0,'barrier admitted participant from different barrier identity')
ok(H.no_runtime_words(all:bytes()))
print('PASS cc 45: barrier is directed multiway open composition, distinct from rendezvous SCC atomicity ('..count()..')')
