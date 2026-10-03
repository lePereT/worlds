local H=require('speculation.showcases.transactions.transactional_geometry_viability.common')
 local eq,count=select(2,H.counter())
 local K=H.K
local function branch(v)
  local g={membranes={{parent=0}},points={{membrane=1},{membrane=1},{membrane=1}},strands={{membrane=1,points={1}},{membrane=1,points={2}}},faces={{membrane=1,inputs={1},outputs={2}}}}
  local ctx={{point=3,sort='bool',values={false,true}}}
  return assert(H.Context.plug(H.Context.closed({geometry=g,theory=K.spec(K.point_value(ctx,3,v)),authority={inputs={1},outputs={2}},values={inputs={},outputs={}}}),{}))
end
eq(H.Case.key(branch(true)),H.Case.key(branch(false)),'knowledge on a closed internal Point should disappear from boundary viability')
print('PASS gv 51: internal occurrence facts are existentially hidden from boundary cases ('..count()..')')
