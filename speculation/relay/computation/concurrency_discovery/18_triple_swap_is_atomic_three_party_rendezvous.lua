local H=require('speculation.relay.computation.concurrency_discovery.common')
local Triple=require('speculation.relay.computation.concurrency_discovery.triple_swap')
local ok,eq,count=H.counter()
local p=H.C.together({
  Triple.swap('swap','alice',1),
  Triple.swap('swap','bob',2),
  Triple.swap('swap','carol',3)})
eq(#p:family().items,6,'triple swap did not preserve its six lawful role/order outcomes')
eq(#p:family().edges,0,'triple swap acquired an arbitrary preference')
local function pair(a,b) if a>b then a,b=b,a end return tostring(a)..':'..tostring(b) end
for i=1,#p:family().items do
  local a=p:alternative(i)
  eq(#a.authority.inputs,0,'triple swap left protocol ingress open')
  eq(#a.authority.outputs,0,'triple swap left protocol egress open')
  eq(#a.geometry.faces,1,'three-party rendezvous did not SCC-normalise to one joint Face')
  eq(pair(H.value(p,i,1),H.value(p,i,2)),'2:3','participant 1 did not receive participants 2 and 3')
  eq(pair(H.value(p,i,3),H.value(p,i,4)),'1:3','participant 2 did not receive participants 1 and 3')
  eq(pair(H.value(p,i,5),H.value(p,i,6)),'1:2','participant 3 did not receive participants 1 and 2')
end
ok(H.no_runtime_words(p:bytes()))
ok(not p:bytes():find('relay.triple.',1,true),'closed swap retained protocol matcher residue')
ok(not p:bytes():find('alice',1,true) and not p:bytes():find('bob',1,true) and not p:bytes():find('carol',1,true),
  'private group tickets escaped closed swap meaning')
print('PASS cc 18: triple swap is one atomic three-party rendezvous of ordinary pairwise cuts ('..count()..')')
