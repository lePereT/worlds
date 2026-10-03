local H=require('speculation.showcases.transactions.transactional_geometry_viability.common')
 local eq,count=select(2,H.counter())
 local K=H.K
local function branch(via_hidden)
  local g={membranes={{parent=0}},points={{membrane=1},{membrane=1},{membrane=1}},strands={{membrane=1,points={1}},{membrane=1,points={2}}},faces={{membrane=1,inputs={1},outputs={2}}}}
  local ctx={{point=1,sort='bool',values={false,true}},{point=3,sort='bool',values={false,true}}}
 local k
  if via_hidden then k=K.meet(K.points_equal(ctx,1,3),K.point_value(ctx,3,true)) else k=K.point_value(ctx,1,true) end
  return assert(H.Context.plug(H.Context.closed({geometry=g,theory=K.spec(k),authority={inputs={1},outputs={2}},values={inputs={},outputs={}}}),{}))
end
eq(H.Case.key(branch(true)),H.Case.key(branch(false)),'existential hiding lost a boundary consequence mediated by an internal Point')
print('PASS gv 52: hidden Theory witnesses preserve their positive boundary consequence ('..count()..')')
