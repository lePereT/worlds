local H=require('speculation.relay.computation.concurrency_discovery.common')
local ok,eq,count=H.counter()
local E,W=H.ExactEndpoint,H.W
local a=E.mint('endpoint')
local b=E.mint('endpoint')
ok(a~=b,'dynamic endpoint minting reused exact Point identity')
eq(W.kind(a),'point')
local send=E.send(a)
local recv=E.recv(a)
ok(not send.geometry:owns_point(a) and not recv.geometry:owns_point(a),
  'endpoint identity became owned protocol Geometry instead of an imported exact Point')
local same=E.close(send,recv)
eq(#same,1,'same exact endpoint did not have one complete rendezvous')
eq(#same[1].geometry:faces(),1,'exact rendezvous did not SCC-normalise to one joint Face')
eq(#E.close(E.send(a),E.recv(b)),0,
  'different freshly minted endpoint Points were incorrectly unifiable')
ok(not same[1].geometry:owns_point(a),'closed rendezvous retained dynamic endpoint identity as internal Geometry')
print('PASS cc 39: dynamic channel identity is a fresh rigid imported Point, not a string name ('..count()..')')
