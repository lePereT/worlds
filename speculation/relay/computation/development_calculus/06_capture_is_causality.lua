local H=require('speculation.relay.computation.development_calculus.common')
local ok,eq,count=H.counter()
 local C,G=H.C,H.G
local left=H.identity_operation()
 local right=H.branch({{true,'yes'}},{auth=true})
local p=C.bind(left,right,{captures={{from=1,to=1}}})
local g=p:alternative(1).geometry
 eq(#g.faces,2)
 ok(G.face_reaches(g,1,2))
 eq(#p:alternative(1).authority.inputs,1)
 eq(#p:alternative(1).authority.outputs,1)
print('PASS td 06: explicit authority capture alone creates causality ('..count()..')')
