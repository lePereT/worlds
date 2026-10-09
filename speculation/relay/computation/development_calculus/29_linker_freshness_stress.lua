local H=require('speculation.relay.computation.development_calculus.common')
local ok,eq,count=H.counter()
 local C=H.C
local left=H.identity_operation()
 local right=H.branch({{true,'yes'},{false,'no'}},{auth=true})
local root=nil
for i=1,100 do
  local p=C.bind(H.roundtrip(left),H.roundtrip(right),{captures={{from=1,to=1}}})
  root=root or p:root()
 eq(p:root(),root,'fresh exact normalisation leaked into Package root')
end
local a,b,c=C.operation(1,1),C.operation(1,1),C.operation(1,1)
local spec={sources={{part=1,port=1},{part=2,port=1}},targets={{part=3,port=1}}}
local tr=nil
for i=1,25 do local p=C.together({H.roundtrip(a),H.roundtrip(b),H.roundtrip(c)},spec)
  tr=tr or p:root()
 eq(p:root(),tr,'Close normalisation leaked exact identity') end
print('PASS td 29: fresh linker normalisation is semantically deterministic ('..count()..')')
