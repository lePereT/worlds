local H=require('speculation.relay.computation.concurrency_discovery.common')
local ok,eq,count=H.counter()
local P,W=H.ParameterEndpoint,H.W
local a=P.mint('endpoint')
local b=P.mint('endpoint')
local sa,ra=P.send(a),P.recv(a)
ok(not sa.geometry:owns_point(a) and not ra.geometry:owns_point(a),
  'instantiated endpoint parameter became owned action Geometry')
eq(W.points(sa.offer)[1],a,'send seam did not import supplied exact Point')
eq(W.points(ra.offer)[1],a,'receive seam did not import supplied exact Point')
eq(P.close(sa,ra),1,'same imported endpoint parameter did not rendezvous')
eq(P.close(P.send(a),P.recv(b)),0,'distinct imported endpoint parameters were incorrectly quotiented')
ok(a~=b,'fresh endpoint mint reused exact identity')
print('PASS cc 41: portable Point parameter instantiates directly to rigid exact endpoint identity ('..count()..')')
