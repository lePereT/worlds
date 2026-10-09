local H=require('speculation.relay.computation.concurrency_discovery.common')
local ok,eq,count=H.counter()
local function source()
  local g,p=H.G.operation(0,1)
  return H.C.atom({geometry=g,theory={variables={},equalities={}},
    support={strands={[p.outputs[1]]={protocol='arena.seam'}}},
    authority={inputs={},outputs=p.outputs,open={outputs={1}}},values={inputs={},outputs={}}})
end
local function target(open)
  local g,p=H.G.operation(1,1)
  return H.C.atom({geometry=g,theory={variables={},equalities={}},
    support={strands={[p.inputs[1]]={protocol='arena.seam'}}},
    authority={inputs=p.inputs,outputs=p.outputs,open=open and {inputs={1}} or nil},
    values={inputs={},outputs={}}})
end
local closed=H.C.together({source(),target(true)})
local framed=H.C.together({source(),target(false)})
eq(#closed:family().items,1,'declared seam did not compose')
eq(#closed:alternative(1).geometry.faces,2,'one-way seam unexpectedly formed a causal SCC')
eq(#framed:family().items,1,'non-open supported target should remain an ordinary positive sibling')
eq(#framed:alternative(1).authority.inputs,1,'positive knowledge alone authorised a cut')
eq(#framed:alternative(1).authority.outputs,2,'framed target/source boundary was not preserved')
ok(not H.G.face_reaches(framed:alternative(1).geometry,1,2) and
  not H.G.face_reaches(framed:alternative(1).geometry,2,1),
  'mere supported knowledge introduced causality')
print('PASS cc 34: positive occurrence knowledge is not permission to close ('..count()..')')
