local H=require('speculation.relay.computation.concurrency_discovery.common')
local ok,eq,count=H.counter()
local T,G,C=H.T,H.G,H.C
local function reader()
  local g,p=G.operation(0,1)
  return C.atom({geometry=g,
    theory={variables={'x','y'},equalities={T.eq(T.var('x'),T.var('y'))}},
    authority={inputs=p.inputs,outputs=p.outputs},values={inputs={'x'},outputs={'y'}}})
end
local readers=C.each({reader(),reader()})
local p=C.and_then(H.Cell.full('stable',7),readers,{value_pairs={{from=1,to=1},{from=1,to=2}}})
eq(#p:family().items,1)
eq(H.value(p,1,1),7)
eq(H.value(p,1,2),7)
local a=p:alternative(1)
eq(#a.geometry.faces,3,'stable observation changed action count')
ok(not H.G.face_reaches(a.geometry,1,2) and not H.G.face_reaches(a.geometry,1,3),
  'positive value knowledge manufactured causal edges to observers')
eq(#a.authority.outputs,3,'stable cell authority was consumed by knowledge-only observers')
print('PASS cc 28: stable cell knowledge fans out without serialising its exact state authority ('..count()..')')
