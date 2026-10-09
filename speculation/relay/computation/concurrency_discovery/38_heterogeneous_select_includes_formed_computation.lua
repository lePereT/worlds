local H=require('speculation.relay.computation.concurrency_discovery.common')
local ok,eq,count=H.counter()
local C=H.C
local formed=H.SelectableForm.event(33,'select.ready')
local select=C.choice(H.Channel.recv('wire'),C.choice(H.MVar.take('box'),formed))
eq(#select:family().items,3,'heterogeneous choice did not retain all three event kinds')
local seen_form=false
for i=1,#select:family().items do if H.value(select,i,1)==33 then seen_form=true end end
ok(seen_form,'form/perform event is not an ordinary choice alternative')
local by_channel=C.together({select,H.Channel.send('wire',11)})
eq(#by_channel:family().items,1,'channel environment did not select exactly one descendant')
eq(H.value(by_channel,1,1),11,'channel-selected descendant returned wrong value')
local owner=H.MVar.ground(H.MVar.full('box',22))
local by_mvar=C.together({select,owner})
eq(#by_mvar:family().items,1,'MVar environment did not select exactly one descendant')
eq(H.value(by_mvar,1,1),22,'MVar-selected descendant returned wrong value')
ok(H.no_runtime_words(select:bytes()))
print('PASS cc 38: rendezvous, grounded state and performed Form share one ordinary choice family ('..count()..')')
