local H=require('speculation.relay.computation.concurrency_discovery.common')
local ok,eq,count=H.counter()
local T,G,C=H.T,H.G,H.C
local function signal(name)
  local g,p=G.operation(0,2)
  return C.atom({geometry=g,
    theory={variables={'name'},equalities={T.eq(T.var('name'),name)}},
    support={strands={[p.outputs[1]]={protocol='arena.signal',name=T.var('name')}}},
    authority={inputs=p.inputs,outputs=p.outputs,open={outputs={1}}},values={inputs={},outputs={}}})
end
local function wait(name)
  local g,p=G.operation(1,1)
  return C.atom({geometry=g,
    theory={variables={'name'},equalities={T.eq(T.var('name'),name)}},
    support={strands={[p.inputs[1]]={protocol='arena.signal',name=T.var('name')}}},
    authority={inputs=p.inputs,outputs=p.outputs,open={inputs={1}}},values={inputs={},outputs={}}})
end
local hit=C.together({signal('go'),wait('go')})
local miss=C.together({signal('go'),wait('stop')})
eq(#hit:family().items,1,'generic signal/wait seam did not close')
eq(#miss:family().items,0,'Strand-supported positive meaning ignored contradiction')
eq(#hit:alternative(1).authority.inputs,0)
eq(#hit:alternative(1).authority.outputs,2)
ok(true)
print('PASS cc 14: together discovers non-channel protocols through the same Strand-supported opening ('..count()..')')
