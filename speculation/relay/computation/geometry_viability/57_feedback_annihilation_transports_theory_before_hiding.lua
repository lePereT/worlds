local H=require('speculation.relay.computation.geometry_viability.common')
 local ok,eq,count=H.counter()
 local K=H.K

-- Wrapper leaves one public identity authority, while a second one-hole authority
-- channel is fed back through a Face.  Plugging a causal child closes that channel
-- into a causal SCC.  The child's output fact must cross the exact cut before the
-- internal occurrence is existentially hidden from the public boundary case.
local function wrapper()
  local g={membranes={{parent=0}},points={{membrane=1},{membrane=1},{membrane=1}},strands={},faces={}}
  g.strands[1]={membrane=1,points={1}} -- public identity
  g.strands[2]={membrane=1,points={2}} -- hole input (wrapper output)
  g.strands[3]={membrane=1,points={3}} -- hole output (wrapper input)
  g.faces[1]={membrane=1,inputs={3},outputs={2}} -- feedback half
  local ctx={{point=1,sort='bool',values={false,true}},{point=3,sort='bool',values={false,true}}}
  local theory=K.points_equal(ctx,1,3)
  return H.Context.normal({
    template={geometry=g,theory=K.spec(theory),authority={inputs={1,3},outputs={1,2}},values={inputs={},outputs={}}},
    outer={authority={inputs={1},outputs={1}},values={inputs={},outputs={}}},
    holes={{target={definition='x'},authority={to_target={2},from_target={2}},values={to_target={},from_target={}}}}
  })
end
local function child()
  local g={membranes={{parent=0}},points={{membrane=1},{membrane=1}},strands={{membrane=1,points={1}},{membrane=1,points={2}}},faces={{membrane=1,inputs={1},outputs={2}}}}
  local ctx={{point=2,sort='bool',values={false,true}}}
  return assert(H.Context.plug(H.Context.closed({geometry=g,theory=K.spec(K.point_value(ctx,2,true)),authority={inputs={1},outputs={2}},values={inputs={},outputs={}}}),{}))
end
local out,why=H.Context.plug(wrapper(),{child()})
 assert(out,why)
ok(H.A.complete(out),'feedback annihilation leaked open authority')
local bk=H.Case.knowledge(out)
 local status,value=K.observe(bk,'a1')
eq(status,'Hit','hidden feedback witness did not leave a certified public consequence')
eq(value,true,'wrong public fact survived feedback annihilation')
print('PASS gv 57: Construction feedback transports Theory before internal authority is hidden ('..count()..')')
