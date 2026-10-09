local H=require('speculation.relay.computation.concurrency_discovery.common')
local ok,eq,count=H.counter()
local send=H.C.choice(H.Channel.send('numbers',41),H.Channel.send('numbers',99))
local p=H.C.together({send,H.Channel.recv('numbers')})
eq(#p:family().items,2,'choice was scheduled instead of preserved')
eq(#p:family().edges,0,'unordered choice acquired dominance')
local seen={}
for i=1,2 do seen[H.value(p,i,1)]=true end
ok(seen[41] and seen[99],'rendezvous lost a possible payload outcome')
print('PASS cc 06: choice remains semantic alternatives through concurrent rendezvous ('..count()..')')
