local H=require('speculation.relay.computation.concurrency_discovery.common')
local ok,eq,count=H.counter()
local p=H.C.together({H.Channel.send_authority('cap'),H.Channel.recv_authority('cap')})
eq(#p:family().items,1)
local a=p:alternative(1)
eq(#a.authority.inputs,1,'scarce payload did not remain external sender ingress')
eq(#a.authority.outputs,3,'authority rendezvous public outputs changed')
eq(#a.geometry.faces,1,'authority rendezvous was not one joint action')
local exact=p:instantiate(1)
local incoming=exact.authority.inputs[1]
local outgoing=exact.authority.outputs[3]
eq(#H.W.points(incoming),1)
eq(#H.W.points(outgoing),1)
ok(H.W.points(incoming)[1]==H.W.points(outgoing)[1],
  'scarce authority payload lost exact Point identity across the rendezvous')
print('PASS cc 04: the same rendezvous transports exact scarce authority ('..count()..')')
