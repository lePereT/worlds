local H=require('speculation.relay.computation.development_calculus.common')
local ok,eq,count=H.counter()
 local C,T,G=H.C,H.T,H.G
local left=H.identity_operation()
 local right=H.branch({{true,'yes'},{false,'no'}},{auth=true})
local p=C.bind(left,right)
 eq(#p:family().items,2)
for i=1,2 do local g=p:alternative(i).geometry
 eq(#g.faces,2)
 ok(not G.face_reaches(g,1,2))
 ok(not G.face_reaches(g,2,1)) end
print('PASS td 05: knowledge-dependent bind creates no causal edge ('..count()..')')
