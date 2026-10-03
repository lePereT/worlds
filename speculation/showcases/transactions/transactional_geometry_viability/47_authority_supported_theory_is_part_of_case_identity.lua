local H=require('speculation.showcases.transactions.transactional_geometry_viability.common')
 local ok,eq,count=H.counter()
 local K=H.K
local function branch(guard)
  local g={membranes={{parent=0}},points={{membrane=1}},strands={{membrane=1,points={1}}},faces={}}
  local ctx={{point=1,sort='bool',values={false,true}}}
  return assert(H.Context.plug(H.Context.closed({geometry=g,theory=K.spec(K.point_value(ctx,1,guard)),authority={inputs={1},outputs={1}},values={inputs={},outputs={}}}),{}))
end
local a,b=branch(true),branch(false)
ok(H.A.key(a)==H.A.key(b),'Theory accidentally changed authority Geometry quotient')
ok(H.Case.key(a)~=H.Case.key(b),'authority-supported occurrence knowledge missing from boundary Development case')
print('PASS gv 47: boundary case identity includes Theory on authority-support Points ('..count()..')')
